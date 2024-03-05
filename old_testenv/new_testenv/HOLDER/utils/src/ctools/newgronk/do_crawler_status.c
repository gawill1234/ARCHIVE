#include "myincludes.h"

int do_crawler_status(char *collection_file)
{
char mycrawl[] = "vse-run/crawler";
char myrun[] = "run";
char **pathes;
struct mynode *crawltags, *indextags;
char *tag, *crawlpid, *pathval;
int pid;

   crawlpid = NULL;
   pid = 0;

   pathes = split_path(mycrawl);
   crawltags = findnode(pathes, collection_file);

   if (crawltags != NULL) {
      tag = findatag(crawltags, myrun);
      if (tag != NULL) {
         crawlpid = getattrib(tag, "pid");
      }
   }

   freenodelist(crawltags);

   if (crawlpid == NULL) {
      return(0);
   }

   pid = atoi(crawlpid);
   free(crawlpid);

   return(pid);
}

