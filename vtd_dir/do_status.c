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

/************************************************************************/
/*
 *   TEST STATUS ROUTINES.
 *        dofail(), dopass(), dopassfail(), dostatus()
 */
int whyNotRun(int slotid)
{
   if (running_tests[slotid].sup == 0)
      return(UNSUPP);
   if (running_tests[slotid].type == 0)
      return(NRTYPE);
   if (running_tests[slotid].exists == 0)
      return(NOEXIST);

   return(UNK);
}

void dofail(int pid, int slotid, int runtime, int killflag, int status)
{
char finclass[32];

   switch (killflag) {
      case 1:
                sprintf(finclass, "KILLED");
                break;
      case 2:
                switch (whyNotRun(slotid)) {
                   case NOEXIST:
                            sprintf(finclass, "NOT RUN (TEST NOT FOUND)");
                            break;
                   case NEEDFS:
                            sprintf(finclass, "NOT RUN (NEEDS LOCAL FS)");
                            break;
                   case UNSUPP:
                            sprintf(finclass, "NOT RUN (NOT SUPPORTED)");
                            break;
                   case NRTYPE:
                            sprintf(finclass, "NOT RUN (MANUAL, BROKEN OR HOST BASED)");
                            break;
                   case SUIDFAIL:
                            sprintf(finclass, "NOT RUN (SETUID FAILED)");
                            break;
                   case NOTROOT:
                            sprintf(finclass, "NOT RUN (DRIVER NOT ROOT)");
                            break;
                   case NEEDMEM:
                            sprintf(finclass, "NOT RUN (NOT ENOUGH MEMORY)");
                            break;
                   default:
                            sprintf(finclass, "NOT RUN (UNKNOWN)");
                            break;
                }
                break;
      default:
                sprintf(finclass, "Normal");
                break;
   }

   if (slotid >= 0) {
      running_tests[slotid].resstat = 1;
      fprintf(outfp, "%s, Test Failed, death(%s), time(M:%d, A:%d), exit(E:%d, A:%d), pid(%d)\n",
              running_tests[slotid].name, finclass,
              running_tests[slotid].max_time, runtime,
              running_tests[slotid].passval, status, pid);
      fflush(outfp);
      if (killflag != 2)
         dumpline(slotid);
      freeslot(slotid);
   } else {
      fprintf(outfp, "NAME_UNKNOWN, Test Failed, death(%s), UNKNOWN, pid(%d)\n",
              finclass, pid);
      fflush(outfp);
   }
  
   return;
}

void dopass(int pid, int slotid, int runtime, int status)
{
   if (slotid >= 0) {
      fprintf(outfp, "%s, Test Passed, death(Normal), time(M:%d, A:%d), exit(E:%d, A:%d), pid(%d)\n",
              running_tests[slotid].name,
              running_tests[slotid].max_time, runtime,
              running_tests[slotid].passval, status, pid);
      fflush(outfp);
      cleardir(slotid);
      freeslot(slotid);
   } else {
      fprintf(outfp, "NAME_UNKNOWN, Test Passed, death(Normal), UNKNOWN, pid(%d)\n", pid);
      fflush(outfp);
   }

   return;
}


void dopassfail(int pid, int slotid, int status, int runtime)
{
int killflag;

   killflag = 0;

   if (status == SUIDFAIL_EXIT) {
      killflag = 2;
   }

   if (running_tests[slotid].type == 1) {
      if (status == running_tests[slotid].passval) {
         dopass(pid, slotid, runtime, status);
      } else {
         dofail(pid, slotid, runtime, killflag, status);
      }
   } else {
      if (status != running_tests[slotid].passval) {
         dopass(pid, slotid, runtime, status);
      } else {
         dofail(pid, slotid, runtime, killflag, status);
      }
   }
  
   return;
}

void dostatus(int status, int pid)
{
int slotid, endtime, runtime, exstatus;

   endtime = (int)time((time_t *)NULL);
   slotid = findslotbypid(pid);

   if (slotid >= 0) {
      runtime = endtime - running_tests[slotid].start_time;
      running_tests[slotid].end_time = endtime;
   } else {
      return;
   }

   checktmpdir(tmpdirname, running_tests[slotid].name);
   exstatus = WEXITSTATUS(status);

   if ((!WIFSIGNALED(status)) && (WTERMSIG(status) != SIGKILL)) {
      dopassfail(pid, slotid, exstatus, runtime);
   } else {
      dofail(pid, slotid, runtime, 1, exstatus);
   }
   fflush(outfp);

   runcount--;
}

/*
 *   END OF TEST STATUS ROUTINES.
 */
/************************************************************************/
