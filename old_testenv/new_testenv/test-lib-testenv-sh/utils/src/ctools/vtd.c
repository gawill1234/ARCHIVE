/***************************************************************************/
/*   This is vtd.  A program to run tests and gather their results.
 *   Yes, it is one big huge file.  If you have this file, you have it all.
 *
 *   Author:  Gary Williams
 *   Made safe for uclibc
 *
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/vfs.h>
#include <fcntl.h>
#include <dirent.h>
#include <time.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include <sys/msg.h>
//#include <sys/sysinfo.h>
#include <sys/utsname.h>
#include <libgen.h>
#include <errno.h>

#define READLEN 512
#define DIRLEN 512

#define MAXLEV 5
#define MAXRISK 5
#define MAXTESTS 32
#define MAXMUTCLEAN 1800
#define MAXTIMEOUT 172800
#define MAXREPEAT 32
#define ID_COL 2
#define MAXARGS 48

#define UNK 0
#define NEEDFS 1
#define UNSUPP 2
#define NRTYPE 3
#define NOEXIST 4
#define SUIDFAIL 5
#define NOTROOT 6
#define NEEDMEM 7

#define SUIDFAIL_EXIT 103

#define NFS_SUPER_MAGIC 0x6969

#define EXT_SUPER_MAGIC 0x137D
#define EXT2_OLD_SUPER_MAGIC 0xEF51
#define EXT2_SUPER_MAGIC 0xEF53
#define EXT3_SUPER_MAGIC 0xEF53
#define REISERFS_SUPER_MAGIC 0x52654973
#define JFFS2_SUPER_MAGIC 0x72b6
#define UFS_MAGIC 0x00011954

struct tdata {
   int type;
   int passval;
   int resstat;
   int scon;
   int mbs;
   int mcon;
   int sup;
   int pid;
   int exists;
   int start_time;
   int end_time;
   int max_time;
   int run_cnt;
   int run_done;
   int newsess;
   int copy;
   char *suite;
   char *category;
   char *name;
   char *path;
   char *directory;
   char *directory_base;
   char *cmdline;
   char *holdargs;
   char **args;
};

struct limitations {
   int type;
   int sess;
   int mbs;
   int passval;
   int scon;
   int exists;
   int mcon;
   int sup;
   int max_time;
   int run_cnt;
   int copy;
   char *suite;
   char *category;
   char *name;
};

struct limitations test_limits;

struct thing {
   int line;
   int used;
};

struct thing **mymess;

/****************************************************/
/*  This is the running test table.  It contains all
 *  of the data for up to MAXTESTS tests (default, 32).
 *  This defines the maximum level of concurrency 
 *  allowed by the drive.
 */
struct tdata running_tests[MAXTESTS];

char *newenv, *thome, *optDir;
char *driveCommand;
char *infile;
int myuid;

FILE *outfp, *fp, *failfp, *runfp;

char *tmpdirname;
int runcount, newsession;

int MAXCONCUR;
int TIMEOUT_TIME;
int SLEEPTIME;
int REPEAT_COUNT;
int RUN_TIME;

int GL_keepall, GL_dorandom, GL_time_over;
int GL_ig_ig, GL_totalmem, GL_wantmem;

time_t GL_start_time, GL_end_time;

#define BLOCK_SIZE 4096

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

/* 
 * Attempt to create nested directories, return 1 on success, 0 on failure
 * Why does it take so much code to do the right thing?
 *
 * Returns 1 when all of the directories get created, 0 otherwise
 *
 */
int create_nested_directories(const char *szFileName, FILE *pErrFile, int fff)
{
  char szCreateDir[DIRLEN + 1]; /* accumulator for directories we're creating */
  char* szBaseName;             /* we remove the basename and store the result here */
  char* szPath;                 /* scratch copy of sFileName, because dirname touches the input string */
  struct stat nodeInfo;         /* we need a place to store stat info when we test if directory exists */
  int nStatus;                  /* scratch var for success of library calls */
  int nWorked = 1;              /* what we return to the user about this function */
  char* pcEnd;                  /* pointer used to traverse string */


  szCreateDir[0] = '\0';
  szPath = strdup(szFileName);

  if (fff == 0)
     szBaseName = dirname(szPath);
  else
     szBaseName = szPath;

  pcEnd = szBaseName;
  while (*(pcEnd + 1) && *(pcEnd + 1) != '/')
    pcEnd++;

  while (nWorked && *pcEnd) {

    strncpy(szCreateDir, szBaseName, pcEnd - szBaseName + 1);
    szCreateDir[pcEnd - szBaseName + 1] = '\0';
 
    nStatus = stat(szCreateDir, &nodeInfo);
    if (nStatus == 0) {
      if (! S_ISDIR(nodeInfo.st_mode)) {
	fprintf(pErrFile, "Could not create directory %s, because %s exists as a non-directory\n",
		szCreateDir, szCreateDir);
	nWorked = 0;
	break;
      }
    }
    else {
      nStatus = mkdir(szCreateDir, S_IRWXO | S_IRWXG | S_IRWXU);
      if (nStatus != 0) {
	fprintf(pErrFile, "Could not create directory %s, error code %d\n", 
		szCreateDir, errno);
	nWorked = 0;
	break;
      }
    }

    pcEnd++;
    if (*pcEnd != '\0') {
       while (*(pcEnd + 1) && *(pcEnd + 1) != '/')
          pcEnd++;
    }

  }

  free(szPath);
  return nWorked;

}


/********************************************************************/
/*   Build a complete path from a directory and a filename.
 */
char *buildPath(const char *filePath, char *fileName)
{
char *fullPath;

   if (filePath == NULL)
      return(NULL);

   if (fileName == NULL)
      return(NULL);

   fullPath = (char *)calloc(strlen(filePath) + strlen(fileName) + 2, 1);

   if (strlen(filePath) == 1)
      sprintf(fullPath, "/%s", fileName);
   else
      sprintf(fullPath, "%s/%s", filePath, fileName);

   return(fullPath);
}

/******************************************************************/
/*   Remove the contents of a directory.
 */
int clearDirectory(const char *directory_name)
{
DIR *dirp, *opendir();
struct dirent *dp, *readdir();
char *rmthing, *buildPath();

   if (directory_name == NULL)
      return(0);

   if (direxist(directory_name) == 0) {
      dirp = opendir(directory_name);
   } else {
      return(0);
   }

   if (dirp != NULL) {
      while ((dp = readdir(dirp)) != NULL) {
         if (strcmp(dp->d_name, ".") != 0) {
            if (strcmp(dp->d_name, "..") != 0) {
               rmthing = buildPath(directory_name, dp->d_name);
               if (rmthing != NULL) {
                  if (unlink(rmthing) < 0) {
                     if (direxist(rmthing) == 0) {
                        clearDirectory(rmthing);
                        if (rmdir(rmthing) != 0) {
                           printf("VTD:  Could not remove directory %s\n", rmthing);
                        }
                     } else {
                        printf("VTD:  Could not remove file %s\n", rmthing);
                     }
                  }
                  free(rmthing);
               }
            }
         }
      }
      closedir(dirp);
   }

   return(0);
}

int copyfile(char *infile, char *outfile)
{
int fno, fno2, readnum, writenum;
char mychunk[BLOCK_SIZE];

#ifdef DEBUG
   printf("doCopy():  copying %s  to  %s\n", infile, outfile);
   fflush(stdout);
#endif

   /************************************/
   /*   Open infile for reading
   */ 
   if ((fno = open(infile, O_RDONLY, 00666)) == (-1)) {
      return(fno);
   }

   /************************************/
   /*   Open outfile for writing
   */ 
   if ((fno2 = open(outfile, O_RDWR|O_CREAT,00666)) == (-1)) {
      return(fno2);
   }

   /*************************************/
   /*  Read file a block a time and write
       to the output file.
   */
   readnum = read(fno, mychunk, BLOCK_SIZE);
   while (readnum == BLOCK_SIZE) {
      writenum = write(fno2, mychunk, BLOCK_SIZE);
      readnum = read(fno, mychunk, BLOCK_SIZE);
   }
   writenum = write(fno2, mychunk, readnum);

   /*************************************/
   /*   Close both files
   */
   close(fno);
   close(fno2);

   /*************************************/
   /*  return(success)
   */
   return(0);

}

int matchmode(char *copything, char *copyto)
{
struct stat buf;

   if (stat(copything, &buf) == 0) {
      chmod(copyto, buf.st_mode);
   } else {
      return(-1);
   }
   return(0);
}

