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
 *  TEST TITLE           : Socket system calls regression - UNIX STREAM bind()
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
 *			   4) bad ptr to sockaddr struct		negative
 *			   5) bad namelen				negative
 *			   6) pathname /this/does/not/exist		negative
 *			   7) valid arguments				positive
 *			   8) bind same socket to the same file twice	negative
 *
 *  CPU TYPES            : CRAY-XMP, CRAY-YMP, CRAY-2, CRAY-C90, CRAY-EL
 *
 *  INPUT SPECIFICATION  : Usage: unix_bind_s [-f file]
 *			   file is the file that the program will be
 *			   binding to.  The default is unixs.bind.
 *
 *  OUTPUT SPECIFICATION : Standard output provided by cuts library.
 *
 *  SPECIAL REQUIREMENTS : none
 *
 *  IMPLEMENTATION NOTES : At the time this test was written UNICOS did not
 *                         support UNIX domain for getsockname.  That support
 *                         is planned for a future release.  Then getsockname
 *			   could be used to verify a positive test as it is
 *			   for the TCP protocol test.
 *
 *                         The flexibility of changing the file name is
 *                         provided to allow multiple copies of the test to run
 *                         without contention.  The default file name is the
 *                         default file name used in the corresponding TCP/IP
 *                         multithreading test.
 *
 *			   This test does not include negative test cases for
 *			   many filesystem related errors which may occur
 *			   because these errors do not originate in networking
 *			   code.  One filesystem related negative test case
 *			   is included to ensure that the error interface
 *			   between networking and filesystem code is
 *			   functioning correctly.
 *
 *  DETAILED DESCRIPTION : For the negative test cases, check that the return
 *			   value = -1 and that the errno is correct.
 *
 *			   For the positive test case, use the stat()
 *			   system call after the bind.  Ensure that the 
 *			   S_IFSOCK bits in the mode field of the stat structure
 *			   returned by stat() are on.
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
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/un.h>
#include "test.h"
#include <unistd.h>

extern char *sys_errlist[];
char *TCID= "unix_bind_s";	/* Test case identifier */
int TST_TOTAL = 8;              /* Total number of test cases */

main(int argc, char *argv[])
{
  int c;
  int fd, fd_null;        /* file and socket descriptors */
  char *file="unixs.bind";/* the default file name for sun_path */
  extern int optind;
  extern char *optarg;

  struct sockaddr_un sock;
  int socklen;
  struct stat statbuf;

  void check_negative(), l_exit();

  while ((c = getopt(argc, argv, "f:")) != EOF) {

    switch(c) {

    case 'f':
      file = optarg;
      break;

    case '?':
      tst_resm(TBROK, "Usage: %s [-f file]\n",argv[0]);
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
  tst_resm(TINFO, "will bind to file %s", file);

  if ((fd=socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
    tst_resm(TBROK, "socket(): %s (errno %d)", sys_errlist[errno], errno);
    l_exit();
  }

  sock.sun_family = AF_UNIX;
  strcpy(sock.sun_path, file);
  socklen=strlen(sock.sun_path) + sizeof(AF_UNIX);

  /****	Test case 1 ****/

  check_negative(-1, (struct sockaddr *) &sock, socklen, EBADF);

  /****	Test case 2 ****/

  check_negative((int) sysconf(_SC_OPEN_MAX), (struct sockaddr *) &sock,
		 socklen, EBADF);

  /****	Test case 3 ****/

  if (fd_null=open("/dev/null", O_RDONLY) < 0) {
    tst_resm(TBROK, "open(): %s (errno %d)", sys_errlist[errno], errno);
  }
  else {
    check_negative(fd_null, (struct sockaddr *) &sock, socklen, ENOTSOCK);
    if (close(fd_null) < 0) {
      tst_resm(TWARN, "close(): %s (errno %d)", sys_errlist[errno], errno);
    }
  }

  /****	Test case 4 ****/

  check_negative(fd, (struct sockaddr *) -1, socklen, EFAULT);

  /****	Test case 5 ****/

  check_negative(fd, (struct sockaddr *) &sock, -1, EINVAL);

  /****	Test case 6 ****/

  strcpy(sock.sun_path, "/this/does/not/exist");
  check_negative(fd, (struct sockaddr *) &sock,
		 strlen(sock.sun_path) + sizeof(AF_UNIX), ENOENT);
  strcpy(sock.sun_path, file);

  /****	Test case 7 ****/

  if (bind(fd, (struct sockaddr *) &sock, socklen) < 0) {
    tst_resm(TFAIL, "bind (): %s (errno %d)", sys_errlist[errno], errno);
  }
  else {
    if (stat(file, &statbuf) < 0) {
      tst_resm(TFAIL, "stat(): %s (errno %d)", sys_errlist[errno], errno);
    }
    else {
      if ((statbuf.st_mode & S_IFSOCK) != S_IFSOCK) {
        tst_resm(TFAIL, "file %s is not a socket", file);
      }
      else {
        tst_resm(TPASS, "successful with file %s", file);
      }
    }
  }

  /****	Test case 8 ****/

  check_negative(fd, (struct sockaddr *) &sock, socklen, EINVAL);

  if (close(fd) < 0) {
    tst_resm(TWARN, "close: %s (errno %d)", sys_errlist[errno], errno);
  }
  if (unlink(file) < 0) {
    tst_resm(TWARN, "unlink(%s): %s (errno %d)", file, sys_errlist[errno],
	     errno);
  }

  l_exit();
}
