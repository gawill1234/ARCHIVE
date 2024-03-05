#include <windows.h>
#include <tlhelp32.h>
#include <stdio.h>

//
//      windows:
//         gcc -mno-cygwin -I/usr/include/w32api
//             -o winps winps.c -L/usr/lib/w32api -lpsapi
//         should give you winps.exe
//
//      This is a basic ps that provides the parent process id
//      and the command name even under 64 bit windows.
//

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

BOOL GetProcessList()
{
HANDLE hProcessSnap;
HANDLE hProcess;
PROCESSENTRY32 pe32;
DWORD dwPriorityClass;

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
   // display information about each process in turn
   printf("   PID     PPID  THREADS PRIORITY   COMMAND\n");
   printf("------   ------  ------- --------   ------------\n");
   do {
      printf("%6d   %6d   %6d   %6d   %s\n", pe32.th32ProcessID,
             pe32.th32ParentProcessID, pe32.cntThreads,
             pe32.pcPriClassBase, pe32.szExeFile);

   } while (Process32Next( hProcessSnap, &pe32));

   CloseHandle(hProcessSnap);
   return(TRUE);
}

int main( )
{
  GetProcessList( );
}
