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

void xmldump(int slotid)
{
   fprintf(runfp, "<test>\n");
   fprintf(runfp, "<pid>%d</pid>\n", running_tests[slotid].pid);
   fprintf(runfp, "<stime>%d</stime>\n", running_tests[slotid].start_time);
   fprintf(runfp, "<name>%s</name>\n", running_tests[slotid].name);
   fprintf(runfp, "<parent>");
   if (running_tests[slotid].suite != NULL) {
      fprintf(runfp, "/%s", running_tests[slotid].suite);
   } else {
      fprintf(runfp, "/UNKNOWN");
   }
   if (running_tests[slotid].category != NULL) {
      fprintf(runfp, "/%s", running_tests[slotid].category);
   } else {
      fprintf(runfp, "/UNKNOWN");
   }
   fprintf(runfp, "</parent>\n");
   fprintf(runfp, "<loc>%s</loc>\n", running_tests[slotid].directory);
   fprintf(runfp, "<path>%s</path>\n", running_tests[slotid].path);
   fprintf(runfp, "<info>%s</info>\n", running_tests[slotid].cmdline);
   if (running_tests[slotid].resstat == 0)
      fprintf(runfp, "<result>Test Passed</result>\n");
   else
      fprintf(runfp, "<result>Test Failed</result>\n");
   fprintf(runfp, "<etime>%d</etime>\n", running_tests[slotid].end_time);
   fprintf(runfp, "</test>\n");

   fflush(runfp);
}
