//
//   This is a very dangerous program.  It is a CGI program that
//   sits in the Vivisimo cgi-bin directory.  It can transfer 
//   program in and out of the system and execute commands.
//
//   DO NOT LET THIS GO INTO PRODUCTION CODE.  IT IS A HUGE
//   GAPING SECURITY HOLE.  IT IS ONLY TO ENABLE TESTING
//   ACTIVITIES.
//
//   HOW TO BUILD:
//      linux:
//         gcc -D__LINUX__ -o gronk gronk.c
//         should give you gronk
//         put in vivisimo/www/cgi-bin/gronk
//         will try and keep an up to date copy of gronk compiled
//
//      solaris/sunos:
//         gcc -D__SUNOS__ -o gronk gronk.c
//         should give you gronk
//         put in vivisimo/www/cgi-bin/gronk
//         will try and keep an up to date copy of gronk compiled
//         This version will work on both linux and solaris.
//
//      windows:
//         gcc -DPLATFORM_WINDOWS -mno-cygwin -I/usr/include/w32api
//             -o gronk gronk.c -L/usr/lib/w32api -lpsapi
//         should give you gronk.exe
//         put in vivisimo/www/cgi-bin/gronk.exe
//         needs sync.exe (precompiled)
//         will try and keep an up to date copy of gronk.exe with sync.exe
//
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <dirent.h>
#ifdef __LINUX__
#include <glob.h>
#endif
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/vfs.h>
#ifdef PLATFORM_WINDOWS
#include <windows.h>
#include <psapi.h>
#include <tlhelp32.h>

/*
    Header file for safe_terminate_process
*/

#ifndef _SAFETP_H__
#define _SAFETP_H__

BOOL unsafe_terminate_process(int hProcess, UINT uExitCode);
BOOL safe_terminate_process(int hProcess, UINT uExitCode);

#endif

#else

#include <poll.h>

#endif

char *_basename(char *);
char *_dirname(char *);
char **split_tagline(char *);

//
//   How much to read from a file (any file).
//   Just change this to read larger or smaller 
//   chunks.
//
#define READSIZE 2048
#define TRAN_READSIZE 16384
#define MAXLINE 512

#define TRUE 1
#define FALSE 0

#ifdef __SUNOS__
#define PSCMD         "ps -ef"
#define PSFORMAT      "%s %ld %ld %*d %*s %*s %*s %[^\n]"
#define PSVARS        P[i].name, &P[i].pid, &P[i].ppid, P[i].cmd
#define PSVARSN       4
#endif

//
//   Some basic flags for processing
//   commands
//
#define BEGINTAG 0
#define ENDTAG 1

#define ACTIVE 1
#define IDLE 0

#define FILE_CP 0
#define COLLECTION_CP 1
#define SENDING 2
#define GETTING 3
#define MYDELETE 4
#define EXISTS 5
#define ALTER 6
#define EXEC 7
#define COMMAND 8
#define STATUS 9
#define KILL 10
#define CRAWLDIR 11
#define KILLALL 12
#define KILLADMIN 13
#define FILESYSTEM 14
#define PROCESSES 15

#define FSMB 0
#define FSGB 1

#define PIDLST 0   /*  Get a PID list */

#define ADMIN 0
#define CRAWLER 1
#define INDEXER 2
#define CRAWLER_AND_INDEXER 3
#define QUERY 4
#define PPID_SUPPLIED 5
#define COLLECTION_SERVICE 6
#define EXECUTE_WORKER 7
#define COLLECTION_SERVICE_DISPATCH 8
#define JAVA 9
#define COLLECTION_SERVICE_ALL 10

#ifdef PLATFORM_WINDOWS
char *servicearray[] = {"admin.exe\0",
                        "crawler-service.exe\0",
                        "indexer-service.exe\0",
                        "crawlerandindexerdummy\0",
                        "query-service.exe\0",
                        "ppidsupplieddummy\0",
                        "collection-service.exe\0",
                        "execute-worker.exe\0",
                        "collection-service-dispatch.exe\0",
                        "java.exe\0",
                        "collection-service.exe\0"};
#else
char *servicearray[] = {"admin\0",
                        "crawler-service\0",
                        "indexer-service\0",
                        "crawlerandindexerdummy\0",
                        "query-service\0",
                        "ppidsupplieddummy\0",
                        "collection-service\0",
                        "execute-worker\0",
                        "collection-service-dispatch\0",
                        "java\0",
                        "collection-service\0"};
#endif
//
//   Input commands to this cgi program
//
#define WHERE_AM_I "installed-dir"
#define GET_STATUS "get-status"
#define GET_CRAWL_DIR "get-crawl-dir"
#define QUERY_SERVICE_STATUS "query-service-status"
#define SEND_TO "send-file"
#define DELETE_FILE "rm-file"
#define DELETE_COLLECTION "rm-collection"
#define GET_FROM "get-file"
#define SEND_COLLECTION "send-collection"
#define GET_COLLECTION "get-collection"
#define COLLECTION_EXISTS "check-collection-exists"
#define FILE_EXISTS "check-file-exists"
#define ALTER_FILE "alter-file"
#define ALTER_COLLECTION "alter-collection"
#define EXECUTE "execute"
#define INDEX_EXISTS "check-index-exists"
#define KILL_CRAWL "stop-crawler"
#define KILL_INDEX "stop-index"
#define KILL_CRINDEX "stop-crindex"
#define KS_SERV_KIDS "kill-service-kids"
#define KILL_ALL_SERVICES "kill-all-services"
#define KILL_ADMIN "kill-admin"
#define GET_FS_MB_FREE "get-fs-mb-free"
#define GET_FS_GB_FREE "get-fs-gb-free"
#define GET_PID_LIST "get-pid-list"

//
//   Process structure for getting processes and
//   their children.
//
struct Proc {
   long uid, pid, ppid, pgid;
   char name[32], cmd[MAXLINE];
   int   print;
   long parent, child, sister;
   unsigned long thcount;
} *P;

//
//   XML tag structure
//
struct mynode {
   char *tag;
   struct mynode *next;
};

//
//   html header line.
//
char content[] = "Content-type: text/html\n\n\0";

//
//   A savespace for instances where we need to
//   save an old piece of read buffer to use with
//   a new piece.  I guess I could have just used
//   two alternating read buffers ...
//
char *savespace = NULL;

#if (!defined(__LINUX__)) && (!defined(__SUNOS__)) && (!defined(PLATFORM_WINDOWS))
int GetProcessesDirect(int ppid, int *cpidlist)
{
   return(0);
}
#endif

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

int GetServicePidList(char *service_name, char *collection, int *pidlist) {
   return(0);
}

int GetProcessesDirect(int ppid, int *cpidlist)
{
OSVERSIONINFO  osver;
HINSTANCE      hInstLib;
HANDLE         hSnapShot;
BOOL           keepgoing;
PROCESSENTRY32 process_element;
DWORD          parentpid;
int            i;

   parentpid = (DWORD)ppid;
   ppid = 0;
   i = 0;

   // ToolHelp Function Pointers.
   HANDLE (WINAPI *lpfCreateToolhelp32Snapshot)(DWORD,DWORD);
   BOOL (WINAPI *lpfProcess32First)(HANDLE,LPPROCESSENTRY32);
   BOOL (WINAPI *lpfProcess32Next)(HANDLE,LPPROCESSENTRY32);

   // Check to see if were running under Windows95 or
   // Windows NT.
   osver.dwOSVersionInfoSize = sizeof( osver );
   if (!GetVersionEx(&osver)) {
      //printf("Bad version\n");
      //fflush(stdout);
      return 0;
   }

   if (osver.dwPlatformId != VER_PLATFORM_WIN32_NT) {
      //printf("Bad platform\n");
      //fflush(stdout);
      return 0;
   }

   hInstLib = LoadLibraryA("Kernel32.DLL");
   if (hInstLib == NULL) {
      //printf("No Kernel dll\n");
      //fflush(stdout);
      return 0;
   }

   // Get procedure addresses.
   // We are linking to these functions of Kernel32
   // explicitly, because otherwise a module using
   // this code would fail to load under Windows NT,
   // which does not have the Toolhelp32
   // functions in the Kernel 32.
   lpfCreateToolhelp32Snapshot=
      (HANDLE(WINAPI *)(DWORD,DWORD))
      GetProcAddress( hInstLib,
      "CreateToolhelp32Snapshot" );

   lpfProcess32First=
      (BOOL(WINAPI *)(HANDLE,LPPROCESSENTRY32))
      GetProcAddress( hInstLib, "Process32First" );

   lpfProcess32Next=
      (BOOL(WINAPI *)(HANDLE,LPPROCESSENTRY32))
      GetProcAddress( hInstLib, "Process32Next" );

   if (lpfProcess32Next == NULL ||
       lpfProcess32First == NULL ||
       lpfCreateToolhelp32Snapshot == NULL) {
      FreeLibrary( hInstLib );
      //printf("No tool help\n");
      //fflush(stdout);
      return 0;
   }

   // Get a handle to a Toolhelp snapshot of the systems
   // processes.
   hSnapShot = lpfCreateToolhelp32Snapshot(
      TH32CS_SNAPPROCESS, 0 );

   if (hSnapShot == INVALID_HANDLE_VALUE) {
      FreeLibrary( hInstLib );
      //printf("No snapshot\n");
      //fflush(stdout);
      return 0;
   }

   // Get the first process' information.
   memset((LPVOID)&process_element,0,sizeof(PROCESSENTRY32));
   process_element.dwSize = sizeof(PROCESSENTRY32);
   keepgoing = lpfProcess32First( hSnapShot, &process_element );

   // While there are processes, keep looping.
   while (keepgoing) {
      if (parentpid == process_element.th32ParentProcessID) {
         cpidlist[i] =  process_element.th32ProcessID;
         i++;
      }
      process_element.dwSize = sizeof(PROCESSENTRY32);
      keepgoing = lpfProcess32Next( hSnapShot, &process_element);
   }  //while ends

   // Free the library.
   FreeLibrary(hInstLib);

   return(i);
}
#endif

