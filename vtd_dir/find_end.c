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

int findend(char *argstr, int start)
{
int end, found;

   found = 0;
   end = start + 1;

   while (!found) {
      switch (argstr[end]) {
         case '\0':
         case '\n':
         case ' ':
         case ')':
         case '(':
         case ':':
         case '\t':
         case '/':
         case '$':
                    found = 1;
                    break;
         default:
                    end++;
                    break;
      }
   }

   return(end);
}
