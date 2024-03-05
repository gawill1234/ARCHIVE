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

char *copyline(char *mystr)
{
int len;
char *line;

   len = strlen(mystr);

   /**  Any use of this is freed when freeslot is called and the data
    **  is freed.
    **/
   line = (char *)calloc(len + 1, 1);

   if (line == NULL) {
      printf("FATAL:  calloc() failed, exiting\n");
      exit(1);
   }

   sprintf(line, "%s", mystr);

   if (line[len - 1] == '\n') {
      line[len - 1] = '\0';
   }

   return(line);
}
