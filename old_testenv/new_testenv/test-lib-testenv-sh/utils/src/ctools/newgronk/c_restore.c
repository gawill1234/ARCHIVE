#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <ctype.h>
#include <dirent.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/stat.h>
#include "myincludes.h"

#define BLOCK_SIZE 4096
#define DIRLEN 512

struct thread_data{
   char *infile;
   char *outfile;
};

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

int create_initial_dir_stack(const char *dirToCreate)
{
char *dirbase, *dirduplicate;
struct stat buf;
int err;

   err = stat(dirToCreate, &buf);
   if ( err == 0 ) {
      if (S_ISDIR(buf.st_mode)) {
         return(0);
      } else {
         printf("Directory exists as file:  %s\n", dirToCreate);
         return(0);
      }
   }

   dirduplicate = strdup(dirToCreate);

   dirbase = _dirname(dirduplicate);

   create_initial_dir_stack(dirbase);
   free(dirduplicate);

#ifdef PLATFORM_WINDOWS
   mkdir(dirToCreate);
#else
   mkdir(dirToCreate, 0755);
#endif

   return(0);
}


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

//////////////////////////////////////////////////////////////////////
//
//   These functions are here in order to facilitate threading the
//   copy process.  If you do not see a bunch of 'heap' or 'pthread'
//   references it means the threading is not yet done.  Which of course
//   means that these functions look totally out of place.  They will
//   not be when this is done.
//
void runCopy(struct thread_data *copydata)
{
   printf("<copy type=\"file\">\n");
   printf("<source-file>%s</source-file>\n", copydata->infile);
   printf("<target-file>%s</target-file>\n", copydata->outfile);
   fflush(stdout);
   doCopy(copydata->infile, copydata->outfile, 1);
   printf("<copy-status>complete</copy-status>\n");
   printf("</copy>\n");
   fflush(stdout);
   return;
}

void threaded_copy(char *copything, char *copyto)
{
struct thread_data *copydata;
int rc;

   copydata = (struct thread_data *)malloc(sizeof(struct thread_data));
   if ( copydata != NULL ) {
      copydata->infile = copything;
      copydata->outfile = copyto;
   } else {
      return;
   }

   runCopy(copydata);

   free(copydata);

   return;
}
//
//   End threading facilitators.
//
//////////////////////////////////////////////////////////////////////