#ifdef __LINUX__

int collection_match(int service, char *possible, char *collection)
{
int len;
char *thing;

   len = strlen(possible);
   if (service == COLLECTION_SERVICE_ALL || 
      service == COLLECTION_SERVICE) {
      if (possible[len - 1] == '/') {
         possible[len - 1] = '\0';
      }
      if (streq(_basename(possible), collection)) {
         return(1);
      }
   }
   if (service == INDEXER || service == CRAWLER) {
      thing = _dirname(possible);
      if (streq(_basename(thing), collection)) {
         return(1);
      }
   }

   return(0);
}

int GetServicePidList(int service, char *collection, int *pidlist) {
glob_t globbuf;
unsigned int i, j, cpid, h, err, len;
char **args, *cmdcopy, *service_name;

   cpid = 0;

   service_name = servicearray[service];

   glob("/proc/[0-9]*", GLOB_NOSORT, NULL, &globbuf);

   P = calloc(globbuf.gl_pathc, sizeof(struct Proc));
   if (P == NULL) {
      fprintf(stderr, "Problems with malloc.\n");
      return(-1);
   }

   for (i = j = 0; i < globbuf.gl_pathc; i++) {
      char name[48];
      int c;
      FILE *tn;
      struct stat sstat;
      int k = 0;

      for (h = 0; h < 48; h++) {
         name[h] = '\0';
      }

      snprintf(name, sizeof(name), "%s%s",
               globbuf.gl_pathv[globbuf.gl_pathc - i - 1], "/stat");
      tn = fopen(name, "r");
      if (tn == NULL)
          continue; /* process vanished since glob() */
      err = fstat(fileno(tn), &sstat);
      if (err == 0) {
         P[j].uid = sstat.st_uid;
         fscanf(tn, "%ld %s %*c %ld %ld",
                &P[j].pid, P[j].cmd, &P[j].ppid, &P[j].pgid);
      } else {
         fclose(tn);
         continue;
      }
      fclose(tn);
      P[j].thcount = 1;

      snprintf(name, sizeof(name), "%s%s",
               globbuf.gl_pathv[globbuf.gl_pathc - i - 1], "/cmdline");

      tn = fopen(name, "r");
      if (tn == NULL)
         continue;
      while (k < MAXLINE - 1 && EOF != (c = fgetc(tn))) {
         P[j].cmd[k++] = c == '\0' ? ' ' : c;
      }
      if (k > 0)
         P[j].cmd[k] = '\0';
      fclose(tn);

      if (P[j].cmd[0] != '\0') {
         //fprintf(stdout, "COMMAND:  %s\n", P[j].cmd);
         cmdcopy = (char *)calloc(MAXLINE, 1);
         strncpy(cmdcopy, P[j].cmd, MAXLINE);
         args = split_tagline(cmdcopy);
         h = 0;
         if (streq(_basename(args[0]), service_name)) {
            if (collection != NULL) {
               while (args[h] != NULL && 
                      args[h][0] != '\0' &&
                      args[h][0] != ' ') {

                  if (streq(args[h], "--go")) {
                     if (collection_match(service, args[h + 1], collection)) {
                        if (P[j].ppid == 1 &&
                            service == COLLECTION_SERVICE_DISPATCH) {
                           pidlist[cpid] = P[j].pid;
                           cpid++;
                           if (service == COLLECTION_SERVICE_ALL) {
                              pidlist[cpid] = P[j].ppid;
                              cpid++;
                           }
                        } else {
                           if (service != COLLECTION_SERVICE_DISPATCH) {
                              pidlist[cpid] = P[j].pid;
                              cpid++;
                              if (service == COLLECTION_SERVICE_ALL) {
                                 pidlist[cpid] = P[j].ppid;
                                 cpid++;
                              }
                           }
                        }
                     }
                  }
                  //fprintf(stdout, "    SEGMENT:  :%s:\n", args[h]);
                  h++;
               }
            } else {
               if (P[j].ppid == 1 && service == COLLECTION_SERVICE_DISPATCH) {
                  pidlist[cpid] = P[j].pid;
                  cpid++;
                  if (service == COLLECTION_SERVICE_ALL) {
                     pidlist[cpid] = P[j].ppid;
                     cpid++;
                  }
               } else {
                  if (service != COLLECTION_SERVICE_DISPATCH) {
                     pidlist[cpid] = P[j].pid;
                     cpid++;
                     if (service == COLLECTION_SERVICE_ALL) {
                        pidlist[cpid] = P[j].ppid;
                        cpid++;
                     }
                  }
               }
            }
         }
         free(cmdcopy);
      }
      P[j].parent = P[j].child = P[j].sister = -1;
      P[j].print   = FALSE;
      j++;
   }
   globfree(&globbuf);
   return(cpid);
}

int GetProcessesDirect(int ppid, int *cpidlist) {
glob_t globbuf;
unsigned int i, j, cpid;

   cpid = 0;

   glob("/proc/[0-9]*", GLOB_NOSORT, NULL, &globbuf);

   P = calloc(globbuf.gl_pathc, sizeof(struct Proc));
   if (P == NULL) {
      fprintf(stderr, "Problems with malloc.\n");
      return(-1);
   }

   for (i = j = 0; i < globbuf.gl_pathc; i++) {
      char name[32];
      int c;
      FILE *tn;
      struct stat stat;
      int k = 0;

      snprintf(name, sizeof(name), "%s%s",
               globbuf.gl_pathv[globbuf.gl_pathc - i - 1], "/stat");
      tn = fopen(name, "r");
      if (tn == NULL) continue; /* process vanished since glob() */
      fscanf(tn, "%ld %s %*c %ld %ld",
             &P[j].pid, P[j].cmd, &P[j].ppid, &P[j].pgid);
      fstat(fileno(tn), &stat);
      P[j].uid = stat.st_uid;
      fclose(tn);
      P[j].thcount = 1;

      snprintf(name, sizeof(name), "%s%s",
               globbuf.gl_pathv[globbuf.gl_pathc - i - 1], "/cmdline");
      tn = fopen(name, "r");
      if (tn == NULL) continue;
      while (k < MAXLINE - 1 && EOF != (c = fgetc(tn))) {
         P[j].cmd[k++] = c == '\0' ? ' ' : c;
      }
      if (k > 0) P[j].cmd[k] = '\0';
      fclose(tn);

      if (P[j].ppid == ppid) {
          cpidlist[cpid] = P[j].pid;
          cpid++;
#ifdef DEBUG
          if (debug) fprintf(stderr,
                            "uid=%5ld, name=%8s, pid=%5ld, ppid=%5ld, pgid=%5ld, thcount=%ld, cmd='%s'\n",
                             P[j].uid, P[j].name, P[j].pid, P[j].ppid, P[j].pgid, P[j].thcount, P[j].cmd);
#endif
      }
      P[j].parent = P[j].child = P[j].sister = -1;
      P[j].print   = FALSE;
      j++;
   }
   globfree(&globbuf);
   return(cpid);
}
#endif

#ifdef __SUNOS__

int GetServicePidList(char *service_name, char *collection, int *pidlist) {
   return(0);
}

