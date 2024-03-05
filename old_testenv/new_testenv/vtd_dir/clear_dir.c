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
/*   Clear a tests execution directory.  Destroy the files and
 *   remove the directory.  It is generally only employed if
 *   the test passes.
 */
void cleardir(int slotid)
{
   if (GL_keepall == 0) {
      clearDirectory(running_tests[slotid].directory);

      if (rmdir(running_tests[slotid].directory) != 0) {
         printf("VTD:  Unable to remove directory %s\n", 
                         running_tests[slotid].directory);
         fflush(stdout);
      }
   }
   return;
}
