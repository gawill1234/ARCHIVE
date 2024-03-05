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
 *  TEST TITLE           : Socket system calls regression -- RAW bind()
 *
 *  PARENT DOCUMENT      : Socket System Calls Regression Test Plan
 *
 *  AUTHOR               : Bill Schoofs
 *
 *  CO-PILOT             : Hal Peterson
 *
 *  INITIAL RELEASE      : Unicos 8.0
 *
 *  TEST CASES           : Call bind with:
 *			   1) descriptor = -1				negative
 *			   2) descriptor = OPEN_MAX			negative
 *			   3) valid descriptor for an open
 *			      file that is NOT a socket			negative
 *			   4) closed socket				negative
 *			   5) valid, unused descriptor			negative
 *			   6) internet address 192.0.2.1 *		negative
 *			   7) broadcast internet address 192.0.2.255 *	negative
 *			   8) broadcast internet address 255.255.255.255
 *									negative
 *			   9) bad ptr to sockaddr struct		negative
 *			   10)bad namelen				negative
 *			   11)specify both internet address and port	negative
 *			   12)specify port, but not internet address	positive
 *			   13)specify neither port nor internet address positive
 *			   14)specify internet address, but not port	positive
 *
 *  CPU TYPES            : CRAY-XMP, CRAY-YMP, CRAY-2, CRAY-C90, CRAY-EL
 *
 *  INPUT SPECIFICATION  : Usage: raw_bind [-P port]
 *                         port is the port number that the program will be
 *			   binding to.  The default port number is 50099.
 *
 *  OUTPUT SPECIFICATION : Standard output provided by cuts library.
 *
 *  SPECIAL REQUIREMENTS : This test needs to be run as uid=0 (root) in order
 *			   to create a raw socket.
 *
 *  IMPLEMENTATION NOTES : This test assumes that the getsockname() system call
 *			   is functioning correctly.
 *
 *			   The flexibility of changing the port number is
 *			   provided to allow multiple copies of the test to run
 *			   without contention.  The default port number is the
 *			   default port number used in the corresponding TCP/IP
 *			   multithreading test minus one.
 *
 *			 * The network number 192.0.2 is designated as a TEST
 *			   network number in RFC 1166.
 *
 *  DETAILED DESCRIPTION : For the negative test cases, check that the return
 *			   value = -1 and that the errno is correct.
 *
 *			   For the positive test cases, use the getsockname()
 *			   system call after the bind.  Ensure that the 
 *			   members of the sockaddr structure returned by
 *			   getsockname() match the members of the sockaddr
 *			   structure that was input to the bind.
 *
 *  KNOWN BUGS           : There is a problem in the inconsistent way raw
 *			   bind() handles the presence of a port number.  
 *			   Binding a port number to a RAW socket accomplishes
 *			   nothing.  Test case 11 is a negative test case and
 *			   test case 12 is positive as a result.  See SPR 73228
 *			   for further details.
 */

/*
 * Revision control information. 
 */
 static char Revision[] = "$Header:$";

#include <errno.h>
#include <fcntl.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include "test.h"
#include <unistd.h>
#include <usctest.h>

#define TEST_ADDR "192.0.2"	/* Test network number */
#define MAXMSG 200		/* max length of messages */

extern char *sys_errlist[];
char *TCID= "raw_bind";		/* Test case identifier */
const int wait_time = 120;
int TST_TOTAL = 14;             /* Total number of test cases */

