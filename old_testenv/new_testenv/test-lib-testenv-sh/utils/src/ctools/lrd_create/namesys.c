/**************************************************************/
/*   NAMESYS

    This routine accepts a string which is a path name to 
    a file or directory, and gets the name of the file system
    on which the file or directory resides.  It returns a string.
*/
/*
   parameters:
      workdir    The name of the directory which is to have the file
                 system name extracted from

   return value:
      name of file system
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "viv_goop.h"

extern char *getcwd();
extern char *strrchr();

char *namesys(char *workdir)
{
char *sysname;
char *oldsysname;
char *endstr;
char *curdir;
struct stat *buf;
int done, err;
dev_t oldid;

   buf = (struct stat *)malloc(sizeof(struct stat));
   sysname = (char *)malloc(strlen(workdir) + 1);
   oldsysname = (char *)malloc(strlen(workdir) + 1);
   strcpy(sysname,workdir);
   curdir = getcwd((char *)NULL, 80);
   if (strcmp(workdir,curdir) != 0) {
      err = chdir(workdir);
      if (err != 0) {
         if (verbose)
            perror("getting system name");
         return(NULL);
      }
      else {
         err = chdir(curdir);
      }
   }
   free(curdir);
   done = 0;
   oldid = 0;
   while (done == 0) {
      err = stat(sysname,buf);
      if (err == 0) {
         if (oldid != 0) {
            if (oldid != buf->st_dev) {
               free(sysname);
               return(oldsysname);
            }
         }
         oldid = buf->st_dev;
      }
      strcpy(oldsysname,sysname);
      endstr = strrchr(sysname,'/');
      *endstr = '\0';
      if (*sysname == '\0') {
         *sysname = '/';
         endstr++;
         *endstr = '\0';
         if (oldid == 0) {
           free(oldsysname);
           return(sysname);
         }
         stat(sysname,buf);
         if (oldid == buf->st_dev) {
           done = 1;
         }
      }
   }
   free(oldsysname);
   return(sysname);
}
