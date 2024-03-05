#include "myincludes.h"

#ifdef __SUNOS__

#include <stdio.h>
#include <sys/types.h>
#include <sys/fcntl.h>
#include <sys/procfs.h>
#include <string.h>
#include <stdlib.h>
#include <pwd.h>
#include <dirent.h>
#include <sys/mkdev.h>

#ifndef FALSE
#define FALSE 0
#endif
#ifndef TRUE
#define TRUE 1
#endif

/* maximum number of processes */
#define MAXPROC   5000

typedef struct qps {
   int pid;
   char ppid[40];
   char tty[5];
   char user[11];
   float cpu;
   float mem;
   char pname[17];
   char *arglist;
} *QPS;

/*
 * Subproc to display all args (as opposed to what's in arglist
 */
char *showallargs(int fd, struct prpsinfo *p, int getgodir)
{
   /* routine rewritten by Roger Faulkner - procfs co-designer and guru */
   char **argv;               /* hold arg pointers */
   char *env[400];               /* hold environment */
   int argc = p->pr_argc;         /* arg count */
   char buf[BUFSIZ+1];            /* temporary buffer */
   int len;                  /* strlen(buf) */
   char *retbuf= NULL;            /* to return arglist */
   int argsize=64;               /* keep argsize for allocation records */
   int retbuflen;               /* strlen(retbuf) */
   int i = 0;
   int usenext = 0;
   char *sp;                     /* a space character */


   if ((retbuf = malloc(argsize)) == NULL) {
      fprintf(stderr, "Out of memory in malloc!");
      exit(1);
   }
   retbuf[0] = (char) NULL;
   retbuflen = 0;
   buf[BUFSIZ] = (char) NULL;

   if (argc * sizeof(*argv) <= sizeof(env))
      argv = env;      /* use local buffer */
   else if ((argv = malloc(argc * sizeof(*argv))) == NULL) {
      fprintf(stderr, "Out of memory in malloc!");
      exit(1);
   }
   if ((argc = pread(fd, argv, argc * sizeof(*argv), p->pr_argv)) > 0)
      argc /= sizeof(*argv);

   for (i = 0; i < argc; i++) {
      if (argv[i] == NULL || pread(fd, buf, BUFSIZ, argv[i]) <= 0)
         continue;
      len = strlen(buf);

      /* If it's a bunch of spaces (zero'd out by process), skip/trunc it*/
      sp = strchr(buf, ' ');
      if (sp == buf)
         continue;
      else if (sp != (char *) NULL) {
         sp = buf + len;
         while (*--sp == ' ') {
            *sp = (char) NULL;
            len--;
         }
      }

      while (retbuflen + len + 1 >= argsize) {
         argsize *= 2;
         if ((retbuf = realloc(retbuf, argsize)) == NULL) {
            fprintf(stderr, "Out of memory in realloc!");
            exit(1);
         }
      }
      if (retbuflen != 0)
         retbuf[retbuflen++] = ' ';
      if (getgodir == 1) {
         if (usenext == 1) {
            strcpy(retbuf + retbuflen, buf);
            retbuflen += len;
            usenext = 0;
         }
         if (strcmp(buf, "--go") == 0) {
            usenext = 1;
         }
      } else {
         strcpy(retbuf + retbuflen, buf);
         retbuflen += len;
      }
   }

   if (argv != env)      /* if we allocated argv */
      free(argv);         /* free it */

   return(retbuf);
}

