/***************************************************************************/
/*
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

int copyfile(char *infile, char *outfile)
{
int fno, fno2, readnum, writenum;
char mychunk[BLOCK_SIZE];

#ifdef DEBUG
   printf("doCopy():  copying %s  to  %s\n", infile, outfile);
   fflush(stdout);
#endif

   /************************************/
   /*   Open infile for reading
   */ 
   if ((fno = open(infile, O_RDONLY, 00666)) == (-1)) {
      return(fno);
   }

   /************************************/
   /*   Open outfile for writing
   */ 
   if ((fno2 = open(outfile, O_RDWR|O_CREAT,00666)) == (-1)) {
      return(fno2);
   }

   /*************************************/
   /*  Read file a block a time and write
       to the output file.
   */
   readnum = read(fno, mychunk, BLOCK_SIZE);
   while (readnum == BLOCK_SIZE) {
      writenum = write(fno2, mychunk, BLOCK_SIZE);
      readnum = read(fno, mychunk, BLOCK_SIZE);
   }
   writenum = write(fno2, mychunk, readnum);

   /*************************************/
   /*   Close both files
   */
   close(fno);
   close(fno2);

   /*************************************/
   /*  return(success)
   */
   return(0);

}
