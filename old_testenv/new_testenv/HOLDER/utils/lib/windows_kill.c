// kill.cpp : kill something by exe name or by pid
//
// source:			http://www.documentroot.com/kill.cpp
// corrections to:	code@documentroot.com
// copyright:		open source

#define WIN32_LEAN_AND_MEAN

#include <stdio.h>
#include <stdlib.h>
#include <tchar.h>
#include <windows.h>
#include <tlhelp32.h>
#include <lmerr.h>

BOOL TerminateProcessByName(char *name);
void DisplayErrorText(DWORD dwLastError);

#define USAGE_STRING "Usage: kill [pid|appname]\n"
#define PROCESS_EXIT_CODE 100

int _tmain(int argc, _TCHAR* argv[])
{
	if (argc <= 1 ) {fprintf(stderr, USAGE_STRING);exit(1);}

	_TCHAR *potn = argv[1];
	while (isspace(*potn)) ++potn;

	if (!*potn) {fprintf(stderr, USAGE_STRING);exit(1);}

	_TCHAR *p = potn;
	while (*p && isdigit(*p)) ++p;
	if (!*p) {
		unsigned long pid = strtoul(potn, &p, 10);
		HANDLE hp = OpenProcess(PROCESS_TERMINATE,false,pid);
		if (hp) {
			if (!TerminateProcess(hp,PROCESS_EXIT_CODE))
				DisplayErrorText(GetLastError());
			CloseHandle(hp);
		} else
			DisplayErrorText(GetLastError());
	} else {
		TerminateProcessByName(potn);
	}
	return 0;
}

BOOL TerminateProcessByName(char *name) 
{ 
    HANDLE         hProcessSnap = NULL; 
    BOOL           bRet      = FALSE; 
    PROCESSENTRY32 pe32      = {0}; 
 
    //  Take a snapshot of all processes in the system. 

    hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0); 

    if (hProcessSnap == INVALID_HANDLE_VALUE) 
        return (FALSE); 
 
    //  Fill in the size of the structure before using it. 

    pe32.dwSize = sizeof(PROCESSENTRY32); 
 
    //  Walk the snapshot of the processes, and for each process, 
    //  display information. 

    if (Process32First(hProcessSnap, &pe32)) 
    { 
		TCHAR *buf = new TCHAR[MAX_PATH];
		strlwr(name);
		TCHAR *a;
		TCHAR *b;
        do 
        {
			a = name;
			b = pe32.szExeFile;

			while (*a && *b && tolower(*a) == tolower(*b)) {
				++a;
				++b;
			}
			if (*b =='.' || !*b) {
				HANDLE hp = OpenProcess(PROCESS_TERMINATE,false,pe32.th32ProcessID);
				if (hp) {
					printf("%u\t%s\n", pe32.th32ProcessID, pe32.szExeFile); fflush(stdout);
					if (!TerminateProcess(hp,PROCESS_EXIT_CODE))
						DisplayErrorText(GetLastError());
					CloseHandle(hp);
				} else {
					DisplayErrorText(GetLastError());
				}
			}
        } while (Process32Next(hProcessSnap, &pe32));

		bRet = TRUE; 
    } 
	else {
        bRet = FALSE;    // could not walk the list of processes 
		DisplayErrorText(GetLastError());
	}
 
    // Do not forget to clean up the snapshot object. 

    CloseHandle (hProcessSnap); 
    return (bRet); 
} 


void DisplayErrorText(DWORD dwLastError)
{
    HMODULE hModule = NULL; // default to system source
    LPSTR MessageBuffer;
    DWORD dwBufferLength;

    DWORD dwFormatFlags = FORMAT_MESSAGE_ALLOCATE_BUFFER |
        FORMAT_MESSAGE_IGNORE_INSERTS |
        FORMAT_MESSAGE_FROM_SYSTEM ;

    //
    // If dwLastError is in the network range, 
    //  load the message source.
    if(dwLastError >= NERR_BASE && dwLastError <= MAX_NERR) {
        hModule = LoadLibraryEx(
            TEXT("netmsg.dll"),
            NULL,
            LOAD_LIBRARY_AS_DATAFILE
            );

        if(hModule != NULL)
            dwFormatFlags |= FORMAT_MESSAGE_FROM_HMODULE;
    }

    //
    // Call FormatMessage() to allow for message 
    //  text to be acquired from the system 
    //  or from the supplied module handle.

	if(dwBufferLength = FormatMessageA(
        dwFormatFlags,
        hModule, // module to get message from (NULL == system)
        dwLastError,
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // default language
        (LPSTR) &MessageBuffer,
        0,
        NULL
        ))
    {
        DWORD dwBytesWritten;

        // Output message string on stderr.
        WriteFile(
            GetStdHandle(STD_ERROR_HANDLE),
            MessageBuffer,
            dwBufferLength,
            &dwBytesWritten,
            NULL
            );

        // Free the buffer allocated by the system.
        LocalFree(MessageBuffer);
    }

    // If we loaded a message source, unload it.
    if(hModule != NULL)
        FreeLibrary(hModule);
}
