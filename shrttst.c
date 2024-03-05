#include <stdio.h>
#include <unistd.h>

void doawait(filename)
char *filename;
{
   printf("Before wait, in function:  FILENAME = %s\n", filename);
   fflush(stdout);
   while (wait((int *)0) != -1);
   printf("After wait, in function:   FILENAME = %s\n", filename);
   fflush(stdout);
   return;
}

main()
{
char *filename;

   filename = tempnam(getcwd((char *)NULL, 64), "rndts");
   printf("Before wait:  FILENAME = %s\n", filename);
   fflush(stdout);
   while (wait((int *)0) != -1);
   printf("After wait:   FILENAME = %s\n", filename);
   fflush(stdout);
   free(filename);

   filename = tempnam(getcwd((char *)NULL, 64), "rndts");
   doawait(filename);
   free(filename);
}
