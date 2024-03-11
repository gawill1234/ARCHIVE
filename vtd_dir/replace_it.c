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

void replaceit(char *argstr, int start)
{
int end, envlen;
char *tmpstr, *envname, *envstr, *trac;

   tmpstr = (char *)calloc(READLEN, 1);
   sprintf(tmpstr, "%s", argstr);

   end = findend(tmpstr, start);

   envlen = end - (start + 1);

   trac = &tmpstr[end];

   envname = (char *)calloc(envlen + 1, 1);
   strncpy(envname, &tmpstr[start + 1], envlen);
   envstr = getenv(envname);

   if (envstr != NULL) {
      sprintf(&argstr[start], "%s", envstr);
      start = start + strlen(envstr);
      sprintf(&argstr[start], "%s", trac);
   } else {
      sprintf(argstr, "%s", tmpstr);
   }

   free(envname);
   free(tmpstr);

   return;
}
