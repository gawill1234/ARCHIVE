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
 *  TEST TITLE           : Socket system calls regression-UNIX STREAM recvmsg()
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
 *			   unless specifically noted otherwise.
 *
 *			   1) socket not connected 			negative
 *			   2) msg_iovlen = 0				positive
 *			   3) bad iov_base address 			negative
 *			   4) MSG_OOB specified				negative
 *                         5) receive operation is interrupted by
 *                            delivery of a signal before any data is
 *                            available for the receive                 negative
 *			   6) nonblocking with no messages available	negative
 *			   7) nonblocking with messages available and
 *			      msg_iovlen = 1				positive
 *			   8) msg_iovlen = MSG_MAXIOVLEN-1		positive
 *			   9) MSG_PEEK flag				positive
 *			   10)MSG_EOR flag				positive
 *			   11)MSG_WAITALL flag				positive
 *			   12)msg_name specified			positive
 *			   13)pass file descriptors			positive
 *			   14)MSG_CTRUNC flag				positive
 *			   15)blocking with no messages available	positive
 *
 *  CPU TYPES            : CRAY-XMP, CRAY-YMP, CRAY-2, CRAY-C90, CRAY-EL
 *
 *  INPUT SPECIFICATION  : Usage: unix_recvmsg_s [-d data_file] [-f file] 
 *                         file is the file that the program will bind to.
 *			   The default is "unixs.msg".  data_file is the file
 *			   whose descriptor is passed from one process to
 *			   another process.  The default is "unixs.data".
 *
 *  OUTPUT SPECIFICATION : Standard output provided by the cuts library.
 *
 *  SPECIAL REQUIREMENTS : none
 *
 *  IMPLEMENTATION NOTES : The flexibility of changing the file name is
 *                         provided to allow multiple copies of the test to run
 *                         without contention.  The default file name is the
 *                         default file name used in the corresponding TCP/IP
 *                         multithreading test.
 *
 *  DETAILED DESCRIPTION : For the negative test cases, check that the return
 *			   value = -1 and that the errno is correct.  For
 *			   nonblocking positive test cases ensure that the data
 *			   received is the same as the data sent and ensure
 *			   the proper flags are received.
 *
 *			   Test case 5) A child process is forked to send a
 *			     signal before any data is received.
 *
 *			   Test case 9) The data should be able to be received
 *			     again when the MSG_PEEK flag is specified.
 *
 *			   Test case 15) Should block until the alarm goes off.
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
#include <signal.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <sys/un.h>
#include "test.h"
#include <unistd.h>

#define BUFSIZE 80		/* Size of each individual buffer */
#define FALSE 0
#define MALLOCSIZE 128		/* Size of msg_control buffer */
#define TESTDATA "test.data.test.data.test.data.test.data.test.data.test.data.test.data.test.data"
#define TRUE 1
#define TRY_MAX 60              /* Maximum number of bind retries */

extern int Tst_nobuf;		/* Output buffering flag */
char *TCID = "unix_recvmsg_s";	/* Test case identifier */
int TST_TOTAL = 15;		/* Total number of test cases */

/* the default file name for file descriptor which is passed */
static char *data_file="unixs.data";
char *file = "unixs.msg";	/* the default file name for sun_path */

static int open_max;            /* maximum number of open files */
int should_block = FALSE;	/* indicator of whether blocking is expected */
const int wait_time = 60;	/* number of seconds for alarm */

