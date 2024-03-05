#include "myincludes.h"

//
//   Find an XML tag and return it.
//   
char *getatag(char **searchstream)
{
char *begintag, *endtag, *tag;
int len, len2;

   len = len2 = 0;
   endtag = begintag = *searchstream;

   if (savespace == NULL) {
      while ((*begintag != '<') && (*begintag != '\0')) {
         begintag++;
      }
      if (*begintag == '<') {
         endtag = begintag;
      } else {
         //
         //   We are in some junk that has no tags, so
         //   we do not care about the data.  Dump it.
         //
         return(NULL);
      }
   }

   while ((*endtag != '>') && (*endtag != '\0')) {
      endtag++;
   }

   if (*endtag == '>') {
      if (savespace != NULL) {
         len = strlen(savespace);
         len2 = (endtag - begintag) + 1;
         tag = (char *)calloc(len + len2 + 1, 1);
         strcpy(tag, savespace);
         strncat(tag, begintag, len2);
         free(savespace);
         savespace = NULL;
      } else {
         len = (endtag - begintag) + 1;
         tag = (char *)calloc(len + 1, 1);
         memcpy(tag, begintag, len);
      }
   } else {
      saveit(begintag);
      return(NULL);
   }
   begintag = endtag;

   *searchstream = endtag;
   return(tag);
}

