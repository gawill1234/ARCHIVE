 /*************************************************************************
 *
 *  TCP/IP Testing       Cray Research, Inc.   Eagan, Minnesota
 *
 *  TEST IDENTIFIER      : $Source:$
 *
 *  TEST TITLE           : Socket system calls regression -- socket()
 *
 *  PARENT DOCUMENT      : Socket System Calls Regression Test Plan
 *
 *  AUTHOR               : Bill Schoofs
 *
 *  CO-PILOT             : Hal Peterson
 *
 *  INITIAL RELEASE      : Unicos 8.0
 *
 *  TEST CASES           : Positive test cases should return a valid socket
 *			   descriptor.  Negative test cases should return -1.
 *			   There is no negative test case for RAW or TRACE
 *			   protocols because any value is allowed for the
 *			   third parameter of socket() when the second 
 *			   parameter is SOCK_RAW.
 *
 *			   RAW test cases
 *
 *			   1) socket(AF_INET,SOCK_RAW,IPPROTO_RAW)	positive
 *			   2) socket(AF_INET,SOCK_RAW,IPPROTO_ICMP)	positive
 *			   3) socket(AF_INET,SOCK_RAW,IPPROTO_EGP)	positive
 *			   4) socket(AF_INET,SOCK_RAW,0)  		positive
 *			   
 *			   TCP test cases
 *			     Cases 2 and 3 are independent of the protocol and
 *			     are arbitrarily executed only with the TCP tests.
 *
 *			   1) socket(AF_INET,SOCK_STREAM,IPPROTO_TCP)	positive
 *		 	   2) socket(0,SOCK_STREAM,0)			negative
 *			   3) socket(AF_INET,0,0)			negative
 *			   4) socket(AF_INET,SOCK_STREAM,0)  		positive
 *			   5) socket(AF_INET,SOCK_STREAM,-1)		negative
 *
 *			   TRACE test cases
 *                      
 *			   1) socket(AF_TRACE,SOCK_RAW,0)		positive
 *
 *                         UDP test cases
 *                      
 *                         1) socket(AF_INET,SOCK_DGRAM,IPPROTO_UDP)    positive
 *                         2) socket(AF_INET,SOCK_DGRAM,0)		positive
 *                         3) socket(AF_INET,SOCK_DGRAM,-1)   		negative
 *                      
 *                         UNIX_D test cases
 *                      
 *                         1) socket(AF_UNIX,SOCK_DGRAM,0)              positive
 *                         2) socket(AF_UNIX,SOCK_DGRAM,-1)             negative
 *
 *                         UNIX_S test cases
 *                      
 *                         1) socket(AF_UNIX,SOCK_STREAM,0)             positive
 *                         2) socket(AF_UNIX,SOCK_STREAM,-1)            negative
 *
 *  CPU TYPES            : CRAY-XMP, CRAY-YMP, CRAY-2, CRAY-C90
 *
 *  INPUT SPECIFICATION  : Usage: socket -p protocol
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
 *  DETAILED DESCRIPTION : 1) Execute socket() system call for each test case
 *				above.
 *			   2) if (positive test case)
 *				Check to ensure that the value of the
 *                              descriptor returned is valid.  The test passes
 *                              if 0 <= the value of the descriptor <= OPEN_MAX.
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
#include <signal.h>
#include <sys/param.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include "test.h"
#include "usctest.h"


extern char *sys_errlist[];
extern int Tst_count;
int exp_enos[]={0, 0};
char *TCID="socket";
void setup(), cleanup();

static struct test_case_t {
    int family;
    int socket_type;
    int protocol;
    int positive;
    char *string;
} Test_cases[] = {
  { AF_INET,  SOCK_RAW,    IPPROTO_RAW,  1, "RAW"},
  { AF_INET,  SOCK_RAW,    IPPROTO_ICMP, 1, "RAW"},
  { AF_INET,  SOCK_RAW,    IPPROTO_EGP,  1, "RAW"},
  { AF_INET,  SOCK_RAW,    0,            1, "RAW"},
  { AF_INET,  SOCK_STREAM, IPPROTO_TCP,  1, "TCP"},
  { 0,        SOCK_STREAM, 0,            0, "TCP"},
  { AF_INET,  0,           0,            0, "TCP"},
  { AF_INET,  SOCK_STREAM, 0,            1, "TCP"},
  { AF_INET,  SOCK_STREAM, -1,           0, "TCP"},
  { AF_TRACE, SOCK_RAW,    0,            1, "TRACE"},
  { AF_INET,  SOCK_DGRAM,  IPPROTO_UDP,  1, "UDP"},
  { AF_INET,  SOCK_DGRAM,  0,            1, "UDP"},
  { AF_UNIX,  SOCK_DGRAM,  0,            1, "UNIX_D"},
  { AF_UNIX,  SOCK_DGRAM,  -1,           0, "UNIX_D"},
  { AF_UNIX,  SOCK_STREAM, 0,            1, "UNIX_S"},
  { AF_UNIX,  SOCK_STREAM, -1,           0, "UNIX_S"},
};

main(int ac, char **av)
{
  int lc, tc;
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
             check_positive(Test_cases[tc].family, Test_cases[tc].socket_type, Test_cases[tc].protocol, Test_cases[tc].string);
          } else {
             check_negative(Test_cases[tc].family, Test_cases[tc].socket_type, Test_cases[tc].protocol, Test_cases[tc].string);
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
  int sfd;

  TEST(socket(c_family, c_sock_type, c_protocol));
  sfd=TEST_RETURN;
  if (sfd < 0) {
    tst_resm(TBROK, "socket(%d,%d,%d) with protocol %s : %d %s", c_family, c_sock_type, c_protocol,
            ptr, errno, sys_errlist[errno]);
  }
  else if ( 0 <= sfd && sfd < OPEN_MAX) {
         tst_resm(TPASS, "socket(%d,%d,%d) positive test with protocol %s. Descriptor = %d",
		c_family, c_sock_type, c_protocol, ptr, sfd);
         if (close(sfd) < 0) {
            tst_resm(TBROK, "close: unable to close socket with protocol %s", ptr);
         }
       } else {
            tst_resm(TFAIL, "socket(%d,%d,%d) with protocol %s - Invalid descriptor value %d.",
         c_family, c_sock_type, c_protocol, ptr, sfd);
       }
}

/* Function to check result of negative test */

void check_negative(c_family,c_sock_type,c_protocol,ptr)
int c_family, c_sock_type, c_protocol;
char *ptr;
{
  int sfd;

  TEST(socket(c_family, c_sock_type, c_protocol));
  sfd=TEST_RETURN;
  if (sfd != -1) {
     tst_resm(TFAIL, "socket(%d,%d,%d) should have failed with protocol %s. Descriptor = %d",
	    c_family, c_sock_type, c_protocol, ptr, sfd);
    if (close(sfd) < 0) {
      tst_resm(TBROK, "close: unable to close socket with protocol %s", ptr);
    }
  } else {
     tst_resm(TPASS, "socket(%d,%d,%d) negative test with protocol %s" , c_family, c_sock_type,
	    c_protocol, ptr);
  }
}
