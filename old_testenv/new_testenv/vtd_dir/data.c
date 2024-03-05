/***************************************************************************/
/*   This is vtd.  A program to run tests and gather their results.
 *   Yes, it is one big huge file.  If you have this file, you have it all.
 *
 *   Author:  Gary Williams
 *   Made safe for uclibc
 *
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/vfs.h>
#include <fcntl.h>
#include <dirent.h>
#include <time.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include <sys/msg.h>
//#include <sys/sysinfo.h>
#include <sys/utsname.h>
#include <libgen.h>
#include <errno.h>

#include "locals.h"

struct limitations test_limits;

struct thing **mymess;

/****************************************************/
/*  This is the running test table.  It contains all
 *  of the data for up to MAXTESTS tests (default, 32).
 *  This defines the maximum level of concurrency 
 *  allowed by the drive.
 */
struct tdata running_tests[MAXTESTS];

char *newenv, *thome, *optDir;
char *driveCommand;
char *infile;
int myuid;

FILE *outfp, *fp, *failfp, *runfp;

char *tmpdirname;
int runcount, newsession;

int MAXCONCUR;
int TIMEOUT_TIME;
int SLEEPTIME;
int REPEAT_COUNT;
int RUN_TIME;

int GL_keepall, GL_dorandom, GL_time_over;
int GL_ig_ig, GL_totalmem, GL_wantmem;

time_t GL_start_time, GL_end_time;
