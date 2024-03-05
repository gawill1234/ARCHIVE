#include "myincludes.h"

//
//   Free the tag nodes
//
int freenodelist(struct mynode *nodehead)
{
struct mynode *trac;

   trac = nodehead;
   while (nodehead != NULL) {
      nodehead = nodehead->next;
      free(trac->tag);
      free(trac);
      trac = nodehead;
   }
}

