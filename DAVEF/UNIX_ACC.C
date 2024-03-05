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
 *  TEST TITLE           : Socket system calls regression - UNIX STREAM accept()
 *
 *  PARENT DOCUMENT      : Socket System Calls Regression Test Plan
 *
 *  AUTHOR               : Bill Schoofs
 *
 *  CO-PILOT             : Hal Peterson
 *
 *  INITIAL RELEASE      : Unicos 8.0
 *
 *  TEST CASES           : 1) descriptor = -1				negative
 *			   2) descriptor = OPEN_MAX			negative
 *			   3) valid descriptor for an open file that
 *			      is NOT a socket				negative
 *			   4) bind not called before accept		negative
 *			   5) listen not called before accept		negative
 *			   6) bad ptr to sockaddr struct 		negative
 *			   7) bad ptr to addrlen			negative
 *			   8) nonblocking with no pending connection	negative
 *			   9) nonblocking with a pending connection with
 *			      addrlen=sizeof(sockaddr_un)		positive
 *			   10)blocking with addrlen=sizeof(sockaddr_un) positive
 *			   11)blocking with addrlen<sizeof(sockaddr_un) positive
 *
 *  CPU TYPES            : CRAY-XMP, CRAY-YMP, CRAY-2, CRAY-C90, CRAY-EL
 *
 *  INPUT SPECIFICATION  : Usage: unix_accept_s [-f file]
 *                                [-f file] is the file name that the
 *                                server is listening on.  Default file
 *                                is "unixs.acce"
 *
 *  OUTPUT SPECIFICATION : Standard output provided by the cuts library.
 *
 *  SPECIAL REQUIREMENTS : none
 *
 *  IMPLEMENTATION NOTES : This test assumes that the getpeername() system call
 *			   is functioning correctly.
 *
 *                         The flexibility of changing the file name is
 *                         provided to allow multiple copies of the test to run
 *                         without contention.  The default file name is the
 *                         default file name used in the corresponding TCP/IP
 *                         multithreading test.
 *
 *			   At the time this test was written, the man page
 *			   listed EOPNOTSUPP as a possible errno returned.
 *			   Although the kernel code does check for this error,
 *			   it will always return EINVAL first because any
 *			   listen() before the accept() would fail.
 *
 *  DETAILED DESCRIPTION : For the negative test cases, check that the return
 *			   value = -1 and that the errno is correct.
 *
 *			   Test Cases 9 & 10)  Ensure the descriptor returned
 *			     is valid and not already in use.
 *			     Ensure getpeername does not set ENOTCONN errno.
 *			   Test Case 11) Same as test case 9 and ensure that
 *			     truncation has occurred.
 *
 *  KNOWN BUGS           : None
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
#include <sys/stat.h>
#include <sys/un.h>
#include "test.h"
#include <unistd.h>

#define FALSE 0
#define TLEN 8                  /* length used for truncation */
#define TRUE 1
#define TRY_MAX 60		/* Maximum number of bind retries */

extern char *sys_errlist[];
extern int Tst_nobuf;		/* Output buffering flag */
char *TCID = "unix_accept_s";	/* Test case identifier */
int TST_TOTAL = 11;		/* Total number of test cases */
static const int on = 1;	/* For ioctl arg */
static int open_max;		/* maximum number of open files */
const int wait_time = 120;      /* number of seconds for alarm */

