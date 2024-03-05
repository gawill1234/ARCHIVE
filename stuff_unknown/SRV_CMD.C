#include <stdio.h>
#include <unistd.h>
#include <sys/param.h>
#include <time.h>
#include "test_clnt_srv.h"
#include "test.h"

#ifndef HZ
#define HZ CLK_TCK
#endif

#include "test_macros.h"

extern int pass_msg, fail_msg, verbose, do_verify;
extern struct sockaddr_in g_serv_addr;

/******************************************************/
/*  CHANGE_VERIFY

    Change verification configuration to the opposite.

    RETURN:
       none
*/
void change_verify()
{
   if (do_verify)
      do_verify = 0;
   else
      do_verify = 1;
}

/******************************************************/
/*  CHANGE_PASS_MSG

    Change passing message configuration to the opposite.

    RETURN:
       none
*/
void change_pass_msg()
{
   if (pass_msg)
      pass_msg = 0;
   else
      pass_msg = 1;
}

/******************************************************/
/*  CHANGE_FAIL_MSG

    Change failure message configuration to the opposite.

    RETURN:
       none
*/
void change_fail_msg()
{
   if (fail_msg)
      fail_msg = 0;
   else
      fail_msg = 1;
}

/******************************************************/
/*  CHANGE_MSG_VERBOSITY

    Change verbose configuration to the opposite.

    RETURN:
       none
*/
void change_msg_verbosity()
{
   if (verbose)
      verbose = 0;
   else
      verbose = 1;
}

/******************************************************/
/*  PRINT_FAIL

    Configure server/client to print a verification fail.
    Default situation.

    PARAMETER:
       fd:   socket descriptor to send config command on

    RETURN:
       none
*/
void print_fail(fd)
int fd;
{
void send_command();

   if (!(fail_msg)) {
      fail_msg = 1;
      send_command(fd, CNF_GRP | CNF_FAIL, 0, 0);
   }
}

/******************************************************/
/*  NO_FAIL

    Configure server/client to be silent even if verification fails.

    PARAMETER:
       fd:   socket descriptor to send config command on

    RETURN:
       none
*/
void no_fail(fd)
int fd;
{
void send_command();

   if (fail_msg) {
      fail_msg = 0;
      send_command(fd, CNF_GRP | CNF_FAIL, 0, 0);
   }
}

/******************************************************/
/*  PRINT_PASS

    Configure server/client to print a verification pass.

    PARAMETER:
       fd:   socket descriptor to send config command on

    RETURN:
       none
*/
void print_pass(fd)
int fd;
{
void send_command();

   if (!(pass_msg)) {
      pass_msg = 1;
      send_command(fd, CNF_GRP | CNF_PASS, 0, 0);
   }
}

/******************************************************/
/*  NO_PASS

    Configure server/client to be silent if verifcation passes.
    Default situation.

    PARAMETER:
       fd:   socket descriptor to send config command on

    RETURN:
       none
*/
void no_pass(fd)
int fd;
{
void send_command();

   if (pass_msg) {
      pass_msg = 0;
      send_command(fd, CNF_GRP | CNF_PASS, 0, 0);
   }
}

/******************************************************/
/*  PRINT_VERBOSE

    Configure server/client to operate in non-verbose mode.
    Default situation for now.  This default will change in
    the near future.

    PARAMETER:
       fd:   socket descriptor to send config command on

    RETURN:
       none
*/
void print_verbose(fd)
int fd;
{
void send_command();

   if (!(verbose)) {
      verbose = 1;
      send_command(fd, CNF_GRP | CNF_VERBOSE, 0, 0);
   }
}

/******************************************************/
/*  NO_VERBOSE

    Configure server/client to operate in verbose mode.

    PARAMETER:
       fd:   socket descriptor to send config command on

    RETURN:
       none
*/
void no_verbose(fd)
int fd;
{
void send_command();

   if (verbose) {
      verbose = 0;
      send_command(fd, CNF_GRP | CNF_VERBOSE, 0, 0);
   }
}

/******************************************************/
/*  NO_VERIFY

    Configure server to not verify transmitted data.

    PARAMETER:
       fd:   socket descriptor to send config command on

    RETURN:
       none
*/
void no_verify(fd)
int fd;
{
void send_command();

   if (do_verify) {
      do_verify = 0;
      send_command(fd, CNF_GRP | CNF_VERIFY, 0, 0);
   }
}

