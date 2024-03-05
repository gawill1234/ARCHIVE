/*********************************************************************/
/*  All of the routines in this file represent functions which are
    specific to a data return server.  All of the functions are part
    of a library, so they are available for general use.

    Being part of a larger server, each of these routines were
    designed to work best with each other.  Some attempt has been
    made to generalize them.  The attempt is not perfect, but I
    did not want to make the routines so they did not work well
    anywhere.
*/
#include <stdio.h>
#include <time.h>
#include <signal.h>
#include <fcntl.h>
#include <time.h>
#include <netinet/in.h>
#include <sys/param.h>
#if defined(AIX) || defined(__alpha)
#include <sys/ioctl.h>
#include <sys/timers.h>
#else
#include <sys/filio.h>
#endif

#include "test_clnt_srv.h"
#include "test_struct.h"
#include "test.h"

struct hdr {
   char magic[4];
   uword checksum, len, seq, in_time, tot_size, len_after_this;
};

struct troz {
   struct hdr header;
   void *data;
};

#define HDR_SIZE 28

#define DEF_MAX_SIZE 8192
#define DATA_MIN_SIZE 8
#define DATA_MAX_SIZE (65535 - HDR_SIZE)

#ifndef HZ
#define HZ CLK_TCK
#endif

int Pass = 0;
int Fail = 0;
int Csum = 0;
int Sequ = 0;
int Leng = 0;

int drops = 0;
int total_drops = 0;
long drec = 0;
long dexp = 0;
long tdrec = 0;

long rcvd = 0;

extern int do_verify;
extern int protocol;

extern int Gmax_size, Gquit;
extern int Gdata_size;

int new_data_size(fd, _x)  
int fd, _x;
{

   Gmax_size = get_snd_buffer_size(fd);
   if (Gmax_size == 0) {
      new_buffer_size(fd, _x, _x);
      Gmax_size = get_snd_buffer_size(fd);
      if (Gmax_size == 0)
         Gmax_size = _x;
   }

   if (_x > Gmax_size)
      Gdata_size = Gmax_size - HDR_SIZE;
   else
      Gdata_size = _x - HDR_SIZE;
                                
   if (Gdata_size < DATA_MIN_SIZE) {
      Gdata_size = DATA_MIN_SIZE;
   }
}

int add_my_header(len, seq, buf, newbuf, buffer_size, sent)
int len, seq, buffer_size, sent;
void *buf, *newbuf;
{
struct troz *zort;
struct tms blue;
unsigned int goofy;
extern int GFsync;

   zort = (struct troz *)newbuf;

   strncpy(zort->header.magic, "HEAD", 4);

   zort->header.checksum = htonl(gen_crc32(0, buf, len));
   zort->header.len = htonl(len);
   zort->header.seq = htonl(seq);
   zort->header.tot_size = htonl(buffer_size);
   zort->header.len_after_this = htonl(sent);
   zort->data = (char *)newbuf + HDR_SIZE;
   memcpy(zort->data, (char *)buf, len);

   if (GFsync) {
      GETTIMES(goofy, blue);
      zort->header.in_time = htonl(goofy);
   }

   return(len + HDR_SIZE);
}

int unpack_hdr(header)
struct hdr *header;
{
   if (strncmp(header->magic, "HEAD", 4) != 0)
      return(-1);

   header->seq = ntohl(header->seq);
   header->len = ntohl(header->len);
   header->tot_size = ntohl(header->tot_size);
   header->len_after_this = ntohl(header->len_after_this);
   header->checksum = ntohl(header->checksum);
   return(header->len);
}

uword server_shit(header, timein, len)
struct hdr header;
unsigned timein;
int len;
{
extern int GFsync;
double transit;

   if (GFsync) {
      header.in_time = ntohl(header.in_time);
      ONE_WAY_ELAPSED(header.in_time, timein, transit);

      if (transit > (double)0.050) {
         if (transit > (double)(((double)len / 1024.0) / 4.0)) {
            fprintf(stderr, "Transfer:  Transit time exceeds .25 seconds per 1024 bytes\n");
            fprintf(stderr, "        :  Size - %d,   Time - %2.15f\n", len, transit);
         }
      }
   }
#ifdef DEBUG
   fprintf(stderr, "%u:   %u:    PACKET TRANSIT TIME:    %f  seconds\n",
           header.in_time, timein,  transit);
#endif
   return(header.in_time);
}