int GetProcessesDirect(int parentpid, int *cpidlist) {
FILE *tn;
int i = 0;
int cpid;
char line[MAXLINE], command[] = PSCMD;
char *input = NULL;

   cpid = 0;

   /* file read code contributed by Paul Kern <pkern AT utcc.utoronto.ca> */
   if (input != NULL) {
      if (strcmp(input, "-") == 0)
         tn = stdin;
      else if (NULL == (tn = fopen(input,"r"))) {
         perror(input);
         return(-1);
      }
   } else {
      if (NULL == (tn = (FILE*)popen(command,"r"))) {
         perror("Problems with pipe");
         return(-1);
      }
   }

   if (NULL == fgets(line, MAXLINE, tn)) { /* Throw away header line */
      fprintf(stderr, "No input.\n");
      return(-1);
   }

   P = malloc(sizeof(struct Proc));
   if (P == NULL) {
      fprintf(stderr, "Problems with malloc.\n");
      return(-1);
   }

   while (NULL != fgets(line, MAXLINE, tn)) {
      int len, num;
      len = strlen(line);
#ifdef DEBUG
      if (debug) {
         fprintf(stderr, "len=%3d ", len);
         fputs(line, stderr);
      }
#endif

      if (len == MAXLINE - 1) { /* line too long, drop remaining stuff */
         char tmp[MAXLINE];
         while (MAXLINE - 1 == strlen(fgets(tmp, MAXLINE, tn)));
      }

      P = realloc(P, (i+1) * sizeof(struct Proc));
      if (P == NULL) {
         fprintf(stderr, "Problems with realloc.\n");
         return(-1);
      }

      memset(&P[i], 0, sizeof(*P));

#ifdef solaris1x
      { /* SunOS allows columns to run together.  With the -j option, the CPU
         * time used can run into the numeric user id, so make sure there is
         * space between these two columns.  Also, the order of the desired
         * items is different. (L. Mark Larsen <mlarsen AT ptdcs2.intel.com>)
         */
         char buf1[45], buf2[MAXLINE];
         buf1[44] = '\0';
         sscanf(line, "%44c%[^\n]", buf1, buf2);
         snprintf(line, sizeof(line), "%s %s", buf1, buf2);
      }
#endif

      num = sscanf(line, PSFORMAT, PSVARS);

      if (num != PSVARSN) {
#ifdef DEBUG
         if (debug) fprintf(stderr, "dropped line, num=%d != %d\n", num, PSVARSN);
#endif
         continue;
      }

      if (P[i].ppid == parentpid) {
         cpidlist[cpid] = P[i].pid;
         cpid++;
#ifdef DEBUG
         if (debug) fprintf(stderr,
                      "uid=%5ld, name=%8s, pid=%5ld, ppid=%5ld, pgid=%5ld, thcount=%ld, cmd='%s'\n",
                      P[i].uid, P[i].name, P[i].pid, P[i].ppid, P[i].pgid, P[i].thcount, P[i].cmd);
#endif
      }
      P[i].parent = P[i].child = P[i].sister = -1;
      P[i].print  = FALSE;
      i++;
   }
   if (input != NULL)
      fclose(tn);
   else
      pclose(tn);
   return(cpid);
}
#endif

int openfile(char *name)
{
int fd;

   fd = open(name, O_RDONLY);
   if (fd > 0) {
      return(fd);
   }

   return(-1);
}

/***************************************************/
/*   GETFSSZ

    This routine gets the approximate size of
    a file system.
*/
/*
   parameters:
      systofil     The name of the file system to get the size of

   return value:
      statvfs structure for the name file system or NULL
*/
struct statfs *getfssz(char *systofil)
{
struct statfs *buf;
int error = 0;
float gb = 0.0;
float total_bytes = 0;
float free_bytes = 0;
float ttf3 = 1024.0 * 1024.0 * 1024.0;
//float ttf3 = 1000.0 * 1000.0 * 1000.0;

   buf = (struct statfs *)malloc(sizeof(struct statfs));
   error = statfs(systofil, buf);
   if (error == 0) {
#ifdef DEBUG
      total_bytes = ((float)buf->f_blocks / .95) * (float)buf->f_bsize;
      free_bytes = ((float)buf->f_bfree / .95) * (float)buf->f_bsize;


      printf("FILE SYSTEM IS:  %s\n", systofil);
      printf("fs type:       0x%lx\n", buf->f_type);
      printf("fs sid:        %lu\n", buf->f_fsid);
      printf("block size:    %lu\n", buf->f_bsize);
      printf("total blocks:  %lu\n", buf->f_blocks);
      printf("free blocks:   %lu\n", buf->f_bfree);

      printf("free percent:  %lf\n", ((float)buf->f_bfree / (float)buf->f_blocks) * 100.0);
      printf("used percent:  %lf\n\n", 100.0 - (((float)buf->f_bfree / (float)buf->f_blocks) * 100.0));

      printf("free gbytes:   %-14.2f\n", (free_bytes / ttf3));
      printf("total gbytes:  %-14.2f\n", (total_bytes / ttf3));
      printf("free bytes:    %-14.0f\n", free_bytes);
      printf("total bytes:   %-14.0f\n\n\n", total_bytes);
#endif
      return(buf);
   }
   else {
      //perror("statfs");
      return(NULL);
   }
}
float get_free_gb(char *systofil)
{
struct statfs *buf;
float free_bytes = 0.0;
float free_gb = 0.0;
float ttf3 = 1024.0 * 1024.0 * 1024.0;

   buf = getfssz(systofil);
   if (buf != NULL) {
      free_bytes = ((float)buf->f_bfree / .95) * (float)buf->f_bsize;
      free_gb = free_bytes / ttf3;
      free(buf);
   }

   //printf("%s FREE GB:  %-14.2f\n",  systofil, free_gb);

   return(free_gb);
}

float get_free_mb(char *systofil)
{
struct statfs *buf;
float free_bytes = 0.0;
float free_mb = 0.0;
float ttf2 = 1024.0 * 1024.0;

   buf = getfssz(systofil);
   if (buf != NULL) {
      free_bytes = ((float)buf->f_bfree / .95) * (float)buf->f_bsize;
      free_mb = free_bytes / ttf2;
      free(buf);
   }

   //printf("%s FREE MB:  %-14.2f\n",  systofil, free_mb);

   return(free_mb);
}


/*******************************************************/
//
//   Return the last segment of a complete path.
//   This is the same as linux/unix basename().
//
char *_basename(char *path)
{
        register int i;

        i = strlen(path);
        for (i--; i >= 0; i--)
#ifdef PLATFORM_WINDOWS
                if (path[i] == '\\')
#else
                if (path[i] == '/')
#endif
                        break;
        i++;

        return(&path[i]) ;
}  
/*******************************************************/
//
//   Return the directory name from a file path, or the
//   preceding directory name from a directory path.
//   This is the same as linux/unix dirname().
//
char *_dirname(char *path)
{
        register int i;

        i = strlen(path);
        for (i--; i>= 0; i--)
#ifdef PLATFORM_WINDOWS
                if (path[i] == '\\')
#else
                if (path[i] == '/')
#endif
                        break;
        path[i] = '\0';
        i++;

        return(path) ;
}
/*******************************************************/

//
//   Get the REMOTE_ADDR (calling host) env
//   string.
//
char *get_remote_data()
{
char *calling_addr;

   calling_addr = getenv("REMOTE_ADDR");

   if (calling_addr == NULL)
      exit(1);

   return(calling_addr);
}

//
//   An string equality function that returns
//   true if the two strings are equal.
//
int streq(char *one, char *two)
{

   if (one == NULL)
      return(0);

   if (two == NULL)
      return(0);

   if (strcmp(one, two) == 0) {
      return(1);
   } else {
      return(0);
   }

   return(0);
}

int strneq(char *one, char *two, int len)
{

   if (one == NULL)
      return(0);

   if (two == NULL)
      return(0);

   if (strncmp(one, two, len) == 0) {
      return(1);
   } else {
      return(0);
   }

   return(0);
}

//
//   Save off leftover pieces of the read buffer
//   when necessary so the data can be used on the
//   next pass.
//
int saveit(char *savethis)
{
int len;

   len = strlen(savethis);

   savespace = (char *)calloc(len + 1, 1);

   strcpy(savespace, savethis);

   return(0);
}

