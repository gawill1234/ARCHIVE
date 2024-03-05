#include "myincludes.h"

//
//   Create and/or null a buffer for reading.
//   Fill it with READSIZE bytes.
//
int doread(int fd, char *buffer)
{
static char *nullchunk = NULL;
int amt = 0;

   if (nullchunk == NULL) {
      nullchunk = (char *)calloc(READSIZE + 1, 1);
   }
   memcpy(buffer, nullchunk, READSIZE);

   amt = read(fd, buffer, READSIZE);

   return(amt);
}

