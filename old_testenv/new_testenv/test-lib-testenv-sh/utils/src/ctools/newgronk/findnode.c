#include "myincludes.h"

//
//   Find a whole xml node, from beginning to end
//
struct mynode *findnode(char **pathes, char *collection_file)
{
char *begintag, *endtag;
char *mobilestream, *tag, *buffer;
struct mynode *head, *curnode;
int fd, amt, begintag_found, endtag_found, pcnt, using;

   head = curnode = NULL;
   fd = openfile(collection_file);
   buffer = (char *)calloc(READSIZE + 1, 1);
   endtag_found = begintag_found = 0;
   using = pcnt = 0;

   while (pathes[pcnt] != NULL) {
      pcnt++;
   }

   begintag = buildtag(pathes[using], BEGINTAG);
   endtag = buildtag(pathes[using], ENDTAG);

   if (head == NULL) {
      head = newnode();
      curnode = head;
   } else {
      curnode->next = newnode();
      curnode = curnode->next;
   }

   amt = doread(fd, buffer);

   while ((amt > 0) && (endtag_found == 0)) {
      mobilestream = buffer;
      tag = getatag(&mobilestream);
      while ((tag != NULL) && (endtag_found == 0)) {
         if (using < (pcnt - 1)) {
            if (strneq(tag, begintag, strlen(begintag))) {
               using++;
               free(begintag);
               free(endtag);
               begintag = buildtag(pathes[using], BEGINTAG);
               endtag = buildtag(pathes[using], ENDTAG);
            }
            tag = getatag(&mobilestream);
         } else {
            if (begintag_found == 0) {
               if (strneq(tag, begintag, strlen(begintag))) {
                  begintag_found = 1;
                  curnode->tag = tag;
                  endtag_found = check_begin_end(tag);
               } else {
                  free(tag);
               }
            } else {
               curnode->next = newnode();
               curnode = curnode->next;
               curnode->tag = tag;
               if (strneq(tag, endtag, strlen(endtag))) {
                  endtag_found = 1;
                  return(head);
               }
            }
            if (endtag_found == 0) {
               tag = getatag(&mobilestream);
            }
         }
      }
      if (endtag_found == 0) {
         amt = doread(fd, buffer);
      }
   }

   if (endtag_found == 0) {
      head = NULL;
   }

   close(fd);
   return(head);
}

