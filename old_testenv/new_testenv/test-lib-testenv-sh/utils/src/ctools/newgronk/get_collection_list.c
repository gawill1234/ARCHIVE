#include "myincludes.h"
//#include <stdio.h>
//#include <stdlib.h>
//#include <unistd.h>
//#include <string.h>
//#include <fcntl.h>
//#include <dirent.h>
//#include <libgen.h>

//#include <glob.h>
//#include <sys/vfs.h>

//#include <sys/types.h>
//#include <sys/stat.h>

//
//   Recursive routine to remove a directory and all
//   of its contents.  It drills down to get rid of
//   everything.
//

int list_collection_directory(char *directory, int level)
{
struct stat buf;
DIR *dirp;
char fullpath[256];
char *tmpdir;
struct dirent *dp;
int err = 0;

   level += 1;

   //printf("GARBAGE: %s\n", directory);
   //fflush(stdout);

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
               if (level < 3) {
                  err += list_collection_directory(fullpath, level);
               }
            }
         }
      }
      closedir(dirp);
      if (level == 3) {
         tmpdir = (char *)malloc(strlen(directory) + 1);
         strcpy(tmpdir, directory);
         printf("      <COLLECTION>\n");
         printf("         <COLLECTION_DIR>%s</COLLECTION_DIR>\n",
                 _basename(_dirname(tmpdir)));
         printf("         <COLLECTION_NAME>%s</COLLECTION_NAME>\n",
                 _basename(directory));
         printf("      </COLLECTION>\n");
         fflush(stdout);
         free(tmpdir);
      }
   } else {
      printf("   <ERROR>collection dir:  %s could not be opened</ERRORp>\n", directory);
      fflush(stdout);
      err = -1;
   }

   return(err);
}

void get_collection_list(char *collection_dir) {

   int err;

   printf("%s", content);
   fflush(stdout);

   printf("<REMOP>\n");
   printf("   <OP>COLLECTION_LIST</OP>\n");
   printf("   <COLLECTION_PATH>%s</COLLECTION_PATH>\n", collection_dir);
   printf("   <COLLECTION_LIST>\n");
   fflush(stdout);
   err = list_collection_directory(collection_dir, 0);
   printf("   </COLLECTION_LIST>\n");
   printf("</REMOP>\n");
   fflush(stdout);

   return;
}


//int main() {
//
//   get_collection_list("/var/www/html/vivisimo/data/search-collections");
//
//}
