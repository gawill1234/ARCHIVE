#include "myincludes.h"

int setup_status(char *collection, int whos)
{

   if (whos == 1) {
      return(do_query_status(collection));
   } else {
      return(do_vse_status(collection));
   }
}

