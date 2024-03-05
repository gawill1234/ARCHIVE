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

int mkTestDir(int slotid)
{
   free(running_tests[slotid].directory);
   running_tests[slotid].directory = newdir(running_tests[slotid].directory_base);

   if (mkdir(running_tests[slotid].directory, 0777) != 0) {
      sleep(1);
      if (mkdir(running_tests[slotid].directory, 0777) != 0) {
         printf("VTD:  Could not create test directory:  %s\n",
                 running_tests[slotid].directory);
         fflush(stdout);
         return(-1);
      }
   }

   return(0);
}
