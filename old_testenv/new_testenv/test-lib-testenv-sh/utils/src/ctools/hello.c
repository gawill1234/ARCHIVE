#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>


char content[] = "Content-type: text/html\n\n\0";

int main()
{
   printf("%s", content);
   fflush(stdout);
   printf("Hello World\n");
   fflush(stdout);
}

