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


void doenv()
{
char *testroot = NULL;

   tmpdirname = (char *)calloc(8, 1);
   strcpy(tmpdirname, "/tmp");

   testroot = getenv("TEST_ROOT");

   if (testroot == NULL) {
      printf("TEST_ROOT not set, exiting\n");
      fflush(stdout);
      exit(1);
   }
  

   // printf("TEST_ROOT=%s\n", getenv("TEST_ROOT"));
   // printf("TEST_BIN=%s\n", getenv("TEST_BIN"));
   // printf("PATH=%s\n", getenv("PATH"));
   // fflush(stdout);

   return;
}