int copydirectory(char *directory_name, char *outdir)
{
DIR *dirp, *opendir();
struct dirent *dp, *readdir();
char *copything, *copyto, *buildPath();
struct stat buf;

   /*************************************/
   /*   Check that directory names are 
    *   not null.
    */
   if (directory_name == NULL)
      return(0); 

   if (outdir == NULL)
      return(0); 

   /**************************************/
   /*   If the source directory exists, open it.
    *   Otherwise return.
    */
   if (direxist(directory_name) == 0) {
      dirp = opendir(directory_name);
   } else {
      return(0);
   }

   /*************************************/
   /*   If the destination directory does not
    *   exist, create it.
    */
   if (direxist(outdir) != 0) {
      create_nested_directories(outdir, stdout, 1);
   }
   
   /*************************************/
   /*   Read the files from the directory and copy them
    *   to the destination.
    */
   if (dirp != NULL) {

      while ((dp = readdir(dirp)) != NULL) {

         /*************************************/
         /*   Do not want to copy "." and ".."
          */
         if (strcmp(dp->d_name, ".") != 0) {
            if (strcmp(dp->d_name, "..") != 0) {

               /*************************************/
               /*   Create full pathes for both the source
                *   and destination files.
                */
               copything = buildPath(directory_name, dp->d_name);
               copyto = buildPath(outdir, dp->d_name);

               stat(copything, &buf);
               if (S_ISDIR(buf.st_mode)) {
                  copydirectory(copything, copyto);
               } else {
                  /*************************************/
                  /*   Copy the files, if the pathes were created
                   *   properly.
                   */
                  if (copything != NULL) {
                     if (copyto != NULL) {
                        copyfile(copything, copyto);
                        matchmode(copything, copyto);
                        free(copyto);
                     }
                     free(copything);
                  } else {
                     if (copyto != NULL) {
                        free(copyto);
                     }
                  }
               }
            }
         }
      }
      closedir(dirp);
   }

   return(0);
}

/**********************************************/
/*  Get the date.
 */
char *getdate()
{
struct tm *tm_ptr;
time_t the_time;
char *buf;

   buf = (char *)calloc(32, 1);
   if (buf != NULL) {
      (void) time(&the_time);
      tm_ptr = localtime(&the_time);
      strftime(buf, 32, "%F", tm_ptr);
   }

   return(buf);
}

/******************************************************************/
/*   Read a line of data from the specified file.
 */
int readline(FILE *fp, char *mystr)
{
int readres;

   readres = 1;
   if (fgets(mystr, READLEN, fp) == NULL) {
      readres = 0;
   }

   return(readres);
}


/********************************************************************/
/*   Set up a random list of tests from the supplied file.  The file
 *   is save in an iterim file.  The reason is that if there is an
 *   issue, the interim file can be use to duplicate the irksome
 *   results of a bad run.
 */
void randomize(int count)
{
int i, puthere;
int tmp;

   srand48(time((time_t *)NULL));

   for (i = 0; i < count; i++) {
      puthere = (int)(drand48() * count);
      tmp = mymess[i]->line;
      mymess[i]->line = mymess[puthere]->line;
      mymess[puthere]->line = tmp;
   }
}

void makeLineUseTrack(int count)
{
int i;

   mymess = (struct thing **)malloc(sizeof(struct thing *) * (count + 1));

   for (i = 0; i < count; i++) {
      mymess[i] = (struct thing *)malloc(sizeof(struct thing));
      mymess[i]->used = 0;
      mymess[i]->line = i;
   }

   mymess[count] = NULL;
}

void clearLineUseTrack(int count)
{
int i;

   for (i = 0; i < count; i++) {
      free(mymess[i]);
   }

   free(mymess);
}

char *getTestLine(FILE *localfp, int which, char *mystr)
{
int count = 0;

   fseek(localfp, 0, SEEK_SET);

   do {
      if (readline(localfp, mystr)) {
         if (strlen(mystr) > 1) {
            count++;
         }
      }
   } while (count < which);

   return(mystr);
}

int doTestCount(FILE *localfp)
{
char *mystr;
int i;
int testCount = 0;
int done = 0;

   mystr = (char *)malloc(READLEN);

   do {
      for (i = 0; i < READLEN; i++)
         mystr[i] = '\0';
      if (readline(localfp, mystr)) {
         if (strlen(mystr) > 1) {
            testCount++;
         }
      } else {
         done = 1;
      }
   } while (!done);

   free(mystr);

   return(testCount);
}

char *newTestListFile(char *oldfile)
{
char *filefullname;

   filefullname = NULL;

   do {
      if (filefullname != NULL) {
         free(filefullname);
      }
      filefullname = tempnam(thome, "DRVLS");
   } while (access(filefullname, F_OK) == 0);

   if (filefullname != NULL) {
      if (oldfile != NULL) {
         if (access(oldfile, F_OK) == 0) {
            unlink(oldfile);
         }
      }
   } else {
      filefullname = oldfile;
   }
   
   return(filefullname);
}

void fillNewFile(FILE *basefp, FILE *newfp)
{
int i, j;
char *mystr;

   i = j = 0;
   mystr = (char *)malloc(READLEN);

   while (mymess[i] != NULL) {
      for (j = 0; j < READLEN; j++) {
         mystr[j] = '\0';
      }
      mystr = getTestLine(basefp, mymess[i]->line, mystr);
      if (mystr != NULL) {
         fprintf(newfp, "%s", mystr);
      }
      i++;
   }

   free(mystr);
}

char *newTestFileData(char *basefile, char *oldfile)
{
FILE *localfp, *bfp;
char *newFileName;
int testCount;

   testCount = 0;
   newFileName = newTestListFile(oldfile);

   if (newFileName == NULL) {
      return(NULL);
   }

   localfp = fopen(newFileName, "a+");
   bfp = fopen(basefile, "r");
   if (bfp == NULL) {
      printf("ERROR:  Could not open file %s\n", basefile);
      fflush(stdout);
      exit(0);
   }

   if (testCount <= 0) {
      testCount = doTestCount(bfp);
   }

   makeLineUseTrack(testCount);
   randomize(testCount);

   fillNewFile(bfp, localfp);

   clearLineUseTrack(testCount);
   fclose(bfp);
   fclose(localfp);

   return(newFileName);
}

/********************************************************************/


/**************************************************************************/
/*   Get the file system type specified by path.
 */
long getFSType(char *path)
{
struct statfs buf;

   if (statfs(path, &buf) != (-1)) {
      return(buf.f_type);
   }

   return(-1);
}

/**************************************************************************/
/*   True/False, is file system NFS mounted.
 */
int fsIsNFS(long fstype)
{
   if (fstype == 0x6969) {
      return(1);
   }

   return(0);
}

/**************************************************************************/
/*   True/False, is file system directly mounted.
 */
int dirAttFS(char *path)
{
long fstype;

   fstype = getFSType(path);

   switch (fstype) {
      case EXT_SUPER_MAGIC:
      case EXT2_OLD_SUPER_MAGIC:
      case EXT3_SUPER_MAGIC:
      case REISERFS_SUPER_MAGIC:
      case JFFS2_SUPER_MAGIC:
      case UFS_MAGIC:
                                return(1);
                                break;
      case NFS_SUPER_MAGIC:
      default:
                                return(0);
                                break;
   }

   return(0);
}

/***************************************************************/
/*   Check for the existence of a directory
 */
int direxist(const char *directory_name)
{
struct stat buf;

   if (stat(directory_name, &buf) == 0) {
      if ((S_IFMT & buf.st_mode) != S_IFDIR)
         return(-1);
   } else {
      return(-1);
   }
   return(0);
}

/***************************************************************/
/*   Check for the existence of a file as a file or a pipe.
 */
int fileexist(char *filename)
{
struct stat buf;

   if (stat(filename, &buf) == 0) {
      if ((S_IFMT & buf.st_mode) != S_IFREG)
         if ((S_IFMT & buf.st_mode) != S_IFIFO)
            return(-1);
   } else {
      return(-1);
   }
   return(0);
}

char *searchdir(char *testdir, char *testname)
{
struct stat buf;
DIR *dirp;
char fullpath[DIRLEN], *testpath;
struct dirent *dp;
int err = 0;

   testpath = NULL;

   dirp = opendir(testdir);

   if (dirp != NULL) {
      while (((dp = readdir(dirp)) != NULL) &&
             (testpath == NULL)) {
         if ((strcmp(dp->d_name, ".") != 0) &&
             (strcmp(dp->d_name, "..") != 0)) {
            sprintf(fullpath, "%s/%s\0", testdir, dp->d_name);
            stat(fullpath, &buf);
            if (S_ISDIR(buf.st_mode)) {
               testpath = searchdir(fullpath, testname);
            } else {
               if (streq(testname, dp->d_name)) {
                  testpath = (char *)calloc(strlen(testdir) + 1, 1);
                  strcpy(testpath, testdir);
               }
            }
         }
      }
      closedir(dirp);
   } else {
      printf("%s could not be opened\n", testdir);
      fflush(stdout);
      err = -1;
   }

   return(testpath);
}

