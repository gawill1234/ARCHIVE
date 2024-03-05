/********************************************************/
/*  Initialize the data structure used to hold file and
    directory data during the check of that file or 
    directory (or whatever, socket, link ...).
*/
#include <stdio.h>

#include "struct.h"

struct prodstruct *initaprod(oneline)
char *oneline;
{
struct prodstruct *aprod = NULL;

   aprod = (struct prodstruct *)malloc(sizeof(struct prodstruct));

   aprod->notfound = 0;
   aprod->tryexec = 0;
   aprod->owner = 0;
   aprod->group = 0;
   aprod->other = 0;
   aprod->couldbepair = 0;
   aprod->nameout = 0;
   aprod->setuid = 0;
   aprod->setgid = 0;
   aprod->stickybit = 0;
   aprod->size = NULL;
   aprod->fullpath = NULL;
   aprod->location = NULL;
   aprod->name = NULL;
   aprod->inline = (char *)malloc(strlen(oneline) + 1);
   strcpy(aprod->inline, oneline);
   aprod->linkto = NULL;
   aprod->dirorfile[0] = '-';
   aprod->dirorfile[1] = '\0';
   aprod->permstr = NULL;
   return(aprod);
}
int freeaprod(aprod)
struct prodstruct *aprod;
{

  if (aprod->size != NULL)
     free(aprod->size);
  if (aprod->fullpath != NULL)
     free(aprod->fullpath);
  if (aprod->location != NULL)
     free(aprod->location);
  if (aprod->name != NULL)
     free(aprod->name);
  if (aprod->linkto != NULL)
     free(aprod->linkto);
  if (aprod->permstr != NULL)
     free(aprod->permstr);
  if (aprod->inline != NULL)
     free(aprod->inline);
  free(aprod);
}
