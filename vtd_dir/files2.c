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

/*
 * This does the grunt work of re-opening the file and barking in case of error
 * Doesn't return anything, but errors appear on the console for the user 
 */ 
void do_reopen(const char* szFileName,      /* name of file to open */
               const char* szMode,          /* mode string */
	       const char* szEnglishName,   /* in case of error, we print */
                                            /* this out so the user knows */
                                            /* about the problem */
               FILE* pFileHand,             /* the file handle to be reopened */
	       FILE* pErrFile)              /* the file handle where errors get reported */

{ 
  int nStatus;    /* container for result of function calls */

  nStatus = create_nested_directories(szFileName, pErrFile, 0);

  if (nStatus) {
    pFileHand = freopen(szFileName, szMode, pFileHand);
    if (!pFileHand && pErrFile) {
      fprintf(pErrFile, "Could not re-open %s to file %s\n", 
	      szEnglishName, szFileName);
    }
  }

  return;

}

/*   Close the standard I/O files (to the screen) and reopen
 *   them as files.  Makes it so test data is not lost.
 */
void move_std_files(char *mydir, char *cmd)
{
char stdfile[DIRLEN + 1];     /* scratch var for holding the name of the file to reopen */

   sprintf(stdfile, "%s/%s.stdout", mydir, cmd);
   do_reopen(stdfile, "w", "stdout", stdout, stderr);

   sprintf(stdfile, "%s/%s.stdin", mydir, cmd);
   do_reopen(stdfile, "a+", "stdin", stdin, stderr);

   sprintf(stdfile, "%s/%s.stderr", mydir, cmd);
   do_reopen(stdfile, "w", "stderr", stderr, stdout);

   return;
}
