/*
 *   Author:  Gary Williams
 *   Made safe for uclibc
 *
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/vfs.h>
#include <fcntl.h>
#include <dirent.h>
#include <time.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include <sys/msg.h>
//#include <sys/sysinfo.h>
#include <sys/utsname.h>
#include <libgen.h>
#include <errno.h>

#include "locals.h"
#include "externs.h"

int copydirectory(char *directory_name, char *outdir)
{
DIR *dirp, *opendir();
struct dirent *dp, *readdir();
char *copything, *copyto, *buildPath();
struct stat buf;

   /*************************************/
   /*   Check that directory names are 
    *   not null.
    */
   if (directory_name == NULL)
      return(0); 

   if (outdir == NULL)
      return(0); 

   /**************************************/
   /*   If the source directory exists, open it.
    *   Otherwise return.
    */
   if (direxist(directory_name) == 0) {
      dirp = opendir(directory_name);
   } else {
      return(0);
   }

   /*************************************/
   /*   If the destination directory does not
    *   exist, create it.
    */
   if (direxist(outdir) != 0) {
      create_nested_directories(outdir, stdout, 1);
   }
   
   /*************************************/
   /*   Read the files from the directory and copy them
    *   to the destination.
    */
   if (dirp != NULL) {

      while ((dp = readdir(dirp)) != NULL) {

         /*************************************/
         /*   Do not want to copy "." and ".."
          */
         if (strcmp(dp->d_name, ".") != 0) {
            if (strcmp(dp->d_name, "..") != 0) {

               /*************************************/
               /*   Create full pathes for both the source
                *   and destination files.
                */
               copything = buildPath(directory_name, dp->d_name);
               copyto = buildPath(outdir, dp->d_name);

               stat(copything, &buf);
               if (S_ISDIR(buf.st_mode)) {
                  copydirectory(copything, copyto);
               } else {
                  /*************************************/
                  /*   Copy the files, if the pathes were created
                   *   properly.
                   */
                  if (copything != NULL) {
                     if (copyto != NULL) {
                        copyfile(copything, copyto);
                        matchmode(copything, copyto);
                        free(copyto);
                     }
                     free(copything);
                  } else {
                     if (copyto != NULL) {
                        free(copyto);
                     }
                  }
               }
            }
         }
      }
      closedir(dirp);
   }

   return(0);
}