main(int argc, char *argv[])
{
  int c;
  int fd, fd_null;		/* file and socket descriptors */
  const maxport = (1<<16) - 1;	/* port numbers must fit in sixteen bits */
  int open_max = sysconf(_SC_OPEN_MAX);	/* maximum number of open files */
  /* int port = 50099; */		/* the default port number */
  int port;	/* the default port number */
  struct sockaddr_in sock;

  extern int optind;
  extern char *optarg;

  struct stat statbuf;
  void check_negative(), check_positive(), l_exit();

  TEST_PORT(getpid());
  port=ATEST_PORT;
  while ((c = getopt(argc, argv, "P:")) != EOF) {

    switch(c) {

    case 'P':
      port = atoi(optarg);
      if (port < IPPORT_RESERVED || port > maxport) {
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

  if ((fd=socket(AF_INET, SOCK_RAW, 0)) < 0) {
    if (errno == EACCES) {
      tst_resm(TWARN, "This test must be run as uid=0 (root)");
    }
    tst_resm(TBROK, "socket(): %s (errno %d)", sys_errlist[errno], errno);
    l_exit();
  }

  sock.sin_family = AF_INET;
  sock.sin_port = port;
  sock.sin_addr.s_addr = INADDR_ANY;

  /****	Test case 1 ****/

  check_negative(-1, (struct sockaddr *) &sock, sizeof(sock), EBADF);

  /****	Test case 2 ****/

  check_negative(open_max, (struct sockaddr *) &sock, sizeof(sock), EBADF);

  /****	Test case 3 ****/

  if (fd_null=open("/dev/null", O_RDONLY) < 0) {
    tst_resm(TBROK, "open(): %s (errno %d)", sys_errlist[errno], errno);
  }
  else {
    check_negative(fd_null, (struct sockaddr *) &sock, sizeof(sock), ENOTSOCK);
    if (close(fd_null) < 0) {
      tst_resm(TWARN, "close(): %s (errno %d)", sys_errlist[errno], errno);
    }
  }

  /****	Test case 4 ****/

  if (close(fd) < 0) {
    tst_resm(TBROK, "close(): %s (errno %d)", sys_errlist[errno], errno);
  }
  else {
    check_negative(fd, (struct sockaddr *) &sock, sizeof(sock), EBADF);
  }

  /**** Test case 5 ****/

  /*	Ensure the descriptor is not already in use with fstat()	*/

  for(fd=4; fd<open_max; fd++) {
    if ((fstat(fd, &statbuf) < 0) && (errno == EBADF)) {
      check_negative(fd, (struct sockaddr *) &sock, sizeof(sock), EBADF);
      break;
    }
  }
  if (fd == open_max) {
    tst_resm(TBROK, "no unused file descriptors available");
  }

  /**** Test case 6 ****/

  if ((fd=socket(AF_INET, SOCK_RAW, 0)) < 0) {
    tst_resm(TBROK, "socket(): %s (errno %d)", sys_errlist[errno], errno);
    l_exit();
  }

  sock.sin_addr.s_addr = inet_addr(TEST_ADDR".1");
  check_negative(fd, (struct sockaddr *) &sock, sizeof(sock), EADDRNOTAVAIL);

  /**** Test case 7 ****/

  sock.sin_addr.s_addr = inet_addr(TEST_ADDR".255");
  check_negative(fd, (struct sockaddr *) &sock, sizeof(sock), EADDRNOTAVAIL);

  /**** Test case 8 ****/

  sock.sin_addr.s_addr = inet_addr("255.255.255.255");
  check_negative(fd, (struct sockaddr *) &sock, sizeof(sock), EADDRNOTAVAIL);

  /****	Test case 9 ****/

  sock.sin_addr.s_addr = inet_addr("127.0.0.1");
  check_negative(fd, (struct sockaddr *) -1, sizeof(sock), EFAULT);

  /****	Test case 10 ****/

  check_negative(fd, (struct sockaddr *) &sock, -1, EINVAL);

  /**** Test case 11 ****/

  sock.sin_port = port;
  check_negative(fd, (struct sockaddr *) &sock, sizeof(sock), EADDRNOTAVAIL);

  /****	Test case 12 ****/

  sock.sin_addr.s_addr = INADDR_ANY;
  check_positive(fd, &sock, sock.sin_port, (short) SOCK_RAW);

  if (close(fd) < 0) {
    tst_resm(TWARN, "close: %s (errno %d)", sys_errlist[errno], errno);
  }

  /****	Test case 13 ****/

  if ((fd=socket(AF_INET, SOCK_RAW, 0)) < 0) {
    tst_resm(TBROK, "socket(): %s (errno %d)", sys_errlist[errno], errno);
    l_exit();
  }

  sock.sin_port = 0;
  check_positive(fd, &sock, sock.sin_port, (short) SOCK_RAW);

  if (close(fd) < 0) {
    tst_resm(TWARN, "close: %s (errno %d)", sys_errlist[errno], errno);
  }

  /****	Test case 14 ****/

  if ((fd=socket(AF_INET, SOCK_RAW, 0)) < 0) {
    tst_resm(TBROK, "socket(): %s (errno %d)", sys_errlist[errno], errno);
    l_exit();
  }

  sock.sin_addr.s_addr = inet_addr("127.0.0.1");
  check_positive(fd, &sock, sock.sin_port, (short) SOCK_RAW);

  if (close(fd) < 0) {
    tst_resm(TWARN, "close: %s (errno %d)", sys_errlist[errno], errno);
  }
  l_exit();
}