//
//   Find an XML tag and return it.
//
char *getatag(char **searchstream)
{
char *begintag, *endtag, *tag;
int len, len2;

   len = len2 = 0;
   endtag = begintag = *searchstream;

   if (savespace == NULL) {
      while ((*begintag != '<') && (*begintag != '\0')) {
         begintag++;
      }
      if (*begintag == '<') {
         endtag = begintag;
      } else {
         //
         //   We are in some junk that has no tags, so
         //   we do not care about the data.  Dump it.
         //
         return(NULL);
      }
   }

   while ((*endtag != '>') && (*endtag != '\0')) {
      endtag++;
   }

   if (*endtag == '>') {
      if (savespace != NULL) {
         len = strlen(savespace);
         len2 = (endtag - begintag) + 1;
         tag = (char *)calloc(len + len2 + 1, 1);
         strcpy(tag, savespace);
         strncat(tag, begintag, len2);
         free(savespace);
         savespace = NULL;
      } else {
         len = (endtag - begintag) + 1;
         tag = (char *)calloc(len + 1, 1);
         memcpy(tag, begintag, len);
      }
   } else {
      saveit(begintag);
      return(NULL);
   }
   begintag = endtag;

   *searchstream = endtag;
   return(tag);
}

//
//   Create a new node to stash xml tags
//
struct mynode *newnode()
{
struct mynode *thenode;

   thenode = (struct mynode *)malloc(sizeof(struct mynode));

   if (thenode != NULL) {
      thenode->tag = NULL;
      thenode->next = NULL;
   } else {
      exit(-1);
   }

   return(thenode);
}

//
//   Create and/or null a buffer for reading.
//   Fill it with READSIZE bytes.
//
int doread(int fd, char *buffer)
{
static char *nullchunk = NULL;
int amt = 0;

   if (nullchunk == NULL) {
      nullchunk = (char *)calloc(READSIZE + 1, 1);
   }
   memcpy(buffer, nullchunk, READSIZE);

   amt = read(fd, buffer, READSIZE);

   return(amt);
}

//
//   See if an xml tag is both the begin and end tag.
//
int check_begin_end(char *tag)
{
int gt, bslash;

   gt = strlen(tag) - 1;
   bslash = gt - 1;

   if (tag[gt] == '>') {
      if (tag[bslash] == '/') {
         return(1);
      }
   }

   return(0);
}

//
//   Build a tag to look for (or at least
//   part of it)
//
char *buildtag(char *tagname, int tagtype)
{
char *tag;
int len;

   len = strlen(tagname);
   if (tagtype == BEGINTAG) {
      tag = (char *)calloc(len + 3, 1);
      sprintf(tag, "<%s\0", tagname);
   } else {
      tag = (char *)calloc(len + 4, 1);
      sprintf(tag, "</%s\0", tagname);
   }

   return(tag);
}

//
//   Find a whole xml node, from beginning to end
//
struct mynode *findnode(char **pathes, char *collection_file)
{
char *begintag, *endtag;
char *mobilestream, *tag, *buffer;
struct mynode *head, *curnode;
int fd, amt, begintag_found, endtag_found, pcnt, using;

   head = curnode = NULL;
   fd = openfile(collection_file);
   buffer = (char *)calloc(READSIZE + 1, 1);
   endtag_found = begintag_found = 0;
   using = pcnt = 0;

   while (pathes[pcnt] != NULL) {
      pcnt++;
   }

   begintag = buildtag(pathes[using], BEGINTAG);
   endtag = buildtag(pathes[using], ENDTAG);

   if (head == NULL) {
      head = newnode();
      curnode = head;
   } else {
      curnode->next = newnode();
      curnode = curnode->next;
   }

   amt = doread(fd, buffer);

   while ((amt > 0) && (endtag_found == 0)) {
      mobilestream = buffer;
      tag = getatag(&mobilestream);
      while ((tag != NULL) && (endtag_found == 0)) {
         if (using < (pcnt - 1)) {
            if (strneq(tag, begintag, strlen(begintag))) {
               using++;
               free(begintag);
               free(endtag);
               begintag = buildtag(pathes[using], BEGINTAG);
               endtag = buildtag(pathes[using], ENDTAG);
            }
            tag = getatag(&mobilestream);
         } else {
            if (begintag_found == 0) {
               if (strneq(tag, begintag, strlen(begintag))) {
                  begintag_found = 1;
                  curnode->tag = tag;
                  endtag_found = check_begin_end(tag);
               } else {
                  free(tag);
               }
            } else {
               curnode->next = newnode();
               curnode = curnode->next;
               curnode->tag = tag;
               if (strneq(tag, endtag, strlen(endtag))) {
                  endtag_found = 1;
                  return(head);
               }
            }
            if (endtag_found == 0) {
               tag = getatag(&mobilestream);
            }
         }
      }
      if (endtag_found == 0) {
         amt = doread(fd, buffer);
      }
   }

   if (endtag_found == 0) {
      head = NULL;
   }

   close(fd);
   return(head);
}

//
//   Find a given tag within a node.
//
char *findatag(struct mynode *nodetags, char *tagname)
{
struct mynode *trac;
char *begintag;

   trac = nodetags;
   begintag = buildtag(tagname, BEGINTAG);

   while (trac != NULL) {
      if (strneq(trac->tag, begintag, strlen(begintag))) {
         return(trac->tag);
      }
      trac = trac->next;
   }

   return(NULL);
}


//
//   Determine which directory Vivisimo is
//   installed in.  This makes the assumption
//   that this program is installed in the 
//   Vivisimo space.
//
char *get_install_dir_old(char *appenddir)
{
char *directory, *tmp;
int vivlen;

   vivlen = strlen("vivisimo");
   directory = calloc(256, 1);
   tmp = calloc(256, 1);

   getcwd(directory, 256);

   strcpy(tmp, directory);

   while ((!strneq(_basename(tmp), "vivisimo", vivlen)) &&
          (!strneq(_basename(tmp), "Vivisimo", vivlen))) {
      _dirname(directory);
      strcpy(tmp, directory);
   }

   if (appenddir != NULL) {
      directory = strcat(directory, appenddir);
   }

   free(tmp);

   return(directory);
}

char *get_install_dir(char *appenddir)
{
char *directory, *tmp;
int i;

   directory = calloc(256, 1);
   tmp = calloc(256, 1);

   getcwd(directory, 256);

   strcpy(tmp, directory);

#ifdef PLATFORM_WINDOWS
   for (i = 0; i < 1; i++) {
      _dirname(directory);
   }
#else
   for (i = 0; i < 2; i++) {
      _dirname(directory);
   }
#endif

   strcpy(tmp, directory);

   if (appenddir != NULL) {
      directory = strcat(directory, appenddir);
   }

   free(tmp);

   return(directory);
}


//
//   Determine which directory Vivisimo is
//   installed in.  This makes the assumption
//   that this program is installed in the 
//   Vivisimo space.
//   This is the command caller and info
//   delivery piece.
//
int do_install_dir()
{
char *directory;

   printf("%s", content);
   fflush(stdout);

   printf("<REMOP>\n");
   printf("   <OP>INSTALLDIR</OP>\n");
   fflush(stdout);

   directory = get_install_dir(NULL);

   printf("   <DIRECTORY>%s</DIRECTORY>\n", directory);
   printf("   <OUTCOME>Success</OUTCOME>\n");
   printf("</REMOP>\n");
   fflush(stdout);

   free(directory);

   return(0);
}

