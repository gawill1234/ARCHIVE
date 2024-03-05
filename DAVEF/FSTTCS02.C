 /*************************************************************************
 *
 *  TCP/IP Testing       Cray Research, Inc.   Eagan, Minnesota
 *
 *  TEST IDENTIFIER      : $Source:$
 *
 *  TEST TITLE           : Socket system calls regression -- fstat()
 *
 *  PARENT DOCUMENT      : Socket System Calls Regression Test Plan
 *
 *  AUTHOR               : Bill Schoofs
 *
 *  CO-PILOT             : Hal Peterson
 *
 *  INITIAL RELEASE      : Unicos 8.0
 *
 *  TEST CASES           : There is a positive test case for each protocol.
 *			   The negative test cases are independent of the
 *			   protocol and are arbitrarily executed only with the
 *			   TCP test.
 *
 *			   RAW test cases
 *
 *			   1) call fstat with valid socket descriptor	positive
 *			   
 *			   TCP test cases
 *
 *			   1) call fstat with descriptor = -1		negative
 *			   2) call fstat with descriptor = OPEN_MAX	negative
 *			   3) call fstat with bad ptr to stat struct    negative
 *			   4) call fstat with valid socket descriptor	positive
 *
 *			   TRACE test cases
 *                      
 *			   1) call fstat with valid socket descriptor	positive
 *
 *                         UDP test cases
 *                      
 *			   1) call fstat with valid socket descriptor	positive
 *                      
 *                         UNIX_D test cases
 *                      
 *			   1) call fstat with valid socket descriptor	positive
 *
 *                         UNIX_S test cases
 *                      
 *			   1) call fstat with valid socket descriptor	positive
 *
 *  CPU TYPES            : CRAY-XMP, CRAY-YMP, CRAY-2, CRAY-C90
 *
 *  INPUT SPECIFICATION  : Usage: fstat -p protocol
 *                         where protocol = RAW, TCP, TRACE, UDP, UNIX_D,
 *                         or UNIX_S
 *
 *  OUTPUT SPECIFICATION : Standard output provided by t_res.c
 *
 *  SPECIAL REQUIREMENTS : RAW and TRACE protocols need to be run as uid=0
 *                         (root).
 *
 *  IMPLEMENTATION NOTES : None
 *
 *  DETAILED DESCRIPTION : 1) Execute fstat() system call for each test case
 *				above.
 *			   2) if (positive test case)
 *				Check to ensure that the st_mode, st_uid, and
 *				st_gid members returned in the stat structure
 *				are valid.  If UNIX domain or TCP protocol,
 *				also check to ensure that the st_blksize and
 *				st_oblksize members are valid.
 *			   3) if (negative test case)
 *                              Check that return value = -1.
 *
 *  KNOWN BUGS           : This test will exit on a system running
 *			   UNICOS 6.1 or older with the TRACE protocol because
 *			   it would panic the system.
 *
 */

#include <errno.h>
#include <signal.h>
#include <sys/param.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include "test.h"
#include "usctest.h"
#include <unistd.h>

#define MAXMSG 200      /* max length of messages */

extern char *sys_errlist[];
extern int Tst_count;
int exp_enos[]={0, 0};
char *TCID="fsttcs02";      /* Test case identifier */
struct stat statbuf2;
void setup(), cleanup();

static struct test_case_t {
    int family;
    int socket_type;
    int positive;
    char *string;
} Test_cases[] = {
  { AF_INET,  SOCK_RAW,    1, "RAW"},
  { AF_INET,  SOCK_STREAM, 0, "TCP"},
  { AF_TRACE, SOCK_RAW,    1, "TRACE"},
  { AF_INET,  SOCK_DGRAM,  1, "UDP"},
  { AF_UNIX,  SOCK_DGRAM,  1, "UNIX_D"},
  { AF_UNIX,  SOCK_STREAM, 1, "UNIX_S"},
};

