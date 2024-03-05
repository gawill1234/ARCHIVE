#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

char **split_string();
#define BININIT "binning-state="

char *process_string(char *collist)
{
char **args;
int i, len;
char *binstr = NULL;

   len = strlen(collist);
   len = 20 + 30 + 1 + strlen(BININIT);

   binstr = (char *)calloc(len, 1);

   if (binstr != NULL) {

      args = split_string(collist, ':');

      i = 0;
      strcpy(binstr, BININIT);
      while (args[i] != NULL) {
         strcat(binstr, args[i]);
         i++;
         strcat(binstr, "==");
         if (args[i] != NULL) {
            strcat(binstr, args[i]);
            i++;
            if (args[i] != NULL) {
               strcat(binstr, "%0a");
            }
         } else {
            free(binstr);
            return(NULL);
         }
      }
   }

   return(binstr);
}

int main(int argc, char **argv)
{
char *collist, *binstr;

   if (argc < 2) {
      printf("Usage:  mbinstr <binlist> (var:val:var:val ...)\n");
      fflush(stdout);
      exit(1);
   }
   collist = argv[1];

   binstr = process_string(collist);

   if (binstr != NULL) {
      printf("%s", binstr);
      fflush(stdout);
   }

   exit(0);
}
