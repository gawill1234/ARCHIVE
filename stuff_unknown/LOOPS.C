#include "test.h"
#include "test_macros.h"
#include "inet.h"
#include "test_clnt_srv.h"

extern int timing, Gquit;

void server_loop(fd)
int fd;
{
char *buffer, *rcv_data();
int i;
extern int verbose;

#ifdef DEBUG
   printf("SERVER:  started\n");
   fflush(stdout);
#endif

   Gquit = i = 0;

   for (;;) {
/*
      if (i >= 25) {
         i = 0;
         if (!(verbose))
            fprintf(stderr, "\n");
      }
      if (!(verbose))
         fprintf(stderr, "%d", i);
*/
      buffer = rcv_data(fd);
      if (buffer != NULL)
         free(buffer);
/*
      if (!(verbose))
         fprintf(stderr, "/");
      i++;
*/
      if (Gquit != 0)
         break;
   }
   return;
}

int doit(tfd, datatype, dataflow, one_big_bunch)
int tfd, one_big_bunch;
word datatype, dataflow;
{
int bytestosend, flags, pid, datareturn;
char *sendline, *create_chr_data();
int maxbytes = MAX_SEND_BYTES;
int i = 0;
extern int Gsend_bytes;

   Gquit = 0;

   if (one_big_bunch != 0) {
      return(doit2(tfd, datatype, dataflow));
   }

   if (dataflow == DUPLEX)
      datareturn = DG_PACK_ECHO;
   else
      datareturn = DG_NO_ECHO;

/*
#ifdef __alpha
   maxbytes = (DEF_MAX_SIZE < MAX_SEND_BYTES) ? DEF_MAX_SIZE : MAX_SEND_BYTES;
#endif
*/

#ifdef DEBUG
   maxbytes = 4096;
#ifdef __alpha
   maxbytes = (DEF_MAX_SIZE < 4096) ? DEF_MAX_SIZE : 4096;
#endif
#endif

   pid = getpid();
   while (1) {
      if (timing) {
         if (i >= 25) {
            i = 0;
            t_sync_time(tfd);
         }
      }
      bytestosend = getsize(maxbytes);
      if (Gsend_bytes > 0) {
         if (bytestosend > Gsend_bytes)
            bytestosend = Gsend_bytes;
         Gsend_bytes = Gsend_bytes - bytestosend;
         if (Gsend_bytes == 0)
            Gquit = 1;
      }
      sendline = (char *)gen_data(datatype, &bytestosend);
#ifdef DEBUG
      fprintf(stderr, "doit:  %d\n", bytestosend);
      if (datatype != DG_DATA_UNK)
         fprintf(stderr, "%s\n", sendline);
      else
         fprintf(stderr, "UNKNOWN DATA\n", sendline);
#endif
      send_data(tfd, sendline, bytestosend, DATA_GRP | datatype | datareturn);
      clear_data_amt();
      free(sendline);
      i++;
      if (Gquit != 0) {
         server_exit(tfd);
         break;
      }
   }
   return(0);
}

int doit2(tfd, datatype, dataflow)
int tfd;
word datatype, dataflow;
{
int bytestosend, flags, pid, datareturn;
char *sendline, *create_chr_data();
int maxbytes;
int i = 0;
extern int Gsend_bytes, Gdata_size, Gmax_size;

   Gquit = 0;

   if (dataflow == DUPLEX)
      datareturn = DG_PACK_ECHO;
   else
      datareturn = DG_NO_ECHO;

   if (Gsend_bytes <= 0) {
      server_exit(tfd);
      return(0);
   }

   bytestosend = Gsend_bytes;
   maxbytes = Gmax_size - 28;
   sendline = (char *)gen_data(datatype, &maxbytes);
   send_data(tfd, sendline, bytestosend, DATA_GRP | datatype | datareturn | DG_SAME_CHK);
   free(sendline);
   server_exit(tfd);
   return(Gsend_bytes);
}
