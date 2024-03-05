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
 *  TEST TITLE           : Socket system calls regression -- TCP listen()
 *
 *  PARENT DOCUMENT      : Socket System Calls Regression Test Plan
 *
 *  AUTHOR               : Bill Schoofs
 *
 *  CO-PILOT             : Hal Peterson
 *
 *  INITIAL RELEASE      : Unicos 8.0
 *
 *  TEST CASES           : The negative test cases are independent of the
 *			   protocol and are arbitrarily executed only with this
 *			   TCP listen test.
 *
 *			   1) call listen with descriptor = -1		negative
 *			   2) call listen with descriptor = OPEN_MAX	negative
 *			   3) call listen with valid descriptor for an open
 *			      file that is NOT a socket			negative
 *			   4) call listen with a socket of type SOCK_DGRAM
 *									negative
 *			   5) call listen with a backlog of -1 		positive
 *			   6) call listen with a backlog of 100		positive
 *			   7) call listen with a backlog of 1 and ensure that
 *			      only 2 connections are queued.		positive
 *
 *  CPU TYPES            : CRAY-XMP, CRAY-YMP, CRAY-2, CRAY-C90
 *
 *  INPUT SPECIFICATION  : Usage: tcp_listen [-P port]
 *                         port is the port number that the program will be
 *			   binding to.  The default port number is 30499.
 *
 *  OUTPUT SPECIFICATION : Standard output provided by t_res.c
 *
 *  SPECIAL REQUIREMENTS : none
 *
 *  IMPLEMENTATION NOTES : This test will take in excess of one minute to run
 *			   because the connect() call waits for the ETIMEDOUT
 *			   timeout to occur.
 *
 *  DETAILED DESCRIPTION : For the negative test cases, check that the return
 *			   value = -1 and that the errno is correct.
 *
 *			   For the first two positive test cases, specify
 *			   backlogs of -1 and 100 and check that the return
 *			   code is successful.
 *
 *			   For the third positive test case, specify a backlog
 *			   of 1 with listen.  Then fork two children to connect
 *			   to the port.  Attempt another connect with the parent
 *			   process.  The last connect should fail with errno
 *			   equal to ETIMEDOUT.  (See known bugs)
 *
 *  KNOWN BUGS           : It is a known bug of the listen system call that the
 *			   backlog is limited (silently) to five pending
 *			   connection requests.  No error message is issued when
 *			   the number entered in the backlog argument is higher
 *			   than 5.  As a result, The positive test cases with
 *			   backlogs of -1 and 100 simply check for a successful
 *			   return code.
 *
 *			   *** The kernel actually adds a "fudge factor" to the 
 *			   backlog value.  A backlog of 1 results in a maximum
 *			   incoming connection queue length of 2.
 */

/*
 * Revision control information. 
 */
 static char Revision[] = "$Header:$";

#include <errno.h>
#include <sys/types.h>
#include <netdb.h>
#include <netinet/in.h>
#include <signal.h>
#include <sys/param.h>
#include <sys/socket.h>
#include "test.h"
#include <unistd.h>

#define TCID "tcp_listen"         /* Test case identifier */
#define MAXMSG 200      /* max length of messages */

extern char *sys_errlist[];
char *MSG_LOG="tcp_listen.log";
char *Tcid=TCID;
char mesg[MAXMSG];      /* t_result message */
int port=30499;         /* the default port number */
int s_sd, c_sd;	        /* socket descriptors */
int f, childpid[2];	/* fork pids */
int tnum=0;
void t_result();
void t_print();
void close_n_exit();
void finish();

