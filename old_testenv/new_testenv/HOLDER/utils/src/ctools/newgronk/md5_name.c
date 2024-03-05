#include "myincludes.h"
#include "md5.h"

char *get_collection_path(char *collection_name, int fileordir)
{
char *collection_dir, *new_collection_dir;
char *collection_wdir, *new_collection_wdir, *new_collection_disprun;
char *collection_file, *new_collection_file, *md5;
int cflen, newcflen;

   if (collection_name == NULL) {
      return(NULL);
   }

   cflen = strlen(vivisimo_env_config_values[OLD_COLLECTIONS_DIR]) +
           strlen(collection_name) + 128;
   newcflen = strlen(vivisimo_env_config_values[SEARCH_COLLECTIONS_DIR]) +
           strlen(collection_name) + strlen(collection_name) + 128;

   collection_file = calloc(cflen, 1);
   collection_dir = calloc(cflen, 1);
   collection_wdir = calloc(cflen, 1);

   new_collection_file = calloc(newcflen, 1);
   new_collection_dir = calloc(newcflen, 1);
   new_collection_wdir = calloc(newcflen, 1);
   new_collection_disprun = calloc(newcflen, 1);

   md5 = MD5String((unsigned char *) collection_name);
   //printf("%s\n", md5);
   //fflush(stdout);

   sprintf(collection_dir, "%s\0",
           vivisimo_env_config_values[OLD_COLLECTIONS_DIR]);
   sprintf(new_collection_dir, "%s\0",
           vivisimo_env_config_values[SEARCH_COLLECTIONS_DIR]);

#ifdef PLATFORM_WINDOWS
   sprintf(new_collection_wdir, "%s\\%.3s\\%s\0",
           new_collection_dir, md5, collection_name);
   sprintf(collection_wdir, "%s\\%s\0",
           collection_dir, collection_name);

   sprintf(collection_file, "%s\\%s.xml\0",
           collection_dir, collection_name);
   sprintf(new_collection_file, "%s\\%.3s\\%s.xml\0",
           new_collection_dir, md5, collection_name);
   sprintf(new_collection_disprun, "%s\\%.3s\\%s.run\0",
           new_collection_dir, md5, collection_name);
#else
   sprintf(new_collection_wdir, "%s/%.3s/%s\0",
           new_collection_dir, md5, collection_name);
   sprintf(collection_wdir, "%s/%s\0",
           collection_dir, collection_name);

   sprintf(collection_file, "%s/%s.xml\0",
           collection_dir, collection_name);
   sprintf(new_collection_file, "%s/%.3s/%s.xml\0",
           new_collection_dir, md5, collection_name);
   sprintf(new_collection_disprun, "%s/%.3s/%s.run\0",
           new_collection_dir, md5, collection_name);
#endif

   //printf("CF:  %s\n", collection_file);
   //printf("CD:  %s\n", collection_dir);
   //printf("CWD:  %s\n", collection_wdir);
   //printf("NCF:  %s\n", new_collection_file);
   //printf("NCD:  %s\n", new_collection_dir);
   //printf("NCWD:  %s\n", new_collection_wdir);
   //fflush(stdout);

   if ((access(new_collection_dir, F_OK) != 0) ||
       ((access(collection_file, F_OK) == 0) ||
        (access(collection_wdir, F_OK) == 0))) {

      //printf ("LOW AND INSIDE\n");
      //fflush(stdout);
      free(new_collection_dir);
      free(new_collection_file);
      free(new_collection_wdir);

      switch (fileordir) {
         case CWDIR:
            free(collection_file);
            free(collection_dir);
            return(collection_wdir);
            break;
         case ADIR:
            free(collection_file);
            free(collection_wdir);
            return(collection_dir);
            break;
         default:
            free(collection_dir);
            free(collection_wdir);
            return(collection_file);
            break;
      }
   }

   //printf ("RUN AROUND\n");
   //fflush(stdout);
   free(collection_dir);
   free(collection_wdir);
   free(collection_file);

   switch (fileordir) {
      case CWDIR:
         free(new_collection_file);
         free(new_collection_dir);
         free(new_collection_disprun);
         return(new_collection_wdir);
         break;
      case ADIR:
         free(new_collection_file);
         free(new_collection_wdir);
         free(new_collection_disprun);
         return(new_collection_dir);
         break;
      case CDISPRUN:
         free(new_collection_file);
         free(new_collection_dir);
         free(new_collection_wdir);
         return(new_collection_disprun);
         break;
      default:
         free(new_collection_dir);
         free(new_collection_wdir);
         return(new_collection_file);
         break;
   }


   return(NULL);
}

// *
// *utf8_t *
// *collection_filebase(const_utf8_t *install_dir, const_utf8_t *real_name)
// *{
// *    utf8_t *old_name;
// *    utf8_t *old_xml;
// *    utf8_t *new_name;
// *    char *md5;
// *
// *    /* start with the same case to handle pre-7.5 collections */
// *
// *    old_name = maprintf("%s%s%s%s", install_dir, COLLECTIONS_DIR,
// *                        DIR_SEPARATOR, real_name);
// *    old_xml = collection_filename_from_filebase(old_name);
// *
// *    if (file_exists(old_name) || file_exists(old_xml)) {
// *        free(old_xml);
// *        return old_name;
// *    }
// *
// *    free(old_xml);
// *    md5 = MD5String((unsigned char *) real_name);
// *    new_name = maprintf("%s/data/search-collections/%.3s/%s", 
// *                        install_dir, md5, real_name);
// *    free(md5);
// *
// *    return new_name;
// *}
// *
