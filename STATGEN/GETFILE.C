#include <stdio.h>
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
   retval = (char *)malloc(strlen(filename));
   strcpy(retval, filename);
   return(retval);
}
