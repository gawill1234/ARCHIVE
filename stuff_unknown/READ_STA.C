#include <stdio.h>
#include <errno.h>
#include <signal.h>
#include <time.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <sys/socket.h>
#if defined(AIX) || defined(__alpha)
#include <sys/ioctl.h>
#else
#include <sys/filio.h>
#endif

#if defined(__SPANS)
#include <fore/types.h>
#include <fore_atm/fore_atm_user.h>
#include <fore_atm/fore_msg.h>
#endif

#include "inet.h"
#include "test.h"

extern int cLiEnT, sErVeR;
extern struct sockaddr_in g_serv_addr;
struct sockaddr_in cli_addr;
int cli_length;

extern int errno;


/****************************************************/
/*  WAIT_FOR_DATA
    Use this to wait for a certain number of bytes to be
    available for reading in a file, socket, or pipe.

    PARAMETERS:

       fd:               file descriptor of file, socket or pipe
       num_to_wait_for:  the number of bytes to look for to
                         become available.

    RETURNS:

       Returns the number of bytes actually available in the
       file, socket or pipe.  Times out after TIMEOUT seconds and
       returns the amount it did find.

*/
int wait_for_data(fd, num_to_wait_for)
int fd, num_to_wait_for;
{
int avail_bytes, avail_bytes2;
long timeinsec, starttime;

   avail_bytes2 = avail_bytes = 0;

   starttime = time((long *)0);
   do {
      ioctl(fd, FIONREAD, &avail_bytes);
      if (avail_bytes > 0) {
         if (avail_bytes != avail_bytes2)
            avail_bytes2 = avail_bytes;
         else
            break;
      }
      if (avail_bytes < num_to_wait_for) {
         timeinsec = time((long *)0);
         if ((timeinsec - starttime) > IO_TIMEOUT)
            break;
      }
   } while (avail_bytes < num_to_wait_for);

   return(avail_bytes);
}

/*****************************************************/
/*   READ2

   This routine accepts the same paramters as the read()
   system call and has the same return values as the read()
   system call.  This routine is required for network reads
   and possibly to read large blocks of data that can not be
   written all at once.  The routine is required because
   networks may not deliver data as fast as it is written.
   The wait_for_data() routine is called to try and make
   each individual read() as large as possible.
   
   PARAMETERS:
      fd:       file descriptor of file/socket to be read
      buffer:   pointer to storage for read data
      n:        number of bytes to be read

   RETURN:
      Returns the number of bytes actually place in buffer, or
      a -1 if there is a problem.
*/

int rd_read2(fd, buffer, n)
int fd;
register char *buffer;
unsigned n;
{
register unsigned count = 0;
register int nread;
int waiting_data;

#ifdef DEBUG
   fprintf(stderr, "RDREAD %d ... ", n);
#endif

   do {
      waiting_data = wait_for_data(fd, (n - count));
      if ((nread = read(fd, buffer, (n - count))) > 0) {
         count += (unsigned)nread;
         buffer += nread;
      }
      else if (nread == 0) {
         break;
      }
      else {
         perror("read2");
         return(-1);
      }
   } while (count < n);

#ifdef DEBUG
   fprintf(stderr, "%d DONE\n", count);
#endif

   return((int)count);
}

#if defined(__SPANS)
int atm_read(fd, buffer, n)
int fd;
register char *buffer;
unsigned n;
{
int nread = 0;
extern Vpvc Grvpvc;

#ifdef DEBUG
   fprintf(stderr, "ATM_READ %d ... ", n);
#endif

   /**************************************************************/
   /*  Since the I/O that goes on here is normal, blocking type
       stuff, I needed a method of skipping reads if no data was
       available.  wait_for_data() is up above.  It will eventually
       time out if no data becomes available.
   */
   if (wait_for_data(fd, n) != 0) {
      nread = atm_recvfrom(fd,  buffer, n, &Grvpvc);
      if (nread < 0)
         atm_error("atm_read():  atm_recvfrom()");
   }
#ifdef DEBUG
   fprintf(stderr, "%d DONE\n", nread);
#endif

   return(nread);
}

int atm_read2(fd, buffer, n)
int fd;
register char *buffer;
unsigned n;
{
int nread = 0;

#ifdef DEBUG
   fprintf(stderr, "ATM_READ2 %d ... ", n);
#endif

   /**************************************************************/
   /*  Since the I/O that goes on here is normal, blocking type
       stuff, I needed a method of skipping reads if no data was
       available.  wait_for_data() is up above.  It will eventually
       time out if no data becomes available.
   */
   if (wait_for_data(fd, n) != 0) {
      nread = atm_recv(fd, buffer, n);
      if (nread < 0)
         atm_error("atm_read2():  atm_recv()");
   }
#ifdef DEBUG
   fprintf(stderr, "%d DONE\n", nread);
#endif

   return(nread);
}
#else
void atm_read()
{
   return;
}

void atm_read2()
{
   return;
}
#endif

