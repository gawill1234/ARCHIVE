#include "myincludes.h"

//
//   Recursive routine to remove a directory and all
//   of its contents.  It drills down to get rid of
//   everything.
//
#ifdef WINDOWS_EXEC

int remove_directory(char *directory)
{
struct stat buf;
DIR *dirp;
char fullpath[256];
struct dirent *dp;
int err = 0;

#ifdef PLATFORM_WINDOWS
   sprintf(fullpath, "cmd.exe /C \"rmdir /S /Q %s\"\0", directory);
   system(fullpath);
#else
   dirp = opendir(directory);
   if (dirp != NULL) {
      while ((dp = readdir(dirp)) != NULL) {
         if ((strcmp(dp->d_name, ".") != 0) && (strcmp(dp->d_name, "..") != 0)) {
            sprintf(fullpath, "%s/%s\0", directory, dp->d_name);
            stat(fullpath, &buf);
            if (S_ISDIR(buf.st_mode)) {
               err += remove_directory(fullpath);
            } else {
               err += unlink(fullpath);
            }
         }
      }
      closedir(dirp);
      err += rmdir(directory);
   } else {
      printf("   <ERROR>collection dir:  %s could not be opened</ERRORp>\n", directory);
      fflush(stdout);
      err = -1;
   }
#endif

   return(err);
}

#else

int remove_directory(char *directory)
{
struct stat buf;
DIR *dirp;
char fullpath[256];
struct dirent *dp;
int err = 0;

   dirp = opendir(directory);
   if (dirp != NULL) {
      while ((dp = readdir(dirp)) != NULL) {
         if ((strcmp(dp->d_name, ".") != 0) && (strcmp(dp->d_name, "..") != 0)) {
#ifdef PLATFORM_WINDOWS
            sprintf(fullpath, "%s\\%s\0", directory, dp->d_name);
#else
            sprintf(fullpath, "%s/%s\0", directory, dp->d_name);
#endif
            stat(fullpath, &buf);
            if (S_ISDIR(buf.st_mode)) {
               err += remove_directory(fullpath);
            } else {
               err += unlink(fullpath);
            }
         }
      }
      closedir(dirp);
      err += rmdir(directory);
   } else {
      printf("   <ERROR>collection dir:  %s could not be opened</ERRORp>\n", directory);
      fflush(stdout);
      err = -1;
   }

   return(err);
}

#endif
