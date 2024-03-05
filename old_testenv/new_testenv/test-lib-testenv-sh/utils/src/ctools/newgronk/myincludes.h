#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <dirent.h>
#ifdef __LINUX__
#include <glob.h>
#include <sys/vfs.h>
#endif
#ifdef __SUNOS__
#include <sys/statvfs.h>
#include <sys/vfs.h>
#endif
#include <sys/types.h>
#include <sys/stat.h>
#ifdef PLATFORM_WINDOWS
#include <windows.h>
#include <psapi.h>
#include <tlhelp32.h>

#define WIN32_LEAN_AND_MEAN

#define ProcessBasicInformation 0
#define BUF_SIZE 512

typedef struct
{
   USHORT Length;
   USHORT MaximumLength;
   PWSTR  Buffer;
} UNICODE_STRING, *PUNICODE_STRING;

typedef struct
{
   ULONG        AllocationSize;
   ULONG        ActualSize;
   ULONG        Flags;
   ULONG        Unknown1;
   UNICODE_STRING Unknown2;
   HANDLE       InputHandle;
   HANDLE       OutputHandle;
   HANDLE       ErrorHandle;
   UNICODE_STRING CurrentDirectory;
   HANDLE       CurrentDirectoryHandle;
   UNICODE_STRING SearchPaths;
   UNICODE_STRING ApplicationName;
   UNICODE_STRING CommandLine;
   PVOID        EnvironmentBlock;
   ULONG        Unknown[9];
   UNICODE_STRING Unknown3;
   UNICODE_STRING Unknown4;
   UNICODE_STRING Unknown5;
   UNICODE_STRING Unknown6;
} PROCESS_PARAMETERS, *PPROCESS_PARAMETERS;

typedef struct
{
   ULONG            AllocationSize;
   ULONG            Unknown1;
   HINSTANCE         ProcessHinstance;
   PVOID            ListDlls;
   PPROCESS_PARAMETERS ProcessParameters;
   ULONG            Unknown2;
   HANDLE           Heap;
} PEB, *PPEB;

typedef struct
{
   DWORD ExitStatus;
   PPEB  PebBaseAddress;
   DWORD AffinityMask;
   DWORD BasePriority;
   ULONG UniqueProcessId;
   ULONG InheritedFromUniqueProcessId;
}   PROCESS_BASIC_INFORMATION;

typedef LONG (WINAPI *PROCNTQSIP)(HANDLE,UINT,PVOID,ULONG,PULONG);

PROCNTQSIP NtQueryInformationProcess;

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



//
//   How much to read from a file (any file).
//   Just change this to read larger or smaller
//   chunks.
//
#define READSIZE 2048
#define TRAN_READSIZE 16384
#define MAXLINE 512
#define MAXPIDS 1024

#define TRUE 1
#define FALSE 0

#ifdef __SUNOS__
#define PSCMD         "ps -ef"
#define PSFORMAT      "%s %ld %ld %*d %*s %*s %*s %[^\n]"
#define PSVARS        P[i].name, &P[i].pid, &P[i].ppid, P[i].cmd
#define PSVARSN       4
#endif

//
//   Vivisimo global environment variable markers.
//
#define INSTALL_DIR 0
#define SEARCH_COLLECTIONS_DIR 1
#define VIVISIMO_CONF 2
#define TMP_DIR 3
#define DEBUG_DIR 4
#define REPOSITORY 5
#define USERS_FILE 6
#define USERS_DIR_FILE 7
#define USERS_DIR 8
#define DEFAULT_PROJECT 9
#define BRAND_FILE 10
#define AUTHENTICATION_MACRO 11
#define ADMIN_AUTHENTICATION_MACRO 12
#define BASE_URL 13
#define COOKIE_PATH 14
#define REPORTS_DIR 15
#define SYS_REPORTS_DIR 16
#define META_CACHE_DIR 17
#define CLEANER_FREQ 18
#define CLEANER_FLIMIT 19
#define CLEANER_ACCTIME 20
#define CLEANER_CRTIME 21

