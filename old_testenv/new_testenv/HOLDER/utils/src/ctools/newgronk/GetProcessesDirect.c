#include "myincludes.h"

#if (!defined(__LINUX__)) && (!defined(__SUNOS__)) && (!defined(PLATFORM_WINDOWS))
int GetProcessesDirect(int ppid, int *cpidlist)
{
   return(0);
}
#endif

#ifdef PLATFORM_WINDOWS
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
