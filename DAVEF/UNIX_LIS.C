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
 *  TEST TITLE           : Socket system calls regression - UNIX STREAM listen()
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
 *			   protocol and are arbitrarily executed only with the
 *			   TCP listen test.
 *
 *			   1) call listen with a backlog of -1 		positive
 *			   2) call listen with a backlog of 100		positive
 *			   3) call listen with a backlog of 1 and ensure that
 *			      only 2 connections are queued.		positive
 *
 *  CPU TYPES            : CRAY-XMP, CRAY-YMP, CRAY-2, CRAY-C90
 *
 *  INPUT SPECIFICATION  : Usage: unix_listen_s [-f file]
 *
 *                         file is the file name that the
 *                         server is listening on.  Default file is
 *			   "unixs.list"
 *
 *  OUTPUT SPECIFICATION : Standard output provided by t_res.c
 *
 *  SPECIAL REQUIREMENTS : none
 *
 *  IMPLEMENTATION NOTES : none
 *
 *  DETAILED DESCRIPTION : For the first two positive test cases, specify
 *			   backlogs of -1 and 100 and check that the return
 *			   code is successful.
 *
 *			   For the third positive test case, specify a backlog
 *			   of 1 with listen.  Then fork two children to connect
 *			   to the port.  Attempt another connect with the parent
 *			   process.  The last connect should fail with errno
 *			   equal to ECONNREFUSED.
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
#include <sys/un.h>
#include "test.h"
#include <unistd.h>

#define TCID "unix_listen_s"         /* Test case identifier */
#define MAXMSG 200      /* max length of messages */

extern char *sys_errlist[];
char *MSG_LOG="unix_listen_s.log";
char *Tcid=TCID;
char mesg[MAXMSG];      /* t_result message */
char *file="unixs.list";/* the default file name for sun_path */
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

  struct sockaddr_un svr, cli;
  int s_len;

  if (argc > 3) {
    fprintf(stderr, "Usage: %s [-f file]\n",argv[0]);
    exit (1);
  }

  while ((c = getopt(argc, argv, "f:")) != EOF) {

    switch(c) {

    case 'f':
      file = optarg;
      break;

    case '?':
      fprintf(stderr, "Usage: %s [-f file]\n",argv[0]);
      exit (1);
    default:
      ;
    }
  }

  signal(SIGCHLD, finish);
  sprintf(mesg, "server listening on file %s", file);
  t_result(Tcid, 0, TINFO, mesg);

  /*
   *	Positive test case
   */

  svr.sun_family = AF_UNIX;
  strcpy(svr.sun_path, file);
  s_len=strlen(svr.sun_path) + sizeof(AF_UNIX);

  if ((s_sd=socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
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

  cli.sun_family = AF_UNIX;
  strcpy(cli.sun_path, file);
  s_len=strlen(cli.sun_path) + sizeof(AF_UNIX);

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
      if ((c_sd = socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
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
   *	The third connect in the parent should be refused because the incoming
   *	connection queue backlog has been filled.
   */

  sleep(2);			/* wait for the children to connect first */
  if ((c_sd = socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
    sprintf(mesg, "socket(): %s", sys_errlist[errno]);
    t_result(Tcid, ++tnum, TBROK, mesg);
    finish();
  }

  if (connect(c_sd, (struct sockaddr *) &cli, sizeof(cli)) < 0) {
    if (errno == ECONNREFUSED) {
	sprintf(mesg, "Connection refused correctly");
	t_result(Tcid, ++tnum, TPASS, mesg);
    }
    else {
	sprintf(mesg, "connect(): invalid errno %d", errno);
	t_result(Tcid, ++tnum, TBROK, mesg);
    }
  }
  else {
    sprintf(mesg, "connect(): should have received 'Connection refused'");
    t_result(Tcid, ++tnum, TFAIL, mesg);
  }
  if (close(c_sd) < 0) {
    sprintf(mesg, "close: unable to close socket");
    t_result(Tcid, 0, TWARN, mesg);
  }
  finish();
}

void close_n_exit(fd)
int fd;
{
  char tmp[64];

  if(close(fd) < 0) {
    sprintf(mesg, "close: unable to close socket");
    t_result(Tcid, 0, TWARN, mesg);
  }

  sprintf(tmp, "rm -f %s*", file);
  system(tmp);
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
