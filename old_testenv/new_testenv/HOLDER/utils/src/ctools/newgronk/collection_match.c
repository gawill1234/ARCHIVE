#include "myincludes.h"

//#ifdef __SUNOS__
//int collection_match(int service, char *possible, char *collection)
//{
//   return(0);
//}
//#endif

#ifdef PLATFORM_WINDOWS
int collection_match(int service, char *possible, char *collection)
{
   return(0);
}
#endif

#if defined(__LINUX__) || defined(__SUNOS__)

int collection_match(int service, char *possible, char *collection)
{
int len;
char *thing;

   len = strlen(possible);
   if (service == COLLECTION_SERVICE_ALL ||
      service == COLLECTION_SERVICE) {
      if (possible[len - 1] == '/') {
         possible[len - 1] = '\0';
      }
      if (streq(_basename(possible), collection)) {
         return(1);
      }
   }
   if (service == INDEXER || service == CRAWLER) {
      thing = _dirname(possible);
      if (streq(_basename(thing), collection)) {
         return(1);
      }
   }

   return(0);
}


#endif