unsigned int my_pack_check(len, seq, buf2, timein, buffer_size, got, header)
int len, *seq, buffer_size, got;
char *buf2;
unsigned timein;
struct hdr header;
{
uword this_sum;
unsigned int ret_error = 0;

   if (iamaserver()) {
      header.in_time = server_shit(header, timein, len);
   }

   len = len - HDR_SIZE;

   if (buffer_size != header.tot_size) {
      if (protocol == TCP)
         fprintf(stderr, "Transfer:  Max data this set, expected %d, got %d\n",
                 buffer_size, header.tot_size);
      ret_error = ret_error | 020;
   }

   if (iamaserver()) {
      got = got + len;
   }
   if (got != header.len_after_this) {
      if (protocol == TCP)
         fprintf(stderr, "Transfer:  length after pdu/packet, expected %d, got %d\n",
                 header.len_after_this, got);
      ret_error = ret_error | 040;
   }

   if (len > 0) {
      this_sum = gen_crc32(0, buf2, len);

      if (*seq != (int)header.seq) {
         if (header.seq < *seq)
            drops = drops + (int)header.seq;
         else
            drops = drops + ((int)header.seq - *seq);
         ret_error = ret_error | 01;
         if (protocol == TCP)
            fprintf(stderr, "Transfer:  Out of sequence, expected %d, got %d\n",
                    (int)header.seq, *seq);
         if (iamaserver()) {
            if ((int)header.seq > *seq) {
               *seq = (int)header.seq;
            }
         }
         Sequ++;
      }

      if (len != (int)header.len) {
         ret_error = ret_error | 04;
         fprintf(stderr, "Transfer:  Incorrect data length, expected %d, got %d\n",
                 (int)header.len, len);
         Leng++;
      }
      if (this_sum != header.checksum) {
         ret_error = ret_error | 02;
         fprintf(stderr, "***********************************************\n");
         fprintf(stderr, "****     Transfer:  Checksum incorrect     ****\n");
         fprintf(stderr, "****     %5d       %5d                 ****\n",
                         this_sum, header.checksum);
         fprintf(stderr, "***********************************************\n");
         exit(0);
         Csum++;
      }
   }
   else if (len == 0) {
      if (len != (int)header.len) {
         fprintf(stderr, "Transfer:  Incorrect data length, expected %d, got %d\n",
                 (int)header.len, len);
         Leng++;
         ret_error = ret_error | 04;
      }
      return(ret_error);
   }
   else {
      fprintf(stderr, "Transfer:  Unusable data\n");
      ret_error = ret_error | 010;
   }

   return(ret_error);

}
int back_data_check(len, seq, buf, timein, buffer_size, got)
int len, *seq, buffer_size, got;
char *buf;
unsigned timein;
{
struct hdr header;
char *buf2;

   memcpy((char *)&header, (char *)buf, HDR_SIZE);
   buf2 = buf + HDR_SIZE;
   unpack_hdr(&header);

   return(my_pack_check(len, seq, buf2, timein, buffer_size, got, header));
}



/******************************************************/
/*  END_DATA

    Tell server that this data set is concluded.

    PARAMETER:
       fd:   socket descriptor to send config command on

    RETURN:
       none
*/
void end_data(fd, size, pid)
int fd;
word size, pid;
{
word outgoing[3];

#ifdef DEBUG
   fprintf(stderr, "%d    %d    %d\n", (DATA_GRP | DG_END_DATA), sizeof(word), BYTESINWORD);
   fprintf(stderr, "%d    %d    %d\n", size, sizeof(size), BYTESINWORD);
   fprintf(stderr, "%d    %d    %d\n", pid, sizeof(pid), BYTESINWORD);
#endif

   outgoing[0] = (word)(DATA_GRP | DG_END_DATA);
   outgoing[1] = size;
   outgoing[2] = pid;


   sndcmd(fd, outgoing, 3);
   sndcmd(fd, outgoing, 3);
   sndcmd(fd, outgoing, 3);
   sndcmd(fd, outgoing, 3);

}

/*
int ldo_junk(fd, payload_type, keepbuf, amount, seq, data_received,
             tot_received, buffer_size)
*/
int ldo_junk(fd, payload_type, keepbuf, seq, data_received,
             tot_received, buffer_size)
