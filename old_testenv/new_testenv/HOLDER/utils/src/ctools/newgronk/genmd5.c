#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#include "md5.h"

void usage()
{
   printf("gm5dir -C <collection> [-D <install-dir>] [-n] [-m] [-t]\n");
   printf("  -C <collection>:  Name of collection to generate md5 name for\n");
   printf("  -D <install-dir>:  Install directory of velocity (optional)\n");
   printf("  -n :  Do not output collection path\n");
   printf("  -t :  Output 3 characters of md5 name\n");
   printf("  -m :  Output full md5 name\n");
   fflush(stdout);

   exit(1);
}

int main(int argc, char **argv)
{
extern char *optarg;
static char *optstring = "D:C:nmth";
char *instdir, *collection, *md5, *collection_dir;
int c, dirlen, ocd, threed, md5name;

   collection = instdir = NULL;
   ocd = 1;
   threed = 0;
   md5name = 0;

   while ((c=getopt(argc, argv, optstring)) != EOF) {
      switch ((char)c) {
         case 'D':
                     instdir = optarg;
                     break;
         case 'C':
                     collection = optarg;
                     break;
         case 'n':
                     ocd = 0;
                     break;
         case 't':
                     threed = 1;
                     break;
         case 'm':
                     md5name = 1;
                     break;
         case 'h':
         default:
                     usage();
                     break;
      }
   }

   if (collection == NULL) {
      printf("Can not generate directory with out a collection\n");
      printf("Use blahblah -C <collection name>\n");
      usage();
   }

   md5 = MD5String((unsigned char *) collection);

   if (instdir != NULL) {
      dirlen = strlen(instdir) + strlen(collection) + 32;
   } else {
      dirlen = strlen(collection) + 8;
   }

   collection_dir = (char *)calloc(dirlen, 1);
   if (collection_dir == NULL) {
      printf("Could not allocate memory for collection directory\n");
      fflush(stdout);
      exit(1);
   }

   if (instdir != NULL) {
      sprintf(collection_dir, "%s/data/search-collections/%.3s/%s\0",
           instdir, md5, collection);
   } else {
      sprintf(collection_dir, "%.3s/%s\0", md5, collection);
   }

   if (ocd == 1) {
      printf("%s\n", collection_dir);
   }
   if (md5name == 1) {
      printf("%s\n", md5);
   }
   if (threed == 1) {
      if (instdir == NULL) {
         printf("%.3s\n", md5);
      } else {
         printf("%s/data/search-collections/%.3s\n",
              instdir, md5);
      }
   }
   fflush(stdout);

   exit(0);

}
