#include "myincludes.h"

char *curcrawl(char *collection)
{
struct stat buf;
char *fulldir, *crawldir, *installed;
int dirlen;
DIR *dirp;
struct dirent *dp;

   fulldir = get_collection_path(collection, CWDIR);

   crawldir = (char *)calloc(strlen(fulldir) + 4096, 1);

   //printf("fulldir:  %s\n", fulldir);
   //fflush(stdout);

   dirp = opendir(fulldir);
   if (dirp != NULL) {
      while ((dp = readdir(dirp)) != NULL) {
#ifdef PLATFORM_WINDOWS
         sprintf(crawldir, "%s\\%s\0", fulldir, dp->d_name);
#else
         sprintf(crawldir, "%s/%s\0", fulldir, dp->d_name);
#endif
         stat(crawldir, &buf);
         if (S_ISDIR(buf.st_mode)) {
            if (strncmp(dp->d_name, "crawl", 5) == 0) {
               closedir(dirp);
               return(crawldir);
            }
         }
      }
      closedir(dirp);
   }

   return(NULL);
}

