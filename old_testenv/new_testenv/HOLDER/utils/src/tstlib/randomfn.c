#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <time.h>

char *stirfry(char *stringit)
{
int len, i, thing;
char *newstring = NULL;
void randseed();

   len = strlen(stringit);
   randseed();

   newstring = (char *)calloc(len + 1, 1);

   for (i = 0; i < len; i++) {
      thing = random_int_in_range2(len);
      newstring[i] = stringit[thing];
   }

   return(newstring);
}

void randseed()
{
   srand48(time((time_t *)NULL));
   return;
}

int random_int_in_range2(int range)
{
double myrand;

   myrand = 0.0;

   myrand = drand48();

   //printf("number:  %f\n", myrand);
   //fflush(stdout);

   return((int)(myrand * (double)range));

}

char *genstring(char *startstring)
{
char *newstring;

   if (startstring == NULL) {
      startstring = (char *)calloc(strlen("abcdefghijklmnopqrstuvwxyz1234567890+") + 1, 1);
      strcpy(startstring, "abcdefghijklmnopqrstuvwxyz1234567890+");
   }

   newstring = (char *)stirfry(startstring);

   return(newstring);
}

int random_int_in_range(int range)
{
double myrand;

   myrand = 0.0;

   srand48(time((time_t *)NULL));

   myrand = drand48();

   //printf("number:  %f\n", myrand);
   //fflush(stdout);

   return((int)(myrand * (double)range));

}