int copy_directory(char *directory_name, char *outdir)
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
      create_initial_dir_stack(outdir);
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
                  copy_directory(copything, copyto);
               } else {
                  /*************************************/
                  /*   Copy the files, if the pathes were created
                   *   properly.
                   */
                  if (copything != NULL) {
                     if (copyto != NULL) {
                        threaded_copy(copything, copyto);
                        //matchmode(copything, copyto);
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

char find_samba_drive()
{
int letter = (int)'Z';
char myfile[32];

   while ( letter >= (int)'D' ) {
      sprintf(myfile, "%c:\\CHECKFILE\0", (char)letter);
      if ( access(myfile, F_OK) == 0 )
         return( (char)letter );
      letter -= 1;
   }

   return('Z');
}

char *build_transfer_dir(char *collection) {
#ifdef PLATFORM_WINDOWS
char sep[] = "\\";
#else
char sep[] = "/";
#endif
int mylen;
char *destpath, *mdstr, *mydir;

   destpath = (char *)get_install_dir(NULL);
   mdstr = (char *)MD5String((unsigned char *)collection);
   mylen = strlen(destpath) + 3 + 30 + strlen(collection) + 2;

   mydir = (char *)calloc(mylen, 1);
   sprintf(mydir, "%s%sdata%ssearch-collections%s%.3s\0",
        destpath, sep, sep, sep, mdstr);

  free(mdstr);
  free(destpath);

  return(mydir);
}

int collection_is_viable(char *colpath, char *collection)
{
int viable = 0;
char pathname[512];
char collectionxml[512];
struct stat buf;
#ifdef PLATFORM_WINDOWS
char sep = '\\';
#else
char sep = '/';
#endif

   sprintf(pathname, "%s%c%s\0", colpath, sep, collection);
   sprintf(collectionxml, "%s%c%s.xml\0", colpath, sep, collection);

   stat(pathname, &buf);
   if (S_ISDIR(buf.st_mode)) {
      stat(collectionxml, &buf);
      if (S_ISREG(buf.st_mode)) {
         viable = 1;
      }
   }
   
   return(viable);
}

char *searchdir(char *basedir, char *collection)
{
struct stat buf;
DIR *dirp;
char fullpath[DIRLEN], *collectionpath;
struct dirent *dp;
int err = 0;
int found = 0;
#ifdef PLATFORM_WINDOWS
char sep = '\\';
#else
char sep = '/';
#endif

   collectionpath = NULL;

   if (collection_is_viable(basedir, collection)) {
      return(basedir);
   }

   dirp = opendir(basedir);

   if (dirp != NULL) {
      while (((dp = readdir(dirp)) != NULL) &&
             (collectionpath == NULL)) {
         if ((strcmp(dp->d_name, ".") != 0) &&
             (strcmp(dp->d_name, "..") != 0)) {
            if ( streq(dp->d_name, collection) ) {
               found = 1;
            }
            sprintf(fullpath, "%s%c%s\0", basedir, sep, dp->d_name);
            stat(fullpath, &buf);
            if (S_ISDIR(buf.st_mode)) {
               if ( found == 1 ) {
                  collectionpath = (char *)calloc(strlen(fullpath) + 1, 1);
                  strcpy(collectionpath, fullpath);
                  if (collection_is_viable(collectionpath, collection)) {
                     return(collectionpath);
                   } else {
                      free(collectionpath);
                      found = 0;
                      collectionpath = searchdir(fullpath, collection);
                   }
               } else {
                  found = 0;
                  collectionpath = searchdir(fullpath, collection);
               }
            }
         }
      }
      closedir(dirp);
   } else {
      printf("%s could not be opened\n", basedir);
      fflush(stdout);
      err = -1;
   }

   return(collectionpath);
}

char *build_source_dir(char *testname, char *collection) {
char *copyfile;
#ifdef PLATFORM_WINDOWS
char sep[] = "\\";
char zz;
#else
char sep[] = "/";
#endif

   copyfile = (char *)calloc(256, 1);

   if ( testname != NULL && collection != NULL ) {
#ifdef PLATFORM_WINDOWS
      //zz = find_samba_drive();
      //sprintf(copyfile, "%c:%ssaved-collections%s%s%s%s\0",
      //        zz, sep, sep, testname, sep, collection);
      //sprintf(copyfile, "%s%stestbed5.test.vivisimo.com%stestfiles%ssaved-collections%s%s%s%s\0",
      sprintf(copyfile, "%s%snetapp1a.bigdatalab.ibm.com%stestbed5-data%ssaved-collections%s%s%s%s\0",
              sep, sep, sep, sep, sep, testname, sep, collection);
#else
      sprintf(copyfile, "%stestenv%ssaved-collections%s%s%s%s\0",
              sep, sep, sep, testname, sep, collection);
#endif
   } else {
#ifdef PLATFORM_WINDOWS
      //zz = find_samba_drive();
      //sprintf(copyfile, "%c:%ssaved-collections\0", zz, sep);
      //sprintf(copyfile, "%s%stestbed5.test.vivisimo.com%stestfiles%ssaved-collections\0", sep, sep, sep, sep);
      sprintf(copyfile, "%s%snetapp1a.bigdatalab.ibm.com%stestbed5-data%ssaved-collections\0", sep, sep, sep, sep);
#else
      sprintf(copyfile, "%stestenv%ssaved-collections\0", sep, sep);
#endif
   }

   return(copyfile);
}

int restore_the_collection(char *testname, char *collection)
{
char *destdir, *sourcedir, *newdir;
time_t end_time, start_time;

   sourcedir = build_source_dir(testname, collection);
   destdir = build_transfer_dir(collection);

   newdir = searchdir(sourcedir, collection);

   create_initial_dir_stack(destdir);
   start_time = time(NULL);
   copy_directory(newdir, destdir);
   end_time = time(NULL);

   printf("<time in=\"seconds\">%d</time>\n", end_time - start_time);
   fflush(stdout);

   return(0);
}

/*
int main() 
{

char *destdir, *sourcedir, *newdir;
char collection[32] = "asugtest-autocomplete";
char testname[32] = "test_a_test";
time_t end_time, start_time;

   sourcedir = build_source_dir(NULL, collection);
   destdir = build_transfer_dir(collection);

   printf("%s\n", sourcedir);
   fflush(stdout);
   newdir = searchdir(sourcedir, collection);

   printf("%s\n", newdir);
   printf("%s\n", destdir);
   fflush(stdout);

   create_initial_dir_stack(destdir);
   start_time = time(NULL);
   copy_directory(newdir, destdir);
   end_time = time(NULL);
   printf("Elapsed time:  %d seconds\n", end_time - start_time);
   fflush(stdout);

   exit(0);
}
*/
