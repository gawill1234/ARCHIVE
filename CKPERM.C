/***************************************************/
/*  Checks the permissions of a file or directory or
    whatever and  makes sure they are what is expected.
    If they are not the same as the expected result, an
    error message is printed.
*/
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "struct.h"

int check_perm(aprod, buf)
struct prodstruct *aprod;
struct stat *buf;
{
char *printperm();
int differflag = 0;

   crud.st_mode = buf->st_mode;

   if (aprod->owner != crud.glop.ownerp) {
      differflag = 1;
   }
   if (aprod->group != crud.glop.groupp) {
      differflag = 1;
   }
   if (aprod->other != crud.glop.otherp) {
      differflag = 1;
   }
   if (differflag == 1) {
      if (aprod->nameout == 0)
         nameit(aprod);
      printf("  PERMISSIONS --  EXPECTED:  %s\n", aprod->permstr);
      printf("                  ACTUAL:    %s%s%s\n\n",
              printperm((int)crud.glop.ownerp),
              printperm((int)crud.glop.groupp),
              printperm((int)crud.glop.otherp));
   }
   checksetid(aprod);
}
int checksetid(aprod)
struct prodstruct *aprod;
{
int  gidfl, uidfl, stkfl;


   switch (crud.glop.setid) {
      case 0:
              gidfl = uidfl = stkfl = 0;
              break;

      case 1:
              gidfl = uidfl = 0;
              stkfl = 1;
              break;

      case 2:
              uidfl = stkfl = 0;
              gidfl = 1;
              break;

      case 3:
              gidfl = stkfl = 1;
              uidfl = 0;
              break;

      case 4:
              gidfl = stkfl = 0;
              uidfl = 1;
              break;

      case 5:
              uidfl = stkfl = 1;
              gidfl = 0;
              break;

      case 6:
              gidfl = uidfl = 1;
              stkfl = 0;
              break;

      case 7:
              gidfl = uidfl = stkfl = 1;
              break;

      default:
              gidfl = uidfl = stkfl = 2;
   }

   if (aprod->stickybit != stkfl) {
      bitprob(aprod->stickybit, "STICKY ", aprod);
   }
   if (aprod->setuid != uidfl) {
      bitprob(aprod->setuid, "SET UID", aprod);
   }
   if (aprod->setgid != gidfl) {
      bitprob(aprod->setgid, "SET GID", aprod);
   }
}

int bitprob(flag, bitname, aprod)
int flag;
char *bitname;
struct prodstruct *aprod;
{
   if (aprod->nameout == 0)
      nameit(aprod);

   if (flag == 0) {
      printf("  %s     --  EXPECTED:  NOT SET\n", bitname);
      printf("                  ACTUAL:    SET\n\n");
   }
   else {
      printf("  %s     --  EXPECTED:  SET\n", bitname);
      printf("                  ACTUAL:    NOT SET\n\n");
   }
}
char *printperm(number)
int number;
{

      switch (number) {
         case 7: 
                 return("rwx");
                 break;

         case 6:
                 return("rw-");
                 break;

         case 5:
                 return("r-x");
                 break;

         case 4:
                 return("r--");
                 break;

         case 3:
                 return("-wx");
                 break;

         case 2:
                 return("-w-");
                 break;

         case 1:
                 return("--x");
                 break;

         case 0:
                 return("---");
                 break;

      }
}
