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

/*********************************************************/
/*   Takes the read line dealing with the test and saves
 *   it to the test data area.  At the end of this function,
 *   each test is completely self-contained, at least as far
 *   as associated data is concerned.
 */
int dohickey(char *input)
{
char **myargs, *mycopy1, *mycopy2;
int slotid;

   envvarreplace(input);

   /***************************************************/
   /*   To copies of the read line.  One is to be kept
    *   intact so it can be returned to the user if
    *   necessary.  The other is manipulated to become
    *   the container for the arguments to execvp.
    *   Stored in running_test[].cmdline and
    *             running_test[].modline
    */
   mycopy1 = copyline(input);
   mycopy2 = copyline(input);

   /**************************************************/
   /*   Manipulate one of the lines and have the execvp
    *   args point to it.
    *             running_test[].args
    */
   myargs = domyargs(mycopy1);

   /**************************************************/
   /*   Stash all of the test data in one of the available
    *   test structures.
    */
   slotid = useslot(-1, mycopy2, myargs, mycopy1);

   return(slotid);
}
