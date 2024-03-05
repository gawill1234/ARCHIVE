#include "myincludes.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>

int get_file_stat_time(char *filename, char *whichdate)
{
struct stat buf;
int err;

   err = stat(filename, &buf);

   if (err == 0) {
      if (whichdate != NULL) {
         if ( strncmp(whichdate, "access", 6) == 0 ) {
            return(buf.st_atime);
         }
         if ( strncmp(whichdate, "change", 6) == 0 ) {
            return(buf.st_ctime);
         }
         if ( strncmp(whichdate, "modifi", 6) == 0 ) {
            return(buf.st_mtime);
         }
      }
      //
      //   If whichdate is NULL or does not exist, default to
      //   access time.
      //
      return(buf.st_atime);
   }

   return(err);
}

int get_file_time(char *filename, char *whichdate)
{
time_t timeint;
char *tstring, *success;
char badfile[] = "NO_FILE\0";
char badtime[] = "0000-00-00T00:00:00-00:00\0";
char ogood[] = "Success\0";
char obad[] = "Failure\0";

   printf("%s", content);
   fflush(stdout);

   printf("<REMOP>\n");
   printf("   <OP>FILETIME</OP>\n");
   fflush(stdout);

   if (filename == NULL) {
      filename = badfile;
      tstring = badtime;
      success = obad;
   } else {
      timeint = get_file_stat_time(filename, whichdate);
      if (timeint > 0) {
         success = ogood;
      } else {
         success = obad;
      }
   }

   printf("   <FILENAME>%s</FILENAME>\n", filename);
   printf("   <TIMESTAMP>%ld</TIMESTAMP>\n", timeint);
   printf("   <OUTCOME>%s</OUTCOME>\n", success);
   printf("</REMOP>\n");
   fflush(stdout);


   return(0);

}

int get_file_size(char *filename)
{
struct stat buf;
int err;

   err = stat(filename, &buf);

   if (err == 0) {
      return(buf.st_size);
   }

   return(err);
}

int openreadwrite(char *name)
{
int fd;

   fd = open(name, O_RDWR);
   if (fd > 0) {
      return(fd);
   }

   return(-1);
}

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

        for (i = strlen(path); i>0; i--)
#ifdef PLATFORM_WINDOWS
                if (path[i] == '\\')
#else
                if (path[i] == '/')
#endif
                        break;
        path[i] = '\0';

        return(path) ;
}
/*******************************************************/

//
//   Check for the existence of a collection/file.
//
int collection_exists_check(int from, char *collection_name)
{
char *dirname;
int len, retval;

   retval = 0;

   if (access(collection_name, F_OK) == 0) {
      return(retval);
   } else {
      len = strlen(collection_name);
      dirname = (char *)calloc(len + 1, 1);
      strncpy(dirname, collection_name, len - 4);
      if (access(dirname, F_OK) == 0) {
         retval = 0;
      } else {
         retval = -1;
      }
      free(dirname);
      return(retval);
   }
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
static char *args[MAXPIDS];
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

