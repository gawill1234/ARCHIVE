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

void fillNewFile(FILE *basefp, FILE *newfp)
{
int i, j;
char *mystr;

   i = j = 0;
   mystr = (char *)malloc(READLEN);

   while (mymess[i] != NULL) {
      for (j = 0; j < READLEN; j++) {
         mystr[j] = '\0';
      }
      mystr = getTestLine(basefp, mymess[i]->line, mystr);
      if (mystr != NULL) {
         fprintf(newfp, "%s", mystr);
      }
      i++;
   }

   free(mystr);
}
