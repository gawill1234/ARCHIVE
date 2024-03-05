#include "myincludes.h"

int fs_free(int sizecmd, char *filename)
{
float size;

   printf("%s", content);
   fflush(stdout);

   printf("<REMOP>\n");

   if (sizecmd == 0) {
      size = get_free_mb(filename);
   } else {
      size = get_free_gb(filename);
   }

   printf("   <FILE_SYSTEM>%s</FILE_SYSTEM>\n", filename);
   printf("      <FREE>\n");
   if (sizecmd == 0) {
      printf("         <SIZE>\n");
      printf("            <MB>%-14.2f</MB>\n", size);
      printf("         </SIZE>\n");
   } else {
      printf("         <SIZE>\n");
      printf("            <GB>%-14.2f</GB>\n", size);
      printf("         </SIZE>\n");
   }
   printf("      </FREE>\n");
   printf("   <OUTCOME>Success</OUTCOME>\n");
   printf("</REMOP>\n");
   fflush(stdout);

   free(filename);

   return(0);
}