int GetServicePidList(int service, char *collection, int *pidlist)
{
   struct prpsinfo p;            /* process information structure */
   struct passwd *pw;            /* hold password lookup information */
   char rssinfo[80];            /* character resident set/memory info */
   DIR *dirf;                  /* directory file pointer */
   char nothing[2]=" ";         /* Just empty printing stuff */
   struct dirent *dirp;         /* directory pointer */
   int fd;                     /* file descriptor */
   int cnt, i;                  /* counting and looping */
   int mapuid = TRUE;            /* Map userid to username? */
   register int min, maj;         /* Major and minor device numbers */
   int (*func)(const void *, const void *) = NULL;      /* sorting function pointer */
   struct qps pstruct[MAXPROC];   /* Process structure */
   char parg[15];               /* process name buffer */
   char *ppstr = "";            /* parent and pgid */
   char *pphdr = " PPID  PGID ";   /* PPID and PGID headers */
   char *ppdelim = "";            /* delimiters for PPID and PGID */
   char *ppdelimd="----- ----- ";
   char ppbuf[40] = "";         /* hold actual ppid and pgid */
   time_t now;                  /* what time is it? */

   /* flags */
   int debug = 0;               /* debugging flag */
   int cpid = 0;

   char *srvname = NULL;

   if (service == QUERY || service == QUERY_ALL)
      collection = NULL;

   srvname = servicearray[service];
   time(&now);

   if ((dirf = opendir("/proc")) == NULL) {
      perror("couldn't open proc");
      exit(1);
   }
   (void) readdir(dirf); /* skip over . and .. */
   (void) readdir(dirf);

   cnt = 0;
   /* open /procfs and scan through files one at a time - each a process */
   while ((dirp = readdir(dirf)) != NULL)  {
      sprintf(parg, "/proc/%s", dirp->d_name);

      if (debug)
         printf("process %s\n", dirp->d_name);

      if ((fd = open(parg, O_RDONLY)) < 0) {
         continue;
      }

      /* Grab process information/status */
      if (ioctl(fd, PIOCPSINFO, (void *) &p) < 0) {
         close(fd);
         continue;
      }

      if (strncmp(p.pr_fname, srvname, PRFNSZ-1) == 0) {
         /* map major and minor device numbers */
         min = minor(p.pr_lttydev);
         maj = major(p.pr_lttydev);

         /* Show process arguments with name */
         if (collection == NULL) {
            pstruct[cnt].arglist = showallargs(fd, &p, 0);
         } else {
            pstruct[cnt].arglist = showallargs(fd, &p, 1);
         }

         /* Convert mem and CPU usage to percentage of machine capacity */
         pstruct[cnt].pid = p.pr_pid;
         strcpy(pstruct[cnt].ppid, ppbuf);
         pstruct[cnt].mem = p.pr_pctmem * 100.0 / (float) 0x8000;
         pstruct[cnt].cpu = p.pr_pctcpu * 100.0 / (float) 0x8000;
         /* Get uid/uname */
         if (!mapuid || (pw = getpwuid(p.pr_uid)) == NULL)
            sprintf(pstruct[cnt].user, "%-8d", p.pr_uid);
         else
            sprintf(pstruct[cnt].user, "%-10.10s", pw->pw_name);

         sprintf(pstruct[cnt].pname, "%-16.16s", p.pr_fname);

         if (collection != NULL) {
            if (collection_match(service, pstruct[cnt].arglist, collection)) {
               cpid = addToPidList(service, pidlist, cpid, p.pr_pid, p.pr_ppid);
            }
         } else {
            cpid = addToPidList(service, pidlist, cpid, p.pr_pid, p.pr_ppid);
         }
      }
      if (++cnt == MAXPROC) {
         printf("too many processes. Increase MAXPROC and recompile.\n");
         exit (1);
      }
      close(fd);
   }
   closedir(dirf);

   return(cpid);
}
#endif

#ifdef PLATFORM_WINDOWS
void printError(TCHAR* msg)
{
DWORD eNum;
TCHAR sysMsg[256];
TCHAR* p;

   eNum = GetLastError();
   FormatMessage(
          FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
          NULL, eNum,
          MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // Default lang.
          sysMsg, 256, NULL );

   // Trim the end of the line and terminate it with a null
   p = sysMsg;
   while ((*p > 31) || (*p == 9))
      ++p;

   do {
      *p-- = 0;
   } while((p >= sysMsg) && (( *p == '.') || (*p < 33)));

   // Display the message
   printf("\n  WARNING: %s failed with error %d (%s)", msg, eNum, sysMsg);
}

int GetProcessList(int service, int *pidlist)
{
HANDLE hProcessSnap;
HANDLE hProcess;
PROCESSENTRY32 pe32;
DWORD dwPriorityClass;
int cpid = 0;
char *service_name;

   service_name = servicearray[service];

   // Take a snapshot of all processes in the system.
   hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
   if (hProcessSnap == INVALID_HANDLE_VALUE) {
      printError("CreateToolhelp32Snapshot (of processes)");
      return(FALSE);
   }

   // Set the size of the structure before using it.
   pe32.dwSize = sizeof(PROCESSENTRY32);

   // Retrieve information about the first process,
   // and exit if unsuccessful
   if (!Process32First(hProcessSnap, &pe32)) {
      printError("Process32First"); // Show cause of failure
      CloseHandle(hProcessSnap);    // Must clean up the
                                    //   snapshot object!
      return(FALSE);
   }

   // Now walk the snapshot of processes, and
   // get the service pid of the requested service.
   do {
      if (strcmp(pe32.szExeFile, service_name) == 0) {
         cpid = addToPidList(service, pidlist, cpid, &pe32);
      }

   } while (Process32Next( hProcessSnap, &pe32));

   CloseHandle(hProcessSnap);
   return(cpid);
}

int GetServicePidList(int service, char *collection, int *pidlist)
{
int cpid, i;

   cpid = 0;
   //if (service == QUERY || service == QUERY_ALL)
   //   collection = NULL;

   cpid = GetProcessList(service, pidlist);

   return(cpid);

}
#endif

#ifdef __LINUX__
int GetServicePidList(int service, char *collection, int *pidlist) {
glob_t globbuf;
unsigned int i, j, cpid, h;
char **args, *cmdcopy, *service_name;

   cpid = 0;

   if (service == QUERY || service == QUERY_ALL)
      collection = NULL;

   service_name = servicearray[service];

   glob("/proc/[0-9]*", GLOB_NOSORT, NULL, &globbuf);

   P = calloc(globbuf.gl_pathc, sizeof(struct Proc));
   if (P == NULL) {
      fprintf(stderr, "Problems with malloc.\n");
      return(-1);
   }

   for (i = j = 0; i < globbuf.gl_pathc; i++) {

      if (GetProcessData(globbuf, i, j) == 0) {
         continue;
      }

      if (GetCmdLine(globbuf, i, j) == 0) {
         continue;
      }

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
                        cpid = addToPidList(service, pidlist, cpid, j);
                     }
                  }
                  //fprintf(stdout, "    SEGMENT:  :%s:\n", args[h]);
                  h++;
               }
            } else {
               cpid = addToPidList(service, pidlist, cpid, j);
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
#endif


