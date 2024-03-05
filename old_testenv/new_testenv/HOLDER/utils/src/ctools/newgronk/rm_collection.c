#include "myincludes.h"

//
//   Remove the collection, including the
//   collection directory.
//
int rm_collection(char *filename, char *collection)
{
char *directory;
int err = 0;

   directory = calloc(strlen(filename), 1);
   strcpy(directory, filename);
   directory = _dirname(directory);
#ifdef PLATFORM_WINDOWS
   directory = strcat(directory, "\\");
#else
   directory = strcat(directory, "/");
#endif
   directory = strcat(directory, collection);

   err = unlink(filename);
   if (err != 0) {
      printf("   <ERROR>%s could not be removed</ERRORp>\n", filename);
      fflush(stdout);
   }

   if (access(directory, F_OK) == 0) {
      err += remove_directory(directory);
   }

   return(err);
}

