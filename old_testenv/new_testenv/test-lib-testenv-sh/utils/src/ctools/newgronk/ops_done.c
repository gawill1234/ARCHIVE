#include "myincludes.h"

//
//   Dump some XML about what is going on.
//   This is the trailing XML to the user
//   specified operation.
//
int ops_done(int err, int what, int binflag)
{

   if (binflag == 1) {
      return(0);
   }

   if ((what == GETTING) || (what == EXEC) || (what == STATUS)) {
      //printf("\n]]>\n");
      //printf("   </DATA>\n");
      printf("]]></DATA>\n");
   }

   switch (what) {
      case EXISTS:
         if (err == 0) {
            printf("   <OUTCOME>Yes</OUTCOME>\n");
         } else {
            printf("   <OUTCOME>No</OUTCOME>\n");
         }
         break;
      case SIZE:
         if (err >= 0) {
            printf("   <SIZE>%d</SIZE>\n", err);
         } else {
            printf("   <SIZE>-1</SIZE>\n");
         }
         break;
      default:
         if (err == 0) {
            printf("   <OUTCOME>Success</OUTCOME>\n");
         } else {
            printf("   <OUTCOME>Failure</OUTCOME>\n");
         }
         break;
   }
   printf("</REMOP>\n");
   fflush(stdout);

   return(0);
}

