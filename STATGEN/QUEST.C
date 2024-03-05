#include <stdio.h>

extern char *getfile();

int question(anfp, str1, str2, str3)
FILE *anfp;
char *str1, *str2, *str3;
{
char *answer = NULL;
char *line = NULL;

   clrwin();
   printf("%s(y or n)? ", str1);
   answer = getfile();
   if (answer != NULL) {
      if (strcmp(answer,"y") == 0) {
         fprintf(anfp,"%s:\n", str2);
         while (answer != NULL) {
            free(answer);
            answer = NULL;
            printf("  %s ---> ", str3);
            answer = getfile();
            if (answer != NULL) {
               fprintf(anfp,"   %s\n",answer);
               printf("Enter text:\n");
               while ((line = getfile()) != NULL) {
                  fprintf(anfp, "      %s\n", line);
                  free(line);
               }
               fprintf(anfp,"\n                                ---\n\n");
            }
         }
         fprintf(anfp,"-------------------------------------------\n\n");
      }
   }
}
