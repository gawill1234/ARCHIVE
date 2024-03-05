#include <stdio.h>

void err_dump(in)
char *in;
{

   fprintf(stderr, "err_dump():  %s\n", in);
   exit(1);
}
