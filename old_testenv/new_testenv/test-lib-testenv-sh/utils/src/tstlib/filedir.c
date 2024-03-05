#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/statfs.h>
#include <errno.h>

#define BLOCK_SIZE 4096
#define DIRLEN 256

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

/***************************************************************/
/*   Check for the existence of a file as a file or a pipe.
 */
int fileexist(char *filename)
{
struct stat buf;

   if (stat(filename, &buf) == 0) {
      if ((S_IFMT & buf.st_mode) != S_IFREG)
         if ((S_IFMT & buf.st_mode) != S_IFIFO)
            return(0);
   } else {
      return(0);
   }
   return(1);
}

/***************************************************************/
/*   Check for the existence of a directory
 */
int direxist(const char *directory_name)
{
struct stat buf;

   if (stat(directory_name, &buf) == 0) {
      if ((S_IFMT & buf.st_mode) != S_IFDIR)
         return(0);
   } else {
      return(0);
   }
   return(1);
}

/***************************************************************/
/*   Make sure a given directory name is unique.
 *   Update the name if it is not and check again.
 */
char *uniquedirname(char *base)
{
char *tmpdir;
int i, dirlen;

   dirlen = strlen(base);
   dirlen = dirlen + 1 + 15 + 1;

   tmpdir = (char *)malloc(dirlen);
   strcpy(tmpdir, base);

   i = 0;

   if (direxist(tmpdir)) {
      do {
         sprintf(tmpdir, "%s_%d", base, i);
         i++;
      } while (direxist(tmpdir));
   }

   return(tmpdir);

}

/*
 * Attempt to create nested directories, return 1 on success, 0 on failure
 * Why does it take so much code to do the right thing?
 *
 * Returns 1 when all of the directories get created, 0 otherwise
 *
 */
int create_nested_directories(const char* szFileName,     /* the file name to create directories for, lops off last part */
                              FILE* pErrFile, int fff)    /* file handle to use for reporting errors */
{
  char *_dirname();
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
     szBaseName = _dirname(szPath);
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
    while (*(pcEnd + 1) && *(pcEnd + 1) != '/')
      pcEnd++;

  }

  free(szPath);
  return nWorked;

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
char *copything, *copyto, *buildfullpath();
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
   if (direxist(directory_name)) {
      dirp = opendir(directory_name);
   } else {
      return(0);
   }

   /*************************************/
   /*   If the destination directory does not
    *   exist, create it.
    */
   if (! direxist(outdir)) {
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
               copything = buildfullpath(directory_name, dp->d_name);
               copyto = buildfullpath(outdir, dp->d_name);

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



/******************************************************************/
/*   Remove the contents of a directory, including other
 *   directories.
 */
int cleardirectory(const char *directory_name)
{
DIR *dirp, *opendir();
struct dirent *dp, *readdir();
char *rmthing, *buildfullpath();

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
               rmthing = buildfullpath(directory_name, dp->d_name);
               if (rmthing != NULL) {
                  if (unlink(rmthing) < 0) {
                     if (direxist(rmthing) == 0) {
                        cleardirectory(rmthing);
                        if (rmdir(rmthing) != 0) {
                           printf("cleardirectory:  Could not remove directory %s\n", rmthing);
                        }
                     } else {
                        printf("cleardirectory:  Could not remove file %s\n", rmthing);
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


char *searchdir(char *testdir, char *testname)
{
struct stat buf;
DIR *dirp;
char fullpath[256], *testpath;
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
                  //testpath = (char *)calloc(strlen(fullpath) + 1, 1);
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

char *findfile(char *testname)
{
char *dirbuf, *testpath;
int dirlen;

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

   testpath = searchdir(dirbuf, testname);
   free(dirbuf);

   return(testpath);

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
   while (readnum > 0) {
      writenum = write(fno2, mychunk, BLOCK_SIZE);
      readnum = read(fno, mychunk, BLOCK_SIZE);
   }

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


