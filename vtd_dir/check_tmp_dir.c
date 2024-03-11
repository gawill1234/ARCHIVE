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

/*******************************************************************/
/*  Check the TMP dir.  If a test has destroyed it, recreate it.
 */
void checktmpdir(char *path, char *tdel)
{

   if (direxist(path) != 0) {
      if (tdel != NULL) {
         printf("VTD:  tmpdir (%s) possibly removed by %s\n", path, tdel);
         fflush(stdout);
      }
      if (mkdir(path, 0777) != 0) {
         printf("VTD:  Unable to mkdir() tmpdir (%s)\n", path);
         fflush(stdout);
      } else {
         if (chmod(path, 00777) != 0) {
            printf("VTD:  Unable to chmod() tmpdir (%s)\n", path);
            fflush(stdout);
         }
      }
   }

   return;
}
/*
 *   END OF TEST DATA ROUTINES
 */
/****************************************************************/
