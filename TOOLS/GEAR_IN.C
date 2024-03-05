#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <ctype.h>
#include <string.h>

char *getfile();

int main()
{
float wheel_size, chain_ring[3], free_wheel[8];
char *buffer, *x;
int ncr, nfw, i, j;

   wheel_size = 0.0;


   printf("Default values listed in parenthesis\n");
   while (wheel_size == 0) {
      printf("Enter wheel size in inches ((only 1) 26.7 for 700c):  ");
      buffer = getfile();
      if (buffer != NULL) {
         sscanf(buffer, "%f", &wheel_size);
         free(buffer);
      }
      else
         wheel_size = 26.7;
   }

   printf("Number of teeth on chain ring\n   ((max 3) 53 42, for my bike):  ");
   buffer = getfile();
   if (buffer != NULL) {
     i = 0;
     ncr = 0;
     x = NULL;
     while (i < 80) {
        if (isdigit(buffer[i])) {
           x = &buffer[i];
           while (isdigit(buffer[i + 1]))
              i++;
           buffer[i + 1] = '\0';
        }
        else {
           buffer[i] = '\0';
        }
        if (x != NULL) {
           chain_ring[ncr] = atoi(x);
           ncr++;
           if (ncr == 3)
              break;
           x = NULL;
        }
        i++;
      }
      free(buffer);
   }
   else {
      chain_ring[0] = 53;
      chain_ring[1] = 42;
      chain_ring[2] = 0;
      ncr = 2;
   }

   printf("Number of teeth on free wheel cog\n   ((max 8) 12 13 14 15 17 19 21, again ...):  ");
   buffer = getfile();
   if (buffer != NULL) {
     i = 0;
     nfw = 0;
     x = NULL;
     while (i < 80) {
        if (isdigit(buffer[i])) {
           x = &buffer[i];
           while (isdigit(buffer[i + 1]))
              i++;
           buffer[i + 1] = '\0';
        }
        else {
           buffer[i] = '\0';
        }
        if (x != NULL) {
           free_wheel[nfw] = atoi(x);
           nfw++;
           if (nfw == 8)
              break;
           x = NULL;
        }
        i++;
      }
      free(buffer);
   }
   else {
      free_wheel[0] = 12;
      free_wheel[1] = 13;
      free_wheel[2] = 14;
      free_wheel[3] = 15;
      free_wheel[4] = 17;
      free_wheel[5] = 19;
      free_wheel[6] = 21;
      free_wheel[7] = 0;
      nfw = 7;
   }

   printf("Gear Inches:\n");
   for (i = 0; i < ncr; i++) {
      for (j = 0; j < nfw; j++) {
         printf("  %d/%d:  %f\n", (int)chain_ring[i], (int)free_wheel[j],
                ((chain_ring[i] / free_wheel[j]) * wheel_size));
      }
   }
}

/*************************************************/
/*
   Generic routine to get file names.
*/
char *getfile()
{
char filename[80], *retval;
int i;

   i = 0;
   while((filename[i] = getchar()) != '\n')
     i++;
   filename[i] = '\0';
   if ((filename[0] == '\0') || (filename[0] == '\n'))
      return(NULL);
   retval = (char *)malloc(strlen(filename) + 1);
   strcpy(retval, filename);
   return(retval);
}
