#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int build_the_dir_tree(char *fullpath, int fileordir)
{
char *working_copy, *newdir;

   working_copy = (char *)calloc(strlen(fullpath) + 1, 1);
   sprintf(working_copy, "%s\0", fullpath);


   if (fileordir == AFILE) {
      newdir = _dirname(working_copy);
   } else {
      newdir = working_copy;
   }

   printf("working with %s\n", newdir);
   fflush(stdout);

   if (access(newdir, F_OK) != 0) {
      working_copy = (char *)calloc(strlen(fullpath) + 1, 1);
      sprintf(working_copy, "%s\0", newdir);
      newdir = _dirname(newdir);
      if (strcmp(working_copy, newdir) != 0) {
         build_the_dir_tree(newdir, ADIR);
      }
      printf("Creating %s\n", working_copy);
      fflush(stdout);
      mkdir(working_copy, 0755);
      free(working_copy);
   }

   free(newdir);
   return(0);

}

