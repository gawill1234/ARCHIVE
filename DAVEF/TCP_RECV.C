/*
 *              Cray Research, Inc., Unpublished Proprietary
 *              Information - All Rights Reserved.
 *
 *                      RESTRICTED RIGHTS LEGEND
 *
 *              Use, duplication, or disclosure by the
 *              Government is subject to the restrictions
 *              as set forth in the subparagraph [(c)(1)(ii)] of
 *              the Rights in Technical Data and Computer
 *              Software clause at 52.227-7013. (May 1987)
 *
 *************************************************************************
 *
 *  TCP/IP Testing       Cray Research, Inc.   Eagan, Minnesota
 *
 *  TEST IDENTIFIER      : $Source:$
 *
 *  TEST TITLE           : Socket system calls regression -- TCP recvmsg()
 *
 *  PARENT DOCUMENT      : Socket System Calls Regression Test Plan
 *
 *  AUTHOR               : Bill Schoofs
 *
 *  CO-PILOT             : Mike Habeck
 *
 *  INITIAL RELEASE      : Unicos 8.0
 *
 *  TEST CASES           : All test cases are blocking with no flags specified
 *			   unless specifically noted otherwise.  Test cases 
 *			   one through six are independent of the protocol and
 *                         are arbitrarily executed only in the TCP test.
 *
 *			   1) descriptor = -1				negative
 *			   2) descriptor = OPEN_MAX			negative
 *			   3) valid descriptor for an open file that
 *			      is NOT a socket				negative
 *			   4) bad ptr to msghdr struct 			negative
 *			   5) bad msg_iov address 			negative
 *			   6) msg_iovlen = MSG_MAXIOVLEN		negative
 *			   7) socket not connected 			negative
 *			   8) msg_iovlen = 0				positive
 *			   9) bad iov_base address 			negative
 *			   10)MSG_OOB specified & no OOB data available	negative
 *                         11)receive operation is interrupted by
 *                            delivery of a signal before any data is
 *                            available for the receive                 negative
 *			   12)nonblocking with no messages available	negative
 *			   13)nonblocking with messages available and
 *			      msg_iovlen = 1				positive
 *			   14)MSG_OOB specified & OOB data is available	positive
 *			   15)msg_iovlen = MSG_MAXIOVLEN-1		positive
 *			   16)MSG_PEEK flag				positive
 *			   17)MSG_WAITALL flag				positive
 *			   18)msg_name specified			positive
 *			   19)blocking with no messages available	positive
 *
 *  CPU TYPES            : CRAY-XMP, CRAY-YMP, CRAY-2, CRAY-C90, CRAY-EL
 *
 *  INPUT SPECIFICATION  : Usage: tcp_recvmsg [-P port]
 *                         port is the port number that the program will
 *			   bind to.  The default port number is 31699.
 *
 *  OUTPUT SPECIFICATION : Standard output provided by the cuts library.
 *
 *  SPECIAL REQUIREMENTS : none
 *
 *  IMPLEMENTATION NOTES : The flexibility of changing the port number is
 *                         provided to allow multiple copies of the test to run
 *                         without contention.  The default port number is the
 *                         default port number used in the corresponding TCP/IP
 *                         multithreading test minus one.
 *
 *  DETAILED DESCRIPTION : For the negative test cases, check that the return
 *			   value = -1 and that the errno is correct.  For
 *			   nonblocking positive test cases ensure that the data
 *			   received is the same as the data sent and ensure
 *                         the proper flags are received.
 *
 *			   Test case 11) A child process is forked to send a
 *			     signal before any data is received.
 *
 *			   Test case 16) The data should be able to be received
 *			     again when the MSG_PEEK flag is specified.
 *
 *			   Test case 19) Should block until the alarm goes off.
 *
 *  KNOWN BUGS           : Code to handle partial reads is deferred until a
 *			   later version of this test.
 */

/*
 * Revision control information. 
 */
 static char Revision[] = "$Header:$";

#include <errno.h>
#include <fcntl.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <signal.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/uio.h>
#include "test.h"
#include <unistd.h>

#define BUFSIZE 80		/* Size of each individual buffer */
#define FALSE 0
#define TESTDATA "test.data.test.data.test.data.test.data.test.data.test.data.test.data.test.data"
#define TRUE 1
#define TRY_MAX 60              /* Maximum number of bind retries */

