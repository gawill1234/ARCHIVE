#include "myincludes.h"

//
//   Recursive routine to remove a directory and all
//   of its contents.  It drills down to get rid of
//   everything.
//
int dirsearch(char *directory, char *corepath, char *searchfor)
{
struct stat buf;
DIR *dirp;
char fullpath[256];
struct dirent *dp;
int sflen = 0;
int err = 0;

   if (searchfor != NULL) {
      sflen = strlen(searchfor);
   } else {
      return(0);
   }

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
               err = dirsearch(fullpath, corepath, searchfor);
            } else {
               if (strncmp(dp->d_name, searchfor, sflen) == 0) {
                  strcpy(corepath, fullpath);
                  //printf("core file:  %s, %s\n", dp->d_name, fullpath);
                  //fflush(stdout);
                  err = 1;
               }
            }
         }
         if (err != 0) {
            break;
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

int find_file(char *directory, char *file)
{
int i, count = 0;
char corepath[256];
int pidlist[128];

   count = dirsearch(directory, &corepath[0], file);

   printf("%s", content);
   fflush(stdout);

   printf("<REMOP>\n");

   printf("   <FINDFILE>\n");
   printf("      <DIRECTORY>%s</DIRECTORY>\n", directory);
   printf("      <FILEPROTO>%s</FILEPROTO>\n", file);
   if (count > 0) {
      printf("      <FILEPATH>%s</FILEPATH>\n", corepath);
      printf("      <OUTCOME>Success</OUTCOME>\n");
   } else {
      printf("      <OUTCOME>Failure</OUTCOME>\n");
   }
   printf("   </FINDFILE>\n");

   printf("</REMOP>\n");
   fflush(stdout);

   return(0);
}

int find_collection_core(char *collection)
{
char *fulldir, *directory;
int len;

   fulldir = get_collection_path(collection, CWDIR);

   find_file(fulldir, "core");

   free(fulldir);

   return(0);
}

int find_core()
{
char *directory;

   directory = get_install_dir(NULL);

   find_file(directory, "core");

   free(directory);

   return(0);
}

int find_cgi_core()
{
char *directory;

#ifdef PLATFORM_WINDOWS
    directory = get_install_dir("\\www\\cgi-bin\0");
#else
    directory = get_install_dir("/www/cgi-bin\0");
#endif

   find_file(directory, "core");

   free(directory);

   return(0);
}


//int main()
//{
//int xx = 0;
//
//   xx = find_collection_core("/home/gaw", "tryjunk");
//
//}

