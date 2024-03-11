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

/*********************************************************/
/*  Initialize a test slot with the appropriate test data.
   slotid = useslot(-1, mycopy, myargs, input);
 */
int useslot(int pid, char *cmd, char **execable, char *modline)
{
int myslot;
char *basename(), *trc, *finder;

   myslot = getopenslot();

   if (myslot != -1) {
      running_tests[myslot].type = test_limits.type;
      running_tests[myslot].copy = test_limits.copy;
      running_tests[myslot].mbs = test_limits.mbs;
      running_tests[myslot].passval = test_limits.passval;
      running_tests[myslot].resstat = 0;
      running_tests[myslot].scon = test_limits.scon;
      running_tests[myslot].mcon = test_limits.mcon;
      running_tests[myslot].sup = test_limits.sup;
      running_tests[myslot].exists = test_limits.exists;
      running_tests[myslot].newsess = test_limits.sess;
      running_tests[myslot].pid = pid;
      running_tests[myslot].start_time = (int)time((time_t *)NULL);
      running_tests[myslot].end_time = running_tests[myslot].start_time;
      running_tests[myslot].max_time = test_limits.max_time;
      running_tests[myslot].run_cnt = test_limits.run_cnt;
      running_tests[myslot].run_done = 0;
      running_tests[myslot].suite = test_limits.suite;
      running_tests[myslot].category = test_limits.category;

      /**   Came for mycopy  (mycopy2)  **/
      running_tests[myslot].cmdline = cmd;

      /**   Came from domyargs  (myargs)  **/
      running_tests[myslot].args = execable;

      /**   Came for mycopy  (mycopy1)  **/
      running_tests[myslot].holdargs = modline;

      if ((finder = findcmd(execable[0])) == NULL) {
         //printf("findcmd:  cmd not found\n");
         //printf("findcmd:  %s\n", execable[0]);
         //fflush(stdout);
         running_tests[myslot].exists = 0;
      } else {
         //printf("findcmd:  cmd was found\n");
         //printf("findcmd:  %s\n", execable[0]);
         //fflush(stdout);
         running_tests[myslot].exists = 1;
         running_tests[myslot].path = finder;
      }

      /**   A convenience.  Make is so the test  **/
      /**   name is easily available             **/
      if (test_limits.name != NULL) {
         running_tests[myslot].name = test_limits.name;
      } else {
         running_tests[myslot].name = (char *)malloc(strlen(basename(execable[0])) + 1);
         sprintf(running_tests[myslot].name, "%s\0", basename(execable[0]));
         trc = strrchr(running_tests[myslot].name, (int)'.');
         if (trc != NULL) {
            if (strcmp(trc, ".tst") == 0) {
               *trc = '\0';
            }
         }
      }

      /**   Set the base run directory for the test   **/
      /**   Can be modified by newdir                 **/
      running_tests[myslot].directory = (char *)malloc(DIRLEN);;
      sprintf(running_tests[myslot].directory, "%s/%s",
              thome, running_tests[myslot].name);

      running_tests[myslot].directory_base = (char *)malloc(DIRLEN);;
      sprintf(running_tests[myslot].directory_base, "%s/%s",
              thome, running_tests[myslot].name);

   }

   return(myslot);
}
