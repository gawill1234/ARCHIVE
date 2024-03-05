#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#include "myincludes.h"

//
//   Recursive routine to remove a directory and all
//   of its contents.  It drills down to get rid of
//   everything.
//
//
//   This differs from remove_directory in that it does NOT cause
//   the top level directory to be deleted as it would in remove_directory()
//
int dircollectionsdirs(char *directory)
{
struct stat buf;
DIR *dirp;
char fullpath[2048];
struct dirent *dp;
int sflen = 0;
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
               remove_directory(fullpath);
            } else {
               unlink(dp->d_name);
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

int repo_remove()
{
char *directory;

#ifdef PLATFORM_WINDOWS
    directory = get_install_dir("\\data\0");
#else
    directory = get_install_dir("/data\0");
#endif

   chdir(directory);
   unlink("repository.xml.lock");
   unlink("repository.xml.index");
   unlink("repository.xml.index.meta");
   unlink("repository.xml");

   unlink("collection-broker.sqlt");
   unlink("collection-broker.pipe");
   unlink("collection-broker.lock");
   unlink("collection-broker.xml.run");

   free(directory);

   return(0);
}

int remove_all_collections()
{
char *directory;

    directory = vivisimo_env_config_values[SEARCH_COLLECTIONS_DIR];

   dircollectionsdirs(directory);

   return(0);
}

int restore_default_state()
{
   printf("%s", content);
   fflush(stdout);

   printf("<REMOP>\n");
   printf("   <OP>RESTOREDEFAULTS</OP>\n");
   fflush(stdout);

   remove_all_collections();
   repo_remove();

   printf("   <COLLECTIONS>deleted</COLLECTIONS>\n");
   printf("   <REPOSITORY>deleted</REPOSITORY>\n");
   printf("   <OUTCOME>Success</OUTCOME>\n");
   printf("</REMOP>\n");
   fflush(stdout);

   return(0);
}


//int main()
//{
//int xx = 0;
//
//   xx = restore_default_state();
//
//}