/********************************************************/
/*  This sets the proper environment for the driver to 
 *  run the tests.  Updates the PATH, creates the test 
 *  directory, changes to that directory, and resets the
 *  standard (in, out, err) files to be actual files.
 */

/**************************************************************************/
/*   Find the first occurence of "cmd".  This would be a test to this
 *   program.  Return the full path to the cmd.
 */
char *findcmd(char *cmd)
{
char *dirbuf, *testpath, *tcmd;
int dirlen;

   tcmd = cmd;
   if ((tcmd[0] == '.') && (tcmd[1] == '/')) {
      tcmd = &cmd[2];
   }
   dirbuf = NULL;
   dirlen = strlen(getenv("TEST_ROOT"));

   if (dirlen > 0) {
      dirbuf = calloc(dirlen + 1, 1);
      strcpy(dirbuf, getenv("TEST_ROOT"));
   } else {
      if (dirbuf == NULL) {
         dirbuf = getcwd(dirbuf, 0);
      }
   }

   testpath = searchdir(dirbuf, tcmd);
   free(dirbuf);

   return(testpath);
}
/***************************************************************/
/*   Make sure a given directory name is unique.
 *   Update the name if it is not and check again.
 */
char *newdir(char *base)
{
char *tmpdir;
int i;

   tmpdir = (char *)calloc(DIRLEN, 1);
   sprintf(tmpdir, "%s", base);

   i = 0;

   if (direxist(tmpdir) == 0) {
      do {
         sprintf(tmpdir, "%s_%d", base, i);
         i++;
      } while (direxist(tmpdir) == 0);
   }

   return(tmpdir);

}


/********************************************************************/
/*   Set up the DRIVERS working directory and move into it.
 *   This becomes the DRIVER root.  All test directories
 *   will be under this one.
 */
void dirsetup()
{
char *locHome;

   locHome = (char *)calloc(DIRLEN, 1);

   if (optDir == NULL) {
      getcwd(locHome, DIRLEN - 1);
      sprintf(locHome, "%s/VTD_%d", locHome, getpid());
   } else {
      sprintf(locHome, "%s", optDir);
   }

   thome = newdir(locHome);
   free(locHome);

   if (create_nested_directories(thome, stdout, 1) == 0) {
      printf("VTD:  Could not create driver directory\n");
      fflush(stdout);
      exit(0);
   }

   if (chmod(thome, 00777) != 0) {
      printf("VTD:  Unable to chmod() directory (%s)\n", thome);
      fflush(stdout);
      exit(0);
   }

   if (chdir(thome) != 0) {
      printf("VTD:  Could not enter driver directory\n");
      fflush(stdout);
      exit(0); 
   }

   return;

}

/***************************************************************/
/*   TEST DATA ROUTINES
 */
/**************************************************************/
/*   Find a test by its process id.
 */
int findslotbypid(int pid)
{
int found, i;
   
   found = 0;
   i = 0;

   while (!found) {
      if (running_tests[i].pid == pid) {
         found = 1;
      } else {
         i++;
      }

      if (i >= MAXTESTS) {
         printf("VTD:  slot search error\n");
         found = 1;
         i = -1;
      }
   }

   return(i);
}

/**************************************************************/
/*   Clear a tests execution directory.  Destroy the files and
 *   remove the directory.  It is generally only employed if
 *   the test passes.
 */
void cleardir(int slotid)
{
   if (GL_keepall == 0) {
      clearDirectory(running_tests[slotid].directory);

      if (rmdir(running_tests[slotid].directory) != 0) {
         printf("VTD:  Unable to remove directory %s\n", 
                         running_tests[slotid].directory);
         fflush(stdout);
      }
   }
   return;
}

void dumpline(int slotid)
{
  

   if (failfp != NULL) {
      fprintf(failfp, "%s\n", running_tests[slotid].cmdline);
      fflush(failfp);
   }

   return;
}


/***********************************************************/
/*   Find any unused slot.
 */
int getopenslot()
{
   return(findslotbypid(0));
}

void xmldump(int slotid)
{
   fprintf(runfp, "<test>\n");
   fprintf(runfp, "<pid>%d</pid>\n", running_tests[slotid].pid);
   fprintf(runfp, "<stime>%d</stime>\n", running_tests[slotid].start_time);
   fprintf(runfp, "<name>%s</name>\n", running_tests[slotid].name);
   fprintf(runfp, "<parent>");
   if (running_tests[slotid].suite != NULL) {
      fprintf(runfp, "/%s", running_tests[slotid].suite);
   } else {
      fprintf(runfp, "/UNKNOWN");
   }
   if (running_tests[slotid].category != NULL) {
      fprintf(runfp, "/%s", running_tests[slotid].category);
   } else {
      fprintf(runfp, "/UNKNOWN");
   }
   fprintf(runfp, "</parent>\n");
   fprintf(runfp, "<loc>%s</loc>\n", running_tests[slotid].directory);
   fprintf(runfp, "<path>%s</path>\n", running_tests[slotid].path);
   fprintf(runfp, "<info>%s</info>\n", running_tests[slotid].cmdline);
   if (running_tests[slotid].resstat == 0)
      fprintf(runfp, "<result>Test Passed</result>\n");
   else
      fprintf(runfp, "<result>Test Failed</result>\n");
   fprintf(runfp, "<etime>%d</etime>\n", running_tests[slotid].end_time);
   fprintf(runfp, "</test>\n");

   fflush(runfp);
}

void killMyResiduals(int pid)
{
   pid = pid * (-1);
   kill(pid, 9);
   return;
}

/*********************************************************/
/*  Clear a slot and mark it as free.
 *  pid = 0 is the free marker.
 */
void freeslot(int slotid)
{
int runit();

   if (running_tests[slotid].pid > 0) {
      xmldump(slotid);
      if (running_tests[slotid].newsess == 1) {
         killMyResiduals(running_tests[slotid].pid);
      }
   }

   if (running_tests[slotid].run_done < running_tests[slotid].run_cnt) {
      runit(slotid);
   } else {
      running_tests[slotid].type = 0;
      running_tests[slotid].mbs = 0;
      running_tests[slotid].passval = 0;
      running_tests[slotid].resstat = 0;
      running_tests[slotid].scon = 0;
      running_tests[slotid].mcon = 0;
      running_tests[slotid].sup = 0;
      running_tests[slotid].newsess = 0;
      running_tests[slotid].exists = 0;
      running_tests[slotid].copy = 0;

      running_tests[slotid].pid = 0;
      running_tests[slotid].start_time = 0;
      running_tests[slotid].end_time = 0;
      running_tests[slotid].max_time = 0;
      running_tests[slotid].run_cnt = 0;
      running_tests[slotid].run_done = 0;

      /**  A COPY of myargs[0]  **/
      free(running_tests[slotid].name);
      running_tests[slotid].name = NULL;

      /**  was mycopy2  **/
      free(running_tests[slotid].cmdline);
      running_tests[slotid].cmdline = NULL;

      /**  A copy of the running directory name  **/
      free(running_tests[slotid].directory);
      running_tests[slotid].directory = NULL;

      free(running_tests[slotid].directory_base);
      running_tests[slotid].directory_base = NULL;

      /**   was myargs  **/
      free(running_tests[slotid].args);
      running_tests[slotid].args = NULL;

      /**  was mycopy1  **/
      free(running_tests[slotid].holdargs);
      running_tests[slotid].holdargs = NULL;

      free(running_tests[slotid].path);
      running_tests[slotid].path = NULL;

      if (running_tests[slotid].suite != NULL) {
         free(running_tests[slotid].suite);
         running_tests[slotid].suite = NULL;
      }
      if (running_tests[slotid].category != NULL) {
         free(running_tests[slotid].category);
         running_tests[slotid].category = NULL;
      }
   }

   return;
}

/*********************************************************/
/*  Initialize a test slot with the appropriate test data.
   slotid = useslot(-1, mycopy, myargs, input);
 */
