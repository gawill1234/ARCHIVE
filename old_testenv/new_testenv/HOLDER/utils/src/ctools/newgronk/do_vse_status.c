#include "myincludes.h"

//
//   Find the status of a collection crawl.
//
int do_vse_status(char *collection)
{
int curstat, idlecnt;
int nocomprem;

   idlecnt = 0;

   curstat = my_vse_status(collection);
   if (curstat == IDLE) {
      while (idlecnt < 3) {
#ifdef PLATFORM_WINDOWS
         Sleep(1000);
#else
         sleep(1);
#endif
         curstat = my_vse_status(collection);
         if (curstat == IDLE) {
            idlecnt++;
         } else {
            return(0);
         }
      }
   }

   if ((curstat == IDLE) && (idlecnt >= 3)) {
      printf("Crawler and indexer are idle.\n");
      fflush(stdout);
   }

   return(0);
}

