#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

int main(int argc, char **argv)
{
extern char *optarg;
static char *optstring = "m:M:";
int c, max, min, range, working;

   max = 100;
   min = 0;

   while ((c=getopt(argc, argv, optstring)) != EOF) {
      switch ((char)c) {
         case 'm':
                     min = atoi(optarg);
                     break;
         case 'M':
                     max = atoi(optarg);
                     break;
         default:
                     break;
      }
   }
   
   range = max - min;

   working = random_int_in_range(range);
   c = min + working;

   printf("%d", c);
   fflush(stdout);

   exit(0);
}
