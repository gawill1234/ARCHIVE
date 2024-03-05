#include "myincludes.h"

//
//   Find a given tag within a node.
//
char *findatag(struct mynode *nodetags, char *tagname)
{
struct mynode *trac;
char *begintag;

   trac = nodetags;
   begintag = buildtag(tagname, BEGINTAG);

   while (trac != NULL) {
      if (strneq(trac->tag, begintag, strlen(begintag))) {
         return(trac->tag);
      }
      trac = trac->next;
   }

   return(NULL);
}

