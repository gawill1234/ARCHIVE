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

/********************************************************/
/*  This sets the proper environment for the driver to 
 *  run the tests.  Updates the PATH, creates the test 
 *  directory, changes to that directory, and resets the
 *  standard (in, out, err) files to be actual files.
 */

/**************************************************************************/
/*   Find the first occurence of "cmd".  This would be a test to this
 *   program.  Return the full path to the cmd.
 */
char *findcmd(char *cmd)
{
char *dirbuf, *testpath, *tcmd;
int dirlen;

   tcmd = cmd;
   if ((tcmd[0] == '.') && (tcmd[1] == '/')) {
      tcmd = &cmd[2];
   }
   dirbuf = NULL;
   dirlen = strlen(getenv("TEST_ROOT"));

   if (dirlen > 0) {
      dirbuf = calloc(dirlen + 1, 1);
      strcpy(dirbuf, getenv("TEST_ROOT"));
   } else {
      if (dirbuf == NULL) {
         dirbuf = getcwd(dirbuf, 0);
      }
   }

   testpath = searchdir(dirbuf, tcmd);
   free(dirbuf);

   return(testpath);
}
