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
/*  Clear a slot and mark it as free.
 *  pid = 0 is the free marker.
 */
void freeslot(int slotid)
{
int runit();

   if (running_tests[slotid].pid > 0) {
      xmldump(slotid);
      if (running_tests[slotid].newsess == 1) {
         killMyResiduals(running_tests[slotid].pid);
      }
   }

   if (running_tests[slotid].run_done < running_tests[slotid].run_cnt) {
      runit(slotid);
   } else {
      running_tests[slotid].type = 0;
      running_tests[slotid].mbs = 0;
      running_tests[slotid].passval = 0;
      running_tests[slotid].resstat = 0;
      running_tests[slotid].scon = 0;
      running_tests[slotid].mcon = 0;
      running_tests[slotid].sup = 0;
      running_tests[slotid].newsess = 0;
      running_tests[slotid].exists = 0;
      running_tests[slotid].copy = 0;

      running_tests[slotid].pid = 0;
      running_tests[slotid].start_time = 0;
      running_tests[slotid].end_time = 0;
      running_tests[slotid].max_time = 0;
      running_tests[slotid].run_cnt = 0;
      running_tests[slotid].run_done = 0;

      /**  A COPY of myargs[0]  **/
      free(running_tests[slotid].name);
      running_tests[slotid].name = NULL;

      /**  was mycopy2  **/
      free(running_tests[slotid].cmdline);
      running_tests[slotid].cmdline = NULL;

      /**  A copy of the running directory name  **/
      free(running_tests[slotid].directory);
      running_tests[slotid].directory = NULL;

      free(running_tests[slotid].directory_base);
      running_tests[slotid].directory_base = NULL;

      /**   was myargs  **/
      free(running_tests[slotid].args);
      running_tests[slotid].args = NULL;

      /**  was mycopy1  **/
      free(running_tests[slotid].holdargs);
      running_tests[slotid].holdargs = NULL;

      free(running_tests[slotid].path);
      running_tests[slotid].path = NULL;

      if (running_tests[slotid].suite != NULL) {
         free(running_tests[slotid].suite);
         running_tests[slotid].suite = NULL;
      }
      if (running_tests[slotid].category != NULL) {
         free(running_tests[slotid].category);
         running_tests[slotid].category = NULL;
      }
   }

   return;
}
