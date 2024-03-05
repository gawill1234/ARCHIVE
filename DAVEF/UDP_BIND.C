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
 *  TEST TITLE           : Socket system calls regression -- UDP bind()
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
 *			   11)specify port, but not internet address	positive
 *			   12)specify neither port nor internet address positive
 *			   13)specify internet address, but not port	positive
 *			   14)specify both internet address and port	positive
 *			   15)bind same socket to the same port twice   negative
 *			   16)bind two different sockets to the same port
 *                            and the same internet address             negative
 *			   17)bind two different sockets to the same port
 *                            and different internet addresses          positive
 *			   18)well known port with uid!=0               negative
 *
 *  CPU TYPES            : CRAY-XMP, CRAY-YMP, CRAY-2, CRAY-C90, CRAY-EL
 *
 *  INPUT SPECIFICATION  : Usage: udp_bind [-P port]
 *                         port is the port number that the program will be
 *			   binding to.  The default port number is 30099.
 *
 *  OUTPUT SPECIFICATION : Standard output provided by cuts library.
 *
 *  SPECIAL REQUIREMENTS : none
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
 *  KNOWN BUGS           : Test case 17 blindly assumes that the first
 *                         interface in the array returned from ioctl() will
 *                         be configured up and not be the loopback interface.
 *                         This is not always true, so it should search 
 *                         through the interface array to try to find a 
 *                         suitable interface before attempting the bind().
 */

/*
 * Revision control information. 
 */
 static char Revision[] = "$Header:$";

#include <errno.h>
#include <fcntl.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <net/if.h>
#include "test.h"
#include <unistd.h>

#define TEST_ADDR "192.0.2"	/* Test network number */
#define MAXMSG 200		/* max length of messages */
#define MAXIFR 2000		/* max length of array of ifreq structures */

extern char *sys_errlist[];
char *TCID= "udp_bind";		/* Test case identifier */
const int wait_time = 120;
int TST_TOTAL = 18;             /* Total number of test cases */

main(int argc, char *argv[])
{
  int c;
  int fd, fd2, fd_null;		/* file and socket descriptors */
  const maxport = (1<<16) - 1;	/* port numbers must fit in sixteen bits */
  int open_max = sysconf(_SC_OPEN_MAX);	/* maximum number of open files */
  int port = 30099;		/* the default port number */
  struct ifconf ifc;	 	/* These two lines for ioctl to get ... */ 
  char if_buf[MAXIFR];	 	/* ... interface address */
  struct sockaddr_in sock;
  struct stat statbuf;

  extern int optind;
  extern char *optarg;

  void check_negative(), check_positive(), l_exit();

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

  if ((fd=socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
    tst_resm(TBROK, "socket(): %s (errno %d)", sys_errlist[errno], errno);
    l_exit();
  }

  sock.sin_family = AF_INET;
  sock.sin_port = port;
  sock.sin_addr.s_addr = inet_addr("127.0.0.1");

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

  if ((fd=socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
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

  sock.sin_addr.s_addr = INADDR_ANY;
  check_negative(fd, (struct sockaddr *) -1, sizeof(sock), EFAULT);

  /****	Test case 10 ****/

  check_negative(fd, (struct sockaddr *) &sock, -1, EINVAL);

  /**** Test case 11 ****/

  sock.sin_port = port;
  check_positive(fd, &sock, sock.sin_port, (short) SOCK_DGRAM);

  if (close(fd) < 0) {
    tst_resm(TWARN, "close: %s (errno %d)", sys_errlist[errno], errno);
  }

  /****	Test case 12 ****/

  if ((fd=socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
    tst_resm(TBROK, "socket(): %s (errno %d)", sys_errlist[errno], errno);
    l_exit();
  }

  sock.sin_port = 0;
  check_positive(fd, &sock, sock.sin_port, (short) SOCK_DGRAM);

  if (close(fd) < 0) {
    tst_resm(TWARN, "close: %s (errno %d)", sys_errlist[errno], errno);
  }

  /****	Test case 13 ****/

  if ((fd=socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
    tst_resm(TBROK, "socket(): %s (errno %d)", sys_errlist[errno], errno);
    l_exit();
  }

  sock.sin_addr.s_addr = inet_addr("127.0.0.1");
  check_positive(fd, &sock, sock.sin_port, (short) SOCK_DGRAM);

  if (close(fd) < 0) {
    tst_resm(TWARN, "close: %s (errno %d)", sys_errlist[errno], errno);
  }

  /****	Test case 14 ****/

  if ((fd=socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
    tst_resm(TBROK, "socket(): %s (errno %d)", sys_errlist[errno], errno);
    l_exit();
  }

  sock.sin_port = port;
  check_positive(fd, &sock, sock.sin_port, (short) SOCK_DGRAM);

  /**** Test case 15 ****/

  check_negative(fd, (struct sockaddr *) &sock, sizeof(sock), EINVAL);

  /**** Test case 16 ****/

  if ((fd2=socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
    tst_resm(TBROK, "socket(): %s (errno %d)", sys_errlist[errno], errno);
    l_exit();
  }
  check_negative(fd2, (struct sockaddr *) &sock, sizeof(sock), EADDRINUSE);

  /**** Test case 17 ****/

  /* First get a local interface address using ioctl */

  ifc.ifc_buf = if_buf;
  ifc.ifc_len = sizeof(if_buf);
  if(ioctl(fd2, SIOCGIFCONF, (char *) &ifc) < 0 ) {
    tst_resm(TBROK, "ioctl(): %s (errno %d)", sys_errlist[errno], errno);
  }
  else {
    if (ioctl(fd2, SIOCGIFADDR, (char *) ifc.ifc_req) < 0) {
      tst_resm(TBROK, "ioctl(): %s (errno %d)", sys_errlist[errno], errno);
    }
    else {
      
      /*
       * Now put the local interface address into the sockaddr_in structure
       * and attempt to bind two different sockets to the same port and 
       * different internet addresses
       */

      sock.sin_addr = ((struct sockaddr_in *) &ifc.ifc_req->ifr_addr)->sin_addr;
      check_positive(fd2, &sock, sock.sin_port, (short) SOCK_DGRAM);
    }
  }

  if (close(fd) < 0) {
    tst_resm(TWARN, "close fd: %s (errno %d)", sys_errlist[errno], errno);
  }
  if (close(fd2) < 0) {
    tst_resm(TWARN, "close fd2: %s (errno %d)", sys_errlist[errno], errno);
  }

  /**** Test case 18 ****/

  if ((fd=socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
    tst_resm(TBROK, "socket(): %s (errno %d)", sys_errlist[errno], errno);
  l_exit();
  }

  /*    If uid = 0 (root), change it to 2 (system binaries) */

  if (geteuid() == 0) {
    setuid((uid_t) 2);
  }
  sock.sin_port = IPPORT_RESERVED-1;
  check_negative(fd, (struct sockaddr *) &sock, sizeof(sock), EACCES);

  l_exit();
}
