#include "myincludes.h"

#ifdef PLATFORM_WINDOWS
int addToPidList(int service, int *pidlist, int cpid, PROCESSENTRY32 *pe32)
{
   switch (service) {
      //   Get all of the query services, including the dispatcher
      case QUERY:
      case QUERY_ALL:
         pidlist[cpid] = pe32->th32ProcessID;
         cpid++;
         break;
      //
      //   Get all of the collection-service-dispatches
      //   including the one associated with query-service
      case COLLECTION_SERVICE_DISPATCH:
      case COLLECTION_SERVICE_ALL:
         pidlist[cpid] = pe32->th32ProcessID;
         cpid++;
         break;
      //
      //   Get all of the other service pids
      default:
         pidlist[cpid] = pe32->th32ProcessID;
         cpid++;
         break;
   }
   return(cpid);
}
#endif

#if defined(__LINUX__)
//
//   P is a global structure at the moment and is declared
//   up at the top.
//
int addToPidList(int service, int *pidlist, int cpid, int j)
{
   switch (service) {
      //
      //   Get all of the collection-service-dispatches
      //   except the one associated with query-service
      case COLLECTION_SERVICE_DISPATCH:
         if (P[j].ppid == 1) {
            pidlist[cpid] = P[j].pid;
            cpid++;
         }
         break;
      //
      //   Get only the query service without its dispatcher
      case QUERY:
         if (P[j].ppid != 1) {
            pidlist[cpid] = P[j].pid;
            cpid++;
         }
         break;
      //
      //   Get all of the query services, including the dispatcher
      case QUERY_ALL:
         pidlist[cpid] = P[j].pid;
         cpid++;
         break;
      //
      //   Get all of the collection-service-dispatches
      //   including the one associated with query-service
      case COLLECTION_SERVICE_ALL:
         pidlist[cpid] = P[j].pid;
         cpid++;
         break;
      //
      //   Get all of the other service pids
      default:
         pidlist[cpid] = P[j].pid;
         cpid++;
         break;
   }
   return(cpid);
}
#endif

#if defined(__SUNOS__)
int addToPidList(int service, int *pidlist, int cpid, int pid, int ppid)
{
   switch (service) {
      //
      //   Get all of the collection-service-dispatches
      //   except the one associated with query-service
      case COLLECTION_SERVICE_DISPATCH:
         if (ppid == 1) {
            pidlist[cpid] = pid;
            cpid++;
         }
         break;
      //
      //   Get only the query service without its dispatcher
      case QUERY:
         if (ppid != 1) {
            pidlist[cpid] = pid;
            cpid++;
         }
         break;
      //
      //   Get all of the query services, including the dispatcher
      case QUERY_ALL:
         pidlist[cpid] = pid;
         cpid++;
         break;
      //
      //   Get all of the collection-service-dispatches
      //   including the one associated with query-service
      case COLLECTION_SERVICE_ALL:
         pidlist[cpid] = pid;
         cpid++;
         break;
      //
      //   Get all of the other service pids
      default:
         pidlist[cpid] = pid;
         cpid++;
         break;
   }
   return(cpid);
}
#endif
