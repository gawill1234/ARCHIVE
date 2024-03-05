#include "myincludes.h"

int do_index_status(char *collection_file)
{
char myindex[] = "vse-run/vse-index";
char myrun[] = "run";
char **pathes;
struct mynode *crawltags, *indextags;
char *tag, *indexpid, *pathval;
int pid;

   indexpid = NULL;
   pid = 0;

   pathes = split_path(myindex);
   indextags = findnode(pathes, collection_file);

   if (indextags != NULL) {
      tag = findatag(indextags, myrun);
      if (tag != NULL) {
         indexpid = getattrib(tag, "pid");
      }
   }

   freenodelist(indextags);

   if (indexpid == NULL) {
      return(0);
   }

   pid = atoi(indexpid);
   free(indexpid);

   return(pid);
}

