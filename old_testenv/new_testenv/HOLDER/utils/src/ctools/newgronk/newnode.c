#include "myincludes.h"

//
//   Create a new node to stash xml tags
//
struct mynode *newnode()
{
struct mynode *thenode;

   thenode = (struct mynode *)malloc(sizeof(struct mynode));

   if (thenode != NULL) {
      thenode->tag = NULL;
      thenode->next = NULL;
   } else {
      exit(-1);
   }

   return(thenode);
}

