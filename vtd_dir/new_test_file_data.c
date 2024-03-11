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

char *newTestFileData(char *basefile, char *oldfile)
{
FILE *localfp, *bfp;
char *newFileName;
int testCount;

   testCount = 0;
   newFileName = newTestListFile(oldfile);

   if (newFileName == NULL) {
      return(NULL);
   }

   localfp = fopen(newFileName, "a+");
   bfp = fopen(basefile, "r");
   if (bfp == NULL) {
      printf("ERROR:  Could not open file %s\n", basefile);
      fflush(stdout);
      exit(0);
   }

   if (testCount <= 0) {
      testCount = doTestCount(bfp);
   }

   makeLineUseTrack(testCount);
   randomize(testCount);

   fillNewFile(bfp, localfp);

   clearLineUseTrack(testCount);
   fclose(bfp);
   fclose(localfp);

   return(newFileName);
}
