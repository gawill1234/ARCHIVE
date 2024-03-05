#include "myincludes.h"

//
//   Find the status of the query service
//   based on pid in the query_service_run.xml file
//
int get_query_pid(char *collection_file)
{
char myrun[] = "run";
char **pathes;
struct mynode *querytags;
char *tag, *querypid, *pathval;
int pid;

   querypid = NULL;
   pid = 0;

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
      pid = atoi(querypid);
      free(querypid);
   }

   return(pid);
}