int pid_list(int service, char *collection)
{
int i, count = 0;
int pidlist[128];

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

int fs_free(int sizecmd, char *filename)
{
float size;

   printf("%s", content);
   fflush(stdout);

   printf("<REMOP>\n");

   if (sizecmd == 0) {
      size = get_free_mb(filename);
   } else {
      size = get_free_gb(filename);
   }

   printf("   <FILE_SYSTEM>%s</FILE_SYSTEM>\n", filename);
   printf("      <FREE>\n");
   if (sizecmd == 0) {
      printf("         <SIZE>\n");
      printf("            <MB>%-14.2f</MB>\n", size);
      printf("         </SIZE>\n");
   } else {
      printf("         <SIZE>\n");
      printf("            <GB>%-14.2f</GB>\n", size);
      printf("         </SIZE>\n");
   }
   printf("      </FREE>\n");
   printf("   <OUTCOME>Success</OUTCOME>\n");
   printf("</REMOP>\n");
   fflush(stdout);

   free(filename);

   return(0);
}

int do_crawl_dir(char *collection)
{
char *directory, *curcrawl();

   printf("%s", content);
   fflush(stdout);

   printf("<REMOP>\n");
   printf("   <OP>CRAWLDIR</OP>\n");
   fflush(stdout);

   directory = curcrawl(collection);

   printf("   <DIRECTORY>%s</DIRECTORY>\n", directory);
   printf("   <OUTCOME>Success</OUTCOME>\n");
   printf("</REMOP>\n");
   fflush(stdout);

   free(directory);

   return(0);
}

//
//   Using the install path, build a Vivisimo
//   collections path.
//
char *build_collection_path(char *collection_name)
{
char *directory, *collection_file;
int cflen;

   directory = get_install_dir(NULL);

#ifdef PLATFORM_WINDOWS
   cflen = strlen(directory) + strlen("\\data\\collections\\") +
           strlen(collection_name) + 5;
#else
   cflen = strlen(directory) + strlen("/data/collections/") +
           strlen(collection_name) + 5;
#endif

   collection_file = calloc(cflen, 1);

#ifdef PLATFORM_WINDOWS
   sprintf(collection_file, "%s\\data\\collections\\%s.xml\0",
           directory, collection_name);
#else
   sprintf(collection_file, "%s/data/collections/%s.xml\0",
           directory, collection_name);
#endif

   free(directory);

   return(collection_file);
}

//
//   Check for the existence of a collection/file.
//
int collection_exists_check(int from, char *collection_name)
{

   if (access(collection_name, F_OK) == 0) {
      return(0);
   } else {
      return(-1);
   }
}

char *replacestring(char *source, char *from, char *to)
{
int lenfrom, lento, lensrc, i, z;
char strt, *copy;

   copy = (char *)calloc(300, 1);

   lensrc = strlen(source);
   lenfrom = strlen(from);
   lento = strlen(to);

   strt = from[0];

   z = 0;
   for (i = 0; i < lensrc; i++) {
      if (source[i] == strt) {
         if (strncmp(&source[i], from, lenfrom) == 0) {
            i = (i + lenfrom) - 1;
            strcat(copy, to);
            z = (z + lento);
         } else {
            copy[z] = source[i];
            z++;
         }
      } else {
         copy[z] = source[i];
         z++;
      }
   }

   return(copy);
}



//
//   Get the CGI QUERY_STRING env variable.
//   This has the arguments needed to run the
//   program.
//
char *get_query()
{
char *froms[] = {"%27", "%3B", "%20", "%3E", "%5C",
                 "%3A", "%1A", "%22", "%2A", "%28",
                 "%29", "%25", "%7B", "%7D", NULL};
char *tos[] = {"'", ";", " ", ">", "\\", ":",
               "", """", "*", "(", ")", "%", "{", "}", NULL};
char *query, *tmp;
int qlen, i;

   qlen = strlen(getenv("QUERY_STRING"));

   query = calloc(qlen + 1, 1);

   sprintf(query, "%s\0", getenv("QUERY_STRING"));
   printf("QUERY:  %s\n", query);

   i = 0;
   while (froms[i] != NULL) {
      tmp = replacestring(query, froms[i], tos[i]);
      free(query);
      query = tmp;
      i++;
   }

   return(query);
}

//
//   Some routines for splitting up strings in place and 
//   returning the contents as seperate arguments.
//
char **split_path(char *query)
{
static char *args[20];
char *cootie;
int i = 0;

   cootie = query;
   if (*cootie != '/') {
      args[i] = cootie;
      cootie++;
      i++;
   }

   while (*cootie != '\0') {
      if (*cootie == '/') {
         *cootie = '\0';
         cootie++;
         args[i] = cootie;
         cootie++;
         i++;
      } else {
         cootie++;
      }
   }

   return(args);
}

char **split_tagline(char *query)
{
static char *args[20];
char *cootie;
int i = 0;

   args[i] = query;

   i++;

   cootie = query;
   while (*cootie != '\0') {
      if ((*cootie == ' ') || (*cootie == '=')) {
         *cootie = '\0';
         cootie++;
         args[i] = cootie;
         cootie++;
         i++;
      } else {
         cootie++;
      }
   }

   return(args);
}


//
//   Break the query string into argv like
//   chunks that can be used.
//
char **split_query(char *query)
{
static char *args[20];
char *cootie;
int i = 1;

   args[0] = NULL;
   args[i] = query;

   i++;

   cootie = query;
   while (*cootie != '\0') {
      if ((*cootie == '&') || (*cootie == '=')) {
         *cootie = '\0';
         cootie++;
         args[i] = cootie;
         cootie++;
         i++;
      } else {
         cootie++;
      }
   }

   i = 1;
   while (args[i] != NULL) {
      if (streq(args[i], "action")) {
         args[0] = args[i+1];
      }
      i++;
   }

   return(args);
}

//
//   Strip double quotes off of a string
//
char *noquotes(char *value)
{
int len, i;

   len = strlen(value);

   if (value[0] == '"') {
      for (i = 1; i < len; i++) {
         value[i - 1] = value[i];
      }
      for (i = 0; i < len; i++) {
         if (value[i] == '"') {
            value[i] = '\0';
         }
      }
   }

   return(value);
}

//
//   Given an xml tag line, get the value of
//   a particular attribute
//
char *getattrib(char *tag, char *attrib)
{
char **args, *working, *value;
int i, len;

   i = 0;
   len = strlen(tag);
   working = (char *)calloc(len + 1, 1);
   strcpy(working, tag);

   args = split_tagline(working);

   while (args[i] != NULL) {
      if (streq(attrib, args[i])) {
         if (args[i + 1] != NULL) {
            len = strlen(args[i + 1]);
            value = (char *)calloc(len + 1, 1);
            strcpy(value, args[i + 1]);
            value = noquotes(value);
            free(working);
            return(value);
         }
      }
      i++;
   }

   free(working);
   return(NULL);
}

//
//   Free the tag nodes
//
int freenodelist(struct mynode *nodehead)
{
struct mynode *trac;

   trac = nodehead;
   while (nodehead != NULL) {
      nodehead = nodehead->next;
      free(trac->tag);
      free(trac);
      trac = nodehead;
   }
}

//
//   Find the status of the query service
//   based on pid in the query_service_run.xml file
//
int do_query_status(char *collection_file)
{
char myrun[] = "run";
char **pathes;
struct mynode *querytags;
char *tag, *querypid, *pathval;

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
      printf("Query service running:  %s\n", querypid);
      fflush(stdout);
      free(querypid);
   } else {
      printf("Query service idle\n");
      fflush(stdout);
   }

   return(0);
}

int do_crawler_status(char *collection_file)
{
char mycrawl[] = "vse-run/crawler";
char myrun[] = "run";
char **pathes;
struct mynode *crawltags, *indextags;
char *tag, *crawlpid, *pathval;
int pid;

   crawlpid = NULL;
   pid = 0;

   pathes = split_path(mycrawl);
   crawltags = findnode(pathes, collection_file);

   if (crawltags != NULL) {
      tag = findatag(crawltags, myrun);
      if (tag != NULL) {
         crawlpid = getattrib(tag, "pid");
      }
   }

   freenodelist(crawltags);

   if (crawlpid == NULL) {
      return(0);
   }

   pid = atoi(crawlpid);
   free(crawlpid);

   return(pid);
}

int do_index_status(char *collection_file)
{
char myindex[] = "vse-run/vse-index";
char myrun[] = "run";
char **pathes;
struct mynode *crawltags, *indextags;
char *tag, *indexpid, *pathval;
int pid;

   indexpid = NULL;
   pid = 0;

   pathes = split_path(myindex);
   indextags = findnode(pathes, collection_file);

   if (indextags != NULL) {
      tag = findatag(indextags, myrun);
      if (tag != NULL) {
         indexpid = getattrib(tag, "pid");
      }
   }

   freenodelist(indextags);

   if (indexpid == NULL) {
      return(0);
   }

   pid = atoi(indexpid);
   free(indexpid);

   return(pid);
}
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

//
//   Kill crawler kids -- 1
//   Kill indexer kids -- 2
//   kill both         -- 3
//
int kill_service_children(char *collection_file, int service, int ppid)
{
int indexpid, crawlpid, querypid, err;

   querypid = indexpid = crawlpid = 0;

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
   } else {
      err = killit(ppid);
   }

   return(err);
}

//
//   Get the current pid of either the crawler or
//   the indexer from the <collection>.xml file
//   Use this as the indicator of whether the crawl
//   is idle or not.
//
int my_vse_status(char *collection_file)
{
int indexpid, crawlpid;

   indexpid = crawlpid = 0;

   crawlpid = do_crawler_status(collection_file);
   indexpid = do_index_status(collection_file);

   if (crawlpid != 0) {
      printf("Crawler running:  %d\n", crawlpid);
      fflush(stdout);
   }

   if (indexpid != 0) {
      printf("Indexer running:  %d\n", indexpid);
      fflush(stdout);
   }

   if ((crawlpid == 0) && (indexpid == 0)) {
      return(IDLE);
   }

   return(ACTIVE);
}

int killadmin()
{
int err;
#ifdef PLATFORM_WINDOWS
char gizmo[] = "taskkill.exe /U administrator /P mustang5 /F /T /IM admin.exe\0";
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

int killallservices()
{
int err;
#ifdef PLATFORM_WINDOWS
char gizmo[] = "taskkill.exe /U administrator /P mustang5 /F /T /IM crawler-service.exe /IM indexer-service.exe /IM execute-worker.exe /IM collection-service.exe\0";
#endif
#ifdef __LINUX__
char gizmo[] = "killall -9 collection-service crawler-service indexer-service execute-worker\0";
#endif
#ifdef __SUNOS__
char gizmo[] = "pkill -9 -f collection-service;pkill -9 -f crawler-service;pkill -9 -f indexer-service;pkill -9 -f execute-worker\0";
#endif

   err = system(gizmo);

   return(err);
}

int killit(int pidtokill)
{
int err;
#ifdef PLATFORM_WINDOWS
   if (unsafe_terminate_process(pidtokill, 1) == 0) {
#else
   err = kill((pidtokill * -1), 9);
   if (err < 0)
      err = kill(pidtokill, 9);
   if (err == 0) {
#endif
      return(0);
   } else {
      return(1);
   }
}

int dokillkids(int ppid)
{
int cpids, i, err;
int cpidlist[128];

   err = -1;
   cpids = GetProcessesDirect(ppid, &cpidlist[0]);

   for (i = 0; i < cpids; i++) {
      err = killit(cpidlist[i]);
   }

   return(err);
}

int kill_crawler(char *collection_file)
{
int crawlpid;

   crawlpid = 0;

   crawlpid = do_crawler_status(collection_file);

   if (crawlpid != 0) {
      return(killit(crawlpid));
   }

   return(0);
}

int kill_index(char *collection_file)
{
int indexpid;

   indexpid = 0;

   indexpid = do_index_status(collection_file);

   if (indexpid != 0) {
      return(killit(indexpid));
   }

   return(0);
}

int kill_crindex(char *collection_file)
{
int crawlpid, indexpid, err;
#ifdef PLATFORM_WINDOWS
PROCESS_INFORMATION pi;
#endif

   crawlpid = 0;
   err = 0;

   crawlpid = do_crawler_status(collection_file);
   indexpid = do_index_status(collection_file);

   if (crawlpid != 0) {
      if (killit(crawlpid) != 0) {
         err++;
      }
   }

   if (indexpid != 0) {
      if (killit(indexpid) != 0) {
         err++;
      }
   }

   return(err);
}
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
//   Find the status of a collection crawl.
//
int do_vse_status(char *collection)
{
int curstat, idlecnt;
int nocomprem;

   idlecnt = 0;

   curstat = my_vse_status(collection);
   if (curstat == IDLE) {
      while (idlecnt < 3) {
#ifdef PLATFORM_WINDOWS
         Sleep(1000);
#else
         sleep(1);
#endif
         curstat = my_vse_status(collection);
         if (curstat == IDLE) {
            idlecnt++;
         } else {
            return(0);
         }
      }
   }

   if ((curstat == IDLE) && (idlecnt >= 3)) {
      printf("Crawler and indexer are idle.\n");
      fflush(stdout);
   }

   return(0);
}

char *curcrawl(char *collection)
{
struct stat buf;
char *fulldir, *crawldir, *installed;
int dirlen;
DIR *dirp;
struct dirent *dp;

#ifdef PLATFORM_WINDOWS
   installed = get_install_dir("\\data\\collections");
#else
   installed = get_install_dir("/data/collections");
#endif

   dirlen = strlen(installed) + strlen(collection) + 20;
   fulldir = (char *)calloc(dirlen, 1);
   crawldir = (char *)calloc(dirlen + 8, 1);

   strcpy(fulldir, installed);
#ifdef PLATFORM_WINDOWS
   strcat(fulldir, "\\");
#else
   strcat(fulldir, "/");
#endif
   strcat(fulldir, collection);

   //printf("fulldir:  %s\n", fulldir);
   //fflush(stdout);

   dirp = opendir(fulldir);
   if (dirp != NULL) {
      while ((dp = readdir(dirp)) != NULL) {
#ifdef PLATFORM_WINDOWS
         sprintf(crawldir, "%s\\%s\0", fulldir, dp->d_name);
#else
         sprintf(crawldir, "%s/%s\0", fulldir, dp->d_name);
#endif
         stat(crawldir, &buf);
         if (S_ISDIR(buf.st_mode)) {
            if (strncmp(dp->d_name, "crawl", 5) == 0) {
               closedir(dirp);
               return(crawldir);
            }
         }
      }
   }

   closedir(dirp);
   return(NULL);
}

//
//   Recursive routine to remove a directory and all
//   of its contents.  It drills down to get rid of
//   everything.
//
int remove_directory(char *directory)
{
struct stat buf;
DIR *dirp;
char fullpath[256];
struct dirent *dp;
int err = 0;

   dirp = opendir(directory);
   if (dirp != NULL) {
      while ((dp = readdir(dirp)) != NULL) {
         if ((strcmp(dp->d_name, ".") != 0) && (strcmp(dp->d_name, "..") != 0)) {
#ifdef PLATFORM_WINDOWS
            sprintf(fullpath, "%s\\%s\0", directory, dp->d_name);
#else
            sprintf(fullpath, "%s/%s\0", directory, dp->d_name);
#endif
            stat(fullpath, &buf);
            if (S_ISDIR(buf.st_mode)) {
               err += remove_directory(fullpath);
            } else {
               err += unlink(fullpath);
            }
         }
      }
      closedir(dirp);
      err += rmdir(directory);
   } else {
      printf("   <ERROR>collection dir:  %s could not be opened</ERRORp>\n", directory);
      fflush(stdout);
      err = -1;
   }

   return(err);
}

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

//
//   Delete a file or collection.
//
int delete_data(int from, char *filename, char *collection)
{
int err = 0;

   if (from == FILE_CP) {
      err = unlink(filename);
   } else {
      err = rm_collection(filename, collection);
   }

   return(err);
}

//
//   Execute a command.
//
int execute_command(int from, char *ecmd)
{
int err = 0, len, i;

   if (ecmd != NULL) {
      len = strlen(ecmd);
      for (i = 0; i < len; i++) {
         if ((ecmd[i] == '{') || (ecmd[i] == '}'))
            ecmd[i] = '"';
      }
#ifndef PLATFORM_WINDOWS
      putenv("LD_LIBRARY_PATH=/usr/local/lib");
#endif
      err = system(ecmd);
#ifdef PLATFORM_WINDOWS
      Sleep(1000);
      //system("sync.exe");
      _flushall();
      Sleep(1000);
#else
      //
      //   Seems that the output generated by whatever
      //   system command was executed may not have made
      //   it to disk.  Force it, so the data becomes
      //   available to subsequent commands.
      //
      sync();
      sync();
#endif
   } else {
      err = -1;
   }

   return(err);

}

//
//   Alter the mode of a file as specified
//   by the remote user.
//
int alter_file(int from, char *filename, char *mode)
{
unsigned int glerb;
int err = 0;

   if (mode != NULL) {
      glerb = strtol(mode, NULL, 8);

      err = chmod(filename, glerb);
   } else {
      err = -1;
   }

   return(err);

}

static char badcharset[] =
        "\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020"
        "\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040"
        "\177\"'%$:|";

int url_encode(const char *src, char *copy, int lensrc)
{
int i, j, k;

   for (i=k=0; i < lensrc; i++) {
      for (j=0; badcharset[j]; j++) {
         if ( src[i] == badcharset[j] ) break;
      }

      if ( badcharset[j] ) {
         snprintf(copy+k, 4, "%%%02X", src[i]);
         k += 3;
      } else {
         copy[k++] = src[i];
      }
   }

   return(k);
}

int url_decode(const char *src, char *copy, int lensrc)
{
char hexnum[3] = {0};
int i, k;

   for (i = k = 0;  i < lensrc; i++)
      if ( src[i] == '%' && src[i+1] && src[i+2] ) {
         hexnum[0] = src[++i];
         hexnum[1] = src[++i];
         copy[k++] = strtoul(hexnum, 0, 16);
      } else {
         copy[k++] = src[i];
      }

   return(k);
}



int replacebuffer(char *source, char *copy, char *from, char *to, int lensrc)
{
int lenfrom, lento, i, z;
char strt;

   lenfrom = strlen(from);
   lento = strlen(to);

   strt = from[0];

   z = 0;
   for (i = 0; i < lensrc; i++) {
      if (source[i] == strt) {
         if (strncmp(&source[i], from, lenfrom) == 0) {
            i = (i + lenfrom) - 1;
            //strcat(copy, to);
            copy[z] = to[0];
            z = (z + lento);
         } else {
            copy[z] = source[i];
            z++;
         }
      } else {
         copy[z] = source[i];
         z++;
      }
   }

   return(z);
}
//
//   Grab posted data and stick it in the
//   provided filename.
//
int get_data(int from, char *filename)
{
char holder[3] = {0};
char *tmp;
int i, newamt;
char *buf, *outbuf;
int fd, sin, amt, sout, err, totsize, filelen;
int rdsz, rmdr, cpy;

   filelen = totsize = err = 0;

   if (streq(getenv("REQUEST_METHOD"),"POST")) {
#ifdef PLATFORM_WINDOWS
      fd = open(filename, O_RDWR | O_CREAT | O_BINARY);
#else
      fd = open(filename, O_RDWR | O_CREAT);
#endif

      sin = fileno(stdin);
      fdopen(sin, "r+b");

      filelen = atoi(getenv("CONTENT_LENGTH"));
      printf("   <SIZE>%d</SIZE>\n", filelen);
      fflush(stdout);

      if (filelen == 0) {
         close(fd);
         return(0);
      }

      if (filelen < TRAN_READSIZE) {
         rdsz = filelen;
      } else {
         rdsz = TRAN_READSIZE;
      }

      buf = (char *)calloc(1, rdsz);
      outbuf = (char *)calloc(1, rdsz + 3);

      while (totsize < filelen) {
         if ((amt = read(sin, buf, rdsz)) > 0) {
            cpy = amt;
            i = 0;

            strcpy(outbuf, holder);
            rmdr = strlen(holder);

            holder[0] = '\0';
            holder[1] = '\0';
            if (buf[amt - 1] == '%') {
               cpy = amt - 1;
               holder[0] = buf[amt - 1];
            }
            if (buf[amt - 2] == '%') {
               cpy = amt - 2;
               holder[0] = buf[amt - 2];
               holder[1] = buf[amt - 1];
            }

            strncat(outbuf, buf, cpy);
            cpy = cpy + rmdr;

            tmp = (char *)calloc(1, cpy);
            newamt = url_decode(outbuf, tmp, cpy);

            if (write(fd, tmp, newamt) == (-1)) {
               err = -1;
            }
            free(tmp);
#ifdef PLATFORM_WINDOWS
            _flushall();
#else
            sync();
            sync();
#endif
            totsize = totsize + amt;
         }
      }

      if (amt == (-1)) {
         err = -1;
      }

      if (chmod(filename, 00666) == (-1)) {
         err = -1;
      }
      close(fd);
      free(buf);
      free(outbuf);
   } else {
      printf("   <ERROR>Request method is not POST</ERRORp>\n");
      fflush(stdout);
   }

   return(err);
}

//
//   Send local data from the specified file back
//   to the remote user.
//
int send_data(int from, char *filename)
{
char buf[4096];
int fd, sin, amt, sout, err;

   err = 0;

   if (access(filename, F_OK) == 0) {

      fd = open(filename, O_RDONLY);

      sout = fileno(stdout);

      while ((amt = read(fd, buf, 4096)) > 0) {
         if (write(sout, buf, amt) == (-1)) {
            err = -1;
         }
      }
      if (amt == (-1)) {
         err = -1;
      }

      close(fd);
   }

   return(err);
}

//
//   Dump some XML about what is going on.
//   This is the leading XML to the user
//   specified operation.
//
int ops_out(int from, int what, char *filename, char *collection, int binflag)
{
char *remhost;
//char remhost[] = "junk";

   remhost = get_remote_data();

   printf("%s", content);
   fflush(stdout);

   if (binflag == 1) {
      return(0);
   }

   printf("<REMOP>\n");

   switch (what) {
      case SENDING:
                     printf("   <OP>Send</OP>\n");
                     break;
      case GETTING:
                     printf("   <OP>Get</OP>\n");
                     break;
      case ALTER:
                     printf("   <OP>Alter</OP>\n");
                     break;
      case MYDELETE:
                     printf("   <OP>Delete</OP>\n");
                     break;
      case EXISTS:
                     printf("   <OP>Existence</OP>\n");
                     break;
      case EXEC:
                     printf("   <OP>Execute</OP>\n");
                     break;
      case STATUS:
                     printf("   <OP>Status</OP>\n");
                     break;
      case KILL:
                     printf("   <OP>Kill</OP>\n");
                     break;
      case KILLALL:
                     printf("   <OP>KillAll</OP>\n");
                     break;
      case KILLADMIN:
                     printf("   <OP>KillAdmin</OP>\n");
                     break;
      default:
                     break;
   }

   if (what == EXEC) {
         printf("   <TARGET>Command</TARGET>\n");
   } else {
      if (from == FILE_CP) {
         printf("   <TARGET>File</TARGET>\n");
      } else {
         printf("   <TARGET>Collection</TARGET>\n");
         if (collection != NULL) {
            printf("   <COLLECTION>%s</COLLECTION>\n", collection);
         } else {
            printf("   <COLLECTION>None specified</COLLECTION>\n");
         }
      }
   }

   printf("   <REQUESTOR>%s</REQUESTOR>\n", remhost);

   if (what == EXEC) {
      printf("   <COMMAND>%s</COMMAND>\n", filename);
   } else {
      printf("   <FILENAME>%s</FILENAME>\n", filename);
   }

   if ((what == GETTING) || (what == EXEC) || (what == STATUS)) {
      //printf("   <DATA>\n");
      //printf("<![CDATA[\n");
      printf("   <DATA><![CDATA[");
   }
   fflush(stdout);

   return(0);
}

//
//   Dump some XML about what is going on.
//   This is the trailing XML to the user
//   specified operation.
//
int ops_done(int err, int what, int binflag)
{

   if (binflag == 1) {
      return(0);
   }

   if ((what == GETTING) || (what == EXEC) || (what == STATUS)) {
      //printf("\n]]>\n");
      //printf("   </DATA>\n");
      printf("]]></DATA>\n");
   }

   if (what != EXISTS) {
      if (err == 0) {
         printf("   <OUTCOME>Success</OUTCOME>\n");
      } else {
         printf("   <OUTCOME>Failure</OUTCOME>\n");
      }
   } else {
      if (err == 0) {
         printf("   <OUTCOME>Yes</OUTCOME>\n");
      } else {
         printf("   <OUTCOME>No</OUTCOME>\n");
      }
   }
   printf("</REMOP>\n");
   fflush(stdout);

   return(0);
}

int setup_status(char *collection, int whos)
{

   if (whos == 1) {
      return(do_query_status(collection));
   } else {
      return(do_vse_status(collection));
   }
}
   

//
//   Control routine.  Process the arguments
//   and execute the user operations.
//
int get_data_setup(int what, int argc, char **argv)
{
int larg = 0;
int from, err, doesit, binflag, whos, service, ppid;
int sizecmd = 0;
char *filename, *mode, *collection, *ftype, *ecmd;
char *user, *password;
char nofile[] = "No file supplied\0";

   ppid = service = whos = binflag = doesit = err = 0;
   from = -1;
   ecmd = ftype = collection = mode = filename = NULL;
   user = password = NULL;

   while (larg < argc) {
      if (streq(argv[larg], "file\0")) {
         larg++;
         if (larg < argc) {
            filename = argv[larg];
            from = FILE_CP;
         }
      }
      if (streq(argv[larg], "collection\0")) {
         larg++;
         if (larg < argc) {
            if (service != QUERY) {
               collection = filename = argv[larg];
               filename = build_collection_path(filename);
               from = COLLECTION_CP;
            }
         }
      }
      if (streq(argv[larg], "chmod\0")) {
         larg++;
         if (larg < argc) {
            mode = argv[larg];
         }
      }
      if (streq(argv[larg], "user\0")) {
         larg++;
         if (larg < argc) {
            user = argv[larg];
         }
      }
      if (streq(argv[larg], "ppid\0")) {
         larg++;
         if (larg < argc) {
            filename = argv[larg];
            ppid = atoi(argv[larg]);
         }
      }
      if (streq(argv[larg], "service\0")) {
         larg++;
         if (larg < argc) {
            if (streq(argv[larg], "admin\0")) {
               service = ADMIN;
            }
            if (streq(argv[larg], "crawler\0")) {
               service = CRAWLER;
            }
            if (streq(argv[larg], "indexer\0")) {
               service = INDEXER;
            }
            if (streq(argv[larg], "collection-service\0")) {
               service = COLLECTION_SERVICE;
            }
            if (streq(argv[larg], "collection-service-all\0")) {
               service = COLLECTION_SERVICE_ALL;
            }
            if (streq(argv[larg], "collection-service-dispatch\0")) {
               service = COLLECTION_SERVICE_DISPATCH;
            }
            if (streq(argv[larg], "execute-worker\0")) {
               service = EXECUTE_WORKER;
            }
            if (streq(argv[larg], "java\0")) {
               service = JAVA;
            }
            if (streq(argv[larg], "crindex\0")) {
               service = CRAWLER_AND_INDEXER;
            }
            if (streq(argv[larg], "query\0") ||
                streq(argv[larg], "query-service\0")) {
               service = QUERY;
#ifdef PLATFORM_WINDOWS
               collection = filename = get_install_dir("\\data\\query-service-run.xml\0");
#else
               collection = filename = get_install_dir("/data/query-service-run.xml\0");
#endif
            }
            if (streq(argv[larg], "supplied\0")) {
               service = PPID_SUPPLIED;
            }
         }
      }
      if (streq(argv[larg], "password\0")) {
         larg++;
         if (larg < argc) {
            password = argv[larg];
         }
      }
      if (streq(argv[larg], "type\0")) {
         larg++;
         if (larg < argc) {
            ftype = argv[larg];
            if (streq(ftype, "binary\0")) {
               binflag = 1;
            }
         }
      }
      if (streq(argv[larg], "command\0")) {
         larg++;
         if (larg < argc) {
            filename = argv[larg];
            from = COMMAND;
         }
      }
      if (streq(argv[larg], "action\0")) {
         larg++;
         if (larg < argc) {
            if (streq(argv[larg], QUERY_SERVICE_STATUS)) {
               whos = 1;
#ifdef PLATFORM_WINDOWS
               filename = get_install_dir("\\data\\query-service-run.xml\0");
#else
               filename = get_install_dir("/data/query-service-run.xml\0");
#endif
            }
            if (streq(argv[larg], KILL_ALL_SERVICES)) {
               filename = nofile;
            }
            if (streq(argv[larg], KILL_ADMIN)) {
               filename = nofile;
            }
            if (streq(argv[larg], GET_PID_LIST)) {
               filename = nofile;
            }
            if (streq(argv[larg], KILL_CRAWL)) {
               whos = 1;
            }
            if (streq(argv[larg], KILL_INDEX)) {
               whos = 2;
            }
            if (streq(argv[larg], KILL_CRINDEX)) {
               whos = 3;
            }
            if (streq(argv[larg], KS_SERV_KIDS)) {
               whos = 4;
            }
            if (streq(argv[larg], GET_FS_MB_FREE)) {
               sizecmd = 0;
            }
            if (streq(argv[larg], GET_FS_GB_FREE)) {
               sizecmd = 1;
            }
         }
      }
      larg++;
   }

   if (filename != NULL) {
      switch (what) {
         case CRAWLDIR:
                        do_crawl_dir(collection);
                        break;
         case SENDING:
                        ops_out(from, what, filename, collection, binflag);
                        err = get_data(from, filename);
                        ops_done(err, what, binflag);
                        break;
         case GETTING:
                        ops_out(from, what, filename, collection, binflag);
                        if (access(filename, F_OK) == 0) {
                           err = send_data(from, filename);
                        } else {
                           err = -1;
                        }
                        ops_done(err, what, binflag);
                        break;
         case MYDELETE:
                        ops_out(from, what, filename, collection, binflag);
                        if (access(filename, F_OK) == 0) {
                           err = delete_data(from, filename, collection);
                        }
                        ops_done(err, what, binflag);
                        break;
         case ALTER:
                        ops_out(from, what, filename, collection, binflag);
                        if (access(filename, F_OK) == 0) {
                           err = alter_file(from, filename, mode);
                        } else {
                           err = -1;
                        }
                        ops_done(err, what, binflag);
                        break;
         case EXISTS:
                        ops_out(from, what, filename, collection, binflag);
                        doesit = collection_exists_check(from, filename);
                        ops_done(doesit, what, binflag);
                        break;
         case EXEC:
                        ops_out(from, what, filename, collection, binflag);
                        err = execute_command(from, filename);
                        ops_done(err, what, binflag);
                        break;
         case KILLALL:
                        ops_out(from, what, "ALL", "ALL", binflag);
                        err = killallservices();
                        ops_done(err, what, binflag);
                        break;
         case KILLADMIN:
                        ops_out(from, what, "ADMIN", "ADMIN", binflag);
                        err = killadmin();
                        ops_done(err, what, binflag);
                        break;
         case KILL:
                        ops_out(from, what, filename, collection, binflag);
                        if (whos < 4) {
                           err = kill_it(filename, whos);
                        }
                        else {
                           if (service == QUERY) {
                              err = kill_service_children(collection, service, ppid);
                           } else {
                              err = kill_service_children(filename, service, ppid);
                           }
                        }
                        ops_done(err, what, binflag);
                        break;
         case STATUS:
                        ops_out(from, what, filename, collection, binflag);
                        err = setup_status(filename, whos);
                        ops_done(err, what, binflag);
                        break;
         case FILESYSTEM:
                        err = fs_free(sizecmd, filename);
                        break;
         case PROCESSES:
                        err = pid_list(service, collection);
                        break;
         default:
                        break;
      }
   }

   return(0);
}

int main(int argc, char **argv)
{
char *query;
char **args;
int i = 0;

   //printf("%s", content);
   //fflush(stdout);

   query = get_query();
   args = split_query(query);

   while (args[i] != NULL) {
      i++;
   }
   if (args[0] != NULL) {
      if (streq(args[0], WHERE_AM_I)) {
         do_install_dir();
      }
      if (streq(args[0], GET_PID_LIST)) {
         get_data_setup(PROCESSES, i, args);
      }
      if (streq(args[0], GET_FS_MB_FREE)) {
         get_data_setup(FILESYSTEM, i, args);
      }
      if (streq(args[0], GET_FS_GB_FREE)) {
         get_data_setup(FILESYSTEM, i, args);
      }
      if (streq(args[0], GET_CRAWL_DIR)) {
         get_data_setup(CRAWLDIR, i, args);
      }
      if (streq(args[0], QUERY_SERVICE_STATUS)) {
         get_data_setup(STATUS, i, args);
      }
      if (streq(args[0], COLLECTION_EXISTS)) {
         get_data_setup(EXISTS, i, args);
      }
      if (streq(args[0], FILE_EXISTS)) {
         get_data_setup(EXISTS, i, args);
      }
      if (streq(args[0], SEND_TO)) {
         get_data_setup(SENDING, i, args);
      }
      if (streq(args[0], SEND_COLLECTION)) {
         get_data_setup(SENDING, i, args);
      }
      if (streq(args[0], GET_FROM)) {
         get_data_setup(GETTING, i, args);
      }
      if (streq(args[0], GET_COLLECTION)) {
         get_data_setup(GETTING, i, args);
      }
      if (streq(args[0], DELETE_FILE)) {
         get_data_setup(MYDELETE, i, args);
      }
      if (streq(args[0], DELETE_COLLECTION)) {
         get_data_setup(MYDELETE, i, args);
      }
      if (streq(args[0], ALTER_FILE)) {
         get_data_setup(ALTER, i, args);
      }
      if (streq(args[0], ALTER_COLLECTION)) {
         get_data_setup(ALTER, i, args);
      }
      if (streq(args[0], EXECUTE)) {
         get_data_setup(EXEC, i, args);
      }
      if (streq(args[0], GET_STATUS)) {
         get_data_setup(STATUS, i, args);
      }
      if (streq(args[0], KILL_CRAWL)) {
         get_data_setup(KILL, i, args);
      }
      if (streq(args[0], KILL_INDEX)) {
         get_data_setup(KILL, i, args);
      }
      if (streq(args[0], KILL_CRINDEX)) {
         get_data_setup(KILL, i, args);
      }
      if (streq(args[0], KS_SERV_KIDS)) {
         get_data_setup(KILL, i, args);
      }
      if (streq(args[0], KILL_ALL_SERVICES)) {
         get_data_setup(KILLALL, i, args);
         //killallservices();
      }
      if (streq(args[0], KILL_ADMIN)) {
         get_data_setup(KILLADMIN, i, args);
         //killallservices();
      }
   } else {
      do_install_dir();
      //printf("%s", content);
      //printf("<REMOP>\n");
      //printf("   <OP>UNKNOWN</OP>\n");
      //printf("   <ERROR>No known command used</ERROR>\n");
      //printf("   <OUTCOME>Failure</OUTCOME>\n");
      //printf("</REMOP>\n");
   }

   exit(0);
}