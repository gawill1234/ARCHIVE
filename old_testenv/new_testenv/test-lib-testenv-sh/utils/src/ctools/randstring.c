#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

int main(int argc, char **argv)
{
char *mystr = NULL;

   if (argc > 1) {
      mystr = argv[1];
   }

   printf("%s", genstring(mystr));
   fflush(stdout);

   exit(0);
}
