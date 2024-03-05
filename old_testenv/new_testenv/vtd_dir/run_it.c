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

int runit(int slotid)
{
int childpid, exstat, gotest;

   if ((running_tests[slotid].sup == 1) && 
       (running_tests[slotid].type != 0)) {
      gotest = 1;
   } else {
      //printf("Top:  gotest = 0\n");
      fflush(stdout);
      gotest = 0;
   }

   if (running_tests[slotid].exists == 0) {
      //printf("exists:  gotest = 0\n");
      fflush(stdout);
      gotest = 0;
   }

   if (gotest) {
      if (running_tests[slotid].mbs == 1) {
         hardwait();
      }
      running_tests[slotid].run_done++;
      if (mkTestDir(slotid) == 0) {
         printf("%s BEGUN\n", running_tests[slotid].name);
         fflush(stdout);
         childpid = fork();
         if (childpid == 0) {
            testsetup(running_tests[slotid].args[0], slotid);
            printf("%s RUNNING\n", running_tests[slotid].args[0]);
            exstat = execvp(running_tests[slotid].args[0],
                            running_tests[slotid].args);
            _exit(exstat);
         } else if (childpid > 0) {
            running_tests[slotid].pid = childpid;
            runcount++;
            if (runcount >= running_tests[slotid].mcon) {
               waitforit(running_tests[slotid].mcon, running_tests[slotid].max_time);
            }
         } else {
            printf("%s COULD NOT START\n", running_tests[slotid].name);
            fflush(stdout);
            dofail(0, slotid, 0, 2, -99);
            return(-1);
         }
      } else {
         dofail(0, slotid, 0, 2, -99);
         freeslot(slotid);
      }
   } else {
      running_tests[slotid].run_done = REPEAT_COUNT;
      if (GL_ig_ig == 1) {
         printf("%s IGNORED\n", running_tests[slotid].name);
         fflush(stdout);
         dofail(0, slotid, 0, 2, -99);
      } else {
         freeslot(slotid);
      }
   }

   return(0);

}