int useslot(int pid, char *cmd, char **execable, char *modline)
{
int myslot;
char *basename(), *trc, *finder;

   myslot = getopenslot();

   if (myslot != -1) {
      running_tests[myslot].type = test_limits.type;
      running_tests[myslot].copy = test_limits.copy;
      running_tests[myslot].mbs = test_limits.mbs;
      running_tests[myslot].passval = test_limits.passval;
      running_tests[myslot].resstat = 0;
      running_tests[myslot].scon = test_limits.scon;
      running_tests[myslot].mcon = test_limits.mcon;
      running_tests[myslot].sup = test_limits.sup;
      running_tests[myslot].exists = test_limits.exists;
      running_tests[myslot].newsess = test_limits.sess;
      running_tests[myslot].pid = pid;
      running_tests[myslot].start_time = (int)time((time_t *)NULL);
      running_tests[myslot].end_time = running_tests[myslot].start_time;
      running_tests[myslot].max_time = test_limits.max_time;
      running_tests[myslot].run_cnt = test_limits.run_cnt;
      running_tests[myslot].run_done = 0;
      running_tests[myslot].suite = test_limits.suite;
      running_tests[myslot].category = test_limits.category;

      /**   Came for mycopy  (mycopy2)  **/
      running_tests[myslot].cmdline = cmd;

      /**   Came from domyargs  (myargs)  **/
      running_tests[myslot].args = execable;

      /**   Came for mycopy  (mycopy1)  **/
      running_tests[myslot].holdargs = modline;

      if ((finder = findcmd(execable[0])) == NULL) {
         //printf("findcmd:  cmd not found\n");
         //printf("findcmd:  %s\n", execable[0]);
         //fflush(stdout);
         running_tests[myslot].exists = 0;
      } else {
         //printf("findcmd:  cmd was found\n");
         //printf("findcmd:  %s\n", execable[0]);
         //fflush(stdout);
         running_tests[myslot].exists = 1;
         running_tests[myslot].path = finder;
      }

      /**   A convenience.  Make is so the test  **/
      /**   name is easily available             **/
      if (test_limits.name != NULL) {
         running_tests[myslot].name = test_limits.name;
      } else {
         running_tests[myslot].name = (char *)malloc(strlen(basename(execable[0])) + 1);
         sprintf(running_tests[myslot].name, "%s\0", basename(execable[0]));
         trc = strrchr(running_tests[myslot].name, (int)'.');
         if (trc != NULL) {
            if (strcmp(trc, ".tst") == 0) {
               *trc = '\0';
            }
         }
      }

      /**   Set the base run directory for the test   **/
      /**   Can be modified by newdir                 **/
      running_tests[myslot].directory = (char *)malloc(DIRLEN);;
      sprintf(running_tests[myslot].directory, "%s/%s",
              thome, running_tests[myslot].name);

      running_tests[myslot].directory_base = (char *)malloc(DIRLEN);;
      sprintf(running_tests[myslot].directory_base, "%s/%s",
              thome, running_tests[myslot].name);

   }

   return(myslot);
}

/*******************************************************************/
/*  Check the TMP dir.  If a test has destroyed it, recreate it.
 */
void checktmpdir(char *path, char *tdel)
{

   if (direxist(path) != 0) {
      if (tdel != NULL) {
         printf("VTD:  tmpdir (%s) possibly removed by %s\n", path, tdel);
         fflush(stdout);
      }
      if (mkdir(path, 0777) != 0) {
         printf("VTD:  Unable to mkdir() tmpdir (%s)\n", path);
         fflush(stdout);
      } else {
         if (chmod(path, 00777) != 0) {
            printf("VTD:  Unable to chmod() tmpdir (%s)\n", path);
            fflush(stdout);
         }
      }
   }

   return;
}
/*
 *   END OF TEST DATA ROUTINES
 */
/****************************************************************/


void doenv()
{
char *testroot = NULL;

   tmpdirname = (char *)calloc(8, 1);
   strcpy(tmpdirname, "/tmp");

   testroot = getenv("TEST_ROOT");

   if (testroot == NULL) {
      printf("TEST_ROOT not set, exiting\n");
      fflush(stdout);
      exit(1);
   }
  

   // printf("TEST_ROOT=%s\n", getenv("TEST_ROOT"));
   // printf("TEST_BIN=%s\n", getenv("TEST_BIN"));
   // printf("PATH=%s\n", getenv("PATH"));
   // fflush(stdout);

   return;
}

int escapeWS(char *argstr, int loc)
{
int jj;

   jj = strlen(argstr);

   while ((isspace(argstr[loc])) && (loc < jj)) {
      loc++;
   }

   return(loc);
}

int findThis(char *argstr, int cmstart, char c)
{
int jj;

   jj = strlen(&argstr[cmstart]) + cmstart;

   while ((argstr[cmstart] != c) && (argstr[cmstart] != '\0')) {
      cmstart++;
      if (cmstart > jj)
         break;
   }

   if (argstr[cmstart] != c) {
      cmstart = -1;
   }

   return(cmstart);
}

/*******************************************************/
/*  Set a tests assumed limitations.  These can be 
 *  modified by the test entry in the test data file.
 */
void initLims()
{
   test_limits.type = 1;
   test_limits.mbs = 0;
   test_limits.sup = 1;
   test_limits.exists = 1;
   test_limits.copy = 0;
   test_limits.sess = newsession;
   test_limits.name = NULL;
   test_limits.suite = NULL;
   test_limits.category = NULL;
   test_limits.scon = MAXCONCUR;
   test_limits.mcon = MAXCONCUR;
   test_limits.max_time = TIMEOUT_TIME;
   test_limits.run_cnt = REPEAT_COUNT;
   test_limits.passval = 0;
}


/*******************************************************/
/*   For debugging.  Dump the content of the test_limits
 *   structure.
 */
void dumpLims()
{

   if (test_limits.type == 1) {
      printf("TYPE = POSITIVE\n");
      fflush(stdout);
   } else {
      if (test_limits.type == -1) {
         printf("TYPE = NEGATIVE\n");
         fflush(stdout);
      } else {
         printf("TYPE = BOGUS\n");
         fflush(stdout);
      }
   }
   if (test_limits.sup == 1) {
      printf("SUPPORTED = TRUE\n");
      fflush(stdout);
   } else {
      printf("SUPPORTED = FALSE\n");
      fflush(stdout);
   }

   if (test_limits.mbs == 1) {
      printf("MUST BE STANDALONE = TRUE\n");
      fflush(stdout);
   } else {
      printf("MUST BE STANDALONE = FALSE\n");
      fflush(stdout);
   }
   if (test_limits.sess == 1) {
      printf("NEW SESSION = YES\n");
      fflush(stdout);
   } else {
      printf("NEW SESSION = NO\n");
      fflush(stdout);
   }

   if (test_limits.name != NULL) {
      printf("NAME = %s\n", test_limits.name);
      fflush(stdout);
   } else {
      printf("NAME = DEFAULT\n");
      fflush(stdout);
   }
   printf("MIXED CONCURRENCY = %d\n", test_limits.mcon);
   fflush(stdout);
   printf("SELF CONCURRENCY = %d\n", test_limits.scon);
   fflush(stdout);
   printf("RUN TIME = %d\n", test_limits.max_time);
   fflush(stdout);
   printf("PASS EXIT VALUE = %d\n", test_limits.passval);
   fflush(stdout);
}

/*******************************************************/
/*   Use the test limit name and set the correct
 *   place in the limit structure to the limit value.
 */
void setLimStruct(char *limname, char *limval)
{
int len, i;

   len = strlen(limname);
   for (i = 0; i < len; i++) {
      limname[i] = toupper(limname[i]);
   }

   /*
    *len = strlen(limval);
    *for (i = 0; i < len; i++) {
    *   limval[i] = toupper(limval[i]);
    *}
    */

   if (strcmp(limname, "SESS") == 0) {
      if ((limval[0] == 'Y') || (limval[0] == 'y')) {
         test_limits.sess = 1;
      } else {
         test_limits.sess = 0;
      }
      return;
   }

   if (strcmp(limname, "ONHOST") == 0) {
      if ((limval[0] == 'Y') || (limval[0] == 'y')) {
         test_limits.type = 0;
      }
      return;
   }

   if (strcmp(limname, "COPYDIR") == 0) {
      if ((limval[0] == 'Y') || (limval[0] == 'y')) {
         test_limits.copy = 1;
      }
      return;
   }

   if (strcmp(limname, "NAME") == 0) {
      test_limits.name = (char *)malloc(strlen(limval) + 1);
      strcpy(test_limits.name, limval);
      return;
   }

   if (strcmp(limname, "TYPE") == 0) {
      switch (limval[0]) {
         case '+':
            test_limits.type = 1;
            break;
         case '-':
            test_limits.type = -1;
            break;
         case 'b':
         case 'B':
         case 'm':
         case 'M':
         default:
            test_limits.type = 0;
            break;
      }
      return;
   }

   if ((strcmp(limname, "EXIT") == 0) || (strcmp(limname, "PASS") == 0)) {
      test_limits.passval = atoi(limval);
      return;
   }

   if ((strcmp(limname, "TIME") == 0) || (strcmp(limname, "RUN") == 0)) {
      test_limits.max_time = atoi(limval);
      return;
   }

   if (strcmp(limname, "SCON") == 0) {
      test_limits.scon = atoi(limval);
      return;
   }

   if (strcmp(limname, "LOOP") == 0) {
      test_limits.run_cnt = atoi(limval);
      return;
   }

   if (strcmp(limname, "MCON") == 0) {
      test_limits.mcon = atoi(limval);
      return;
   }

   if (strcmp(limname, "SUPP") == 0) {
      if ((limval[0] == 'Y') || (limval[0] == 'y')) {
         test_limits.sup = 1;
      } else {
         test_limits.sup = 0;
      }
      return;
   }

   if (strcmp(limname, "MBS") == 0) {
      if ((limval[0] == 'Y') || (limval[0] == 'y')) {
         test_limits.mbs = 1;
         test_limits.mcon = 1;
      } else {
         test_limits.mbs = 0;
      }
      return;
   }

   if (strcmp(limname, "SUITE") == 0) {
      i = findThis(limval, 0, ',');
      if (i != (-1)) {
         limval[i] = '\0';
         i++;
         len = strlen(&limval[i]);
         test_limits.category = (char *)calloc(len + 1, 1);
         sprintf(test_limits.category, "%s", &limval[i]);
      }
      len = strlen(&limval[0]);
      test_limits.suite = (char *)calloc(len + 1, 1);
      sprintf(test_limits.suite, "%s", &limval[0]);
      return;
   }

   return;
}

