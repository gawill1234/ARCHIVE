#include <stdio.h>

extern int errno;
extern char *sys_errlist[];

/*******************************************/
/*  Just try and open a file.  Issue and
    error if failure.
*/
FILE *openfile(filename,mode)
char *filename, *mode;
{
extern FILE *fopen();
FILE *fp = NULL;
FILE *filerrlog;
char errstring[256];

   fp = fopen(filename, mode);
   if (fp == NULL) {
      printf("Could not open file:  %s\n", filename);
      exit(0);
   }
   return(fp);
}
