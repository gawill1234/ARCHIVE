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
 *  TEST TITLE           : Socket system calls regression -- getsockname()
 *
 *  PARENT DOCUMENT      : Socket System Calls Regression Test Plan
 *
 *  AUTHOR               : Bill Schoofs
 *
 *  CO-PILOT             : Hal Peterson
 *
 *  INITIAL RELEASE      : Unicos 8.0
 *
 *  TEST CASES           : There are test cases for only the supported
 *			   protocols: RAW, TCP, and UDP.  The negative test
 *			   cases are independent of the protocol and are
 *			   arbitrarily executed only with the TCP test.
 *
 *			   RAW test cases
 *
 *			   1) call getsockname after binding with address
 *			      INADDR_ANY				positive
 *			   
 *			   TCP test cases
 *
 *			   1) call getsockname with descriptor = -1	negative
 *			   2) call getsockname with descriptor = OPEN_MAX
 *									negative
 *			   3) call getsockname with bad ptr to sockaddr struct
 *									negative
 *			   4) call getsockname with valid descriptor for an open
 *			      file that is NOT a socket			negative
 *			   5) call getsockname with bad ptr to namelen  negative
 *			   6) call getsockname after binding with address
 *			      INADDR_ANY				positive
 *			   7) call getsockname after binding with address
 *			      localhost					positive
 *
 *			   UDP test cases
 *                      
 *			   1) call getsockname after binding with address
 *			      INADDR_ANY				positive
 *			   2) call getsockname after binding with address
 *			      localhost					positive
 *
 *  CPU TYPES            : CRAY-XMP, CRAY-YMP, CRAY-2, CRAY-C90
 *
 *  INPUT SPECIFICATION  : Usage: getsockname -p protocol [-P port]
 *                         The protocol can be RAW, TCP, or UDP.  port is the
 *			   port number that the program will be binding to.  The
 *			   default port number is 30399.
 *
 *  OUTPUT SPECIFICATION : Standard output provided by t_res.c
 *
 *  SPECIAL REQUIREMENTS : RAW protocol needs to be run as uid=0 (root).
 *
 *  IMPLEMENTATION NOTES : At the time this test was written UNICOS did not 
 *			   support UNIX domain for getsockname.  That support
 *			   is planned for a future release.
 *
 *  DETAILED DESCRIPTION : 1) Execute getsockname() system call for each test
 *				case above.
 *			   2) if (positive test case)
 *				Check to ensure that all members returned in
 *				the sockaddr_in structure are valid.  Check to
 *				ensure that the namelen returned is the size of
 *				the sockaddr_in structure.
 *			   3) if (negative test case)
 *                              Check that return value = -1.
 *
 *  KNOWN BUGS           : None
 *
 */

/*
 * Revision control information. 
 */
 static char Revision[] = "$Header:$";

#include <errno.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/param.h>
#include <sys/socket.h>
#include "test.h"
#include <unistd.h>

#define TCID "getsockname"         /* Test case identifier */
#define MAXMSG 200      /* max length of messages */

extern char *sys_errlist[];
char *MSG_LOG="getsockname.log";
char *Tcid=TCID;
char mesg[MAXMSG];      /* t_result message */
int family, fd, sock_type;
int port=30399;         /* the default port number */
int tnum=0;
struct sockaddr_in sock, sock_got;
int sock_len = sizeof(sock);
void t_result();
void t_print();

main(int argc, char *argv[])
{
  int c;

  extern int optind;
  extern char *optarg;

  void check_negative(), check_positive();

  if (argc < 3) {
    fprintf(stderr, "Usage: %s -p protocol [-P port]\n",argv[0]);
    exit (1);
  }

  while ((c = getopt(argc, argv, "p:P:")) != EOF) {

    switch(c) {

    case 'P':
      if (argc < 5) {
        fprintf(stderr, "Usage: %s -p protocol [-P port]\n",argv[0]);
        exit (1);
      }
      port = atoi(optarg);
      if (port < 1023 || port > 65535) {
        fprintf(stderr, "[-P port] -- illegal port number\n");
        exit (1);
      }
      break;

    case 'p':
      sprintf(mesg, "Running tests for getsockname -p %s", optarg);
      t_result(Tcid, 0, TINFO, mesg);

      if (!strcmp(optarg , "RAW")) {
        family = AF_INET;
        sock_type = SOCK_RAW;
      }
      else if (!strcmp(optarg , "TCP")) {
        family = AF_INET;
        sock_type = SOCK_STREAM;
      }
      else if (!strcmp(optarg , "UDP")) {
        family = AF_INET;
        sock_type = SOCK_DGRAM;
      }
      else {
        fprintf(stderr, "Error: protocol must be RAW, TCP, or UDP\n");
        exit (1);
      }
      break;
    case '?':
      fprintf(stderr, "Usage: %s -p protocol [-P port]\n",argv[0]);
      exit (1);
    default:
      ;
    }
  }

  sprintf(mesg, "Running test using port %d", port);
  t_result(Tcid, 0, TINFO, mesg);

  if(sock_type == SOCK_STREAM) {

    /*
     * Negative test cases only when -p TCP
     */

    if ((fd=socket(family, sock_type, 0)) < 0) {
      sprintf(mesg, "socket() unsuccessful: %s", sys_errlist[errno]);
      t_result(Tcid, ++tnum, TBROK, mesg);
      t_exit();
    }

    sock.sin_family = AF_INET;
    sock.sin_port = port;
    sock.sin_addr.s_addr = INADDR_ANY;
    while (bind(fd, (struct sockaddr *) &sock, sizeof(sock)) < 0) {
      sprintf(mesg, "waiting on bind...\n");
      t_result(Tcid, 0, TINFO, mesg);
      sleep(1);
    }
    check_negative(-1, &sock, &sock_len, EBADF);

    check_negative(OPEN_MAX, &sock, &sock_len, EBADF);

    check_negative(fd, -1, &sock_len, EFAULT);

    check_negative(STDIN_FILENO, &sock, &sock_len, ENOTSOCK);

    check_negative(fd, &sock, -1, EFAULT);

    if (close(fd) < 0) {
      sprintf(mesg, "close: unable to close socket");
      t_result(Tcid, 0, TWARN, mesg);
    }
  }

  /* Positive test cases */

  check_positive(INADDR_ANY);

  if (sock_type != SOCK_RAW) {
    check_positive(inet_addr("127.0.0.1"));
  }

  t_exit();
}

