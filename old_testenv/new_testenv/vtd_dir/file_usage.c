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

void validateInFile()
{
char *dot, *newfile, *tmpdir;
int len;

   if (infile != NULL) {
      dot = rindex(infile, (int)'.');
      if (dot != NULL) {
         if (strcmp(dot, ".vtd") == 0) {
            if (infile[0] != '/') {
               tmpdir = (char *)calloc(DIRLEN, 1);
               getcwd(tmpdir, DIRLEN);
               len = strlen(tmpdir) + strlen(infile) + 2;
               newfile = (char *)calloc(len, 1);
               sprintf(newfile, "%s/%s", tmpdir, infile);
               infile = newfile;
               free(tmpdir);
            }
            return;
         }
      }
   } else {
      printf("vtd error:   Not input file specified (-i option)\n\n");
      commandLineError();
   }

   printf("vtd error:     file %s is not a valid test list\n", infile);
   printf("               If it is valid, please rename so that the file\n");
   printf("               name ends in .vtd\n\n");
   printf("WARNING:       This utility can not tell the difference between\n");
   printf("               a test and any other executable.  Be aware\n");
   printf("               that any executable that can be found will\n");
   printf("               be executed.  Even if it is shutdown, or\n");
   printf("               rm -rf /.  Be careful how you name your tests.\n");

   exit(-1);
}
