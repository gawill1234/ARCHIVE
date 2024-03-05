#include "myincludes.h"

//#ifdef PLATFORM_WINDOWS
//#include <windows.h>
//#include <stdio.h>
//#include <psapi.h>
//#else
//#include <stdio.h>
//#include <stdlib.h>
//#include <unistd.h>
//#include <string.h>
//#include <fcntl.h>
//#include <dirent.h>
//#include <glob.h>
//#include <sys/types.h>
//#include <sys/stat.h>
//#include <sys/vfs.h>
//#endif


#ifdef PLATFORM_WINDOWS

int GetProcessRSS( DWORD processID )
{
HANDLE hProcess;
PROCESS_MEMORY_COUNTERS pmc;
int rss = -1;
int vmsize = -1;

   // Print the process identifier.

   //printf( "\nProcess ID: %u\n", processID );

   // Print information about the memory usage of the process.

   hProcess = OpenProcess(  PROCESS_QUERY_INFORMATION |
                                   PROCESS_VM_READ,
                                   FALSE, processID );
   if (NULL == hProcess)
      return(rss);

   if ( GetProcessMemoryInfo( hProcess, &pmc, sizeof(pmc)) ) {
      rss = pmc.WorkingSetSize;
      vmsize = pmc.QuotaNonPagedPoolUsage;
   }

   CloseHandle( hProcess );

   printf("   <MEMSIZE pid=\"%d\">%d</MEMSIZE>\n", processID, rss);
   printf("   <VMEMSIZE pid=\"%d\">%d</VMEMSIZE>\n", processID, vmsize);

   return(rss);
}

#else

int GetProcessRSS(int pid)
{
char name[48];
int rss = -1;
int vmsize = -1;
FILE *tn;

   snprintf(name, sizeof(name), "%s%d%s\0", "/proc/", pid, "/stat");

   if (access(name, R_OK) == 0) {
      tn = fopen(name, "r");

      if (tn == NULL)
          return(rss);
      //
      //  rss is the 24th item on /proc/xxx/stat file so we have
      //  to ignore a whole bunch of items before we get to it.
      //
      fscanf(tn, "%*ld %*s %*c %*ld %*ld %*d %*d %*d %*u %*u %*u %*u %*u %*u %*u %*d %*d %*d %*d %*d %*d %*llu %lu %ld",
             &vmsize, &rss);
      fclose(tn);
   }

   printf("   <MEMSIZE pid=\"%d\">%d</MEMSIZE>\n", pid, rss *4096);
   printf("   <VMEMSIZE pid=\"%d\">%d</VMEMSIZE>\n", pid, vmsize);

   return(rss * 4096);
}

#endif

int GetProcessRSSOut(char *pid)
{
int rss = 0;
int vmsize = 0;

   printf("%s", content);
   fflush(stdout);

   printf("<REMOP>\n");
   printf("   <OP>PROCESS_MEMORY</OP>\n");

   if ( pid != NULL ) {
      rss = GetProcessRSS(atoi(pid));
   }

   if ( rss >= 0 )
      printf("   <OUTCOME>Success</OUTCOME>\n");
   else
      printf("   <OUTCOME>Failure</OUTCOME>\n");
   printf("</REMOP>\n");
   fflush(stdout);

   exit(0);
}


//int main(int argc, char **argv)
//{
//int rss = 0;
//
//
//   if ( argc > 1 ) {
//      rss = GetProcessRSSOut(argv[1]);
//   }
//
//   printf("FINAL Resident Set Size:  %d\n", rss);
//   fflush(stdout);
//
//   exit(0);
//}

