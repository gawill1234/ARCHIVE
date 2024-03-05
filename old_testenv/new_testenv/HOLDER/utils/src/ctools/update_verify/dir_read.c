#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <dirent.h>

char *exceptions_list[] = {"collections\0",
                           "repository.xml\0",
                           "repository.xml.index\0",
                           "repository.xml.index.meta\0",
                           "repository.xml.lock\0",
                           "system-reporting\0",
                           "reporting\0",
                           "key\0",
                           "users.xml\0",
                           "users.xml.index\0",
                           "users.xml.index.meta\0",
                           "users.xml.lock\0",
                           "gronk\0",
                           "gronk.exe\0",
                            NULL};

int compare_node(char *fullpath, char *basedir, char *comparedir)
{
struct stat bufa, bufb;
char *stringend, *newstring, *strip_string(), *build_new_string();
int buflen, err, i;

   err = 0;

   stringend = strip_string(fullpath, basedir);
   if (stringend != NULL) {
      newstring = build_new_string(stringend, comparedir);
      if (newstring != NULL) {
         if (access(newstring, F_OK) == 0) {
            lstat(fullpath, &bufa);
            lstat(newstring, &bufb);
            if (bufa.st_size != bufb.st_size) {
               printf("DIFFERENCE FOUND FOR:\n");
               printf("   %s\n", fullpath);
               printf("   %s\n", newstring);
               err++;
            }
         } else {
            lstat(fullpath, &bufa);
            if (S_ISDIR(bufa.st_mode)) {
               printf("MISSING DIRECTORY:\n");
            } else {
               printf("MISSING FILE:\n");
            }
            printf("   FOUND:    %s\n", fullpath);
            printf("   MISSING:  %s\n", newstring);
            err++;
         }
      }
      free(newstring);
   }

   return(err);
}

int excepted(char *name, int echeck)
{
int i, exception;

   i = 0;
   exception = 0;

   if (echeck == 1) {
      return(exception);
   }

   while (exceptions_list[i] != NULL) {
      if (strcmp(exceptions_list[i], name) == 0) {
         exception = 1;
      }
      i++;
   }

   return(exception);
}

//
//   for the first call, directory and basedir will be the same.
//
int compare_directory(char *directory, char *basedir,
                      char *comparedir, int echeck)
{
struct stat buf;
DIR *dirp;
char fullpath[256];
struct dirent *dp;
int err = 0;

   dirp = opendir(directory);
   if (dirp != NULL) {
      while ((dp = readdir(dirp)) != NULL) {
         if ((strcmp(dp->d_name, ".") != 0) &&
             (strcmp(dp->d_name, "..") != 0)) {
            if (!excepted(dp->d_name, echeck)) {
#ifdef PLATFORM_WINDOWS
               sprintf(fullpath, "%s\\%s\0", directory, dp->d_name);
#else
               sprintf(fullpath, "%s/%s\0", directory, dp->d_name);
#endif
               stat(fullpath, &buf);
               if (S_ISDIR(buf.st_mode)) {
                  err += compare_node(fullpath, basedir, comparedir);
                  err += compare_directory(fullpath, basedir,
                                           comparedir, echeck);
               } else {
                  err += compare_node(fullpath, basedir, comparedir);
               }
            }
         }
      }
      closedir(dirp);
   } else {
      printf("   <ERROR>collection dir:  %s could not be opened</ERRORp>\n", directory);
      fflush(stdout);
      err = -1;
   }

   return(err);
}

void show_usage()
{

   printf("Compare the contents of two directories\n");
   printf("dir_comp -l <dir1> -r <dir2> -e\n\n");

   printf("   -l <dir1>:  Directory 1 (conceptually, left)\n");
   printf("   -r <dir2>:  Directory 2 (conceptually, right)\n");
   printf("   -e:         Shut off exceptions processing\n");
   printf("Compare two directories to see if the contents differ\n");
   printf("by size or by files which exist\n");
   printf("This was build to check two installs to see if they are\n");
   printf("the same.  Therefore, there are some exceptions to the\n");
   printf("checking.  Things like the collections directory or\n");
   printf("repository.xml are excluded from the checks\n");

   fflush(stdout);

   exit(0);
}


int main(int argc, char **argv)
{
char *dir1, *dir2;
extern char *optarg;
static char *optstring = "l:r:eh";
int c, err, echeck;


   echeck = err = 0;
   dir1 = dir2 = NULL;

   while ((c=getopt(argc, argv, optstring)) != EOF) {
      switch ((char)c) {
         case 'l':
                     dir1 = optarg;
                     break;
         case 'r':
                     dir2 = optarg;
                     break;
         case 'e':
                     echeck = 1;
                     break;
         case 'h':
         default:
                     show_usage();
                     break;
      }
   }

   if (dir1 == NULL || dir2 == NULL) {
      show_usage();
   }

   err += compare_directory(dir1, dir1, dir2, echeck);
   printf("########################################################\n");
   printf("################  REVERSE CHECK ########################\n");
   printf("########################################################\n");
   err += compare_directory(dir2, dir2, dir1, echeck);

   if (err > 0) {
      printf("KABOOOMMM!!!!\n");
      fflush(stdout);
   }

   exit(err);

}
