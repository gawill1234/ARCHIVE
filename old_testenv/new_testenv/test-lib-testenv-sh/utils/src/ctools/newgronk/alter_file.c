#include "myincludes.h"

//
//   Alter the mode of a file as specified
//   by the remote user.
//
int alter_file(int from, char *filename, char *mode)
{
unsigned int glerb;
int err = 0;

   if (mode != NULL) {
      glerb = strtol(mode, NULL, 8);

      err = chmod(filename, glerb);
   } else {
      err = -1;
   }

   return(err);

}

