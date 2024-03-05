#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

void strip_newline(char *instring, int lenofstring)
{
   if (instring[lenofstring - 1] == '\n') {
      instring[lenofstring - 1] = '\0';
   }

   return;
}

char *strip_string(char *instring, char *string_to_strip)
{
int striplen;
char *retstring;

   retstring = NULL;
   
   if (string_to_strip != NULL) {
      striplen = strlen(string_to_strip);
      strip_newline(instring, strlen(instring));
      if (strncmp(instring, string_to_strip, striplen) == 0) {
         retstring = instring + striplen;
         return(retstring);
      }
   }

   return(retstring);
}

char *build_new_string(char *stringend, char *string_to_add)
{
int lens;
char *newstring;

   newstring = NULL;

   if (string_to_add != NULL) {
      lens = strlen(stringend) + strlen(string_to_add) + 4;

      newstring = (char *)calloc(lens, 1);

      sprintf(newstring, "%s%s\0", string_to_add, stringend);
   }

   return(newstring);
}

int check_string_as_node(char *nodestring, int deleteflag)
{
int result;

   result = 0;

   printf("CHECKING:  %s\n", nodestring);
   fflush(stdout);

   if (access(nodestring, F_OK) != 0) {
      printf("NODE %s DOES NOT EXIST\n", nodestring);
      fflush(stdout);
      result++;
   } else {
      if (deleteflag == 1) {
         printf("DELETED\n");
         fflush(stdout);
         unlink(nodestring);
      }
   }

   return(result);
}

