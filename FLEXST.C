#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "struct.h"

struct stat *file_exist(aprod)
struct prodstruct *aprod;
{
struct stat *buf = NULL;
int there;

   buf = (struct stat *)malloc(sizeof(struct stat));

   there = lstat(aprod->fullpath, buf);

   if (there != 0) {
      aprod->notfound = 1;
      if (aprod->nameout == 0)
         nameit(aprod);
      printf("%s:  No such file or directory\n", aprod->fullpath);
   }
   return(buf);
}

int direxist(filename)
char *filename;
{
struct stat buf;
int value;

   value = stat(filename, &buf);
   if ((S_IFMT & buf.st_mode) != S_IFDIR)
      value = (-1);
   return(value);
}
int fileexist2(filename)
char *filename;
{
struct stat buf;
int value;

   value = stat(filename, &buf);
   if ((S_IFMT & buf.st_mode) != S_IFREG)
      value = (-1);
   return(value);
}
