#include <stdio.h>

#include "defs.h"

char *checkitems(perms, no, owner, group, size, mon, dayofmon,
                  timeofday, filename, lnkptr, lnkto)
char *perms, *no, *owner, *group, *size, *mon, *dayofmon;
char *timeofday, *filename, *lnkptr, *lnkto;
{
int back = 0;

   if (filename[0] == '\0') {
      if (timeofday[0] == '\0')
         back = 1;
      if (dayofmon[0] == '\0')
         back = 2;
      if (mon[0] == '\0')
         back = 3;
      if (size[0] == '\0')
         back = 4;
      if (group[0] == '\0')
         back = 5;
   }
   switch (back) {
      case 0:
              return(timeofday);
              break;
      case 1:
              return(dayofmon);
              break;
      case 2:
              return(mon);
              break;
      case 3:
              return(size);
              break;
      case 4:
              return(group);
              break;
      case 5:
              return(owner);
              break;
   }
}
