#include "myincludes.h"

//
//   Build a tag to look for (or at least
//   part of it)
//
char *buildtag(char *tagname, int tagtype)
{
char *tag;
int len;

   len = strlen(tagname);
   if (tagtype == BEGINTAG) {
      tag = (char *)calloc(len + 3, 1);
      sprintf(tag, "<%s\0", tagname);
   } else {
      tag = (char *)calloc(len + 4, 1);
      sprintf(tag, "</%s\0", tagname);
   }

   return(tag);
}

//
//   See if an xml tag is both the begin and end tag.
//
int check_begin_end(char *tag)
{
int gt, bslash;

   gt = strlen(tag) - 1;
   bslash = gt - 1;

   if (tag[gt] == '>') {
      if (tag[bslash] == '/') {
         return(1);
      }
   }

   return(0);
}