main(int argc, char *argv[])
{
  char buf[MSG_MAXIOVLEN-1][BUFSIZ];
  int c, i;
  int a_sd, c_sd, s_sd;			/* socket descriptors */
  struct iovec riovec[MSG_MAXIOVLEN-1];	/* recvmsg gather/scatter array */
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
  struct sockaddr_un cli, svr;
  int socklen;

  extern int optind;
  extern char *optarg;

  void alarm_handler(), check_fd(), check_negative(), check_positive(),
       close_sock(), do_connect(), init_iovec(), l_exit(), logtime(),
       sigusr1(), ul_exit();
  Tst_nobuf = 1;	/* Disable output buffering */

  while ((c = getopt(argc, argv, "d:f:")) != EOF) {

    switch(c) {

    case 'd':
      data_file = optarg;
      break;

    case 'f':
      file = optarg;
      break;

    case '?':
      tst_resm(TBROK, "Usage: %s [-d data_file] [-f file]\n",argv[0]);
      tst_exit();
    default:
      ;
    }
  }

  if (optind < argc) {
    tst_resm(TBROK, "Usage: %s [-d data_file] [-f file]\n",argv[0]);
    tst_exit();
  }

  logtime();
  tst_resm(TINFO, "will bind to file %s", file);

  open_max = sysconf(_SC_OPEN_MAX);     /* maximum number of open files */
  unlink(file);				/* To remove any leftover socket */
  rmsg.msg_iov = riovec;
  bzero((void *) &svr, sizeof(svr));
  svr.sun_family = AF_UNIX;
  strcpy(svr.sun_path, file);
  socklen = strlen(svr.sun_path) + sizeof(AF_UNIX);

  /* Set a wait_time second alarm in case a test case blocks unexpectedly */

  signal(SIGALRM, alarm_handler);
  alarm(wait_time);

  /**** Test case 1 ****/

  rmsg.msg_iovlen = (u_int) 0;
  rmsg.msg_iov = riovec;
  if ((s_sd = socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
    tst_resm(TBROK, "socket(): %s (errno %d)", sys_errlist[errno], errno);
    l_exit();
  }
  check_negative(s_sd, &rmsg, rflags, ENOTCONN);
  if (close(s_sd) < 0) {
    tst_resm(TWARN, "close(s_sd): %s (errno %d)", sys_errlist[errno], errno);
  }

  /**** Test case 2 ****/

  do_connect(&cli, &svr, socklen, &s_sd, &c_sd, &a_sd);
  check_positive(a_sd, c_sd, &rmsg, rflags);

  /**** Test case 3 ****/

  rmsg.msg_iovlen = 1;
  riovec[0].iov_len = 1;
  riovec[0].iov_base = (caddr_t) -1;
  check_negative(a_sd, &rmsg, rflags, EFAULT);
  riovec[0].iov_base = (caddr_t) 0;

  /**** Test case 4 ****/

  rflags = MSG_OOB;
  check_negative(a_sd, &rmsg, rflags, EOPNOTSUPP);
  rflags = 0;

  /**** Test case 5 ****/

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
               
  /**** Test case 6 ****/

    /*    Mark the socket nonblocking     */

  if (ioctl(a_sd, FIONBIO, (char *)&on) < 0) {
    tst_resm(TBROK, "ioctl(): %s (errno %d)", sys_errlist[errno], errno);
  }
  else {
    check_negative(a_sd, &rmsg, rflags, EWOULDBLOCK);
  }

  /**** Test case 7 ****/

  init_iovec(riovec, buf[0], BUFSIZE);
  check_positive(a_sd, c_sd, &rmsg, rflags);

  /**** Test case 8 ****/

  /* Change back to blocking */

  if (ioctl(a_sd, FIONBIO, (char *)&off) < 0) {
    tst_resm(TBROK, "ioctl(): %s (errno %d)", sys_errlist[errno], errno);
    close_sock(a_sd, c_sd, s_sd);
    ul_exit();
  }

  /* Initialize the gather/scatter array and buffers */
  for (i = 0; i < MSG_MAXIOVLEN-1; i++) {
    init_iovec(&riovec[i], buf[i], BUFSIZE);
  }
  
  rmsg.msg_iovlen = MSG_MAXIOVLEN-1;
  check_positive(a_sd, c_sd, &rmsg, rflags);
  rmsg.msg_iovlen = 1;

  /**** Test case 9 ****/

  init_iovec(riovec, buf[0], BUFSIZE);
  rflags = MSG_PEEK;
  check_positive(a_sd, c_sd, &rmsg, rflags);

  /**** Test case 10 ****/

  init_iovec(riovec, buf[0], BUFSIZE);
  rflags = MSG_EOR;
  check_positive(a_sd, c_sd, &rmsg, rflags);

  /**** Test case 11 ****/

  init_iovec(riovec, buf[0], BUFSIZE);
  rflags = MSG_WAITALL;
  check_positive(a_sd, c_sd, &rmsg, rflags);

  /**** Test case 12 ****/

  init_iovec(riovec, buf[0], BUFSIZE);
  rflags = 0;
  rmsg.msg_name = (caddr_t) &cli;
  rmsg.msg_namelen = socklen;
  check_positive(a_sd, c_sd, &rmsg, rflags);

  /**** Test case 13 ****/

  check_fd(a_sd, c_sd, FALSE);

  /**** Test case 14 ****/

  check_fd(a_sd, c_sd, TRUE);

  /**** Test case 15 ****/

  /*
   * The blocking test case should be last because the alarm handler function
   * will exit.  Execution should not return here after check_positive.
   */

}

/*
 *	Establish a connection
 */

static void
do_connect(cliptr, svrptr, socklen, sd_s, sd_c, sd_a)
struct sockaddr_un *cliptr, *svrptr;
int socklen;
int  *sd_s, *sd_c, *sd_a;

/*
 * Parameters to do_connect are:
 *
 *   cliptr		- pointer to client sockaddr_un structure
 *   svrptr		- pointer to server sockaddr_un structure
 *   socklen		- length of sockaddr_un structure
 *   sd_s, sd_c, sd_a	- pointers to socket descriptors returned to caller
 */

{
  int i;

  if ((*sd_s = socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
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
    ul_exit();
  }

  /*	Do the client connect next, followed by the accept	*/

  cliptr->sun_family = AF_UNIX;
  strcpy(cliptr->sun_path, file);

  if ((*sd_c = socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
    tst_resm(TBROK, "socket(): %s (errno %d)", sys_errlist[errno], errno);
    if (close(*sd_s) < 0) {
      tst_resm(TWARN, "close(*sd_s): %s (errno %d)", sys_errlist[errno], errno);
    }
    ul_exit();
  }

  if (connect(*sd_c, (struct sockaddr *) cliptr, socklen) < 0) {
    tst_resm(TBROK, "connect(): %s (errno %d)", sys_errlist[errno], errno);
    close_sock(*sd_s, *sd_c, 0);
    ul_exit();
  }

  /*
   *	Sleep for a few seconds to give the connection request time to be
   *	queued on the server socket 
   */
  sleep(3);
    
  if ((*sd_a = accept(*sd_s, (struct sockaddr *) svrptr, &socklen)) < 0) {
    tst_resm(TBROK, "accept(): %s (errno %d)", sys_errlist[errno], errno);
    close_sock(*sd_s, *sd_c, 0);
    ul_exit();
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
    ul_exit();
  }
  else {
    /* do sendmsg */
    int nsent;

    sflags = flags;
    smsg.msg_iovlen = msg->msg_iovlen;
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
          if ((flags == MSG_EOR) && (msg->msg_flags != MSG_EOR)) {
            tst_resm(TFAIL,"msg_flags = %d, should be set to MSG_EOR (%d)",
                     msg->msg_flags, MSG_EOR);
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

/*
 * Perform test cases involving passing file descriptors
 */

static void
check_fd(n_sd_2, sd_1, ctrunc)
int n_sd_2, sd_1, ctrunc;

/*
 * Parameters to check_fd are:
 *
 *   n_sd_2	- server socket descriptor
 *   sd_1	- client socket descriptor
 *   ctrunc	- TRUE if MSG_CTRUNC is to be tested, else FALSE
 */

{
  int i, j, r, fd, n;
  char data[BUFSIZ];
  fd_set fd_all;        /* file descriptor bitmask */
  struct stat statbuf;

  struct msghdr msg;
  struct cmsghdr c_msg;
  struct iovec	iov[1];

  char *buf;

  for (i=0; i < 2; i++) {
    switch (fork()) {
    case -1:
      tst_resm(TBROK, "fork(): %s (errno %d)", sys_errlist[errno], errno);
      break;
  
    case 0:
      /*
       * child: is the client sending the fd to the server
       */
      sleep(1);
#ifdef DEBUG
      printf("child: started\n");
#endif
  
      (void) unlink(data_file);
      if ((fd = open(data_file, O_CREAT|O_RDWR, 0777)) < 0) {
        tst_resm(TBROK, "open(): %s (errno %d)", sys_errlist[errno], errno);
        exit(1);
      }
      if (write(fd, TESTDATA, BUFSIZ) != BUFSIZ) {
        tst_resm(TBROK, "write(): %s (errno %d)", sys_errlist[errno], errno);
        exit(1);
      }
      if (lseek(fd, 0, 0) < 0) {
        tst_resm(TBROK, "lseek(): %s (errno %d)", sys_errlist[errno], errno);
        exit(1);
      }
  
      buf=(char *)malloc(MALLOCSIZE);
      iov[0].iov_base = (char *) 0;
      iov[0].iov_len = 0;
      msg.msg_iov = iov;
      msg.msg_iovlen = 1;
      msg.msg_name = (caddr_t) 0;
  
      c_msg.cmsg_level = SOL_SOCKET;
      c_msg.cmsg_type = SCM_RIGHTS;
      c_msg.cmsg_len = sizeof(c_msg) + sizeof(fd);
      memcpy(buf, &c_msg, sizeof(c_msg));
      memcpy(buf + sizeof(c_msg), &fd, sizeof(fd));
  
      msg.msg_control = (caddr_t) buf;
      msg.msg_controllen = sizeof(c_msg) + sizeof(fd);
  
      if (sendmsg(sd_1, &msg, 0) < 0) {
        tst_resm(TBROK, "sendmsg(): %s (errno %d)", sys_errlist[errno], errno);
        ul_exit();
      }
#ifdef DEBUG
      printf("child: sendmsg()\n");
#endif
      free(buf);
      exit(0);
      break;
  
    default:
      /*
       * parent: is the server receiving the fd to the client
       */
#ifdef DEBUG
      printf("parent: started\n");
#endif
      buf=(char *)malloc(MALLOCSIZE);
      iov[0].iov_base = data;
      iov[0].iov_len = sizeof(data);
      msg.msg_iov = iov;
      msg.msg_iovlen = 1;
      msg.msg_name = (caddr_t) 0;
      msg.msg_control = (caddr_t) buf;
      if (ctrunc) 
        msg.msg_controllen = sizeof(struct cmsghdr)/2;
      else
        msg.msg_controllen = MALLOCSIZE;

      /*
       * Contruct an fd_set bitmap of currently open files using fstat().  Use
       * this bitmap after the recvmsg to verify that the file descriptor
       * returned was not already open.
       */
    
      FD_ZERO(&fd_all);
      for(j=0; j < open_max; j++) {
        if (fstat(j, &statbuf) == 0) {
          FD_SET(j, &fd_all);
        }
      }
  
#ifdef DEBUG
      printf("parent: BEFORE: msg.msg_controllen=%d\n", msg.msg_controllen);
#endif
  
      if ((r=recvmsg(n_sd_2, &msg, 0)) < 0) {
        tst_resm(TFAIL, "passing file descriptor: %s (errno %d)",
                 sys_errlist[errno], errno);
        if (unlink(data_file) < 0) {
          tst_resm(TWARN, "unlink(%s): %s (errno %d)", file, sys_errlist[errno],
             errno);
        }
        return;
      }
#ifdef DEBUG
      printf("parent: recvmsg()\n");
      printf("parent: r=%d\n", r);
      printf("parent: AFTER: msg.msg_controllen=%d\n", msg.msg_controllen);
      printf("parent: msg.msg_flags=%d\n",msg.msg_flags);
#endif

      /*  Special case for MSG_CTRUNC flag */
      if (ctrunc) {
        if (msg.msg_flags != MSG_CTRUNC) {
          tst_resm(TFAIL,"msg_flags = %d, should be set to MSG_CTRUNC (%d)",
                   msg.msg_flags, MSG_CTRUNC);
        }
        else {
          tst_resm(TPASS,"correctly received MSG_CTRUNC flag");
        }
        if (unlink(data_file) < 0) {
          tst_resm(TWARN, "unlink(%s): %s (errno %d)", file, sys_errlist[errno],
             errno);
        }
        return;
      }
  
      /* Should receive exactly one file descriptor */
      if (msg.msg_controllen != sizeof(struct cmsghdr) + sizeof(int)) {
        tst_resm(TFAIL, "received %d file descriptors, expecting 1.",
                 (msg.msg_controllen - sizeof(struct cmsghdr)) / sizeof(int));
        if (unlink(data_file) < 0) {
          tst_resm(TWARN, "unlink(%s): %s (errno %d)", file, sys_errlist[errno],
             errno);
        }
        return;
      }
      fd = *(int *)(buf + sizeof(c_msg));
#ifdef DEBUG
      printf("received fd=%d\n", fd);
#endif
      if (FD_ISSET(fd, &fd_all)) {
        tst_resm(TFAIL, "Descriptor %d returned by recvmsg was already in use",
                 fd);
        if (unlink(data_file) < 0) {
          tst_resm(TWARN, "unlink(%s): %s (errno %d)", file, sys_errlist[errno],
             errno);
        }
        return;
      }
  
      if ((n = read(fd, data, sizeof(data))) < 0) {
        tst_resm(TBROK, "read(): %s (errno %d)", sys_errlist[errno], errno);
      } else {
#ifdef DEBUG
        printf("parent: got %s\n", data);
#endif
        if (strcmp(data,TESTDATA)) {
          tst_resm(TFAIL, "data read from passed file descriptor %d does not match data written", fd);
          return;
        }
      }
      free(buf);
      if (unlink(data_file) < 0) {
        tst_resm(TWARN, "unlink(%s): %s (errno %d)", file, sys_errlist[errno],
           errno);
      }
    }
  }
  tst_resm(TPASS, "successfully passed 1 file descriptor two times");
}