int fd, *seq, buffer_size;
word payload_type;
word *data_received, *tot_received;
char **keepbuf;
{
char *inputbuffer, *buf2;
word compit;
uword timein;
int oldseq, this_read, i, int_chk;
struct hdr header;
struct tms blue;

   oldseq = *seq;
   inputbuffer = (char *)malloc(Gmax_size);

   /******************************************************/
   /*  The only fixed size read is the header attached
       to each hunk of data.  Read that header, get the
       size of the remaining data, and read in the rest of
       the data.
   */
   do {
      if (protocol == TCP) {
         this_read = rem_read(fd, inputbuffer, HDR_SIZE);
      }
      else {
         this_read = rem_read(fd, inputbuffer, Gdata_size + HDR_SIZE);
      }
      if (this_read < 0)
         return(-1);
   } while (this_read == 0);

   /******************************************************/
   /*  get the time.  Used to calculate transit time.
   */
   GETTIMES(timein, blue);

   /******************************************************/
   /*  If what we read is a new command, it ain't data.
       I expect data here and didn't get it, so if it is
       an endofdata command, return.
   */
   if (this_read <= CMD_SIZE) {
      memcpy((char *)&compit, inputbuffer, sizeof(word));
      compit = ntohl(compit);
      if (compit & DG_END_DATA) {
#ifdef DEBUG
         fprintf(stderr, "get_data():  Breaking loop\n");
#endif
         free(inputbuffer);
         return(-1);
      }
   }

   memcpy((char *)&header, (char *)inputbuffer, HDR_SIZE);

   if (unpack_hdr(&header) != -1) {
      buf2 = inputbuffer + HDR_SIZE;
      if (protocol == TCP) {
         this_read += rem_read(fd, buf2, header.len);
      }
   }
   else {
      return(-1);
   }

   /******************************************************/
   /*  Send the data back to the client if we are supposed
       to
   */
   if (payload_type & DG_PACK_ECHO) {
      rem_write(fd, inputbuffer, this_read);
   }


   /*******************************************************/
   /*  I apparently got data.  Check the sizes and sequence
       and that kind of stuff, issue any error messages,
       and continue.
   */
   if (my_pack_check(this_read, seq, buf2, timein, buffer_size, *data_received, header) != 0) {
      Fail++;
      if (*seq < oldseq) {
         free(inputbuffer);
         return(-1);
      }
      if (!(payload_type & DG_SAME_CHK)) {
         if (*seq > oldseq) {
            int_chk = (this_read - HDR_SIZE) + *data_received;
            if (int_chk < buffer_size) {
               for (i = 0; i < ((*seq - oldseq) - 1); i++) {
                  *keepbuf = (char *)*keepbuf + BYTESINWORD;
               }
            }
         }
      }
   }

   /*******************************************************/
   /*   Update the save buffer and the total amount read
   */
   if (!(payload_type & DG_SAME_CHK))
      memcpy((char *)*keepbuf, (char *)buf2, (this_read - HDR_SIZE));

   *data_received += (this_read - HDR_SIZE);
   *tot_received += this_read;

   free(inputbuffer);
   return(this_read - HDR_SIZE);
}

/********************************************************/
/*  GET_DATA

    Read data from a connection

    PARAMETERS:

       fd:            file descriptor of file, socket, or pipe
       buffer_stuff:  a pointer to word.  Data buffer.
       payload_type:  describes data type and disposition.
       buffer_size:   amount of data to be retrieved

    RETURNS:
       Returns amount of data read.
*/
word get_data(fd, buffer, payload_type, buffer_size)
int fd;
char *buffer;
word payload_type, buffer_size;
{
word data_received, tot_received;
int i, sdif;
char *track;

   i = data_received = tot_received = 0;

   track = buffer;

   while (data_received < buffer_size) {
      sdif = ldo_junk(fd, payload_type, &track, &i,
                      &data_received, &tot_received, buffer_size);
      if (sdif < 0)
         break;
      if (payload_type & DG_SAME_CHK)
         track = buffer;
      else
         track += sdif;
      i++;
   }

   total_drops += drops;
   drec += data_received;
   dexp += buffer_size;


   return(data_received);
}

