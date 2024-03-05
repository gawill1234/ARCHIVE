#include <sys/types.h>
#if defined(__SPANS)
#include <fore/types.h>
#include <fore_atm/fore_msg.h>
#include <fore_atm/fore_atm_user.h>
#endif
#include <time.h>
#if defined(AIX) || defined(__alpha)
#include <sys/ioctl.h>
#include <sys/timers.h>
#else
#include <sys/filio.h>
#endif

#include "inet.h"
#include "test.h"
#include "test_clnt_srv.h"

char *progname = NULL;
char prog_unkown[14] = {"No test name\0"};

char sdn[15] = {"/dev/fa0\0"};
char qdn[15] = {"/dev/qaa0\0"};
char edn[15] = {"/dev/le0\0"};
char lpdn[15] = {"/dev/lo0\0"};

int Gmax_size = 8192;
int Gdata_size = 0;
int Gsend_bytes = -1;

int timing = 0;
int GFsync = 0;
uword Gtime_diff = 0;
uword Gcli_hz = 0;

int hostc = 0;
char *hostlist[25] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

#if defined(__SPANS)
Vpvc Grvpvc = 0;
#endif

int Gmtu = 1500;

int routine_tfd;
int Gquit = 0;
int Gsend_type = 0;

word diag_total_run_time_memory = 0;

/*******************************************/
/*   Global options used by parse_opts and several
     macros and routines.
*/
int pause_opt = 0;
int loop_opt = 0;
int timing_opt = 0;

char *syscall_name[10];
int start_time[10] = {0,0,0,0,0,0,0,0,0,0};
int end_time[10] = {0,0,0,0,0,0,0,0,0,0};
float average_time[10] = {0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0};
int cum_time[10] = {0,0,0,0,0,0,0,0,0,0};
int max_time[10] = {0,0,0,0,0,0,0,0,0,0};
int min_time[10]= {0,0,0,0,0,0,0,0,0,0};

int num_here[10] = {0,0,0,0,0,0,0,0,0,0};

struct sockaddr_in g_serv_addr, g_cli_addr;
struct mcast_strt dohickey[255];
int init_mcast = 0;
