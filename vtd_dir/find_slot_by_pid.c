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

/**************************************************************/
/*   Find a test by its process id.
 */
int findslotbypid(int pid)
{
int found, i;
   
   found = 0;
   i = 0;

   while (!found) {
      if (running_tests[i].pid == pid) {
         found = 1;
      } else {
         i++;
      }

      if (i >= MAXTESTS) {
         printf("VTD:  slot search error\n");
         found = 1;
         i = -1;
      }
   }

   return(i);
}
