#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *replacestring(char *source, char *from, char *to)
{
int lenfrom, lento, lensrc, i, z;
char strt, *copy;

   copy = (char *)calloc(300, 1);

   lensrc = strlen(source);
   lenfrom = strlen(from);
   lento = strlen(to);

   strt = from[0];

   z = 0;
   for (i = 0; i < lensrc; i++) {
      if (source[i] == strt) {
         if (strncmp(&source[i], from, lenfrom) == 0) {
            i = (i + lenfrom) - 1;
            strcat(copy, to);
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

   return(copy);
}

int main(int argc, char **argv)
{
char *froms[] = {"%20", "%3E", NULL};
char *tos[] = {" ", ">", NULL};
char *hippy, *source;
int i;

   i = 0;
   source = (char *)calloc(128, 1);
   strcpy(source, "abcde%20fg%20hi%20%3E%20yabbadabbadoo");
   while (froms[i] != NULL) {
      hippy = replacestring(source, froms[i], tos[i]);
      source = hippy;
      i++;
   }
   printf("%s\n", hippy);
   fflush(stdout);
}