char *rcv_data(fd)
int fd;
{
word incoming[3], received;
char *buffer, *get_buffer();
int waiting_data;
void send_data();
   
   if (Gdata_size == 0)
      Gdata_size = Gmax_size - HDR_SIZE;

   drops = 0;

   do {
      getcmd(fd, incoming, 3);
   } while (incoming[0] & DG_END_DATA);


   Fail = 0;

   switch (incoming[0] & GRP_MASK) {
      case DATA_GRP:
                      if (incoming[0] & DG_SAME_CHK)
                         buffer = get_buffer(Gmax_size);
                      else
                         buffer = get_buffer(incoming[1]);
                      received = get_data(fd, buffer, incoming[0], incoming[1]);
                      rcvd = rcvd + received;
                      if ((verify_size(incoming[1], received)) || (Fail)) {
                         if (do_verify)
                            verify_data(buffer, incoming[0], incoming[1], incoming[2], received);
                      }
                      if (incoming[0] & DG_GROUP_ECHO) {
                         if (!(incoming[0] & DG_SAME_CHK))
                            send_data(fd, buffer, incoming[1], (word)(DATA_GRP | DG_NO_ECHO));
                      }
                      free(buffer);
                      if (drops > 0) {
                         fprintf(stderr, "\nDropped %d pdu/packets.  Data lost = %d bytes.\n",
                                 drops, (incoming[1] - received));
                      }
                      return(NULL);
                      break;

      case CMD_GRP:
                      process_cmds(fd, incoming[0], incoming[1], incoming[2]);
                      if (Gquit != 0) {
                         fprintf(stdout, "Received %d bytes\n", rcvd);
                         rcvd = 0;
                      }
                      return(NULL);
                      break;

      case CNF_GRP:
                      process_config(fd, incoming[0], incoming[1], incoming[2]);
                      return(NULL);
                      break;

      case MSG_GRP:
                      fprintf(stderr, "MSG_GRP:  Not impemented yet -- Skipping\n");
                      return(NULL);
                      break;

      default:
                      return(NULL);
                      break;
   }

   return(NULL);
}

void delay()
{
#if defined(Solaris) || defined(IRIX)
struct timespec rqtp, rmtp;

   rqtp.tv_sec = 0;
   rqtp.tv_nsec = 200000000;
   nanosleep(&rqtp, &rmtp);
#else
   usleep(200000);
#endif

}

int do_the_write(fd, datachunk, seq, databuffer,
                 outbuffer, buffer_size, sent, ret_buffer, payload_type)
int fd, datachunk, *seq, buffer_size, sent;
char *databuffer, *outbuffer, *ret_buffer;
word payload_type;
{
int send_amount, ret_recv;
uword timein;
struct tms blue;

   send_amount = add_my_header(datachunk, *seq, databuffer, outbuffer, buffer_size, sent);
   send_amount = rem_write(fd, outbuffer, send_amount);
   if (payload_type & DG_PACK_ECHO) {
      ret_recv = rem_read(fd, ret_buffer, send_amount);
      if (ret_recv > 0) {
         GETTIMES(timein, blue);
         back_data_check(ret_recv, seq, ret_buffer, timein, buffer_size, sent);
         drec += ret_recv - HDR_SIZE;
         tdrec += ret_recv - HDR_SIZE;
      }
      else {
         drops++;
         total_drops++;
      }
      dexp += buffer_size;
   }
}

int fixed_io(fd, buffer, buffer_size, payload_type, pid)
int fd, pid;
char *buffer;
word buffer_size, payload_type;
{
int i, j, sent;
word num_chunks, final_chunk, received;
char *track, *outbuffer, *ret_buffer;
extern int Gdata_size;

   num_chunks = buffer_size / Gdata_size;
   final_chunk = buffer_size - (num_chunks * Gdata_size);
   track = buffer;

   if (payload_type & DG_PACK_ECHO) {
      ret_buffer = (char *)malloc(Gmax_size);
   }
   outbuffer = (char *)malloc(Gmax_size);

   sent = j = 0;

   for (i = 0; i < num_chunks; i++) {
      sent += Gdata_size;
      if (protocol != TCP) {
         j = j + Gdata_size + HDR_SIZE;
         if (j > Gmax_size) {
            j = Gdata_size + HDR_SIZE;
            delay();
         }
      }
      do_the_write(fd, Gdata_size, &i, track, outbuffer,
                   buffer_size, sent, ret_buffer, payload_type);

      if (!(payload_type & DG_SAME_CHK)) {
         track = buffer + (Gdata_size * (i + 1));
      }
   }

   if (final_chunk > 0) {
      sent += final_chunk;
      do_the_write(fd, final_chunk, &i, track, outbuffer,
                   buffer_size, sent, ret_buffer, payload_type);
   }

   end_data(fd, buffer_size, pid);

   if (payload_type & DG_PACK_ECHO) {
      free(ret_buffer);
   }
   free(outbuffer);

   delay();

}