main(int argc, char *argv[])
{
  int c, i;
  int fd_null, s_sd;		/* socket descriptors */
  char *file="unixs.acce";	/* the default file name for sun_path */
  struct sockaddr_un svr, sock_trunc;
  int socklen = sizeof(svr);

  extern int optind;
  extern char *optarg;

  void check_negative(), check_positive(), l_exit(), logtime();
  void sockinit(), too_long();

  Tst_nobuf = 1;	/* Disable output buffering */

  while ((c = getopt(argc, argv, "f:")) != EOF) {

    switch(c) {

    case 'f':
      file = optarg;
      break;

    case '?':
      tst_resm(TBROK, "Usage: %s [-f file]\n", argv[0]);
      tst_exit();
    default:
      ;
    }
  }

  if (optind < argc) {
    tst_resm(TBROK, "Usage: %s [-f file]\n",argv[0]);
    tst_exit();
  }

  logtime();
  open_max = sysconf(_SC_OPEN_MAX);	/* maximum number of open files */
  tst_resm(TINFO, "will bind to file %s", file);

  sockinit(&svr, file);

  /****	Test case 1 ****/

  check_negative(-1, (struct sockaddr *) &svr, &socklen, EBADF);

  /****	Test case 2 ****/

  check_negative(open_max, (struct sockaddr *) &svr, &socklen, EBADF);

  /****	Test case 3 ****/

  if (fd_null=open("/dev/null", O_RDONLY) < 0) {
    tst_resm(TBROK, "open(): %s (errno %d)", sys_errlist[errno], errno);
  }
  else {
    check_negative(fd_null, (struct sockaddr *) &svr, &socklen, ENOTSOCK);
    if (close(fd_null) < 0) {
      tst_resm(TWARN, "close(): %s (errno %d)", sys_errlist[errno], errno);
    }
  }

  /****	Test case 4 ****/

  if ((s_sd=socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
    tst_resm(TBROK, "socket(): %s (errno %d)", sys_errlist[errno], errno);
    l_exit();
  }
  check_negative(s_sd, (struct sockaddr *) &svr, &socklen, EINVAL);

  /****	Test case 5 ****/

  for(i=0 ;
      (bind(s_sd, (struct sockaddr *) &svr, socklen) < 0) && (i < TRY_MAX) ;
      i++) {
    tst_resm(TINFO, "bind(): %s (errno %d)", sys_errlist[errno], errno);
    sleep(1);
  }
  if (i == TRY_MAX) {
    tst_resm(TBROK, "bind(): See previous INFO messages for details of error");
    l_exit();
  }

  check_negative(s_sd, (struct sockaddr *) &svr, &socklen, EINVAL);

  /****	Test case 6 ****/

  if (listen(s_sd, 5) < 0) {
    tst_resm(TBROK, "listen(): %s (errno %d)", sys_errlist[errno], errno);
    l_exit();
  }
  check_negative(s_sd, (struct sockaddr *) -1, &socklen, EFAULT);

  /****	Test case 7 ****/

  check_negative(s_sd, (struct sockaddr *) &svr, (int *) -1, EFAULT);

  /****	Test case 8 ****/

  /* Set a wait_time second alarm in case the non-blocking test cases block */

  signal(SIGALRM, too_long);
  alarm(wait_time);

  /*	Mark the socket nonblocking	*/

  if (ioctl(s_sd, FIONBIO, (char *)&on) < 0) {
    tst_resm(TBROK, "ioctl(): %s (errno %d)", sys_errlist[errno], errno);
  }
  else {
    check_negative(s_sd, (struct sockaddr *) &svr, &socklen, EWOULDBLOCK);
      }

  if (close(s_sd) < 0) {
    tst_resm(TWARN, "close(): %s (errno %d)", sys_errlist[errno], errno);
  }
  if (unlink(file) < 0) {
    tst_resm(TBROK, "unlink(%s): %s (errno %d)", file, sys_errlist[errno],
             errno);
    l_exit();
  }

  /****	Test case 9 ****/

  sockinit(&svr, file);
  check_positive(&svr, file, (struct sockaddr_un *) 0, FALSE);

  /****	Test case 10 ****/

  sockinit(&svr, file);
  check_positive(&svr, file, (struct sockaddr_un *) 0, TRUE);

  /****	Test case 11 ****/

  sockinit(&sock_trunc, file);
  check_positive(&sock_trunc, file, &svr, TRUE);

  l_exit();
}

/*
 *	function to close two sockets and unlink the socket directory entry
 */

static void
close_sock(sd1, sd2, fp)
int sd1, sd2;
char *fp;
{
  if (close(sd1) < 0) {
    tst_resm(TWARN, "close(%d): %s (errno %d)", sd1, sys_errlist[errno], errno);
  }
  if (close(sd2) < 0) {
    tst_resm(TWARN, "close(%d): %s (errno %d)", sd2, sys_errlist[errno], errno);
  }
  if (unlink(fp) < 0) {
    tst_resm(TBROK, "unlink(%s): %s (errno %d)", fp, sys_errlist[errno],
             errno);
    l_exit();
  }
}

/* Function to perform positive test cases */

static void check_positive(c_sockptr, c_file, c_sockcmp, c_block)
struct sockaddr_un *c_sockptr;
char *c_file;
struct sockaddr_un *c_sockcmp;
int c_block;

/*
 * Parameters to check_positive are:
 *
 *   c_sockptr   - pointer to sockaddr_un structure used with the accept
 *   c_file      - pointer to file name for bind and connect
 *   c_sockcmp	 - pointer to sockaddr_un structure already used in a previous
 *		   accept in which no truncation was done.  It used for 
 *		   comparison after truncation is done.  0 if no truncation is
 *		   to be done.
 *   c_block	 - Boolean value that indicates if accept should block or not
 */

{
  int a_len;		/* length to use with accept */
  fd_set fd_all;	/* file descriptor bitmask */
  int i;
  int sd_a, sd_c, sd_s;	/* socket descriptors */
  struct sockaddr_un cli, sock_got, sock_zero;
  int socklen = sizeof(cli);
  struct stat statbuf;

  if ((sd_s=socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
    tst_resm(TBROK, "socket(): %s (errno %d)", sys_errlist[errno], errno);
    l_exit();
  }

  for(i=0 ;
      (bind(sd_s, (struct sockaddr *) c_sockptr, socklen) < 0)&&(i < TRY_MAX);
      i++) {
    tst_resm(TINFO, "bind(): %s (errno %d)", sys_errlist[errno], errno);
    sleep(1);
  }
  if (i == TRY_MAX) {
    tst_resm(TBROK, "bind(): See previous INFO messages for details of error");
    if (close(sd_s) < 0) {
      tst_resm(TWARN, "close(sd_s): %s (errno %d)", sys_errlist[errno], errno);
    }
    l_exit();
  }

  if (listen(sd_s, 5) < 0) {
    tst_resm(TBROK, "listen(): %s (errno %d)", sys_errlist[errno], errno);
    if (close(sd_s) < 0) {
      tst_resm(TWARN, "close(sd_s): %s (errno %d)", sys_errlist[errno], errno);
    }
    if (unlink(c_file) < 0) {
      tst_resm(TWARN, "unlink(%s): %s (errno %d)", c_file, sys_errlist[errno],
               errno);
    }
    l_exit();
  }

  /*	Do the client connect next, followed by the accept	*/

  cli.sun_family = AF_UNIX;
  strcpy(cli.sun_path, c_file);

  if ((sd_c=socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
    tst_resm(TBROK, "socket(): %s (errno %d)", sys_errlist[errno], errno);
    l_exit();
  }

  if (connect(sd_c, (struct sockaddr *) &cli, sizeof(cli)) < 0) {
    tst_resm(TBROK, "connect(): %s (errno %d)", sys_errlist[errno], errno);
    close_sock(sd_s, sd_c, c_file);
    return;
  }

  /*
   *	Sleep for a few seconds to give the connection request time to be
   *	queued on the server socket 
   */
  sleep(3);

  if (c_sockcmp) {
    bzero((void *) c_sockptr, socklen);
    a_len = TLEN;		/* truncation to length TLEN will occur */
  }
  else {
    a_len = sizeof(cli);
  }

  if (!c_block) {
    if (ioctl(sd_s, FIONBIO, (char *)&on) < 0) {
      tst_resm(TBROK, "ioctl(): %s (errno %d)", sys_errlist[errno], errno);
      close_sock(sd_s, sd_c, c_file);
      return;
    }
  }

  /*
   * Contruct an fd_set bitmap of currently open files using fstat().  Use this 
   * bitmap after the accept to verify that the file descriptor returned was
   * not already open.
   */

  FD_ZERO(&fd_all);
  for(i=0; i < open_max; i++) {
    if (fstat(i, &statbuf) == 0) {
      FD_SET(i, &fd_all);
    }
  }
    
  if ((sd_a=accept(sd_s, (struct sockaddr *) c_sockptr, &a_len)) < 0) {
    tst_resm(TFAIL, "accept(): %s (errno %d)", sys_errlist[errno], errno);
  }
  else {
    if (sd_a >= open_max) {
      tst_resm(TFAIL, "Descriptor %d returned by accept is > OPEN_MAX", sd_a);
    }
    else {
      if (FD_ISSET(sd_a, &fd_all)) {
        tst_resm(TFAIL, "Descriptor %d returned by accept was already in use",
                 sd_a);
      }
      else {

      /*
       *  Ensure that the the socket is connected after the accept by doing
       *  a getpeername.  getpeername will fail with errno ENOTCONN if not
       *  connected.
       */

        if (((getpeername(sd_a, (struct sockaddr *) &sock_got, &socklen)) < 0)
            && errno == ENOTCONN) {
        tst_resm(TFAIL, "server socket not connected after accept");
      }
      else {

          /*	cast some pointers for use with bcmp */

          char *cs_ptr = (char *) c_sockptr;
          char *sz_ptr = (char *) &sock_zero;

	/*
         * Ensure the truncation was done if a pointer to a comparison
         * sockaddr_un structure was passed to this function.  The
         * structures should be identical for a_len bytes (the length passed
         * to the accept() system call.)  The remainder of the structure
         * (beyond a_len bytes) should remain zeroed.
	 */

          bzero((void *) &sock_zero, socklen);
          if ((c_sockcmp) &&
                 ((bcmp(c_sockptr, c_sockcmp, a_len)) ||
	                 (bcmp(cs_ptr+a_len, sz_ptr+a_len, socklen-a_len)))) {
            tst_resm(TFAIL, "accept did not truncate its result to length %d",
                     TLEN);
        }
	else {
	tst_resm(TPASS, "server socket connected after accept");
	}
      }

      if (close(sd_a) < 0) {
        tst_resm(TWARN, "close(sd_a): %s (errno %d)", sys_errlist[errno],
                 errno);
      }
    }
    }
  }

  close_sock(sd_s, sd_c, c_file);
}

/*
 *	function to initialize a sockaddr_un structure
 */

static void
sockinit(sock, fp)
struct sockaddr_un *sock;
char *fp;
{
  struct sockaddr_un sizesock;		/* just to get the size */

  bzero((void *) sock, sizeof(sizesock));
  sock->sun_family = AF_UNIX;
  strcpy(sock->sun_path, fp);
}
