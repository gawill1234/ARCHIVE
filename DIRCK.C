#include <stdio.h>
#include <string.h>

#include "struct.h"
#include "defs.h"

char *dircheck(oneline, iostart, listfp)
char *oneline, *iostart;
FILE *listfp;
{
int i, spaces, colons, lastchr;
char *end, *newdir;

   spaces = colons = 0;
   end = newdir = NULL;

   spaces = countchars(oneline, ' ');
   colons = countchars(oneline, ':');

   if ((spaces == 0) && (colons == 1)) {
      end = strchr(oneline, ':');
      *end = '\0';
      if (oneline[0] == '/') {
         newdir = (char *)malloc(strlen(oneline) + 2);
         strcpy(newdir, oneline);
      }
      else {
         lastchr = strlen(iostart);
         newdir = (char *)malloc(strlen(oneline) + 2 + lastchr);
         strcpy(newdir, iostart);
         if (iostart[lastchr - 1] != '/')
            strcat(newdir, "/");
         strcat(newdir, oneline);
      }
   }

   if (newdir != NULL) {
      while (direxist(newdir) != 0) {
         printf("DIRECTORY %s DOES NOT EXIST\n", newdir);
         printf("   SKIPPING THROUGH CONTENTS TO NEXT DIRECTORY\n");
         free(newdir);
         newdir = NULL;
         while (newdir == NULL) {
            if ((oneline = fgets(oneline, LINELEN, listfp)) == NULL) {
               return(NULL);
            }
            newdir = (char *)dircheck(oneline, iostart, listfp);
            if (newdir == NULL)
               printf("SKIPPING:  %s", oneline);
         }
      }
   }

   return(newdir);

}
