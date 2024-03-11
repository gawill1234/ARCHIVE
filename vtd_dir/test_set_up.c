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

void testsetup(char *cmd, int slotid)
{
char *basename(), *fullcmd, *srcdir, *mangle;
char prename[64];
int dirlen;

   if (running_tests[slotid].newsess == 1)
      setsid();

   /****************************************************/
   /*   Files required by driver could interfere with
    *   a test.  Close them.
    */
   fclose(runfp);
   fclose(outfp);
   fclose(failfp);
   fclose(fp);

   signal(SIGHUP, SIG_DFL);
   signal(SIGINT, SIG_DFL);

   signal(SIGUSR1, SIG_DFL);
   signal(SIGUSR2, SIG_DFL);

   signal(SIGABRT, SIG_DFL);
   signal(SIGSTOP, SIG_DFL);
   signal(SIGQUIT, SIG_DFL);
   signal(SIGTERM, SIG_DFL);

   copydirectory(running_tests[slotid].path, running_tests[slotid].directory);

   if (chdir(running_tests[slotid].directory) != 0) {
      printf("VTD:  Could not enter test directory %s\n",
              running_tests[slotid].directory);
      fflush(stdout);
      exit(-1); 
   }

   /********************************************/
   /*   Do copydir junk here.
    */
   if (running_tests[slotid].copy == 1) {
      dirlen = strlen(cmd);
      mangle = (char *)malloc(dirlen + 10);
      strcpy(mangle, cmd);
      srcdir = dirname(mangle);
      copydirectory(srcdir, running_tests[slotid].directory);
      free(mangle);
   }

   move_std_files(running_tests[slotid].directory, running_tests[slotid].name);

   /****************************************************/
   /*    Run a ".pre" setup file for a test if it exists.
    */
   sprintf(prename, "%s.pre", running_tests[slotid].name);
   if ((fullcmd = findcmd(prename)) != NULL) {
      system(fullcmd);
      free(fullcmd);
   }


   return;
}
