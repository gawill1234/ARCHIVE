#include "myincludes.h"

//
//   Delete a file or collection.
//
int delete_data(int from, char *filename, char *collection)
{
int err = 0;
struct stat buf;

   if (from == FILE_CP) {
      stat(filename, &buf);
      if (S_ISDIR(buf.st_mode))
         err = remove_directory(filename);
      else
         err = unlink(filename);
   } else {
      err = rm_collection(filename, collection);
   }

   return(err);
}

