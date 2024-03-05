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

/********************************************************************/
/*   Build a complete path from a directory and a filename.
 */
char *buildPath(const char *filePath, char *fileName)
{
char *fullPath;

   if (filePath == NULL)
      return(NULL);

   if (fileName == NULL)
      return(NULL);

   /*
    *   "+ 2" is to contain the added "/" and "\0" in the new string.
    */
   fullPath = (char *)calloc(strlen(filePath) + strlen(fileName) + 2, 1);

   /*
    *   If the filePath is "/", just create the new full path as
    *      "/<fileName>"
    *   otherwise
    *      "/<filePath>/<fileName>"
    */
   if (strlen(filePath) == 1)
      sprintf(fullPath, "/%s", fileName);
   else
      sprintf(fullPath, "%s/%s", filePath, fileName);

   return(fullPath);
}
