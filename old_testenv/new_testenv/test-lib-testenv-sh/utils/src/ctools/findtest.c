#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>

//
//   An string equality function that returns
//   true if the two strings are equal.
//
int streq(char *one, char *two)
{

   if (one == NULL)
      return(0);

   if (two == NULL)
      return(0);

   if (strcmp(one, two) == 0) {
      return(1);
   } else {
      return(0);
   }

   return(0);
}


char *searchdir(char *testdir, char *testname)
{
struct stat buf;
DIR *dirp;
char fullpath[256], *testpath;
struct dirent *dp;
int err = 0;

   testpath = NULL;

   dirp = opendir(testdir);

   if (dirp != NULL) {
      while (((dp = readdir(dirp)) != NULL) && 
             (testpath == NULL)) {
         if ((strcmp(dp->d_name, ".") != 0) && 
             (strcmp(dp->d_name, "..") != 0)) {
            sprintf(fullpath, "%s/%s\0", testdir, dp->d_name);
            stat(fullpath, &buf);
            if (S_ISDIR(buf.st_mode)) {
               testpath = searchdir(fullpath, testname);
            } else {
               if (streq(testname, dp->d_name)) {
                  //testpath = (char *)calloc(strlen(fullpath) + 1, 1);
                  testpath = (char *)calloc(strlen(testdir) + 1, 1);
                  strcpy(testpath, testdir);
               }
            }
         }
      }
      closedir(dirp);
   } else {
      printf("%s could not be opened\n", testdir);
      fflush(stdout);
      err = -1;
   }

   return(testpath);
}

char *findtest(char *testname)
{
char *dirbuf, *testpath;
int dirlen;

   dirbuf = NULL;
   dirlen = strlen(getenv("TEST_ROOT"));

   if (dirlen > 0) {
      dirbuf = calloc(dirlen + 1, 1);
      strcpy(dirbuf, getenv("TEST_ROOT"));
   } else {
      if (dirbuf == NULL) {
         dirbuf = getcwd(dirbuf, 0);
      }
   }

   printf("Current directory:  %s\n", dirbuf);
   fflush(stdout);


   testpath = searchdir(dirbuf, testname);
   free(dirbuf);

   if (testpath != NULL) {
      printf("test path:  %s\n", testpath);
      fflush(stdout);
   }

   return(testpath);

}

int main()
{
char *testpath;

   testpath = findtest("simple_search");

   exit(0);
}
