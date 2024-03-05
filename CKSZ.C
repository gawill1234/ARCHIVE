/****************************************************/
/*  Makes sure a files size is within 10 percent of the
    expected value.  If it is not it will print a message.
*/
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "struct.h"

int check_size(aprod, buf, sizeflag)
struct prodstruct *aprod;
struct stat *buf;
int sizeflag;
{

   if (sizeflag == 1) {
      if (buf->st_size != atoi(aprod->size)) {
         sizeis(aprod, buf);
      }
   }
   else {
      if ((buf->st_size <= 0) && (atoi(aprod->size) != 0)) {
         sizeis(aprod, buf);
      }
   }
}
