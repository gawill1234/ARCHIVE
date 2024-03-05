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
#include "externs.h"

void driversetup(int argc, char **argv)
{
//struct sysinfo sysglom;
char *outfile, *outxmlfile, *failfile, *devhld;
extern char *optarg;
static char *optstring = "i:o:C:nT:r:kRt:avD:s:x:";
int c, setserial;
//int er;
FILE *ravifd;

   //er = sysinfo(&sysglom);
   ////GL_totalmem = sysglom.mem_unit * sysglom.totalram;

   signal(SIGHUP, SIG_IGN);
   signal(SIGINT, SIG_IGN);

   signal(SIGUSR1, SIG_IGN);
   signal(SIGUSR2, SIG_IGN);

   signal(SIGABRT, SIG_IGN);
   signal(SIGSTOP, SIG_IGN);
   signal(SIGQUIT, SIG_IGN);
   signal(SIGTERM, SIG_IGN);

   driveCommand = argv[0];

   doenv();

   runcount = 0;
   newsession = 0;
   GL_keepall = 0;
   GL_time_over = 0;
   GL_dorandom = 0;
   GL_ig_ig = 0;

   myuid = geteuid();

   MAXCONCUR = 1;
   TIMEOUT_TIME = 28800;
   REPEAT_COUNT = 1;
   RUN_TIME = 0;

   if (argc < 3) {
      while ((c=getopt(argc, argv, optstring)) != EOF) {
         switch ((char)c) {
            case 'v':
                    version_info();
                    exit(0);
                    break;
            default:
                    version_info();
                    commandLineError();
                    break;
         }
      }
   }

   // infile = (char *)calloc(12, 1);
   // sprintf(infile, "tests.vtd");
   outfile = (char *)calloc(12, 1);
   sprintf(outfile, "RESULTS");
   outxmlfile = strdup("RUNTESTS.xml");

   /********************************************/
   /*
    *   Process and set arguments supplied on the 
    *   command line.
    */
   while ((c=getopt(argc, argv, optstring)) != EOF) {
      switch ((char)c) {
         case 'D':
                    optDir = optarg;
                    break;
         case 'i':
                    free(infile);
                    infile = optarg;
                    break;
         case 'o':
                    free(outfile);
                    outfile = optarg;
                    break;
         case 'x':
                    free(outxmlfile);
                    outxmlfile = optarg;
                    break;
         case 'T':
                    TIMEOUT_TIME = atoi(optarg);
                    if (TIMEOUT_TIME > MAXTIMEOUT)
                       TIMEOUT_TIME = MAXTIMEOUT;
                    break;
         case 's':
                    SLEEPTIME = atoi(optarg);
                    break;
         case 't':
                    RUN_TIME = atoi(optarg);
                    break;
         case 'r':
                    REPEAT_COUNT = atoi(optarg);
                    //if (REPEAT_COUNT > MAXREPEAT)
                    //   REPEAT_COUNT = MAXREPEAT;
                    break;
         case 'C':
                    MAXCONCUR = atoi(optarg);
                    if (MAXCONCUR > MAXTESTS)
                       MAXCONCUR = MAXTESTS;
                    break;
         case 'n':
                    newsession = 1;
                    break;
         case 'k':
                    GL_keepall = 1;
                    break;
         case 'R':
                    GL_dorandom = 1;
                    break;
         case 'v':
                    version_info();
                    exit(0);
                    break;
         case 'a':
                    GL_ig_ig = 1;
                    break;
         default:
                    version_info();
                    commandLineError();
                    break;
      }
   }

   validateInFile();

   dirsetup();
   outfp = fopen(outfile, "a+");
   runfp = fopen(outxmlfile, "a+");

   failfp = fopen("FAILURES", "a+");
   if (failfp == NULL) {
      failfile = tempnam(thome, "FAILS");
      if (failfile != NULL) {
         failfp = fopen(failfile, "a+");
      }
   }

   setserial = 0;
   if ((devhld = getenv("SERIAL_DEV")) == NULL) {
      setserial = 1;
   } else {
      if (access(devhld, F_OK) != 0) {
         setserial = 1;
      }
   }
 
   if (setserial == 1) {
      if (access("/dev/ttyS0", F_OK) == 0) {
         setenv("SERIAL_DEV", "/dev/ttyS0", 1);
      } else {
         setenv("SERIAL_DEV", "/dev/tts/0", 1);
      }
   }

   return;
}