/******************************************************/
/*   Originally had strtok_r in here, but in some cases,
 *   it did not work correctly.
 *   This is a new way of doing getLIms.  It uses more
 *   space, but is a lot cleaner in its means of 
 *   execution.  The original kludge fix to strtok is
 *   now labelled getLims2() and is commented out.
 *   If this fails you, you can rename getLims to
 *   useLess, rename getLims2 to getLims and recompile.
 *   It should work.
 */
void getLims(char *lims)
{
struct limstruct {
   char item[DIRLEN];
   char *limname, *limval;
   int good;
};
struct limstruct thing[10];
int end, left, right, i, j, eqcnt, thingcnt;
char *begin;

   end = strlen(lims);

   thingcnt = eqcnt =  right = left = 0;
   begin = lims;

   for (i = 0; i < 10; i++) {
      thing[i].limname = NULL;
      thing[i].limval = NULL;
      thing[i].good = 0;
      for (j = 0; j < DIRLEN; j++) {
         thing[i].item[j] = '\0';
      }
   }
   
   /************************************************/
   /*   If there are no equal signs, there are no
    *   pairs.  return.
    */
   for (i = 0; i < end; i++) {
      if (lims[i] == '=')
         eqcnt++;
   }

   if (eqcnt == 0)
      return;

   /************************************************/
   /*   Find all of the '=' pairs which should be
    *   seperated by a colon.
    */
   while (left < end) {
      right = findThis(lims, left, ':');
      if (right != (-1)) {
         strncpy(thing[thingcnt].item, begin, right - left);
         begin = &lims[right + 1];
         left = right + 1;
      } else {
         strncpy(thing[thingcnt].item, begin, end - left);
         left = end + 1;
      }
      thingcnt++;
   }

   /************************************************/
   /*   Split each of the '=' pairs into a name and
    *   a value.  If there is no equal sign here, 
    *   ignore the thing.
    */
   for (i = 0; i < thingcnt; i++) {
      right = findThis(thing[i].item, 0, '=');
      if (right != (-1)) {
         thing[i].limname = &thing[i].item[0];
         thing[i].limval = &thing[i].item[right + 1];
         thing[i].item[right] = '\0';
         thing[i].good = 1;
      }
   }

   /************************************************/
   /*   Process the pairs for setting the test
    *   limitations.
    */
   for (i = 0; i < thingcnt; i++) {
      if (thing[i].good == 1) {
         setLimStruct(thing[i].limname, thing[i].limval);
      }
   }

   return;
}

int testLims(char *argstr)
{
int cmstart, left, right;

   initLims();
   cmstart = escapeWS(argstr, 0);

   if (argstr[cmstart] == '(') {
      left = cmstart;
      right = findThis(argstr, left, ')');
      if (right != (-1)) {
         cmstart = right + 1;
         cmstart = escapeWS(argstr, cmstart);
         argstr[left] = '\0';
         argstr[right] = '\0';
         left++;
         getLims(&argstr[left]);
      }
   }

#ifdef LIM_DEBUG
   dumpLims();
#endif

   return(cmstart);
}

int findend(char *argstr, int start)
{
int end, found;

   found = 0;
   end = start + 1;

   while (!found) {
      switch (argstr[end]) {
         case '\0':
         case '\n':
         case ' ':
         case ')':
         case '(':
         case ':':
         case '\t':
         case '/':
         case '$':
                    found = 1;
                    break;
         default:
                    end++;
                    break;
      }
   }

   return(end);
}

void replaceit(char *argstr, int start)
{
int end, envlen;
char *tmpstr, *envname, *envstr, *trac;

   tmpstr = (char *)calloc(READLEN, 1);
   sprintf(tmpstr, "%s", argstr);

   end = findend(tmpstr, start);

   envlen = end - (start + 1);

   trac = &tmpstr[end];

   envname = (char *)calloc(envlen + 1, 1);
   strncpy(envname, &tmpstr[start + 1], envlen);
   envstr = getenv(envname);

   if (envstr != NULL) {
      sprintf(&argstr[start], "%s", envstr);
      start = start + strlen(envstr);
      sprintf(&argstr[start], "%s", trac);
   } else {
      sprintf(argstr, "%s", tmpstr);
   }

   free(envname);
   free(tmpstr);

   return;
}

void envvarreplace(char *argstr)
{
int i, len;

   len = strlen(argstr);

   for (i = 0; i < len; i++) {
      if (argstr[i] == '$') {
         replaceit(argstr, i);
         len = strlen(argstr);
      }
   }

   return;
}

/**************************************************************/
/*   Break a commandline into its individual arguments and
 *   set them up appropriately for use by execvp.
 */
char **domyargs(char *argstr)
{
char **myargs;
int i, j, jj, cmstart, argcnt;
char *tmpstr;

   cmstart = testLims(argstr);

   jj = strlen(&argstr[cmstart]);

   argcnt = 1;
   for (j = cmstart; j < (jj + cmstart); j++) {
      if (argstr[j] == ' ') {
         argcnt++;
      }
   }

   myargs = (char **)malloc(sizeof(char **) * (argcnt + 1));

   i = 0;
   myargs[i] = &argstr[cmstart];
   i = 1;


   for (j = cmstart; j < (jj + cmstart); j++) {
      if (argstr[j] == ' ') {
         tmpstr = &argstr[j];
         *tmpstr = '\0';
         tmpstr++;
         myargs[i] = tmpstr;
         i++;
      }
   }
   myargs[i] = NULL;

   /*************************************************/
   /*   Since we could have been reading the argument
    *   from a file, the last character could be a newline.
    *   This gets rid of it.
    */
   i = 0;
   while (myargs[i] != NULL) {
      jj = strlen(myargs[i]);
      for (j = 0; j < jj; j++) {
         if (myargs[i][j] == '\n') {
            myargs[i][j] = '\0';
         }
         if (myargs[i][j] == '\r') {
            myargs[i][j] = '\0';
         }
      }
      i++;
   }

#ifdef DEBUG
   i = 0;
   while (myargs[i] != NULL) {
      printf("Argurment %d:   %s\n", i, myargs[i]);
      i++;
   }
#endif


   return(myargs);

}

/***********************************************************/
/*   KILL ROUTINES
 *       killit(), flusholdtests()
 */
/**************************************************/
/*   Send the kill signal to the hoggish child.
 */
void killit(int slotid)
{

   killMyResiduals(running_tests[slotid].pid);
   kill(running_tests[slotid].pid, SIGKILL);

   return;
}

/*************************************************/
/*   See if any of the child processes have been running
 *   for longer than allow.  If so, kill the pigs.
 */
void flusholdtests()
{
int curr_time, i, tstdone;

   curr_time =(int)time((time_t *)NULL);

   for (i = 0; i < MAXTESTS; i++) {
      if (running_tests[i].pid > 0) {
         tstdone = running_tests[i].start_time + running_tests[i].max_time;
         if (curr_time > tstdone) {
            killit(i);
         }
      }
   }

}
/*
 *   END OF KILL ROUTINES
 */
/******************************************************/

/************************************************************************/
/*
 *   TEST STATUS ROUTINES.
 *        dofail(), dopass(), dopassfail(), dostatus()
 */
