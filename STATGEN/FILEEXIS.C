#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>

int fileexist(filename)
char *filename;
{
struct stat buf;

   return(stat(filename, &buf));
}
int noexist(filename)
char *filename;
{
      perror(filename);
      waitasec();
      return(0);
}