main(int argc, char *argv[])
{
  int c,i;
  extern int optind;
  extern char *optarg;

  struct sockaddr_in svr, cli;
  struct hostent *hp;

  void check_negative();

  if (argc > 3) {
    fprintf(stderr, "Usage: %s [-P port]\n",argv[0]);
    exit (1);
  }

  while ((c = getopt(argc, argv, "P:")) != EOF) {

    switch(c) {

    case 'P':
      port = atoi(optarg);
      if (port < 1023 || port > 65535) {
        fprintf(stderr, "[-P port] -- illegal port number\n");
        exit (1);
      }
      break;

    case '?':
      fprintf(stderr, "Usage: %s [-P port]\n",argv[0]);
      exit (1);
    default:
      ;
    }
  }

  signal(SIGCHLD, finish);
  sprintf(mesg, "server listening on port %d", port);
  t_result(Tcid, 0, TINFO, mesg);

  /*
   *	Negative test cases
   */

  check_negative(-1, SOCK_STREAM, EBADF);

  check_negative(OPEN_MAX, SOCK_STREAM, EBADF);

  check_negative(STDIN_FILENO, SOCK_STREAM, ENOTSOCK);

  check_negative(0, SOCK_DGRAM, EOPNOTSUPP);

  /*
   *	Positive test cases
   */

  svr.sin_family = AF_INET;
  svr.sin_port = port;
  svr.sin_addr.s_addr = 0;

  if ((s_sd=socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    sprintf(mesg, "socket(): %s", sys_errlist[errno]);
    t_result(Tcid, ++tnum, TBROK, mesg);
    t_exit();
  }

  while (bind(s_sd, (struct sockaddr *) &svr, sizeof(svr)) < 0) {
    sprintf(mesg, "waiting on bind...");
    t_result(Tcid, 0, TINFO, mesg);
    sleep(1);
  }

  if (listen(s_sd, -1) < 0) {
    sprintf(mesg, "listen(): %s", sys_errlist[errno]);
    t_result(Tcid, ++tnum, TFAIL, mesg);
  }
  else {
    sprintf(mesg, "successful with backlog = %d", -1);
    t_result(Tcid, ++tnum, TPASS, mesg);
  }

  if (listen(s_sd, 100) < 0) {
    sprintf(mesg, "listen(): %s", sys_errlist[errno]);
    t_result(Tcid, ++tnum, TFAIL, mesg);
  }
  else {
    sprintf(mesg, "successful with backlog = %d", 100);
    t_result(Tcid, ++tnum, TPASS, mesg);
  }

  if (listen(s_sd, 1) < 0) {
    sprintf(mesg, "listen(): %s", sys_errlist[errno]);
    t_result(Tcid, ++tnum, TFAIL, mesg);
    close_n_exit(s_sd);
  }

  hp = gethostbyname("localhost");
  cli.sin_family = AF_INET;
  cli.sin_port = port;
  bcopy(hp->h_addr_list[0], &cli.sin_addr, hp->h_length);

  /*
   *	Fork two children to do the first two connects.
   */

  for(i=0; i < 2 ; i++) {
    if ((f=fork()) < 0) {
      sprintf(mesg, "fork(): %s", sys_errlist[errno]);
      t_result(Tcid, ++tnum, TBROK, mesg);
      finish();
    }
    if (f == 0) {
      /* Child process */
      if ((c_sd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        sprintf(mesg, "socket(): %s", sys_errlist[errno]);
        t_result(Tcid, ++tnum, TBROK, mesg);
        exit(1);
      }
  
      if (connect(c_sd, (struct sockaddr *) &cli, sizeof(cli)) < 0) {
        sprintf(mesg, "connect(): %s", sys_errlist[errno]);
        t_result(Tcid, ++tnum, TBROK, mesg);
        if (close(c_sd) < 0) {
	  sprintf(mesg, "close: unable to close socket");
	  t_result(Tcid, 0, TWARN, mesg);
        }
        exit(1);
      }
  
      sleep(1000000);	/* wait to be killed by the parent */
      exit(1);
    }
    else {
      /* Parent process */
      childpid[i] = f;
    }
  }

  /*
   *	The third connect in the parent should timeout because the incoming
   *	connection queue backlog has been filled.
   */

  sleep(2);			/* wait for the children to connect first */
  if ((c_sd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    sprintf(mesg, "socket(): %s", sys_errlist[errno]);
    t_result(Tcid, ++tnum, TBROK, mesg);
    finish();
  }

  if (close(c_sd) < 0) {
    sprintf(mesg, "close: unable to close socket");
    t_result(Tcid, 0, TWARN, mesg);
  }
  finish();
}

/* Function to check result of negative test */

void check_negative(sfd,sock_type,c_errno)
int sfd, sock_type, c_errno;
{
  struct sockaddr_in c_sock;

  c_sock.sin_family = AF_INET;
  c_sock.sin_port = port;
  c_sock.sin_addr.s_addr = 0;

  if ( sock_type == SOCK_DGRAM ) {
    /*
     *	Need to open and bind a socket for only one negative test case.
     *	The other negative test cases all use invalid socket descriptors.
     */

    if ((sfd=socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
      sprintf(mesg, "socket(): %s", sys_errlist[errno]);
      t_result(Tcid, ++tnum, TBROK, mesg);
      t_exit();
    }

    while (bind(sfd, (struct sockaddr *) &c_sock, sizeof(c_sock)) < 0) {
      sprintf(mesg, "waiting on bind...");
      t_result(Tcid, 0, TINFO, mesg);
      sleep(1);
    }
  }
    
  if (listen(sfd, 5) < 0) {
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

  if ( sock_type == SOCK_DGRAM ) {
    if (close(sfd) < 0) {
      sprintf(mesg, "close: unable to close socket");
      t_result(Tcid, 0, TWARN, mesg);
    }
  }
}

void close_n_exit(fd)
int fd;
{
  if(close(fd) < 0) {
    sprintf(mesg, "close: unable to close socket");
    t_result(Tcid, 0, TWARN, mesg);
  }
  t_exit();
}

void finish()
{
  int j;

  signal(SIGCHLD, SIG_IGN);
  for(j = 0; j < 2; j++) {
    if (childpid[j])
      kill(childpid[j], 9);
  }
  close_n_exit(s_sd);
}