int whyNotRun(int slotid)
{
   if (running_tests[slotid].sup == 0)
      return(UNSUPP);
   if (running_tests[slotid].type == 0)
      return(NRTYPE);
   if (running_tests[slotid].exists == 0)
      return(NOEXIST);

   return(UNK);
}

void dofail(int pid, int slotid, int runtime, int killflag, int status)
{
char finclass[32];

   switch (killflag) {
      case 1:
                sprintf(finclass, "KILLED");
                break;
      case 2:
                switch (whyNotRun(slotid)) {
                   case NOEXIST:
                            sprintf(finclass, "NOT RUN (TEST NOT FOUND)");
                            break;
                   case NEEDFS:
                            sprintf(finclass, "NOT RUN (NEEDS LOCAL FS)");
                            break;
                   case UNSUPP:
                            sprintf(finclass, "NOT RUN (NOT SUPPORTED)");
                            break;
                   case NRTYPE:
                            sprintf(finclass, "NOT RUN (MANUAL, BROKEN OR HOST BASED)");
                            break;
                   case SUIDFAIL:
                            sprintf(finclass, "NOT RUN (SETUID FAILED)");
                            break;
                   case NOTROOT:
                            sprintf(finclass, "NOT RUN (DRIVER NOT ROOT)");
                            break;
                   case NEEDMEM:
                            sprintf(finclass, "NOT RUN (NOT ENOUGH MEMORY)");
                            break;
                   default:
                            sprintf(finclass, "NOT RUN (UNKNOWN)");
                            break;
                }
                break;
      default:
                sprintf(finclass, "Normal");
                break;
   }

   if (slotid >= 0) {
      running_tests[slotid].resstat = 1;
      fprintf(outfp, "%s, Test Failed, death(%s), time(M:%d, A:%d), exit(E:%d, A:%d), pid(%d)\n",
              running_tests[slotid].name, finclass,
              running_tests[slotid].max_time, runtime,
              running_tests[slotid].passval, status, pid);
      fflush(outfp);
      if (killflag != 2)
         dumpline(slotid);
      freeslot(slotid);
   } else {
      fprintf(outfp, "NAME_UNKNOWN, Test Failed, death(%s), UNKNOWN, pid(%d)\n",
              finclass, pid);
      fflush(outfp);
   }
  
   return;
}

void dopass(int pid, int slotid, int runtime, int status)
{
   if (slotid >= 0) {
      fprintf(outfp, "%s, Test Passed, death(Normal), time(M:%d, A:%d), exit(E:%d, A:%d), pid(%d)\n",
              running_tests[slotid].name,
              running_tests[slotid].max_time, runtime,
              running_tests[slotid].passval, status, pid);
      fflush(outfp);
      cleardir(slotid);
      freeslot(slotid);
   } else {
      fprintf(outfp, "NAME_UNKNOWN, Test Passed, death(Normal), UNKNOWN, pid(%d)\n", pid);
      fflush(outfp);
   }

   return;
}


void dopassfail(int pid, int slotid, int status, int runtime)
{
int killflag;

   killflag = 0;

   if (status == SUIDFAIL_EXIT) {
      killflag = 2;
   }

   if (running_tests[slotid].type == 1) {
      if (status == running_tests[slotid].passval) {
         dopass(pid, slotid, runtime, status);
      } else {
         dofail(pid, slotid, runtime, killflag, status);
      }
   } else {
      if (status != running_tests[slotid].passval) {
         dopass(pid, slotid, runtime, status);
      } else {
         dofail(pid, slotid, runtime, killflag, status);
      }
   }
  
   return;
}

void dostatus(int status, int pid)
{
int slotid, endtime, runtime, exstatus;

   endtime = (int)time((time_t *)NULL);
   slotid = findslotbypid(pid);

   if (slotid >= 0) {
      runtime = endtime - running_tests[slotid].start_time;
      running_tests[slotid].end_time = endtime;
   } else {
      return;
   }

   checktmpdir(tmpdirname, running_tests[slotid].name);
   exstatus = WEXITSTATUS(status);

   if ((!WIFSIGNALED(status)) && (WTERMSIG(status) != SIGKILL)) {
      dopassfail(pid, slotid, exstatus, runtime);
   } else {
      dofail(pid, slotid, runtime, 1, exstatus);
   }
   fflush(outfp);

   runcount--;
}

/*
 *   END OF TEST STATUS ROUTINES.
 */
/************************************************************************/


/**********************************************************/
/*   A couple of wait routines.  One waits on concurrency.
 *   I.e., if the number of allowable tests drops below the
 *   threshold, waiting stops so a new test can be started.
 *
 *   The other is a hard wait.  It waits for all child 
 *   processes to be done
 */
void hardwait()
{
int pid, status;
struct timespec mine;

   mine.tv_sec = 0;
   mine.tv_nsec = 5;

   pid = 0;

   /**********************************************************/
   /*   Scheduling trickery.  Force the test to run first so
    *   drive does not end up waiting the full 1 second every
    *   time.
    */
   nanosleep(&mine, NULL);

   /**********************************************************/
   /*   A wait loop.  There is no time limit here.  Wait until
    *   all remaining tests are complete before exiting.
    *   Each pass through the loop takes 1 second.
    */
   while (pid >= 0) {
      pid = waitpid(-1, &status, WNOHANG);
      if (pid > 0) {
         dostatus(status, pid);
      } else {
         if (pid == 0) {
            sleep(1);
            flusholdtests();
         }
      }
   }
   /**********************************************************/

}

void waitforit(int waitcount, int newtime)
{
int pid, status, wtime, dothetime;
struct timespec mine;

   mine.tv_sec = 0;
   mine.tv_nsec = 5;

   wtime = 0;
   pid = 0;

   dothetime = MAXTIMEOUT;

   if (newtime > dothetime)
      dothetime = newtime;

   /**********************************************************/
   /*   Scheduling trickery.  Force the test to run first so
    *   drive does not end up waiting the full 1 second every
    *   time.
    */
   nanosleep(&mine, NULL);

   
   /**********************************************************/
   /*   A wait loop.  Wait for dothetime seconds (max).  If the 
    *   test is not complete in that time it gets killed. 
    *   Otherwise, normal cleanup occurs.  Each pass through
    *   the loop takes 1 second.
    */
   while ((wtime < dothetime) && (pid >= 0)) {
      pid = waitpid(-1, &status, WNOHANG);
      if (pid > 0) {
         dostatus(status, pid);
      } else {
         if (pid == 0) {
            if (runcount >= waitcount) {
               sleep(1);
               wtime++;
               flusholdtests();
            } else {
               flusholdtests();
               break;
            }
         }
      }
   }
   /**********************************************************/

}
/*
 *  END OF WAIT ROUTINES
 */
/*********************************************************/

/*
 * This does the grunt work of re-opening the file and barking in case of error
 * Doesn't return anything, but errors appear on the console for the user 
 */ 
void do_reopen(const char* szFileName,      /* name of file to open */
               const char* szMode,          /* mode string */
	       const char* szEnglishName,   /* in case of error, we print */
                                            /* this out so the user knows */
                                            /* about the problem */
               FILE* pFileHand,             /* the file handle to be reopened */
	       FILE* pErrFile)              /* the file handle where errors get reported */

{ 
  int nStatus;    /* container for result of function calls */

  nStatus = create_nested_directories(szFileName, pErrFile, 0);

  if (nStatus) {
    pFileHand = freopen(szFileName, szMode, pFileHand);
    if (!pFileHand && pErrFile) {
      fprintf(pErrFile, "Could not re-open %s to file %s\n", 
	      szEnglishName, szFileName);
    }
  }

  return;

}

/*   Close the standard I/O files (to the screen) and reopen
 *   them as files.  Makes it so test data is not lost.
 */
void move_std_files(char *mydir, char *cmd)
{
char stdfile[DIRLEN + 1];     /* scratch var for holding the name of the file to reopen */

   sprintf(stdfile, "%s/%s.stdout", mydir, cmd);
   do_reopen(stdfile, "w", "stdout", stdout, stderr);

   sprintf(stdfile, "%s/%s.stdin", mydir, cmd);
   do_reopen(stdfile, "a+", "stdin", stdin, stderr);

   sprintf(stdfile, "%s/%s.stderr", mydir, cmd);
   do_reopen(stdfile, "w", "stderr", stderr, stdout);

   return;
}

int mkTestDir(int slotid)
{
   free(running_tests[slotid].directory);
   running_tests[slotid].directory = newdir(running_tests[slotid].directory_base);

   if (mkdir(running_tests[slotid].directory, 0777) != 0) {
      sleep(1);
      if (mkdir(running_tests[slotid].directory, 0777) != 0) {
         printf("VTD:  Could not create test directory:  %s\n",
                 running_tests[slotid].directory);
         fflush(stdout);
         return(-1);
      }
   }

   return(0);
}