int read2(fd, buffer, n)
int fd;
register char *buffer;
unsigned n;
{
int nread = 0;

#ifdef DEBUG
   fprintf(stderr, "READ2 %d ... ", n);
#endif

   cli_length = sizeof(cli_addr);

   /**************************************************************/
   /*  Since the I/O that goes on here is normal, blocking type
       stuff, I needed a method of skipping reads if no data was
       available.  wait_for_data() is up above.  It will eventually
       time out if no data becomes available.
   */
   if (wait_for_data(fd, n) != 0) {

      if (cLiEnT)
         nread = recvfrom(fd,  buffer, n, 0, (struct sockaddr *)0, (int *)0);
      else
         nread = recvfrom(fd,  buffer, n, 0, (struct sockaddr *)&cli_addr, &cli_length);

   }
#ifdef DEBUG
   fprintf(stderr, "%d DONE\n", nread);
#endif

   return(nread);
}

int read3(fd, buffer, n)
int fd;
register char *buffer;
unsigned n;
{
int nread = 0;
struct iovec riovec;
struct msghdr message;

   message.msg_name = (caddr_t) 0;
   message.msg_namelen = (u_int) 0;
   message.msg_iov = NULL;
   message.msg_iovlen = (u_int) 0;
#if defined(_SOCKADDR_LEN) || defined(_KERNEL)
   message.msg_control = (caddr_t) 0;
   message.msg_controlllen = (u_int) 0;
   message.msg_flags = (int) 0;
#else
   message.msg_accrights = (caddr_t) 0;
   message.msg_accrightslen = (u_int) 0;
#endif

#ifdef DEBUG
   fprintf(stderr, "READ3 %d ... ", n);
#endif

   /**************************************************************/
   /*  Since the I/O that goes on here is normal, blocking type
       stuff, I needed a method of skipping reads if no data was
       available.
   */
   if (wait_for_data(fd, n) != 0) {

      riovec.iov_base = buffer;
      riovec.iov_len = n;

      message.msg_iov = &riovec;
      message.msg_iovlen = 1;
      if (cLiEnT) {
         message.msg_name = NULL;
         message.msg_namelen = 0;
      }
      else {
         message.msg_name = (caddr_t)&cli_addr;
         message.msg_namelen = (u_int)sizeof(cli_addr);
      }

      nread = recvmsg(fd, &message, 0);

   }

#ifdef DEBUG
   fprintf(stderr, "%d DONE\n", nread);
#endif

   return(nread);
}
int write2(fd, buffer, amount)
int fd, amount;
char *buffer;
{
int nsent;

   do {
      if (cLiEnT)
         nsent = sendto(fd, buffer, amount, 0, 
                        (struct sockaddr *)&g_serv_addr, sizeof(g_serv_addr));
      else
         nsent = sendto(fd, buffer, amount, 0,
                        (struct sockaddr *)&cli_addr, cli_length);
      if ((nsent < 0) && (errno == ENOBUFS))
         sleep(1);
   } while ((nsent < 0) && (errno == ENOBUFS));

   return(nsent);
}

#if defined(__SPANS)
int atm_write(fd, buffer, amount)
int fd, amount;
char *buffer;
{
int nsent;
extern Vpvc Grvpvc;

   do {
      nsent = atm_sendto(fd, buffer, amount, Grvpvc);
      if (nsent < 0)
         atm_error("atm_write():  atm_sendto()");
   } while (nsent < 0);

   return(nsent);
}

int atm_write2(fd, buffer, amount)
int fd, amount;
char *buffer;
{
int nsent;

   do {
      nsent = atm_send(fd, buffer, amount);
      if (nsent < 0)
         atm_error("atm_write2():  atm_send()");
   } while (nsent < 0);

   return(nsent);
}
#else
void atm_write()
{
   return;
}
void atm_write2()
{
   return;
}
#endif

int write3(fd, buffer, amount)
int fd, amount;
char *buffer;
{
struct iovec siovec;
struct msghdr message;
int nsent;

   message.msg_name = (caddr_t) 0;
   message.msg_namelen = (u_int) 0;
   message.msg_iov = NULL;
   message.msg_iovlen = (u_int) 0;
#if defined(_SOCKADDR_LEN) || defined(_KERNEL)
   message.msg_control = (caddr_t) 0;
   message.msg_controlllen = (u_int) 0;
   message.msg_flags = (int) 0;
#else
   message.msg_accrights = (caddr_t) 0;
   message.msg_accrightslen = (u_int) 0;
#endif

   siovec.iov_base = buffer;
   siovec.iov_len = amount;

   message.msg_iov = &siovec;
   message.msg_iovlen = 1;
   if (cLiEnT) {
      message.msg_name = (caddr_t)&g_serv_addr;
      message.msg_namelen = (u_int)sizeof(g_serv_addr);
   }
   else {
      message.msg_name = (caddr_t)&cli_addr;
      message.msg_namelen = (u_int)sizeof(cli_addr);
   }

   do {
      nsent = sendmsg(fd, &message, 0);
      if ((nsent < 0) && (errno == ENOBUFS))
         sleep(1);
   } while ((nsent < 0) && (errno == ENOBUFS));

   return(nsent);
}
