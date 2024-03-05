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
/*   Set up a random list of tests from the supplied file.  The file
 *   is save in an iterim file.  The reason is that if there is an
 *   issue, the interim file can be use to duplicate the irksome
 *   results of a bad run.
 */
void randomize(int count)
{
int i, puthere;
int tmp;

   srand48(time((time_t *)NULL));

   for (i = 0; i < count; i++) {
      puthere = (int)(drand48() * count);
      tmp = mymess[i]->line;
      mymess[i]->line = mymess[puthere]->line;
      mymess[puthere]->line = tmp;
   }
}