/*******************************************************************/
int random_io(fd, buffer, buffer_size, payload_type, pid)
int fd, pid;
char *buffer;
word buffer_size, payload_type;
{
int i, j, sent, left, send;
word num_chunks, final_chunk, received;
char *track, *outbuffer, *ret_buffer;
extern int Gdata_size;
double random, drand48();

   if (payload_type & DG_PACK_ECHO) {
      ret_buffer = (char *)malloc(Gmax_size);
   }
   outbuffer = (char *)malloc(Gmax_size);

   sent = i = 0;
   left = buffer_size;
   track = buffer;

   while (left > 0) {
      random = drand48();
      send = (int)(random * (double)Gdata_size);
      if (send > left) {
         send = left;
         left = 0;
      }
      else {
         left -= send;
      }
      if (protocol != TCP) {
         j = j + send + HDR_SIZE;
         if (j > Gmax_size) {
            j = send + HDR_SIZE;
            delay();
         }
      }
#ifdef DEBUG
      fprintf(stderr, "random_io:  send = %d, %d, %d\n", send, Gdata_size, Gmax_size);
#endif
      sent += send;
      do_the_write(fd, send, &i, track, outbuffer,
                   buffer_size, sent, ret_buffer, payload_type);

      if (!(payload_type & DG_SAME_CHK)) {
         track = track + send;
      }
      i++;
   }

   end_data(fd, buffer_size, pid);

   if (payload_type & DG_PACK_ECHO) {
      free(ret_buffer);
   }
   free(outbuffer);
   if (protocol != TCP)
      delay();
}

int group_ret(fd, buffer, buffer_size, payload_type, pid)
int fd, pid;
char *buffer;
word buffer_size, payload_type;
{
int received;
char *ret_buffer, *get_buffer();
word incoming[3];

   Fail = 0;
   do {
      getcmd(fd, incoming, 3);
   } while (incoming[0] & DG_END_DATA);
   ret_buffer = get_buffer(buffer_size);
   received = get_data(fd, ret_buffer, payload_type, buffer_size);
   if ((verify_size(buffer_size, received)) || (Fail)) {
      verify_data_sh(buffer, ret_buffer, buffer_size);
   }
   free(ret_buffer);
}
/*****************************************************/
/*  UDP_SEND_DATA

    Send the data through the socket descriptor.  Wait
    for data to be returned and verify the data.  This is
    basically the client function which will correctly use
    the return server.

    PARAMETERS:
       fd:            socket descriptor
       buffer:        buffer full of data to send
       buffer_size:   size of buffer full of data
       payload_type:  flag which describes the data and
                      data disposition

    RETURN:
       currently return nothing.
*/
void send_data(fd, buffer, buffer_size, payload_type)
int fd;
char *buffer;
word buffer_size, payload_type;
{
int pid;
word outgoing[3];
extern int Gsend_type;

   if (Gdata_size == 0)
      Gdata_size = Gmax_size - HDR_SIZE;

   tdrec = drops = 0;

   pid = getpid();

#ifdef DEBUG
   fprintf(stderr, "%d    %d    %d\n", payload_type, sizeof(payload_type), BYTESINWORD);
   fprintf(stderr, "%d    %d    %d\n", buffer_size, sizeof(buffer_size), BYTESINWORD);
   fprintf(stderr, "%d    %d    %d\n", pid, sizeof(pid), BYTESINWORD);
#endif

   outgoing[0] = payload_type;
   outgoing[1] = buffer_size;
   outgoing[2] = pid;
   sndcmd(fd, outgoing, 3);

   if (Gsend_type)
      fixed_io(fd, buffer, buffer_size, payload_type, pid);
   else
      random_io(fd, buffer, buffer_size, payload_type, pid);

   if (payload_type & DG_GROUP_ECHO) {
      if (!(payload_type & DG_SAME_CHK))
         group_ret(fd, buffer, buffer_size, payload_type, pid);
   }

   if (drops > 0) {
      fprintf(stderr, "\nDropped %d pdu/packets.  Data lost = %d bytes.\n",
              drops, (buffer_size - tdrec));
   }
}


