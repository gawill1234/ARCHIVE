#include <stdio.h>

#include "struct.h"
#include "defs.h"

char unkname[10] = "UNKNOWN\0";

int checkinput(aprod)
struct prodstruct *aprod;
{
int nochance = 0;
int namenull, locnull, pathnull;
 
   namenull = locnull = pathnull = 0;

   if (aprod->name == NULL) {
      aprod->name = unkname;
      namenull = 1;
   }

   if (aprod->location == NULL) {
      aprod->location = unkname;
      locnull = 1;
   }

   if (aprod->fullpath == NULL) {
      aprod->fullpath = unkname;
      pathnull = 1;
   }

   if (namenull == 1) {
      if (aprod->nameout == 0)
         aprod->nameout = nameit(aprod);
      printf("  NO NAME PROVIDED\n");
      printf("\n");
      nochance = 1;
   }

   if (locnull == 1) {
      if (aprod->nameout == 0)
         aprod->nameout = nameit(aprod);
      printf("  NO LOCATION PROVIDED\n");
      printf("\n");
      nochance = 1;
   }

   if (pathnull == 1) {
      if (aprod->nameout == 0)
         aprod->nameout = nameit(aprod);
      printf("  UNABLE TO CREATE FULL PATH\n");
      printf("\n");
      nochance = 1;
   }

   if (aprod->permstr != NULL) {
      if (strspn(aprod->permstr, VALIDPERM) != 9) {
         if (aprod->nameout == 0)
            aprod->nameout = nameit(aprod);
         printf("  PROVIDED PERMISSIONS WERE INVALID\n");
         printf("\n");
      }
      if (strlen(aprod->permstr) != 9) {
         if (aprod->nameout == 0)
            aprod->nameout = nameit(aprod);
         printf("  PROVIDED PERMISSIONS WERE INCOMPLETE\n");
         printf("\n");
      }
   }

   if ((aprod->permstr == NULL) ||
       ((aprod->owner + aprod->group + aprod->other) == 0)) {
      if (aprod->nameout == 0)
         aprod->nameout = nameit(aprod);
      aprod->permstr = unkname;
      printf("  FILE HAS NO ACCESS OR PROVIDED PERMISSIONS WERE INVALID\n");
      printf("\n");
   }


   if (strspn(aprod->dirorfile, VALIDTYPE) != 1) {
      if (aprod->nameout == 0)
         aprod->nameout = nameit(aprod);
      printf("  PROVIDED UNIT TYPE WAS INVALID\n");
      printf("\n");
   }

   if ((aprod->dirorfile[0] == 'l') && (aprod->linkto == NULL)) {
      aprod->linkto = unkname;
      if (aprod->nameout == 0)
         aprod->nameout = nameit(aprod);
      printf("  ITEM LINK LINKS TO WAS NOT PROVIDED\n");
      printf("\n");
   }

   if (aprod->size == NULL) {
      aprod->size = unkname;
      if (aprod->nameout == 0)
         aprod->nameout = nameit(aprod);
      printf("  NO EXPECTED SIZE PROVIDED\n");
      printf("\n");
   }
   return(nochance);
}
