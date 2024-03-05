#include "myincludes.h"

int pid_list(int service, char *collection)
{
int i, count = 0;
int pidlist[MAXPIDS];

   count = GetServicePidList(service, collection, &pidlist[0]);

   printf("%s", content);
   fflush(stdout);

   printf("<REMOP>\n");

   printf("   <PIDLIST>\n");
   if (service >= 0) {
      printf("      <SERVICE>%s</SERVICE>\n", servicearray[service]);
   }
   if (collection != NULL) {
      printf("      <COLLECTION>%s</COLLECTION>\n", collection);
   }
   for (i = 0; i < count; i++) {
      printf("      <PID>%d</PID>\n", pidlist[i]);
   }
   printf("   </PIDLIST>\n");
   if (service >= 0) {
      printf("   <OUTCOME>Success</OUTCOME>\n");
   } else {
      printf("   <OUTCOME>No Service Specified</OUTCOME>\n");
   }
   printf("</REMOP>\n");
   fflush(stdout);

   return(0);
}

