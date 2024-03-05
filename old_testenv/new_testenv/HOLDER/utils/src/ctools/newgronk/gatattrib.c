#include "myincludes.h"

//
//   Given an xml tag line, get the value of
//   a particular attribute
//
char *getattrib(char *tag, char *attrib)
{
char **args, *working, *value;
int i, len;

   i = 0;
   len = strlen(tag);
   working = (char *)calloc(len + 1, 1);
   strcpy(working, tag);

   args = split_tagline(working);

   while (args[i] != NULL) {
      if (streq(attrib, args[i])) {
         if (args[i + 1] != NULL) {
            len = strlen(args[i + 1]);
            value = (char *)calloc(len + 1, 1);
            strcpy(value, args[i + 1]);
            value = noquotes(value);
            free(working);
            return(value);
         }
      }
      i++;
   }

   free(working);
   return(NULL);
}

char *getattribbyvalue(char *tag, char *attrib, char *getvalue)
{
char **args, *working, *value;
int i, len;

   i = 0;
   len = strlen(tag);
   working = (char *)calloc(len + 1, 1);
   strcpy(working, tag);

   printf("%s\n", working);
   fflush(stdout);

   args = split_tagline(working);

   while (args[i] != NULL) {
      if (streq(attrib, args[i])) {
         if (args[i + 1] != NULL) {
            len = strlen(args[i + 1]);
            value = (char *)calloc(len + 1, 1);
            strcpy(value, args[i + 1]);
            value = noquotes(value);
            printf("%s   %s\n", value, getvalue);
            fflush(stdout);
            if (strcmp(value, getvalue) == 0) {
               printf("aaaa:  %s\n", value);
               fflush(stdout);
               free(working);
               return(value);
            }
         }
      }
      i++;
   }

   free(working);
   return(NULL);
}

