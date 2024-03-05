 /*************************************************************************
 *
 *  TCP/IP Testing       Cray Research, Inc.   Eagan, Minnesota
 *
 *  TEST IDENTIFIER      : $Source:$
 *
 *  TEST TITLE           : Socket system calls regression -- socketpair()
 *
 *  PARENT DOCUMENT      : Socket System Calls Regression Test Plan
 *
 *  AUTHOR               : Bill Schoofs
 *
 *  CO-PILOT             : Hal Peterson
 *
 *  INITIAL RELEASE      : Unicos 8.0
 *
 *  TEST CASES           : Positive test cases should return 0 and valid socket
 *			   descriptors.  Negative test cases should return -1.
 *			   socketpair is only implemented for the UNIX domain.
 *
 *                         UNIX_D test cases
 *                      
 *                         1) socketpair(AF_UNIX,SOCK_DGRAM,0,sockfd)   positive
 *                         2) socketpair(AF_UNIX,SOCK_DGRAM,-1,sockfd)  negative
 *
 *                         UNIX_S test cases
 *			     Cases 1-7 are independent of the protocol and are
 *			     arbitrarily executed only with the UNIX_S tests.
 *			     Case 1 is an invalid address family.  Cases 2-5
 *			     are valid, but not supported protocols
 *
 *		 	   1) socketpair(0,SOCK_STREAM,0,sockfd)	negative
 *			   2) socketpair(AF_INET,SOCK_STREAM,0,sockfd)	negative
 *			   3) socketpair(AF_INET,SOCK_DGRAM,0,sockfd)	negative
 *			   4) socketpair(AF_INET,SOCK_RAW,0,sockfd)	negative
 *			   5) socketpair(AF_TRACE,SOCK_RAW,0,sockfd)	negative
 *			   6) socketpair(AF_UNIX,0,0,sockfd)		negative
 *			   7) socketpair(AF_UNIX,SOCK_STREAM,0,-1)	negative
 *                         8) socketpair(AF_UNIX,SOCK_STREAM,0,sockfd)  positive
 *                         9) socketpair(AF_UNIX,SOCK_STREAM,-1,sockfd) negative
 *
 *  CPU TYPES            : CRAY-XMP, CRAY-YMP, CRAY-2, CRAY-C90
 *
 *  INPUT SPECIFICATION  : Usage: socketpair -p protocol
 *                         where protocol = UNIX_D or UNIX_S
 *
 *  OUTPUT SPECIFICATION : Standard output provided by t_res.c
 *
 *  SPECIAL REQUIREMENTS : None
 *
 *  IMPLEMENTATION NOTES : None
 *
 *  DETAILED DESCRIPTION : 1) Execute socketpair() system call for each test 
 *				case above.
 *			   2) if (positive test case)
 *				Check to ensure that 0 is returned and that the
 *				value of the descriptors returned is valid.
 *				The test passes if
 *				(0 <= the value of the descriptor <= OPEN_MAX)
 *				and the descriptors are not the same.
 *			   3) if (negative test case)
 *                              Check that return value = -1.
 *
 *  KNOWN BUGS           : None
 *
 */

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
char *TCID="socketpair";
void setup(), cleanup();

static struct test_case_t {
    int family;
    int socket_type;
    int protocol;
    int socketdescriptor;
    int positive;
    char *string;
} Test_cases[] = {
  { AF_UNIX,  SOCK_DGRAM,   0,     0,  1,  "UNIX_D"},
  { AF_UNIX,  SOCK_DGRAM,  -1,     0,  0,  "UNIX_D"},
  { 0,        SOCK_STREAM,  0,     0,  0,  "TCP"},
  { AF_INET,  SOCK_STREAM,  0,     0,  0,  "TCP"},
  { AF_INET,  SOCK_DGRAM,   0,     0,  0,  "UDP"}, 
  { AF_INET,  SOCK_RAW,     0,     0,  0,  "RAW"}, 
  { AF_TRACE, SOCK_RAW,     0,     0,  0,  "TRACE"}, 
  { AF_UNIX,  0,            0,     0,  0,  "UNIX_D"}, 
  { AF_UNIX,  SOCK_STREAM,  0,    -1,  0,  "UNIX_S"}, 
  { AF_UNIX,  SOCK_STREAM,  0,     0,  1,  "UNIX_S"}, 
  { AF_UNIX,  SOCK_STREAM, -1,     0,  0,  "UNIX_S"}, 
};

main(int ac, char **av)
{
  int lc, tc, sockfd[2];
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
              check_positive(Test_cases[tc].family, Test_cases[tc].socket_type, Test_cases[tc].protocol,sockfd, Test_cases[tc].string);
          } else if (Test_cases[tc].socketdescriptor == -1) {
              check_negative(Test_cases[tc].family, Test_cases[tc].socket_type, Test_cases[tc].protocol,-1, Test_cases[tc].string);
          } else {
              check_negative(Test_cases[tc].family, Test_cases[tc].socket_type, Test_cases[tc].protocol,sockfd, Test_cases[tc].string);
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

void check_positive(c_family,c_sock_type,c_protocol,c_sfd, ptr)
int c_family, c_sock_type, c_protocol;
int *c_sfd;
char *ptr;
{
  int i, ret_value, pass=1;

  TEST(socketpair(c_family, c_sock_type, c_protocol, c_sfd));
  ret_value=TEST_RETURN;
  if (ret_value < 0) {
    tst_resm(TFAIL, "socketpair(%d,%d,%d,%d) with protocol %s : %d %s", c_family, c_sock_type,
	    c_protocol, c_sfd, ptr, errno, sys_errlist[errno]);
  } else {

/* Check each of the descriptors returned for validity */

    for(i=0;i<2;i++) {
      if ( 0 > c_sfd[i] || c_sfd[i] >= OPEN_MAX)
	pass=0;
      if (close(c_sfd[i]) < 0) {
         tst_resm(TBROK, "close: unable to close socket with protocol %s", ptr);
      }
    }
    if (c_sfd[0] == c_sfd[1])
      pass=0; 
    if (pass) {
      tst_resm(TPASS, "socketpair(%d,%d,%d,%d) positive test with protocol %s. Descriptors = %d and %d",
	      c_family, c_sock_type, c_protocol, c_sfd, ptr, c_sfd[0], c_sfd[1]);
    } else {
      tst_resm(TFAIL, "socketpair(%d,%d,%d,%d) with protocol %s - Invalid descriptor values %d and %d.",
              c_family, c_sock_type, c_protocol, c_sfd, ptr, c_sfd[0], c_sfd[1]);
    }
  }
}

/* Function to check result of negative test */

void check_negative(c_family,c_sock_type,c_protocol,c_sfd, ptr)
int c_family, c_sock_type, c_protocol;
int *c_sfd;
char *ptr;
{
  int i, ret_value;

  TEST(socketpair(c_family, c_sock_type, c_protocol, c_sfd));
  ret_value=TEST_RETURN;
  if (ret_value != -1) {
     tst_resm(TFAIL, "socketpair(%d,%d,%d,%d) should have failed with protocol %s.", c_family,
	    c_sock_type, c_protocol, c_sfd, ptr);
     for (i=0;i<2;i++) {
         if (close(c_sfd[i]) < 0) {
            tst_resm(TBROK, "close: unable to close socket with protocol %s", ptr);
         }
     }
  }
  else {
     tst_resm(TPASS, "socketpair(%d,%d,%d,%d) negative test with protocol %s." , c_family,
	    c_sock_type, c_protocol, c_sfd, ptr);
  }
}
