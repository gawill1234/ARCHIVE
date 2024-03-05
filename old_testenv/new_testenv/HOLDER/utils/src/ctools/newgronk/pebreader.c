          PPEB peb = NULL;

            PPROCESS_PARAMETERS proc_params = NULL;

            PVOID UserPool = (PVOID)LocalAlloc(LPTR, 8192);

            rc = _ZwReadVirtualMemory(

                       hProcess, 

                       ProcessInfo->PebBaseAddress,  

                       UserPool, 

                       sizeof(PEB), 

                       NULL);

            LocalFree(ProcessInfo);



            peb = (PPEB)UserPool;

            rc = _ZwReadVirtualMemory(

                       hProcess,

                      peb->ProcessParameters,

                       UserPool,

                       sizeof(PROCESS_PARAMETERS),

                       NULL);



proc_params = (PPROCESS_PARAMETERS)UserPool;

            

            ULONG uSize = 0;

            LPVOID pBaseAddress = NULL;

            switch (uFlags)

            {

                 case  0: //process command line

                      {

                            uSize  = proc_params->CommandLine.Length;

                            pBaseAddress  = proc_params->CommandLine.Buffer;

                            break;
 
                       }

                 case  1: //process image file name

                      {

                            uSize  = proc_params->ImagePathName.Length;

                            pBaseAddress  = proc_params->ImagePathName.Buffer;                      

                            break;
 
                       }

                 case  2: //process current directory

                      {

                            uSize  = proc_params->CurrentDirectory.DosPath.Length;

                            pBaseAddress  = proc_params->CurrentDirectory.DosPath.Buffer;                      

                            break;
 
                       }

            }

                 

            if ((uSize > cb) || (uSize <= 0))

            {

                 _ZwClose(hProcess);
 
                 LocalFree(UserPool);
 
                 return  4;//memory buffer too small or nothing found

            }

            rc = _ZwReadVirtualMemory(

                       hProcess, 

                       pBaseAddress, 

                       Buffer, 

                       uSize, 

                       NULL);

            _ZwClose(hProcess);

            LocalFree(UserPool);





OTHER STUFF

typedef NTSTATUS (__stdcall *PZWQUERYSYSTEMINFORMATION)(

    IN SYSTEM_INFORMATION_CLASS  SystemInformationClass,

    OUT PVOID  SystemInformation,

    IN ULONG  Length,

    OUT PULONG  ReturnLength

);



PZWQUERYSYSTEMINFORMATION ZwQuerySystemInformation = NULL;



void main()

{

  ZwQuerySystemInformation = (PZWQUERYSYSTEMINFORMATION)GetProcAddress(GetModuleHandle( "ntdll.dll"), "ZwQuerySystemInformation");



...


PROCESS_BASIC_INFORMATION pbi;
#define ProcessBasicInformation 0

if(ZwQueryInformationProcess(GetCurrentProcess(), ProcessBasicInformation,
      (PVOID)&pbi, sizeof(PROCESS_BASIC_INFORMATION), NULL))





