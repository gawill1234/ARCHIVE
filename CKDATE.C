/******************************************************/
/*   Simple routine checks to make sure that the file
     in question is no older than fileage hours.  fileage
     can be set on the command line
*/
#include <stdio.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "struct.h"

int check_date(today, buf, fileage, aprod, timeinsec)
struct tm *today;
struct stat *buf;
int fileage;
struct prodstruct *aprod;
long timeinsec;
{
struct tm *filedate;
   
   filedate = localtime(&buf->st_mtime);

   if ((timeinsec - buf->st_mtime) > (fileage * ONE_HOUR_IN_SECS)) {
      if (aprod->nameout == 0)
         nameit(aprod);
      printf("**WARNING     --  FILE OR DIRECTORY MAY NOT BE CURRENT\n");
      printf("  DATE        --  EXPECTED:  %s", asctime(today));
      printf("              --  ACTUAL:    %s\n", asctime(filedate));
   }
}
