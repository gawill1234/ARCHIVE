//
//   This is a very dangerous program.  It is a CGI program that
//   sits in the Vivisimo cgi-bin directory.  It can transfer 
//   program in and out of the system and execute commands.
//
//   DO NOT LET THIS GO INTO PRODUCTION CODE.  IT IS A HUGE
//   GAPING SECURITY HOLE.  IT IS ONLY TO ENABLE TESTING
//   ACTIVITIES.
//
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#ifdef PLATFORM_WINDOWS
#include <windows.h>

/*
    Header file for safe_terminate_process
*/

#ifndef _SAFETP_H__
#define _SAFETP_H__

BOOL unsafe_terminate_process(int hProcess, UINT uExitCode);
BOOL safe_terminate_process(int hProcess, UINT uExitCode);

#endif

#endif

//
//   How much to read from a file (any file).
//   Just change this to read larger or smaller 
//   chunks.
//
#define READSIZE 2048

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

//
//   Input commands to this cgi program
//
#define WHERE_AM_I "installed-dir"
#define GET_STATUS "get-status"
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

int openfile(char *name)
{
int fd;

   fd = open(name, O_RDONLY);
   if (fd > 0) {
      return(fd);
   }

   return(-1);
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
char *get_install_dir(char *appenddir)
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

//
//   Get the CGI QUERY_STRING env variable.
//   This has the arguments needed to run the
//   program.
//
char *get_query()
{
char *query;
int qlen;

   qlen = strlen(getenv("QUERY_STRING"));

   query = calloc(qlen + 1, 1);

   sprintf(query, "%s\0", getenv("QUERY_STRING"));
   //printf("QUERY:  %s\n", query);

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

int kill_crawler(char *collection_file)
{
int crawlpid;

   crawlpid = 0;

   crawlpid = do_crawler_status(collection_file);

   if (crawlpid != 0) {
#ifdef PLATFORM_WINDOWS
      if (safe_terminate_process(crawlpid, 1) == 0) {
#else
      if (kill((crawlpid * -1), 9) == 0) {
#endif
         return(0);
      } else {
         return(1);
      }
   }

   return(0);
}

int kill_index(char *collection_file)
{
int indexpid;

   indexpid = 0;

   indexpid = do_index_status(collection_file);

   if (indexpid != 0) {
#ifdef PLATFORM_WINDOWS
      if (safe_terminate_process(indexpid, 1) == 0) {
#else
      if (kill((indexpid * -1), 9) == 0) {
#endif
         return(0);
      } else {
         return(1);
      }
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
#ifdef PLATFORM_WINDOWS
      if (safe_terminate_process(crawlpid, 1) != 0) {
#else
      if (kill((crawlpid * -1), 9) != 0) {
#endif
         err++;
      }
   }

   if (indexpid != 0) {
#ifdef PLATFORM_WINDOWS
      if (safe_terminate_process(indexpid, 1) != 0) {
#else
      if (kill((indexpid * -1), 9) != 0) {
#endif
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
int err = 0;

   if (ecmd != NULL) {
      printf("EXEC %s\n", ecmd);
      fflush(stdout);
      err = system(ecmd);
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

//
//   Grab posted data and stick it in the
//   provided filename.
//
int get_data(int from, char *filename)
{
char buf[4096];
int fd, sin, amt, sout, err, totsize, filelen;

   filelen = totsize = err = 0;

   if (streq(getenv("REQUEST_METHOD"),"POST")) {
      fd = open(filename, O_RDWR | O_CREAT);

      sin = fileno(stdin);

      filelen = atoi(getenv("CONTENT_LENGTH"));
      printf("   <SIZE>%d</SIZE>\n", filelen);
      fflush(stdout);

      while ((amt = read(sin, buf, 4096)) > 0) {
         if (write(fd, buf, amt) == (-1)) {
            err = -1;
         }
         totsize = totsize + amt;
         if (totsize >= filelen) {
            break;
         }
      }
      if (amt == (-1)) {
         err = -1;
      }

      if (chmod(filename, 00666) == (-1)) {
         err = -1;
      }
      close(fd);
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
      printf("   <DATA>\n");
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
      printf("\n   </DATA>\n");
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
int from, err, doesit, binflag, whos;
char *filename, *mode, *collection, *ftype, *ecmd;
char *user, *password;

   whos = binflag = doesit = err = 0;
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
            collection = filename = argv[larg];
            filename = build_collection_path(filename);
            from = COLLECTION_CP;
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
            if (streq(argv[larg], KILL_CRAWL)) {
               whos = 1;
            }
            if (streq(argv[larg], KILL_INDEX)) {
               whos = 2;
            }
            if (streq(argv[larg], KILL_CRINDEX)) {
               whos = 3;
            }
         }
      }
      larg++;
   }

   if (filename != NULL) {
      switch (what) {
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
         case KILL:
                        ops_out(from, what, filename, collection, binflag);
                        err = kill_it(filename, whos);
                        ops_done(err, what, binflag);
                        break;
         case STATUS:
                        ops_out(from, what, filename, collection, binflag);
                        err = setup_status(filename, whos);
                        ops_done(err, what, binflag);
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