void testsetup(char *cmd, int slotid)
{
char *basename(), *fullcmd, *srcdir, *mangle;
char prename[64];
int dirlen;

   if (running_tests[slotid].newsess == 1)
      setsid();

   /****************************************************/
   /*   Files required by driver could interfere with
    *   a test.  Close them.
    */
   fclose(runfp);
   fclose(outfp);
   fclose(failfp);
   fclose(fp);

   signal(SIGHUP, SIG_DFL);
   signal(SIGINT, SIG_DFL);

   signal(SIGUSR1, SIG_DFL);
   signal(SIGUSR2, SIG_DFL);

   signal(SIGABRT, SIG_DFL);
   signal(SIGSTOP, SIG_DFL);
   signal(SIGQUIT, SIG_DFL);
   signal(SIGTERM, SIG_DFL);

   copydirectory(running_tests[slotid].path, running_tests[slotid].directory);

   if (chdir(running_tests[slotid].directory) != 0) {
      printf("VTD:  Could not enter test directory %s\n",
              running_tests[slotid].directory);
      fflush(stdout);
      exit(-1); 
   }

   /********************************************/
   /*   Do copydir junk here.
    */
   if (running_tests[slotid].copy == 1) {
      dirlen = strlen(cmd);
      mangle = (char *)malloc(dirlen + 10);
      strcpy(mangle, cmd);
      srcdir = dirname(mangle);
      copydirectory(srcdir, running_tests[slotid].directory);
      free(mangle);
   }

   move_std_files(running_tests[slotid].directory, running_tests[slotid].name);

   /****************************************************/
   /*    Run a ".pre" setup file for a test if it exists.
    */
   sprintf(prename, "%s.pre", running_tests[slotid].name);
   if ((fullcmd = findcmd(prename)) != NULL) {
      system(fullcmd);
      free(fullcmd);
   }


   return;
}
int runit(int slotid)
{
int childpid, exstat, gotest;

   if ((running_tests[slotid].sup == 1) && 
       (running_tests[slotid].type != 0)) {
      gotest = 1;
   } else {
      //printf("Top:  gotest = 0\n");
      fflush(stdout);
      gotest = 0;
   }

   if (running_tests[slotid].exists == 0) {
      //printf("exists:  gotest = 0\n");
      fflush(stdout);
      gotest = 0;
   }

   if (gotest) {
      if (running_tests[slotid].mbs == 1) {
         hardwait();
      }
      running_tests[slotid].run_done++;
      if (mkTestDir(slotid) == 0) {
         printf("%s BEGUN\n", running_tests[slotid].name);
         fflush(stdout);
         childpid = fork();
         if (childpid == 0) {
            testsetup(running_tests[slotid].args[0], slotid);
            printf("%s RUNNING\n", running_tests[slotid].args[0]);
            exstat = execvp(running_tests[slotid].args[0],
                            running_tests[slotid].args);
            _exit(exstat);
         } else if (childpid > 0) {
            running_tests[slotid].pid = childpid;
            runcount++;
            if (runcount >= running_tests[slotid].mcon) {
               waitforit(running_tests[slotid].mcon, running_tests[slotid].max_time);
            }
         } else {
            printf("%s COULD NOT START\n", running_tests[slotid].name);
            fflush(stdout);
            dofail(0, slotid, 0, 2, -99);
            return(-1);
         }
      } else {
         dofail(0, slotid, 0, 2, -99);
         freeslot(slotid);
      }
   } else {
      running_tests[slotid].run_done = REPEAT_COUNT;
      if (GL_ig_ig == 1) {
         printf("%s IGNORED\n", running_tests[slotid].name);
         fflush(stdout);
         dofail(0, slotid, 0, 2, -99);
      } else {
         freeslot(slotid);
      }
   }

   return(0);

}

char *copyline(char *mystr)
{
int len;
char *line;

   len = strlen(mystr);

   /**  Any use of this is freed when freeslot is called and the data
    **  is freed.
    **/
   line = (char *)calloc(len + 1, 1);

   if (line == NULL) {
      printf("FATAL:  calloc() failed, exiting\n");
      exit(1);
   }

   sprintf(line, "%s", mystr);

   if (line[len - 1] == '\n') {
      line[len - 1] = '\0';
   }

   return(line);
}

void version_info()
{
   printf("VTD:  Version 1.0\n");
   printf("        *   Copyright (c) 2007 Vivisimo Corporation(R)\n");
   printf("        *   1710 Murray Ave\n");
   printf("        *   Pittsburgh, PA  15217\n");
   printf("\n\n");
   fflush(stdout);
   return;
}

void commandLineError()
{

   printf("Usage:  vtd -i <input_file> -o <results_file> -C <number>\n");
   printf("            -T <default_timeout> -t <run_time> -r <repeat_cnt>\n");
   printf("            -n -k -R -D <directory>\n\n");

   printf("All options except the -i option are optional.  -i must be specified.\n\n");

   printf("   -i <input_file>     :  file is a list of test command lines\n");
   printf("      default:  none, you must supply a test list (suffix = .vtd)\n");
   printf("   -D <directory>      :  User specified run directory\n");
   printf("      default:  The current directory\n");
   printf("   -o <results_file>   :  file is where result should go\n");
   printf("      default:  RESULTS\n");
   printf("   -x <results_xml_file>   :  file is where XML result should go\n");
   printf("      default:  RUNTESTS.xml\n");
   printf("   -C <number>         :  number is the quantity of test running at all times\n");
   printf("      default:  1, MAX=32\n");
   printf("   -T <default_timeout>:  How long a test should run before begin killed\n");
   printf("      default:  28800 seconds (8 hours)\n");
   printf("   -t <run_time>       :  How long should this driver run\n");
   printf("      default:  one complete pass through the test list\n");
   printf("   -r <repeat_cnt>     :  How many time should a given test be run in a row\n");
   printf("      default:  1\n");
   printf("   -n                  :  All tests run in new session\n");
   printf("      default:  no\n");
   printf("   -k                  :  Keep ALL test results\n");
   printf("      default:  dispose of passing results\n");
   printf("   -R                  :  Randomize test list\n");
   printf("      default:  run list in order given\n");
   printf("   -a                  :  Put all results in results file\n");
   printf("      default:  ignore results for unsupported or tests not found\n\n");

   printf("Generated Files:\n");
   printf("   RESULTS             :  List of test results (unless changed, above)\n");
   printf("   RUNTESTS.xml        :  List of completed tests in XML format\n");
   printf("   FAILURES            :  Command lines of the failed tests\n");
   printf("   DRVLSxxx            :  Generated if the -R option is specified\n");
   printf("                          xxx is generated by tempnam().  A new file\n");
   printf("                          is generated for each pass through the list\n");
   printf("                          and the old file is destroyed.\n\n");

   printf("Generated Directories:\n");
   printf("   VTD_<pid>           :  Directory which vtd moves into to run tests\n");
   printf("   <test_name>         :  A directory named after the test is created\n");
   printf("                          for each test to run in.  This directory and\n");
   printf("                          its contents are destroyed for passing tests\n");
   printf("                          unless -k is specified\n\n");

   exit(1);
}

void validateInFile()
{
char *dot, *newfile, *tmpdir;
int len;

   if (infile != NULL) {
      dot = rindex(infile, (int)'.');
      if (dot != NULL) {
         if (strcmp(dot, ".vtd") == 0) {
            if (infile[0] != '/') {
               tmpdir = (char *)calloc(DIRLEN, 1);
               getcwd(tmpdir, DIRLEN);
               len = strlen(tmpdir) + strlen(infile) + 2;
               newfile = (char *)calloc(len, 1);
               sprintf(newfile, "%s/%s", tmpdir, infile);
               infile = newfile;
               free(tmpdir);
            }
            return;
         }
      }
   } else {
      printf("vtd error:   Not input file specified (-i option)\n\n");
      commandLineError();
   }

   printf("vtd error:     file %s is not a valid test list\n", infile);
   printf("               If it is valid, please rename so that the file\n");
   printf("               name ends in .vtd\n\n");
   printf("WARNING:       This utility can not tell the difference between\n");
   printf("               a test and any other executable.  Be aware\n");
   printf("               that any executable that can be found will\n");
   printf("               be executed.  Even if it is shutdown, or\n");
   printf("               rm -rf /.  Be careful how you name your tests.\n");

   exit(-1);
}

