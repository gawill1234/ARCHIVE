#include "myincludes.h"

int kill_crawler(char *collection_file)
{
int crawlpid;

   crawlpid = 0;

   crawlpid = do_crawler_status(collection_file);

   if (crawlpid != 0) {
      return(killit(crawlpid));
   }

   return(0);
}

int kill_index(char *collection_file)
{
int indexpid;

   indexpid = 0;

   indexpid = do_index_status(collection_file);

   if (indexpid != 0) {
      return(killit(indexpid));
   }

   return(0);
}

int kill_crindex(char *collection_file)
{
int crawlpid, indexpid, err;
#ifdef PLATFORM_WINDOWS
PROCESS_INFORMATION pi;
#endif

   crawlpid = 0;
   err = 0;

   crawlpid = do_crawler_status(collection_file);
   indexpid = do_index_status(collection_file);

   if (crawlpid != 0) {
      if (killit(crawlpid) != 0) {
         err++;
      }
   }

   if (indexpid != 0) {
      if (killit(indexpid) != 0) {
         err++;
      }
   }

   return(err);
}