//
//  These two need to be last.  So they are
//  1 and 2 greater than the last of the env
//  variable markers.
//
#define OLD_COLLECTIONS_DIR 22
#define REPOSITORY_DIR 23

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
#define FIND 16
#define REPO 17
#define REPOIMPORT 18
#define KILLQUERY 19
#define SIZE 20
#define RESTOREDEFAULT 21
#define RESTORECOLLECTION 22

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
#define QUERY_ALL 11
#define SCHEDULER 12
#define ALERTS 13
#define SOURCETEST 14
#define REPORT 15
#define DISPATCH 16
#define CBROKER 17
#define VELOCITY 18


#define AFILE 0
#define ADIR 1
#define CWDIR 2
#define CDISPRUN 3

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


extern char *servicearray[];
//
//   html header line.
//
extern char content[];

//
//   A savespace for instances where we need to
//   save an old piece of read buffer to use with
//   a new piece.  I guess I could have just used
//   two alternating read buffers ...
//
extern char *savespace;

extern int vivconfvaluecount;
extern char *vivconfvalues[];
extern char *vivisimo_env_config_values[];


//
//   PROTOTYPES
//
char *_basename(char *);
char *_dirname(char *);
char **split_tagline(char *);
char **split_path(char *);
char **split_query(char *);
char *noquotes(char *);
int streq(char *, char *);
int strneq(char *, char *, int);
int saveit(char *);
char *get_remote_data();
int GetProcessesDirect(int, int *);
#if defined(__LINUX__)
int addToPidList(int, int *, int, int);
#endif
#if defined(__SUNOS__)
int addToPidList(int, int *, int, int, int);
#endif
#if defined(PLATFORM_WINDOWS)
int addToPidList(int, int *, int, PROCESSENTRY32 *);
#endif
int alter_file(int, char *, char *);
char *build_collection_path(char *, int);
char *buildtag(char *, int);
int check_begin_end(char *);
int collection_match(int, char *, char *);
char *curcrawl(char *);
int delete_data(int, char *, char *);
int do_crawl_dir(char *);
int do_crawler_status(char *);
int do_index_status(char *);
int do_install_dir();
int do_query_status(char *);
int doread(int, char *);
int do_vse_status(char *);
int execute_command(int, char *);
char *findatag(struct mynode *, char *);
struct mynode *findnode(char **, char *);
int freenodelist(struct mynode *);
int fs_free(int, char *);
char *getattrib(char *, char *);
char *getatag(char **);
int get_data(int, char *);
int get_data_setup(int, int, char **);
#ifdef __LINUX__
struct statfs *getfssz(char *);
#endif
#ifdef PLATFORM_WINDOWS
float getfssz(char *);
#endif
#ifdef __SUNOS
struct statvfs *getfssz(char *);
#endif
float get_free_mb(char *);
float get_free_gb(char *);
char *get_install_dir(char *);
void first_get_install_dir(void);
#ifdef __LINUX__
int GetProcessData(glob_t, int, int);
int GetCmdLine(glob_t, int, int);
#else
int GetProcessData(int, int, int);
int GetCmdLine(int, int, int);
#endif
char *MD5String(unsigned char *);
char *get_query();
int get_query_pid(char *);
int GetServicePidList(int, char *, int *);
int kill_crawler(char *);
int kill_index(char *);
int kill_crindex(char *);
int kill_it(char *, int);
int kill_service_children(char *, int, int);
int killadmin();
int killallservice();
int killit(int);
int dokillkids(int);
int my_vse_status(char *);
struct mynode *newnode();
int ops_done(int, int, int);
int ops_out(int, int, char *, char *, int);
int pid_list(int, char *);
int remove_directory(char *);
int replacebuffer(char *, char *, char *, char *, int);
char *replacestring(const char * const, const char * const, const char * const);
char *get_collection_path(char *, int);
int rm_collection(char *, char *);
int send_data(int, char *);
int setup_status(char *, int);
int url_encode(const char *, char *, int);
int url_decode(const char *, char *, int);
int openfile(char *);
int collection_exists_check(int, char *);


