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
/*   Set up the DRIVERS working directory and move into it.
 *   This becomes the DRIVER root.  All test directories
 *   will be under this one.
 */
void dirsetup()
{
char *locHome;

   locHome = (char *)calloc(DIRLEN, 1);

   if (optDir == NULL) {
      getcwd(locHome, DIRLEN - 1);
      sprintf(locHome, "%s/VTD_%d", locHome, getpid());
   } else {
      sprintf(locHome, "%s", optDir);
   }

   thome = newdir(locHome);
   free(locHome);

   if (create_nested_directories(thome, stdout, 1) == 0) {
      printf("VTD:  Could not create driver directory\n");
      fflush(stdout);
      exit(0);
   }

   if (chmod(thome, 00777) != 0) {
      printf("VTD:  Unable to chmod() directory (%s)\n", thome);
      fflush(stdout);
      exit(0);
   }

   if (chdir(thome) != 0) {
      printf("VTD:  Could not enter driver directory\n");
      fflush(stdout);
      exit(0); 
   }

   return;

}