void driversetup(int argc, char **argv)
{
//struct sysinfo sysglom;
char *outfile, *outxmlfile, *failfile, *devhld;
extern char *optarg;
static char *optstring = "i:o:C:nT:r:kRt:avD:s:x:";
int c, setserial;
//int er;
FILE *ravifd;

   //er = sysinfo(&sysglom);
   ////GL_totalmem = sysglom.mem_unit * sysglom.totalram;

   signal(SIGHUP, SIG_IGN);
   signal(SIGINT, SIG_IGN);

   signal(SIGUSR1, SIG_IGN);
   signal(SIGUSR2, SIG_IGN);

   signal(SIGABRT, SIG_IGN);
   signal(SIGSTOP, SIG_IGN);
   signal(SIGQUIT, SIG_IGN);
   signal(SIGTERM, SIG_IGN);

   driveCommand = argv[0];

   doenv();

   runcount = 0;
   newsession = 0;
   GL_keepall = 0;
   GL_time_over = 0;
   GL_dorandom = 0;
   GL_ig_ig = 0;

   myuid = geteuid();

   MAXCONCUR = 1;
   TIMEOUT_TIME = 28800;
   REPEAT_COUNT = 1;
   RUN_TIME = 0;

   if (argc < 3) {
      while ((c=getopt(argc, argv, optstring)) != EOF) {
         switch ((char)c) {
            case 'v':
                    version_info();
                    exit(0);
                    break;
            default:
                    version_info();
                    commandLineError();
                    break;
         }
      }
   }

   // infile = (char *)calloc(12, 1);
   // sprintf(infile, "tests.vtd");
   outfile = (char *)calloc(12, 1);
   sprintf(outfile, "RESULTS");
   outxmlfile = strdup("RUNTESTS.xml");

   /********************************************/
   /*
    *   Process and set arguments supplied on the 
    *   command line.
    */
   while ((c=getopt(argc, argv, optstring)) != EOF) {
      switch ((char)c) {
         case 'D':
                    optDir = optarg;
                    break;
         case 'i':
                    free(infile);
                    infile = optarg;
                    break;
         case 'o':
                    free(outfile);
                    outfile = optarg;
                    break;
         case 'x':
                    free(outxmlfile);
                    outxmlfile = optarg;
                    break;
         case 'T':
                    TIMEOUT_TIME = atoi(optarg);
                    if (TIMEOUT_TIME > MAXTIMEOUT)
                       TIMEOUT_TIME = MAXTIMEOUT;
                    break;
         case 's':
                    SLEEPTIME = atoi(optarg);
                    break;
         case 't':
                    RUN_TIME = atoi(optarg);
                    break;
         case 'r':
                    REPEAT_COUNT = atoi(optarg);
                    //if (REPEAT_COUNT > MAXREPEAT)
                    //   REPEAT_COUNT = MAXREPEAT;
                    break;
         case 'C':
                    MAXCONCUR = atoi(optarg);
                    if (MAXCONCUR > MAXTESTS)
                       MAXCONCUR = MAXTESTS;
                    break;
         case 'n':
                    newsession = 1;
                    break;
         case 'k':
                    GL_keepall = 1;
                    break;
         case 'R':
                    GL_dorandom = 1;
                    break;
         case 'v':
                    version_info();
                    exit(0);
                    break;
         case 'a':
                    GL_ig_ig = 1;
                    break;
         default:
                    version_info();
                    commandLineError();
                    break;
      }
   }

   validateInFile();

   dirsetup();
   outfp = fopen(outfile, "a+");
   runfp = fopen(outxmlfile, "a+");

   failfp = fopen("FAILURES", "a+");
   if (failfp == NULL) {
      failfile = tempnam(thome, "FAILS");
      if (failfile != NULL) {
         failfp = fopen(failfile, "a+");
      }
   }

   setserial = 0;
   if ((devhld = getenv("SERIAL_DEV")) == NULL) {
      setserial = 1;
   } else {
      if (access(devhld, F_OK) != 0) {
         setserial = 1;
      }
   }
 
   if (setserial == 1) {
      if (access("/dev/ttyS0", F_OK) == 0) {
         setenv("SERIAL_DEV", "/dev/ttyS0", 1);
      } else {
         setenv("SERIAL_DEV", "/dev/tts/0", 1);
      }
   }

   return;
}

/*********************************************************/
/*   Takes the read line dealing with the test and saves
 *   it to the test data area.  At the end of this function,
 *   each test is completely self-contained, at least as far
 *   as associated data is concerned.
 */
int dohickey(char *input)
{
char **myargs, *mycopy1, *mycopy2;
int slotid;

   envvarreplace(input);

   /***************************************************/
   /*   To copies of the read line.  One is to be kept
    *   intact so it can be returned to the user if
    *   necessary.  The other is manipulated to become
    *   the container for the arguments to execvp.
    *   Stored in running_test[].cmdline and
    *             running_test[].modline
    */
   mycopy1 = copyline(input);
   mycopy2 = copyline(input);

   /**************************************************/
   /*   Manipulate one of the lines and have the execvp
    *   args point to it.
    *             running_test[].args
    */
   myargs = domyargs(mycopy1);

   /**************************************************/
   /*   Stash all of the test data in one of the available
    *   test structures.
    */
   slotid = useslot(-1, mycopy2, myargs, mycopy1);

   return(slotid);
}

void setstarttime()
{
   GL_start_time = time((time_t *)NULL);
   GL_end_time = GL_start_time + RUN_TIME;
}

int checktime()
{
time_t now;

   now = time((time_t *)NULL);

   if (now > GL_end_time)
      return(1);
   else
      return(0);
}

int main(int argc, char **argv)
{
char mystr[READLEN];
char *usefile, *buf;
int done, i, slotid;
struct timespec mine;

   done = 0;

   SLEEPTIME = 2;

   driversetup(argc, argv);

   mine.tv_sec = SLEEPTIME;
   mine.tv_nsec = 50000;
   usefile = NULL;
   optDir = NULL;

   /*****************************************/
   /**  If we are using the timed option,  **/
   /**  get now, so we can use it for time **/
   /**  comparisons as we go.              **/
   setstarttime();

   //fprintf(runfp, "<vtd>\n");
   fprintf(runfp, "<pid>%d</pid>\n", getpid());
   buf = getdate();
   if (buf != NULL) {
      fprintf(runfp, "<sdate>%s</sdate>\n", buf);
      free(buf);
   }
   fprintf(runfp, "<stime>%ld</stime>\n", GL_start_time);

   fflush(runfp);

   do {

      /*********************************************/
      /**  The randomizer.  If enabled, generate  **/
      /**  a random order test file for use by    **/
      /**  the driver.  Uses a file so that if    **/
      /**  something happens (like a crash), the  **/
      /**  run in question can be recreated.      **/
      if (GL_dorandom) {
         usefile = newTestFileData(infile, usefile);
      } else {
         usefile = infile;
      }

      fp = fopen(usefile, "r");
      if (fp == NULL) {
         printf("VTD:  Could not open input file:  %s\n", infile);
         exit(0);
      }

      do {
         for (i = 0; i < READLEN; i++)
            mystr[i] = '\0';
         if (readline(fp, mystr)) {
            if (strlen(mystr) > 1) {
               if (mystr[0] != '#') {
                  slotid = dohickey(mystr);
                  nanosleep(&mine, NULL);
                  runit(slotid);
               }
#ifdef DEBUG
               else {
                  printf("COMMENT:  %s\n", mystr);
                  fflush(stdout);
               }
#endif
            }
         } else {
            done = 1;
         }

         /***************************************/
         /**  Are we out of time(if enabled)?  **/
         if (RUN_TIME > 0)
            GL_time_over = checktime();

      } while ((!done) && (!GL_time_over));

      /***************************************/
      /**  Close the existing file because  **/
      /**  we may be generating a new one.  **/
      fclose(fp);

      /***************************************/
      /**  Are we out of time(if enabled)?  **/
      /**  Are we just done?  End of file   **/
      /**  for a single pass ...            **/
      if (RUN_TIME == 0) {
         GL_time_over = 1;
      } else {
         done = 0;
         GL_time_over = checktime();
      }

   } while (!GL_time_over);

   /*********************************************/
   /**  Wait of the remaining tests to finish  **/
   hardwait();

   buf = getdate();
   if (buf != NULL) {
      fprintf(runfp, "<edate>%s</edate>\n", buf);
      free(buf);
   }
   fprintf(runfp, "<etime>%d</etime>\n", (int)time((time_t *)NULL));
   //fprintf(runfp, "</vtd>\n");

   fflush(runfp);

   printf("RUN TIME:  %ld seconds\n", ((int)time((time_t *)NULL) - GL_start_time));

   exit(0);
}