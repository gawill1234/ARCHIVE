#include "myincludes.h"

int replacebuffer(char *source, char *copy, char *from, char *to, int lensrc)
{
int lenfrom, lento, i, z;
char strt;

   lenfrom = strlen(from);
   lento = strlen(to);

   strt = from[0];

   z = 0;
   for (i = 0; i < lensrc; i++) {
      if (source[i] == strt) {
         if (strncmp(&source[i], from, lenfrom) == 0) {
            i = (i + lenfrom) - 1;
            //strcat(copy, to);
            copy[z] = to[0];
            z = (z + lento);
         } else {
            copy[z] = source[i];
            z++;
         }
      } else {
         copy[z] = source[i];
         z++;
      }
   }

   return(z);
}

