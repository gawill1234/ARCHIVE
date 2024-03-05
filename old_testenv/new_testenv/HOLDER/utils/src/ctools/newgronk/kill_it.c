#include "myincludes.h"

#ifdef PLATFORM_WINDOWS
/*
    Safely terminate a process by creating a remote thread
    in the process that calls ExitProcess
*/

int unsafe_terminate_process(int pid, UINT uExitCode)
{
int err = 0;

   HANDLE hp = OpenProcess(PROCESS_TERMINATE, 0, pid);

   if (hp) {
      if (!TerminateProcess(hp, uExitCode)) {
         err++;
      }
      CloseHandle(hp);
   }

   return(err);
}

BOOL safe_terminate_process(int pid, UINT uExitCode)
{
    DWORD dwTID, dwCode, dwErr = 0;
    HANDLE hProcessDup = INVALID_HANDLE_VALUE;
    HANDLE hProcess = INVALID_HANDLE_VALUE;
    HANDLE hRT = NULL;
    HINSTANCE hKernel = GetModuleHandle("Kernel32");
    int err = 1;

    hProcess = OpenProcess(PROCESS_VM_READ, FALSE, pid);

    BOOL bDup = DuplicateHandle(GetCurrentProcess(),
                                hProcess,
                                GetCurrentProcess(),
                                &hProcessDup,
                                PROCESS_ALL_ACCESS,
                                FALSE,
                                0);

    // Detect the special case where the process is
    // already dead...
    if ( GetExitCodeProcess((bDup) ? hProcessDup : hProcess, &dwCode) &&
         (dwCode == STILL_ACTIVE) )
    {
        FARPROC pfnExitProc;

        pfnExitProc = GetProcAddress(hKernel, "ExitProcess");

        hRT = CreateRemoteThread((bDup) ? hProcessDup : hProcess,
                                 NULL,
                                 0,
                                 (LPTHREAD_START_ROUTINE)pfnExitProc,
                                 (PVOID)uExitCode, 0, &dwTID);

        if ( hRT == NULL )
            dwErr = GetLastError();
    }
    else
    {
        dwErr = ERROR_PROCESS_ABORTED;
        err = 0;
    }


    if ( hRT )
    {
        // Must wait process to terminate to
        // guarantee that it has exited...
        WaitForSingleObject((bDup) ? hProcessDup : hProcess,
                            INFINITE);

        CloseHandle(hRT);
        err = 0;
    }

    if ( bDup )
        CloseHandle(hProcessDup);

    if (err != 0)
        SetLastError(dwErr);

    return(err);
}

#endif

int kill_it(char *collection, int which)
{
int err = 0;

   switch (which) {
      case 1:
               err = kill_crawler(collection);
               break;
      case 2:
               err = kill_index(collection);
               break;
      case 3:
               err = kill_crindex(collection);
               break;
      default:
               break;
   }

   return(err);
}

//
//   Kill crawler kids -- 1
//   Kill indexer kids -- 2
//   kill both         -- 3
//
int kill_service_children(char *collection_file, int service, int ppid)
{
int indexpid, crawlpid, querypid, err, brokerpid, cservpid;

   cservpid = brokerpid = querypid = indexpid = crawlpid = 0;

   if (service < PPID_SUPPLIED) {

      if ((service == CRAWLER) || (service == CRAWLER_AND_INDEXER)) {
         crawlpid = do_crawler_status(collection_file);
         if (crawlpid != 0) {
            err = dokillkids(crawlpid);
         }
      }

      if ((service == INDEXER) || (service == CRAWLER_AND_INDEXER)) {
         indexpid = do_index_status(collection_file);
         if (indexpid != 0) {
            err = killit(indexpid);
         }
      }

      if (service == QUERY) {
         querypid = get_query_pid(collection_file);
         if (querypid != 0) {
            err = dokillkids(querypid);
         }
      }

      if (service == COLLECTION_SERVICE) {
         cservpid = get_query_pid(collection_file);
         if (cservpid != 0) {
            err = dokillkids(cservpid);
         }
      }

      if (service == CBROKER) {
         brokerpid = get_query_pid(collection_file);
         if (brokerpid != 0) {
            err = dokillkids(brokerpid);
         }
      }
   } else {
      err = killit(ppid);
   }

   return(err);
}

int killadmin()
{
int err;
#ifdef PLATFORM_WINDOWS
//char gizmo[] = "taskkill.exe /U administrator /P mustang5 
//               /F /T /IM admin.exe\0";
char gizmo[] = "taskkill.exe /F /T /IM admin.exe\0";
#endif
#ifdef __LINUX__
char gizmo[] = "killall -9 admin\0";
#endif
#ifdef __SUNOS__
char gizmo[] = "pkill -9 -f admin\0";
#endif

   err = system(gizmo);

   return(err);
}

