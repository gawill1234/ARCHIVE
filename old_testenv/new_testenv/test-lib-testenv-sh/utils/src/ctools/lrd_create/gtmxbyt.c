#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/vfs.h>

#include "mystructs.h"


/*****************************************************************/
/*   GETMAXBYTES

   Translate the number of available blocks to bytes then calculate
   the amount of that needed to equal 'percent' of the total.
*/
/*
   parameters:
      buf        file system information
      percent    percent full the user wants the file system

   return value:
      total number of bytes to write to  fill the specified file system
      to percent full.
*/
unsigned long getmaxbytes(struct fs_creations *maxbytes, int percent)
{
long maxavailbytes;
long fillmaxbytes;
float percval;
struct statfs *buf, *getfssz();
char *sysname, *namesys();

   sysname = namesys(maxbytes->node_dir);
   buf = getfssz(sysname);

   maxavailbytes = buf->f_bavail;

   free(sysname);
   free(buf);

   if (maxbytes->fill_perc == 0) {
      percval = (float)(100 - percent) / 100.00;
      fillmaxbytes = (long)((float)maxavailbytes * percval);
      maxbytes->fill_perc = fillmaxbytes;
      if (fillmaxbytes > 0)
         return(fillmaxbytes);
      else
         return(0);
   }

   fillmaxbytes = buf->f_bavail - maxbytes->fill_perc;

   if (fillmaxbytes > 0)
      return(fillmaxbytes);
   else
      return(0);

}
