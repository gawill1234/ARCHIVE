#include "myincludes.h"
//count = GetServicePidList(service, collection, &pidlist[0]);

//
//   Find the status of the query service
//   based on pid in the query_service_run.xml file
//
int do_query_status(char *collection_file)
{
char myrun[] = "run";
int pidlist[32], count;
int i, pidfound, ipid;
char **pathes;
struct mynode *querytags;
char *tag, *querypid, *pathval;

   count = 0;
   pidfound = 0;
   querypid = NULL;

   pathes = split_path(myrun);
   querytags = findnode(pathes, collection_file);

   if (querytags != NULL) {
      tag = findatag(querytags, myrun);
      if (tag != NULL) {
         querypid = getattrib(tag, "pid");
      }
   }

   freenodelist(querytags);

   if (querypid != NULL) {
      count = GetServicePidList(QUERY_ALL, NULL, &pidlist[0]);
      if (count > 0) {
         ipid = atoi(querypid);
         for (i = 0; i < count; i++) {
            if (ipid == pidlist[i]) {
               pidfound = 1;
               i = count;
            }
         }
      }
      if (pidfound == 1) {
         printf("Query service running:  %s\n", querypid);
         fflush(stdout);
      } else {
         printf("Query service idle\n");
         fflush(stdout);
      }
      free(querypid);
   } else {
      printf("Query service idle\n");
      fflush(stdout);
   }

   return(0);
}

