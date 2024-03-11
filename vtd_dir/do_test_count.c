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

int doTestCount(FILE *localfp)
{
char *mystr;
int i;
int testCount = 0;
int done = 0;

   mystr = (char *)malloc(READLEN);

   do {
      for (i = 0; i < READLEN; i++)
         mystr[i] = '\0';
      if (readline(localfp, mystr)) {
         if (strlen(mystr) > 1) {
            testCount++;
         }
      } else {
         done = 1;
      }
   } while (!done);

   free(mystr);

   return(testCount);
}
