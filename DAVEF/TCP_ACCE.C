 /*************************************************************************
 *
 *  TCP/IP Testing       Cray Research, Inc.   Eagan, Minnesota
 *
 *  TEST IDENTIFIER      : $Source:$
 *
 *  TEST TITLE           : Socket system calls regression -- TCP accept()
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
 *			      addrlen=sizeof(sockaddr_in)		positive
 *			   10)blocking with addrlen=sizeof(sockaddr_in) positive
 *			   11)blocking with addrlen<sizeof(sockaddr_in) positive
 *
 *  CPU TYPES            : CRAY-XMP, CRAY-YMP, CRAY-2, CRAY-C90, CRAY-EL
 *
 *  INPUT SPECIFICATION  : Usage: tcp_accept [-P port]
 *                         port is the base port number that the program will
 *			   bind to.  The default base port number is 29997.
 *			   Note that this test uses three consecutive port
 *			   numbers beginning with the base port number.
 *
 *  OUTPUT SPECIFICATION : Standard output provided by the cuts library.
 *
 *  SPECIAL REQUIREMENTS : none
 *
 *  IMPLEMENTATION NOTES : This test assumes that the getpeername() system call
 *			   is functioning correctly.
 *
 *                         The flexibility of changing the base port number is
 *                         provided to allow multiple copies of the test to run
 *                         without contention.  The default port number is the
 *                         default port number used in the corresponding TCP/IP
 *                         multithreading test minus three.  
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

#include <errno.h>
#include <fcntl.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <signal.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include "test.h"
#include "usctest.h"
#include <unistd.h>

#define FALSE 0
#define TLEN 8			/* length used for truncation */
#define TRUE 1
#define TRY_MAX 6		/* Maximum number of bind retries */

extern char *sys_errlist[];
extern int Tst_nobuf;		/* Output buffering flag */
extern int Tst_count;
extern int optind;
extern char *optarg;
char *TCID = "tcp_accept";	/* Test case identifier */
int TST_TOTAL = 11;		/* Total number of test cases */
int exp_enos[]={0, 0};
static const int on = 1;	/* For ioctl arg */
static int open_max;		/* maximum number of open files */
const int wait_time = 120;	/* number of seconds for alarm */
void setup(), cleanup();
void check_negative(), check_positive(), l_exit(), logtime();
void sockinit(), too_long();

main(int argc, char *argv[])
{
  int c, i;
  int fd_null, s_sd;			/* socket descriptors */
  int port = 29997;			/* the default base port number */
  struct sockaddr_in svr, sock_trunc;
  int socklen = sizeof(svr);


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
  open_max = sysconf(_SC_OPEN_MAX);	/* maximum number of open files */
  tst_resm(TINFO, "will bind to ports %d, %d, and %d", port, port+1, port+2);

  sockinit(port, &svr);

  /****	Test case 1 ****/

  check_negative(-1, (struct sockaddr *) &svr, &socklen, EBADF);

  /**** Test case 2 ****/

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

  if ((s_sd=socket(AF_INET, SOCK_STREAM, 0)) < 0) {
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


  /****	Test case 9 ****/

  sockinit(port, &svr);
  check_positive(&svr, (struct sockaddr_in *) 0, port, FALSE);
  
  /****	Test case 10 ****/

  sockinit(++port, &svr);
  check_positive(&svr, (struct sockaddr_in *) 0, port, TRUE);

  /****	Test case 11 ****/

  sockinit(++port, &sock_trunc);
  check_positive(&sock_trunc, &svr, port, TRUE);

  l_exit();
}

/* Function to perform positive test cases */

static void check_positive(c_sockptr, c_sockcmp, c_port, c_block)
struct sockaddr_in *c_sockptr, *c_sockcmp;
int c_port, c_block;

/*
 * Parameters to check_positive are:
 *
 *   c_sockptr   - pointer to sockaddr_in structure used with the accept
 *   c_sockcmp	 - pointer to sockaddr_in structure already used in a previous
 *		   accept in which no truncation was done.  It used for 
 *		   comparison after truncation is done.  0 if no truncation is
 *		   to be done.
 *   c_port      - port number for bind and connect
 *   c_block	 - Boolean value that indicates if accept should block or not
 */

{
  int a_len;		/* length to use with accept */
  fd_set fd_all;	/* file descriptor bitmask */
  int i;
  int sd_a, sd_c, sd_s;	/* socket descriptors */
  struct sockaddr_in cli, sock_got, sock_zero;
  int socklen = sizeof(cli);
  struct stat statbuf;
  void close_sock();

  if ((sd_s=socket(AF_INET, SOCK_STREAM, 0)) < 0) {
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
    l_exit();
  }

  /*	Do the client connect next, followed by the accept	*/

  cli.sin_family = AF_INET;
  cli.sin_port = c_port;
  cli.sin_addr.s_addr = inet_addr("127.0.0.1");

  if ((sd_c=socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    tst_resm(TBROK, "socket(): %s (errno %d)", sys_errlist[errno], errno);
    l_exit();
  }

  if (connect(sd_c, (struct sockaddr *) &cli, sizeof(cli)) < 0) {
    tst_resm(TBROK, "connect(): %s (errno %d)", sys_errlist[errno], errno);
    close_sock(sd_s, sd_c);
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
      close_sock(sd_s, sd_c);
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
           * sockaddr_in structure was passed to this function.  The
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

  close_sock(sd_s, sd_c);
}

/*
 *	function to close two sockets
 */

static void
close_sock(sd1, sd2)
int sd1, sd2;
{
  if (close(sd1) < 0) {
    tst_resm(TWARN, "close(%d): %s (errno %d)", sd1, sys_errlist[errno], errno);
  }
  if (close(sd2) < 0) {
    tst_resm(TWARN, "close(%d): %s (errno %d)", sd2, sys_errlist[errno], errno);
  }
}

/*
 *	function to initialize a sockaddr_in structure
 */

static void
sockinit(port, sock)
int port;
struct sockaddr_in *sock;
{
  struct sockaddr_in sizesock;		/* just to get the size */

  bzero((void *) sock, sizeof(sizesock));
  sock->sin_family = AF_INET;
  sock->sin_port = port;
  sock->sin_addr.s_addr = inet_addr("127.0.0.1");
}
