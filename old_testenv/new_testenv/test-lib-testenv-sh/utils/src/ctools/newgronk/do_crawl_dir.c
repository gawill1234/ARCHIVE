#include "myincludes.h"

int do_crawl_dir(char *collection)
{
char *directory, *curcrawl();

   printf("%s", content);
   fflush(stdout);

   printf("<REMOP>\n");
   printf("   <OP>CRAWLDIR</OP>\n");
   fflush(stdout);

   directory = curcrawl(collection);

   printf("   <DIRECTORY>%s</DIRECTORY>\n", directory);
   printf("   <OUTCOME>Success</OUTCOME>\n");
   printf("</REMOP>\n");
   fflush(stdout);

   free(directory);

   return(0);
}

