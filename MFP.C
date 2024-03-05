#include <stdio.h>
#include <string.h>

#include "struct.h"

struct prodstruct *makefullpath(aprod, curdir)
struct prodstruct *aprod;
char *curdir;
{
char *fullpath, *newlocation, *alocation, *aname;
char *tail = NULL;
int i, slash;


   i = slash = 0;

   aname = (char *)malloc(strlen(aprod->name) + 1);
   alocation = (char *)malloc(strlen(aprod->location) + 1);

/*
   alocation[0] = '\0';
*/

   strcpy(aname, aprod->name);
   strcpy(alocation, aprod->location);

   if (alocation[0] != '/') {
      newlocation = (char *)malloc(strlen(curdir) + strlen(alocation) + 2);
      strcpy(newlocation, curdir);
      if (newlocation[strlen(newlocation) - 1] != '/')
         strcat(newlocation, "/");
      strcat(newlocation, alocation);
      free(alocation);
      alocation = newlocation;
   }

   if (strcmp(aname, alocation) == 0) {
      aprod->fullpath = aname;
      aprod->couldbepair = 1;
      free(alocation);
      return(aprod);
   }

   i = strlen(alocation);
   if (alocation[i - 1] == '/') {
      slash = 1;
   }
   else {
      tail = strrchr(alocation, '/');
      tail++;
      if (strcmp(aname, tail) == 0) {
/*
         aprod->fullpath = alocation;
*/
         aprod->couldbepair = 1;
/*
         free(aname);
         return(aprod);
*/
      }
   }


   aprod->fullpath = (char *)malloc(i + strlen(aname) + 2);

   strcpy(aprod->fullpath, alocation);
   if (slash == 0)
      strcat(aprod->fullpath, "/");
   strcat(aprod->fullpath, aname);

   free(aname);
   free(alocation);
   return(aprod);
}
