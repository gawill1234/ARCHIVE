#include "myincludes.h"

//
//   Get the current pid of either the crawler or
//   the indexer from the <collection>.xml file
//   Use this as the indicator of whether the crawl
//   is idle or not.
//
int my_vse_status(char *collection_file)
{
int indexpid, crawlpid;

   indexpid = crawlpid = 0;

   crawlpid = do_crawler_status(collection_file);
   indexpid = do_index_status(collection_file);

   if (crawlpid != 0) {
      printf("Crawler running:  %d\n", crawlpid);
      fflush(stdout);
   }

   if (indexpid != 0) {
      printf("Indexer running:  %d\n", indexpid);
      fflush(stdout);
   }

   if ((crawlpid == 0) && (indexpid == 0)) {
      return(IDLE);
   }

   return(ACTIVE);
}

