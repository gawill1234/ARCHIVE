#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

char *unique_file(char *dirname, int ntype)
{
int exists;
char *filename, *gen_name();

   do {
      filename = gen_name(dirname, ntype);
      exists = access(filename, F_OK);
   } while (exists == 0);

   return(filename);
}