/* Function to check result of positive test */

void check_positive(c_address)
unsigned long c_address;
{
  int fail=0;

  if ((fd=socket(family, sock_type, 0)) < 0) {
    sprintf(mesg, "socket() unsuccessful: %s", sys_errlist[errno]);
    t_result(Tcid, ++tnum, TBROK, mesg);
    t_exit();
  }

  sock.sin_family = AF_INET;
  sock.sin_port = port;
  sock.sin_addr.s_addr = c_address;
  while (bind(fd, (struct sockaddr *) &sock, sizeof(sock)) < 0) {
    sprintf(mesg, "waiting on bind...\n");
    t_result(Tcid, 0, TINFO, mesg);
    sleep(1);
  }

  if (getsockname(fd, (struct sockaddr *) &sock_got, &sock_len) < 0) {
    sprintf(mesg, "%s", sys_errlist[errno]);
    t_result(Tcid, ++tnum, TFAIL, mesg);
  }
  
  /*
   * Check to see if various members in the sockaddr_in structure are valid.
   * Check to see if the namelen returned is valid.  One FAIL message will be
   * output for all errors found.
   */

  if(sock_got.sin_len != sizeof(struct sockaddr_in)) {
    sprintf(mesg, "invalid sin_len value %d", sock_got.sin_len);
    t_result(Tcid, 0, TWARN, mesg);
    fail=1;
  }

  if(sock_got.sin_family != sock.sin_family) {
    sprintf(mesg, "invalid sin_family value %d", sock_got.sin_family);
    t_result(Tcid, 0, TWARN, mesg);
    fail=1;
  }

  if(sock_got.sin_port != sock.sin_port) {
    sprintf(mesg, "invalid sin_port value %d", sock_got.sin_port);
    t_result(Tcid, 0, TWARN, mesg);
    fail=1;
  }

  if(sock_got.sin_addr.s_addr != sock.sin_addr.s_addr) {
    sprintf(mesg, "invalid sin_addr.s_addr value %d",
	    sock_got.sin_addr.s_addr);
    t_result(Tcid, 0, TWARN, mesg);
    fail=1;
  }

  if(sock_len != sizeof(sock_got)) {
  sprintf(mesg, "invalid namelen value %d", sock_len);
  t_result(Tcid, 0, TWARN, mesg);
  fail=1;
  }

  /*
   *  If fail is still equal to 0 here, then the test passes
   */

  if (!fail) {
    sprintf(mesg, "Internet address = %s", inet_ntoa(sock_got.sin_addr));
    t_result(Tcid, ++tnum, TPASS, mesg);
  }
  else {
    sprintf(mesg, "See previous WARN message[s] for details of errors");
    t_result(Tcid, ++tnum, TFAIL, mesg);
  }

  if (close(fd) < 0) {
    sprintf(mesg, "close: unable to close socket");
    t_result(Tcid, 0, TWARN, mesg);
  }
}

/* Function to check result of negative test */

void check_negative(sfd,nameptr,lenptr,c_errno)
int c_errno, sfd;
struct sockaddr *nameptr;
int *lenptr;
{
  if ((getsockname(sfd,nameptr,lenptr)) < 0) {
    if (c_errno == errno) {
      sprintf(mesg, "unsuccessful as expected: %s",
	      sys_errlist[errno]);
      t_result(Tcid, ++tnum, TPASS, mesg);
    }
    else {
      sprintf(mesg, "wrong errno value %d", errno);
      t_result(Tcid, ++tnum, TFAIL, mesg);
    }
  }
  else {
    sprintf(mesg, "should have failed - negative test", sfd);
    t_result(Tcid, ++tnum, TFAIL, mesg);
  }
}