int killqueryservices()
{
int err;
#ifdef PLATFORM_WINDOWS
char gizmo0[] = "taskkill.exe /F /T /IM query-service.exe\0";
char gizmo1[] = "taskkill.exe /F /T /IM collection-service-dispatch.exe\0";

   err = system(gizmo0);
   err = err + system(gizmo1);
#endif
#ifdef __LINUX__
char gizmo[] = "killall -9 query-service collection-service-dispatch\0";

   err = system(gizmo);
#endif
#ifdef __SUNOS__
char gizmo0[] = "pkill -9 -f query-service\0";
char gizmo1[] = "pkill -9 -f collection-service-dispatch\0";

   err = system(gizmo0);
   err = err + system(gizmo1);
#endif

   return(err);
}
#ifdef PLATFORM_WINDOWS
int killallservices(int shutdown)
{
int qrylist[MAXPIDS], qrycnt;
int crawlerlist[MAXPIDS], crwlcnt;
int cslist[MAXPIDS], cscnt;
int indexerlist[MAXPIDS], idxcnt;
int ewlist[MAXPIDS], ewcnt;
int javalist[MAXPIDS], javacnt;
int dispatchlist[5], dispatchcnt;
int cblist[5], cbcnt;
int csdlist[MAXPIDS], csdcnt;
int vctylist[MAXPIDS], vctycnt;
int err, i, pidtokill;

   crwlcnt = idxcnt = cscnt = ewcnt = javacnt = 0;
   qrycnt = dispatchcnt = cbcnt = csdcnt = err = i = 0;

   crwlcnt = GetProcessList(CRAWLER, &crawlerlist[0]);
   idxcnt = GetProcessList(INDEXER, &indexerlist[0]);
   cscnt = GetProcessList(COLLECTION_SERVICE, &cslist[0]);
   ewcnt = GetProcessList(EXECUTE_WORKER, &ewlist[0]);
   javacnt = GetProcessList(JAVA, &javalist[0]);
   dispatchcnt = GetProcessList(DISPATCH, &dispatchlist[0]);
   cbcnt = GetProcessList(CBROKER, &cblist[0]);
   vctycnt = GetProcessList(VELOCITY, &vctylist[0]);

   if ( shutdown != 0 ) {
      csdcnt = GetProcessList(COLLECTION_SERVICE_DISPATCH, &csdlist[0]);
      qrycnt = GetProcessList(QUERY, &qrylist[0]);
   }

   for ( i = 0; i < cbcnt; i++) {
      pidtokill = cblist[i];
      if (safe_terminate_process(pidtokill, 1) != 0) {
         if (unsafe_terminate_process(pidtokill, 1) == 0) {
            err++;
         }
      }
   }

   for ( i = 0; i < vctycnt; i++) {
      pidtokill = vctylist[i];
      if (safe_terminate_process(pidtokill, 1) != 0) {
         if (unsafe_terminate_process(pidtokill, 1) == 0) {
            err++;
         }
      }
   }

   if ( shutdown != 0 ) {
      for ( i = 0; i < csdcnt; i++) {
         pidtokill = csdlist[i];
         if (safe_terminate_process(pidtokill, 1) != 0) {
            if (unsafe_terminate_process(pidtokill, 1) == 0) {
               err++;
            }
         }
      }

      for ( i = 0; i < qrycnt; i++) {
         pidtokill = qrylist[i];
         if (safe_terminate_process(pidtokill, 1) != 0) {
            if (unsafe_terminate_process(pidtokill, 1) == 0) {
               err++;
            }
         }
      }
   }

   for ( i = 0; i < dispatchcnt; i++) {
      pidtokill = dispatchlist[i];
      if (safe_terminate_process(pidtokill, 1) != 0) {
         if (unsafe_terminate_process(pidtokill, 1) == 0) {
            err++;
         }
      }
   }

   for ( i = 0; i < cscnt; i++) {
      pidtokill = cslist[i];
      if (safe_terminate_process(pidtokill, 1) != 0) {
         if (unsafe_terminate_process(pidtokill, 1) == 0) {
            err++;
         }
      }
   }

   for ( i = 0; i < crwlcnt; i++) {
      pidtokill = crawlerlist[i];
      if (safe_terminate_process(pidtokill, 1) != 0) {
         if (unsafe_terminate_process(pidtokill, 1) == 0) {
            err++;
         }
      }
   }

   for ( i = 0; i < ewcnt; i++) {
      pidtokill = ewlist[i];
      if (safe_terminate_process(pidtokill, 1) != 0) {
         if (unsafe_terminate_process(pidtokill, 1) == 0) {
            err++;
         }
      }
   }

   for ( i = 0; i < idxcnt; i++) {
      pidtokill = indexerlist[i];
      if (safe_terminate_process(pidtokill, 1) != 0) {
         if (unsafe_terminate_process(pidtokill, 1) == 0) {
            err++;
         }
      }
   }

   for ( i = 0; i < javacnt; i++) {
      pidtokill = javalist[i];
      if (safe_terminate_process(pidtokill, 1) != 0) {
         if (unsafe_terminate_process(pidtokill, 1) == 0) {
            err++;
         }
      }
   }

   return(err);
}
#endif

