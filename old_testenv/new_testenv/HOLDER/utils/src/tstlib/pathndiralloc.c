#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <libgen.h>
#include <dirent.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>

char *_basename();
char *_dirname();


char *getmydir(int len)
{
char *directory;

   directory = calloc(len, 1);

   getcwd(directory, len);

   return(directory);
}

char *workingdir(char *filename)
{
char *tmp, *thedir;

   tmp = (char *)calloc(strlen(filename) + 1, 1);
   strcpy(tmp, filename);
   thedir = _dirname(tmp);
   
   return(thedir);
}  

char *getthefile(char *filename)
{
char *tmp, *thefile, *myptr;

   tmp = (char *)calloc(strlen(filename) + 1, 1);
   strcpy(tmp, filename);
   myptr = _basename(tmp);

   thefile = (char *)calloc(strlen(myptr) + 1, 1);
   strcpy(thefile, myptr);

   free(tmp);

   return(thefile);
}

char *getfullpath(char *filename)
{
char *directory;
int dirlen, filelen, fulllen, slash, end;

   slash = end = 1;

   if (filename[0] == '/') {
      return(filename);
   } else {
      directory = getmydir(256);
      dirlen = strlen(directory);
      filelen = strlen(filename);

      fulllen = dirlen + filelen + slash + end;

      if (fulllen < 256) {
         strcat(directory, "/");
         strcat(directory, filename);
      } else {
         free(directory);
         directory = getmydir(fulllen);
         strcat(directory, "/");
         strcat(directory, filename);
      }
   }

   return(directory);
}

/********************************************************************/
/*   Build a complete path from a directory and a filename.
 */
char *buildfullpath(const char *filePath, char *fileName)
{
char *fullPath;

   if (filePath == NULL)
      return(NULL);

   if (fileName == NULL)
      return(NULL);

   fullPath = (char *)malloc(strlen(filePath) + strlen(fileName) + 2);

   if (strlen(filePath) == 1)
      sprintf(fullPath, "/%s", fileName);
   else
      sprintf(fullPath, "%s/%s", filePath, fileName);

   return(fullPath);
}