extern int Tst_nobuf;		/* Output buffering flag */
char *TCID = "tcp_recvmsg";	/* Test case identifier */
int TST_TOTAL = 19;		/* Total number of test cases */

char *file = "";		/* Socket name for UNIX protocols only */
int should_block = FALSE;	/* indicator of whether blocking is expected */
const int wait_time = 60;	/* number of seconds for alarm */

main(int argc, char *argv[])
{
  char buf[MSG_MAXIOVLEN-1][BUFSIZ];
  int c, i;
  int fd_null, a_sd, c_sd, s_sd;	/* socket descriptors */
  struct iovec riovec[MSG_MAXIOVLEN-1];	/* recvmsg gather/scatter array */
  int port = 29999;			/* the default port number */
  struct msghdr rmsg = { (caddr_t) 0, 	/* msghdr for recvmsg */
			 (u_int) 0,
			 (struct iovec *) 0,
			 (u_int) 0,
			 (caddr_t) 0,
			 (u_int) 0,
			 (int) 0 };
  const int off = 0;			/* For ioctl arg */
  const int on = 1;			/* For ioctl arg */
  pid_t	ppid;
  int rflags = 0;			/* flags parameter for recvmsg */
  struct sockaddr_in cli, svr;
  int socklen = sizeof(svr);

  extern int optind;
  extern char *optarg;

  void alarm_handler(), check_negative(), check_positive(), close_sock();
  void do_connect(), init_iovec(), l_exit(), logtime(), sigusr1();
  Tst_nobuf = 1;	/* Disable output buffering */

  while ((c = getopt(argc, argv, "P:")) != EOF) {

    switch(c) {

    case 'P':
      port = atoi(optarg);
      if (port < IPPORT_RESERVED || port > 65535) {
        tst_resm(TBROK, "[-P port] -- illegal port number");
        tst_exit();
      }
      break;

    case '?':
      tst_resm(TBROK, "Usage: %s [-P port]\n",argv[0]);
      tst_exit();
    default:
      ;
    }
  }

  if (optind < argc) {
    tst_resm(TBROK, "Usage: %s [-P port]\n",argv[0]);
    tst_exit();
  }

  logtime();
  tst_resm(TINFO, "will bind to port %d", port);

  rmsg.msg_iov = riovec;
  bzero((void *) &svr, sizeof(svr));
  svr.sin_family = AF_INET;
  svr.sin_port = port;
  svr.sin_addr.s_addr = inet_addr("127.0.0.1");

  /* Set a wait_time second alarm in case a test case blocks unexpectedly */

  signal(SIGALRM, alarm_handler);
  alarm(wait_time);

  /****	Test case 1 ****/

  check_negative(-1, &rmsg, rflags, EBADF);

  /**** Test case 2 ****/

  check_negative((int) sysconf(_SC_OPEN_MAX), &rmsg, rflags, EBADF);

  /****	Test case 3 ****/

  if ((fd_null = open("/dev/null", O_RDONLY)) < 0) {
    tst_resm(TBROK, "open(): %s (errno %d)", sys_errlist[errno], errno);
  }
  else {
    check_negative(fd_null, &rmsg, rflags, ENOTSOCK);
    if (close(fd_null) < 0) {
      tst_resm(TWARN, "close(): %s (errno %d)", sys_errlist[errno], errno);
    }
  }

  /****	Test case 4 ****/

  check_negative(s_sd, (struct msghdr *) -1, rflags, EFAULT);

  /**** Test case 5 ****/

  rmsg.msg_iov = (struct iovec *) -1;
  check_negative(s_sd, &rmsg, rflags, EFAULT);

  /**** Test case 6 ****/

  rmsg.msg_iov = (struct iovec *) 0;
  rmsg.msg_iovlen = MSG_MAXIOVLEN;
  check_negative(s_sd, &rmsg, rflags, EMSGSIZE);

  /**** Test case 7 ****/

  rmsg.msg_iovlen = (u_int) 0;
  rmsg.msg_iov = riovec;
  if ((s_sd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    tst_resm(TBROK, "socket(): %s (errno %d)", sys_errlist[errno], errno);
    l_exit();
  }
  check_negative(s_sd, &rmsg, rflags, ENOTCONN);
  if (close(s_sd) < 0) {
    tst_resm(TWARN, "close(s_sd): %s (errno %d)", sys_errlist[errno], errno);
  }

  /**** Test case 8 ****/

  do_connect(&cli, &svr, socklen, port, &s_sd, &c_sd, &a_sd);
  check_positive(a_sd, c_sd, &rmsg, rflags);

  /**** Test case 9 ****/

  rmsg.msg_iovlen = 1;
  riovec[0].iov_len = 1;
  riovec[0].iov_base = (caddr_t) -1;
  check_negative(a_sd, &rmsg, rflags, EFAULT);
  riovec[0].iov_base = (caddr_t) 0;

  /**** Test case 10 ****/

  rflags = MSG_OOB;
  check_negative(a_sd, &rmsg, rflags, EINVAL);
  rflags = 0;

  /**** Test case 11 ****/

  ppid = getpid();
  signal(SIGUSR1, sigusr1);
  switch (fork()) {
  case -1:
    tst_resm(TBROK,"fork(): %s (errno %d)", sys_errlist[errno], errno);
    break;

  case 0:	/* child process */
    sleep(2);	/* give time for the parent to do a blocking recvmsg() */
    kill(ppid, SIGUSR1);
    exit(0);

  default:	/* parent process */
    check_negative(a_sd, &rmsg, rflags, EINTR);
  }
               
  /**** Test case 12 ****/

    /*    Mark the socket nonblocking     */

  if (ioctl(a_sd, FIONBIO, (char *)&on) < 0) {
    tst_resm(TBROK, "ioctl(): %s (errno %d)", sys_errlist[errno], errno);
  }
  else {
    check_negative(a_sd, &rmsg, rflags, EWOULDBLOCK);
  }

  /**** Test case 13 ****/

  init_iovec(riovec, buf[0], BUFSIZE);
  check_positive(a_sd, c_sd, &rmsg, rflags);

  /**** Test case 14 ****/

  /* Change back to blocking */

  if (ioctl(a_sd, FIONBIO, (char *)&off) < 0) {
    tst_resm(TBROK, "ioctl(): %s (errno %d)", sys_errlist[errno], errno);
    close_sock(a_sd, c_sd, s_sd);
    l_exit();
  }

  rflags = MSG_OOB;
  riovec[0].iov_len = 1;		/* One byte of OOB data */
  bzero(buf[0], BUFSIZE);
  check_positive(a_sd, c_sd, &rmsg, rflags);
  riovec[0].iov_len = BUFSIZE;
  rflags = 0;

  /**** Test case 15 ****/

  /* Initialize the gather/scatter array and buffers */
  for (i = 0; i < MSG_MAXIOVLEN-1; i++) {
    init_iovec(&riovec[i], buf[i], BUFSIZE);
  }
  
  rmsg.msg_iovlen = MSG_MAXIOVLEN-1;
  check_positive(a_sd, c_sd, &rmsg, rflags);
  rmsg.msg_iovlen = 1;

  /**** Test case 16 ****/

  init_iovec(riovec, buf[0], BUFSIZE);
  rflags = MSG_PEEK;
  check_positive(a_sd, c_sd, &rmsg, rflags);

  /**** Test case 17 ****/

  init_iovec(riovec, buf[0], BUFSIZE);
  rflags = MSG_WAITALL;
  check_positive(a_sd, c_sd, &rmsg, rflags);

  /**** Test case 18 ****/

  init_iovec(riovec, buf[0], BUFSIZE);
  rflags = 0;
  rmsg.msg_name = (caddr_t) &cli;
  rmsg.msg_namelen = socklen;
  check_positive(a_sd, c_sd, &rmsg, rflags);

  /**** Test case 19 ****/

  /*
   * The blocking test case should be last because the alarm handler function
   * will exit.  Execution should not return here after check_positive.
   */

}

/*
 *	Establish a connection
 */

static void
do_connect(cliptr, svrptr, socklen, port, sd_s, sd_c, sd_a)
struct sockaddr_in *cliptr, *svrptr;
int socklen, port;
int  *sd_s, *sd_c, *sd_a;

/*
 * Parameters to do_connect are:
 *
 *   cliptr		- pointer to client sockaddr_in structure
 *   svrptr		- pointer to server sockaddr_in structure
 *   socklen		- length of sockaddr_in structure
 *   port		- port number for bind and connect
 *   sd_s, sd_c, sd_a	- pointers to socket descriptors returned to caller
 */

{
  int i;

  if ((*sd_s = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    tst_resm(TBROK, "socket(): %s (errno %d)", sys_errlist[errno], errno);
    l_exit();
  }

  for(i = 0 ;
      (bind(*sd_s, (struct sockaddr *) svrptr, socklen) < 0) && (i < TRY_MAX);
      i++) {
    tst_resm(TINFO, "bind(): %s (errno %d)", sys_errlist[errno], errno);
    sleep(1);
  }
  if (i == TRY_MAX) {
    tst_resm(TBROK, "bind(): See previous INFO messages for details of error");
    if (close(*sd_s) < 0) {
      tst_resm(TWARN, "close(*sd_s): %s (errno %d)", sys_errlist[errno], errno);
    }
    l_exit();
  }

  if (listen(*sd_s, 5) < 0) {
    tst_resm(TBROK, "listen(): %s (errno %d)", sys_errlist[errno], errno);
    if (close(*sd_s) < 0) {
      tst_resm(TWARN, "close(*sd_s): %s (errno %d)", sys_errlist[errno], errno);
    }
    l_exit();
  }

  /*	Do the client connect next, followed by the accept	*/

  cliptr->sin_family = AF_INET;
  cliptr->sin_port = port;
  cliptr->sin_addr.s_addr = inet_addr("127.0.0.1");

  if ((*sd_c = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    tst_resm(TBROK, "socket(): %s (errno %d)", sys_errlist[errno], errno);
    if (close(*sd_s) < 0) {
      tst_resm(TWARN, "close(*sd_s): %s (errno %d)", sys_errlist[errno], errno);
    }
    l_exit();
  }

  if (connect(*sd_c, (struct sockaddr *) cliptr, socklen) < 0) {
    tst_resm(TBROK, "connect(): %s (errno %d)", sys_errlist[errno], errno);
    close_sock(*sd_s, *sd_c, 0);
    l_exit();
  }

  /*
   *	Sleep for a few seconds to give the connection request time to be
   *	queued on the server socket 
   */
  sleep(3);
    
  if ((*sd_a = accept(*sd_s, (struct sockaddr *) svrptr, &socklen)) < 0) {
    tst_resm(TBROK, "accept(): %s (errno %d)", sys_errlist[errno], errno);
    close_sock(*sd_s, *sd_c, 0);
    l_exit();
  }
}

static void
check_positive(sd_r, sd_s, msg, flags)
int sd_r, sd_s;
struct msghdr *msg;
int flags;

/*
 * Parameters to check_positive are: 
 *
 *   sd_r		- socket to receive from
 *   sd_s		- socket to send with
 *   msg		- pointer to msghdr structure
 *   flags		- flags argument for recvmsg call
 */

{
  int i;
  static first_call = 1;
  int nbytes = 0;		/* number of bytes to read */
  int nleft = 0;		/* number of bytes still to be read */
  int nread = 0;		/* number of bytes read */

  static struct iovec siovec[MSG_MAXIOVLEN-1]; /* sendmsg gather/scatter array*/
  static struct msghdr smsg = { (caddr_t) 0,   /* msghdr for sendmsg */
                                (u_int) 0,
                                siovec,
                                (u_int) 0,
                                (caddr_t) 0,
                                (u_int) 0,
                                (int) 0 };

  int sflags = 0;		/* flags parameter for sendmsg */

  if (first_call) {
    /*
     * Initialize the sendmsg gather/scatter array only the first time this
     * function is called
     */
    first_call = 0;
    for (i = 0; i < MSG_MAXIOVLEN-1; i++) {
      siovec[i].iov_base = TESTDATA;
      siovec[i].iov_len = BUFSIZE;
    }
  }

  if (!msg->msg_iovlen) {
    /*
     * Special case for 0 elements in the gather/scatter array.  No sendmsg()
     * is needed
     */
    switch (nread = recvmsg(sd_r, msg, flags)) {
    case -1:
      tst_resm(TFAIL, "recvmsg(): %s (errno %d)", sys_errlist[errno], errno);
      break;

    case 0:
      tst_resm(TPASS, "msg_iovlen = 0");
      break;

    default:
      tst_resm(TFAIL, "Zero length receive returned %d", nread);
    }
    return;
  }

  if (should_block) {
    nread = recvmsg(sd_r, msg, flags);
    tst_resm(TFAIL, "msg_iovlen = %d  flags = 0x%x: did not block correctly",
             msg->msg_iovlen, flags);
    close_sock(sd_r, sd_s, 0);
    l_exit();
  }
  else {
    /* do sendmsg */
    int nsent;

    sflags = flags;
    smsg.msg_iovlen = msg->msg_iovlen;
    siovec[0].iov_len = msg->msg_iov->iov_len;
    nsent = sendmsg(sd_s, &smsg, sflags);
    if (nsent < 0) {
      tst_resm(TBROK, "sendmsg(): %s (errno %d)", sys_errlist[errno], errno);
      return;
    }
    else {
#ifdef DEBUG
      printf("nsent = %d   smsg.msg_iov->iov_len = %d\n", nsent,
             smsg.msg_iov->iov_len);
#endif
      sleep(3);			/* give time for the message to be queued */ 
    }
  }

  /*
   * Special case for MSG_PEEK because data remains in input queue after the
   * recvmsg() is done
   */
  if (flags == MSG_PEEK) {
    if ((nread = recvmsg(sd_r, msg, flags)) <= 0) {
      tst_resm(TFAIL, "msg_iovlen = %d  flags = 0x%x: %s (errno %d)",
               msg->msg_iovlen, flags, sys_errlist[errno], errno);
    }
    else {
      /*
       * Do another recvmsg() to drain the queue.  Code to handle partial reads
       * is deferred until a later version of this test.  This recvmsg() should
       * not block.
       */
      flags = 0;
      if ((nread = recvmsg(sd_r, msg, flags)) <= 0) {
        tst_resm(TFAIL, "msg_iovlen = %d  flags = 0x%x: %s (errno %d)",
                 msg->msg_iovlen, MSG_PEEK, sys_errlist[errno], errno);
      }
      else {
        tst_resm(TPASS, "msg_iovlen = %d  flags = 0x%x", msg->msg_iovlen,
                 MSG_PEEK);
      }
    }
    return;
  }

  /* loop for recvmsg */
  {
    struct iovec *iovptr;

#ifdef DEBUG
    printf("msg->msg_iovlen = %d\n", msg->msg_iovlen);
#endif

    for (i = 0, iovptr = msg->msg_iov; i < msg->msg_iovlen; i++, iovptr++)
      nleft += iovptr->iov_len;
    while (nleft > 0) {
#ifdef DEBUG
      printf("nleft = %d \n", nleft);
#endif
      nread = recvmsg(sd_r, msg, flags);
#ifdef DEBUG
      printf("nread = %d\n", nread);
#endif
      if (nread < 0) {
        tst_resm(TFAIL, "msg_iovlen = %d  flags = 0x%x: %s (errno %d)",
                 msg->msg_iovlen, flags, sys_errlist[errno], errno);
         return;
      }
      else {
        if (nread == nleft) {
          /* loop to compare data received with data sent */
          for (i=0,iovptr=msg->msg_iov; i < msg->msg_iovlen; i++,iovptr++) {
            if(bcmp(iovptr->iov_base,siovec[i].iov_base,msg->msg_iov->iov_len)){
              tst_resm(TFAIL,
                "data sent and received differ.  msg_iovlen = %d  flags = 0x%x",
                msg->msg_iovlen, flags);
              return;
            }
          }
          if ((flags == MSG_OOB) && (msg->msg_flags != MSG_OOB)) {
            tst_resm(TFAIL,"msg_flags = %d, should be set to MSG_OOB (%d)",
                     msg->msg_flags, MSG_OOB);
            }
          else {
            tst_resm(TPASS,"msg_iovlen = %d  flags = 0x%x", msg->msg_iovlen,
                     flags);
          }
          return;
        }
        else {		/* nread != nleft */
          if (nread > nleft) {
            tst_resm(TFAIL, "%d bytes returned when only %d bytes requested",
                     nread, nleft);
            return;
            }
          else {	/* nread < nleft */
          /*
           * code to modify iovec array for partial reads is deferred until a
           * later version of this test.  Possible pseudocode for implementing
           * follows:
           *
           *save original msghdr structure and iovec structure array for
           *     final comparision
           *if (partial read) {
           *  if (complete buffer[s] read) {
           *    decrement msg_iovlen
           *    increment msg_iov array pointer
           *  }
           *  if (partial buffer read) {
           *    increment current iov_base address
           *    decrement current iov_len
           *  }
           *}
           */
          tst_resm(TBROK,"fewer bytes returned than requested");
          return;
          }
        }
      }
    }
  }
}