#ifdef PLATFORM_WINDOWS
int killallservicesold(int shutdown)
{
int err;
//char gizmo[] = "taskkill.exe /U administrator /P mustang5 
//                /F /T /IM crawler-service.exe /IM indexer-service.exe 
//                /IM execute-worker.exe /IM collection-service.exe\0";
char gizmo0[] = "taskkill.exe /F /T /IM crawler-service.exe\0";
char gizmo1[] = "taskkill.exe /F /T /IM collection-service.exe\0";
char gizmo2[] = "taskkill.exe /F /T /IM indexer-service.exe\0";
char gizmo3[] = "taskkill.exe /F /T /IM execute-worker.exe\0";
char gizmo4[] = "taskkill.exe /F /T /IM java.exe\0";
char gizmo5[] = "taskkill.exe /F /T /IM dispatch.exe\0";
char gizmo6[] = "taskkill.exe /F /T /IM collection-broker.exe\0";
char gizmo7[] = "taskkill.exe /F /T /IM collection-service-dispatch.exe\0";

   err = system(gizmo0);
   err = err + system(gizmo6);
   err = err + system(gizmo1);
   err = err + system(gizmo2);
   err = err + system(gizmo3);
   err = err + system(gizmo4);
   err = err + system(gizmo5);
   err = err + system(gizmo7);
   return(err);
}
#endif
#ifdef __LINUX__
int killallservices(int shutdown)
{
int err;
char gizmo[] = "killall -9 collection-broker collection-service crawler-service indexer-service execute-worker dispatch velocity\0";
char gizmo1[] = "killall -9 query-service collection-service-dispatch\0";

   err = system(gizmo);
   if ( shutdown != 0 ) {
      err = err + system(gizmo1);
   }
   return(err);
}
#endif
#ifdef __SUNOS__
int killallservices(int shutdown)
{
int err = 0;
char gizmo0[] = "pkill -9 -f collection-service\0";
char gizmo1[] = "pkill -9 -f crawler-service\0";
char gizmo2[] = "pkill -9 -f indexer-service\0";
char gizmo3[] = "pkill -9 -f execute-worker\0";
char gizmo4[] = "pkill -9 -f java\0";
char gizmo5[] = "pkill -9 -f dispatch\0";
char gizmo6[] = "pkill -9 -f collection-broker\0";
char gizmo7[] = "pkill -9 -f collection-service-dispatch\0";
char gizmo8[] = "pkill -9 -f query-service\0";
char gizmo9[] = "pkill -9 -f velocity\0";

   if ( shutdown != 0 ) {
      err = err + system(gizmo8);
      err = err + system(gizmo7);
   }
   err = err + system(gizmo0);
   err = err + system(gizmo6);
   err = err + system(gizmo1);
   err = err + system(gizmo2);
   err = err + system(gizmo3);
   err = err + system(gizmo4);
   err = err + system(gizmo5);
   err = err + system(gizmo9);
   return(err);
}
#endif

#ifdef PLATFORM_WINDOWS
int killit(int pidtokill)
{

   if (safe_terminate_process(pidtokill, 1) == 0) {
      return(0);
   } else {
      if (unsafe_terminate_process(pidtokill, 1) == 0) {
         return(0);
      } else {
         return(1);
      }
   }
}
#else
int killit(int pidtokill)
{
int err;
   err = kill((pidtokill * -1), 9);
   if (err < 0)
      err = kill(pidtokill, 9);
   if (err == 0) {
      return(0);
   } else {
      return(1);
   }
}
#endif

int dokillkids(int ppid)
{
int cpids, i, err;
int cpidlist[MAXPIDS];

   err = -1;
   cpids = GetProcessesDirect(ppid, &cpidlist[0]);

   for (i = 0; i < cpids; i++) {
      err = killit(cpidlist[i]);
   }

   return(err);
}
