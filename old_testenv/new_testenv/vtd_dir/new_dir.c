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

/***************************************************************/
/*   Make sure a given directory name is unique.
 *   Update the name if it is not and check again.
 */
char *newdir(char *base)
{
char *tmpdir;
int i;

   tmpdir = (char *)calloc(DIRLEN, 1);
   sprintf(tmpdir, "%s", base);

   i = 0;

   if (direxist(tmpdir) == 0) {
      do {
         sprintf(tmpdir, "%s_%d", base, i);
         i++;
      } while (direxist(tmpdir) == 0);
   }

   return(tmpdir);

}

