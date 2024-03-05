#include "myincludes.h"

//
//   Using the install path, build a Vivisimo
//   collections path.
//
char *build_collection_path(char *collection_name, int which)
{
char *collection_file;

   if (collection_name == NULL) {
      return(NULL);
   }

   switch (which) {
      case 0:
         //
         //   Get the actual collection stats file.
         //   i.e., either data/collections/<collection_name>.xml or
         //   data/search-collections/xxx/<collection_name>.xml
         //
         collection_file = get_collection_path(collection_name, AFILE);
         break;
      case 1:
         //
         //   Get the collection working directory
         //   i.e., either data/collections/<collection_name> or
         //   data/search-collections/xxx/<collection_name>
         //
         collection_file = get_collection_path(collection_name, CWDIR);
         break;
      case 2:
         //
         //   Get the collection directory
         //   i.e., either data/collections or data/search-collections
         //
         collection_file = get_collection_path(collection_name, ADIR);
         break;
      case 3:
         //
         //   Get the collection collection-service run file
         //   i.e., either data/collections/<collection_name>.run or
         //   data/search-collections/xxx/<collection_name>.run
         //
         collection_file = get_collection_path(collection_name, CDISPRUN);
         break;
      default:
         //
         //   DEFAULTS TO GETTING THE COLLECTION STATS FILE
         //
         //   Get the actual collection config file.
         //   i.e., either data/collections/<collection_name>.xml or
         //   data/search-collections/xxx/<collection_name>.xml
         //
         collection_file = get_collection_path(collection_name, AFILE);
         break;
   }

   return(collection_file);
}

