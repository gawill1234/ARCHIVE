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

char *searchdir(char *testdir, char *testname)
{
struct stat buf;
DIR *dirp;
char fullpath[DIRLEN], *testpath;
struct dirent *dp;
int err = 0;

   testpath = NULL;

   dirp = opendir(testdir);

   if (dirp != NULL) {
      while (((dp = readdir(dirp)) != NULL) &&
             (testpath == NULL)) {
         if ((strcmp(dp->d_name, ".") != 0) &&
             (strcmp(dp->d_name, "..") != 0)) {
            sprintf(fullpath, "%s/%s\0", testdir, dp->d_name);
            stat(fullpath, &buf);
            if (S_ISDIR(buf.st_mode)) {
               testpath = searchdir(fullpath, testname);
            } else {
               if (streq(testname, dp->d_name)) {
                  testpath = (char *)calloc(strlen(testdir) + 1, 1);
                  strcpy(testpath, testdir);
               }
            }
         }
      }
      closedir(dirp);
   } else {
      printf("%s could not be opened\n", testdir);
      fflush(stdout);
      err = -1;
   }

   return(testpath);
}