/******************************************************/
/*  VERIFY

    Configure server to verify transmitted data.

    PARAMETER:
       fd:   socket descriptor to send config command on

    RETURN:
       none
*/
void verify(fd)
int fd;
{
void send_command();

   if (!(do_verify)) {
      do_verify = 1;
      send_command(fd, CNF_GRP | CNF_VERIFY, 0, 0);
   }
}

void iamhere(fd)
int fd;
{
void send_command();

   send_command(fd, MSG_GRP | MSG_EXIST, 0, myinetaddress());
}

void pass(fd)
int fd;
{
void send_command();

   send_command(fd, MSG_GRP | MSG_PASS, 0, myinetaddress());
}

void fail(fd)
int fd;
{
void send_command();

   send_command(fd, MSG_GRP | MSG_FAIL, 0, myinetaddress());
}

void fail_data(fd)
int fd;
{
void send_command();

   send_command(fd, MSG_GRP | MSG_FAIL | MSG_DATA, 0, myinetaddress());
}

void fail_size(fd, received)
int fd, received;
{
void send_command();

   send_command(fd, MSG_GRP | MSG_FAIL | MSG_SIZE, received, myinetaddress());
}

#define SYNC_RUNS 6

void r_sync_time(fd, first_ticks, cli_hz)
int fd;
uword first_ticks, cli_hz;
{
struct tms yutz;
uword ticks[SYNC_RUNS], cli_ticks[SYNC_RUNS], tdiff[SYNC_RUNS];
double cli_secs[SYNC_RUNS], srv_secs[SYNC_RUNS], diff[SYNC_RUNS];
word dataarr[3];
int i;
extern uword Gtime_diff;
extern uword Gcli_hz;
extern int GFsync;

   GETTIMES(ticks[0], yutz);
   cli_ticks[0] = first_ticks;

   for (i = 1; i < SYNC_RUNS; i++) {
      getcmd(fd, dataarr, 3);
      GETTIMES(ticks[i], yutz);
      cli_ticks[i] = dataarr[1];
   }

   GFsync = TRUE;

   Gcli_hz = cli_hz;

   for (i = 0; i < (SYNC_RUNS - 1); i++) {
      tdiff[i] = ticks[i + 1] - ticks[i];
   }

   for (i = 1; i < SYNC_RUNS; i++) {
      tdiff[0] = (tdiff[0] < tdiff[i]) ? tdiff[0] : tdiff[i];
   }

#ifdef DEBUG
   fprintf(stderr,"tdiff[0]:   %d\n", tdiff[0]);
#endif

   for (i = 0; i < SYNC_RUNS; i++) {
      cli_secs[i] = (double)((double)cli_ticks[i] / (double)cli_hz);
      srv_secs[i] = (double)(ticks[i] - tdiff[0]) / (double)HZ;
      diff[i] = cli_secs[i] - srv_secs[i];
#ifdef DEBUG
      fprintf(stderr, "cli:  %f       srv:  %f         diff:  %f\n",
                       cli_secs[i], srv_secs[i],  diff[i]);
#endif
   }

   for (i = 1; i < SYNC_RUNS; i++) {
      diff[0] = (diff[0] > diff[i]) ? diff[0] : diff[i];
   }

   Gtime_diff = (diff[0] * HZ);

#ifdef DEBUG
   fprintf(stderr, "%u     %u      %u\n", ticks[0], ticks[2], ticks[3]);
   fprintf(stderr, "%f     %f      %d\n", cli_secs[0], srv_secs[0], Gtime_diff);
#endif
   return;
   
}

void t_sync_time(fd)
int fd;
{
TIMETYPE ticks;
struct tms yutz;
void send_command();
int i;
extern int GFsync;

   GFsync = TRUE;
   sleep(1);
#ifdef DEBUG
   fprintf(stderr, "SYNCING:  %u     %d\n", ticks, HZ);
#endif

   for (i = 0; i < SYNC_RUNS; i++) {
      GETTIMES(ticks, yutz);
      send_command(fd, CMD_GRP | CMD_TM_SYNC, ticks, HZ);
   }
   
   sleep(1);

   end_data(fd, 0, 0);

}
   