main(int ac, char **av)
{
  int lc, tc, family, fd, sock_type;
  int ntc = sizeof(Test_cases) / sizeof(struct test_case_t);
  char *msg;
  extern int optind;
  extern char *optarg;
  void check_negative(), check_positive();

  if ((msg=parse_opts(ac, av, (option_t *) NULL)) != (char *) NULL) {
      tst_brkm(TBROK, NULL, "OPTION PARSING ERROR - %s", msg); 
      tst_exit();
  }

  /* Do test setup */
  setup();

  /* set the expected errnos... */
  TEST_EXP_ENOS(exp_enos);

  for (lc=0; TEST_LOOPING(lc); lc++) {
      /* reset Tst_count in case we are looping. */
      Tst_count=0;
      for (tc=0; tc<ntc; tc++) {
          if (Test_cases[tc].positive) {
             check_positive(Test_cases[tc].family, Test_cases[tc]
.socket_type, 0, Test_cases[tc].string);
          } else {
	     /*
	     * First negative test
	     */
             check_negative(-1,&statbuf2);

	     /*
	     * Second negative test
	     */
             check_negative(OPEN_MAX,&statbuf2);

	     /*
	     * Third negative test
	     */
	     if ((fd=socket(Test_cases[tc].family, Test_cases[tc].socket_type, 0)) < 0) {
                tst_brkm(TBROK, NULL, "socket(%d,%d,%d) FAILURE: %d %s\n", Test_cases[tc].family, Test_cases[tc].socket_type, 0, errno, sys_errlist[errno]);
          
	     } else {
	        check_negative(fd,-1);
	        if (close(fd) < 0) {
                   tst_brkm(TBROK, cleanup, "close socket descriptor FAILURE: %d %s\n", errno, sys_errlist[errno]);
	        }
             }
          }
      }
  }
  cleanup();
}

void
setup()
{
    /* capture signals */
    tst_sig(NOFORK, DEF_HANDLER, cleanup);

    /* make a temp directory and cd to it */
    tst_tmpdir();

    /* Pause if that option was specified */
    TEST_PAUSE;
}

void
cleanup()
{
    /*
     * print timing stats if that option was specified.
     * print errno log if that option was specified.
     */
    TEST_CLEANUP;

    /* remove the temp dir */
    tst_rmdir();

    /* exit with return code appropriate for results */
    tst_exit();
}

/* Function to check result of positive test */

void check_positive(c_family,c_sock_type,c_protocol, ptr)
int c_family, c_sock_type, c_protocol;
char *ptr;
{
  int fail=1,sfd;
  struct stat statbuf;

  if ((sfd=socket(c_family, c_sock_type, c_protocol)) < 0) {
    tst_resm(TBROK, "socket(%d,%d,%d) with protocol %s: %d %s", c_family, c_sock_type, c_protocol, ptr, errno, sys_errlist[errno]);
    cleanup();
  }
  TEST(fstat(sfd,&statbuf));
  if (TEST_RETURN < 0) {
      tst_resm(TFAIL, "fstat Failure with Protocol %s : %d %s", ptr, errno, sys_errlist[errno]);
  } else {

      /*
       *  The socket and fstat succeeded.  Next check to see if various members
       *  in the stat structure are valid.  One FAIL message will be output for
       *  all errors found.
       */

      if ((statbuf.st_mode & S_IFSOCK) != S_IFSOCK) {
        tst_resm(TFAIL, "fstat: invalid st_mode value %o with protocol %s",statbuf.st_mode, ptr);
      } else if (statbuf.st_uid != geteuid()) {
        tst_resm(TFAIL, "fstat: invalid st_uid value %d with protocol %s",statbuf.st_uid, ptr);
      } else if (statbuf.st_gid != getegid()) {
        tst_resm(TFAIL, "fstat: invalid st_gid value %d with protocol %s",statbuf.st_gid, ptr);
      } else if ((c_family == AF_UNIX) ||
          ((c_family == AF_INET) && (c_sock_type == SOCK_STREAM))) {
    
            if (statbuf.st_blksize <= 0) {
               tst_resm(TFAIL, "fstat: invalid st_blksize value %d with protocol %s",statbuf.st_blksize, ptr);
            } else if (statbuf.st_oblksize <= 0) {
               tst_resm(TFAIL, "fstat: invalid st_oblksize value %d with protocol %s",statbuf.st_oblksize, ptr);
            } else {
              fail=0;
            }
      } else {
        fail=0;
      }
  }

  /*
  *  If fail is still equal to 0 here, then the test passes
  */

  if (!fail) {
    tst_resm(TPASS, "all stat structure members are valid with protocol %s", ptr);
  }

  if (close(sfd) < 0) {
    tst_resm(TBROK, "close socket file descriptor FAILURE with protocol %s : %d %s", ptr, errno, sys_errlist[errno]);
    cleanup();
  }
}

/* Function to check result of negative test */

void check_negative(sfd,statptr)
int sfd;
struct stat *statptr;
{
  TEST(fstat(sfd,statptr));
  if (TEST_RETURN < 0) {
    tst_resm(TPASS, "fstat: failed as expected with descriptor = %d", sfd);
  }
  else {
    tst_resm(TPASS, "fstat: should have failed with descriptor = %d", sfd);
  }
}
