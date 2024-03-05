#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libgen.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <mysql.h>


#define READSZ 80
#define UIDINFOSZ 16

int errorval = 0;
int notfound = 0;

MYSQL mysql;

//////////////////////////////////////////////////////////////
//
//   This program assume the following tables exist in your
//   mysql database:
//
//   file_info:
//   create table file_info (
//      file_id integer not null,
//      file_name varchar(64) not null,
//      file_size integer,
//      data_type varchar(64),
//      file_location varchar(64));
//
//   file_content:
//   create table file_content (
//      file_id integer not null,
//      file_name varchar(64) not null,
//      seg_size integer not null,
//      read_num integer not null,
//      content varchar(64));
//

//////////////////////////////////////////////////////////////
//
//   There is not embedded sql precompiler for mysql.
//   Therefore, had to resort to using the C API
//
//   Compilation line:
//      gcc table_ins.mysql.c -I/usr/include/mysql
//                            -L/usr/lib/mysql
//                            -lmysqlclient
//


//////////////////////////////////////////////////////////////
//
//   Get the current size of a file for inclusion in the
//   file_info table.
//
int getfilesize(char *filename)
{
struct stat buf;
int there;

   there = stat(filename, &buf);
   if (there != 0) {
      printf("Could not stat file:  %s\n", filename);
      exit(1);
   }

   return(buf.st_size);
}


//////////////////////////////////////////////////////////////
//
//   Open a connection to the database.
//
int opendb(char *user, char *psswd)
{

   mysql_init(&mysql);
   mysql_options(&mysql, MYSQL_READ_DEFAULT_GROUP, "table_ins.mysql");
   if (!mysql_real_connect(&mysql, "192.168.0.61", user, psswd, "WWII_Navy", 0, NULL, 0)) {
      printf("DB open failed, exiting\n");
      printf("   Error:  %s\n", mysql_error(&mysql));
      exit(1);
   }

   return(0);
}

//////////////////////////////////////////////////////////////
//
//   Gather some data on the file and insert it into the
//   file_info table.  If the file name already exists,
//   exit the routine.
//
int insertfileinfo(char *argfilename)
{
int fileid, filesize;
char *filename, query[256];
MYSQL_RES *result;
MYSQL_ROW row;

   filename = basename(argfilename);
   filesize = getfilesize(argfilename);
   result = NULL;

   if (filesize <= 0) {
      printf("File contains no data; exiting\n");
      exit(0);
   }

   // EXEC SQL WHENEVER NOT FOUND DO notfoundfunc();
   // EXEC SQL SELECT file_id into :fileid
   //          FROM file_info
   //          WHERE file_name = :filename;
   sprintf(query,
           "select file_id from file_info where file_name = \"%s\"\0",
           filename);
   if (mysql_real_query(&mysql, query, strlen(query))) {
      notfound = 1;
   } else {
      result = mysql_store_result(&mysql);
      if (result) {
         if ((row = mysql_fetch_row(result))) {
            fileid = atoi(row[0]);
         } else {
            notfound = 1;
         }
         mysql_free_result(result);
         result = NULL;
      } else {
         notfound = 1;
      }
   }

   if (notfound == 1) {
      // EXEC SQL SELECT max(file_id) into :fileid
      //          FROM file_info;
      sprintf(query,
              "select max(file_id) from file_info\0");
      if (mysql_real_query(&mysql, query, strlen(query))) {
         errorval = 1;
      } else {
         result = mysql_store_result(&mysql);
         if (result) {
            if ((row = mysql_fetch_row(result))) {
               if (row[0] != NULL) {
                  fileid = atoi(row[0]);
               } else {
                  errorval = 1;
               }
            } else {
               errorval = 1;
            }
            mysql_free_result(result);
            result = NULL;
         } else {
            errorval = 1;
         }
      }

      if (errorval == 1)
         fileid = 0;
      else
         fileid++;

      // EXEC SQL INSERT INTO file_info
      //    (file_id, file_name, file_size)
      //    VALUES (:fileid, :filename, :filesize);
      sprintf(query,
              "insert into file_info (file_id, file_name, file_size) values (%d, \"%s\", %d)\0",
              fileid, filename, filesize);
      if (mysql_real_query(&mysql, query, strlen(query))) {
         errorval = 1;
      }

      // EXEC SQL COMMIT;
      mysql_commit(&mysql);
      notfound = 0;
   }

   return(fileid);
}

//////////////////////////////////////////////////////////////
char *buildquery(char *querystr, int fileid, char *filename,
                 int readsize, int linecount, char *data)
{
static char query[256];
int i;

   for (i = 0; i < 256; i++) {
      query[i] = '\0';
   }
   sprintf(query, "%s (%d, \'%s\', %d, %d, \'",
           querystr, fileid, filename, readsize, linecount);
   //
   //  Internally, strcat does a memcpy so this should work
   //  even if the contents of data is bizarre.
   //
   strcat(query, data);
   strcat(query, "\')");

   return(query);
}

//////////////////////////////////////////////////////////////
//
//   Insert the data into the database as a record.  All of 
//   the data was acquired in  readdata()
//   This routine inserts into the file_content table.
//
int insertdata(char *data, int datasz, char *filename,
               int linecount, int readsize, int fileid)
{
// int fdout;
char *query;

   // EXEC SQL INSERT INTO file_content
   //    (file_id, file_name, seg_size, read_num, content)
   //    VALUES (:fileid, :filename, :readsize, :linecount, :data);
   query = buildquery(
           "insert into file_content (file_id, file_name, seg_size, read_num, content) values",
           fileid, filename, readsize, linecount, data);
   if (mysql_real_query(&mysql, query, strlen(query))) {
      errorval = 1;
   }

   // EXEC SQL COMMIT;
   mysql_commit(&mysql);

   return(0);
}

//////////////////////////////////////////////////////////////
//
//   Open a file for reading only.  If the file can not be
//   opened, exit the program.
//
int openfile(char * filename)
{
int fd;

   fd = open(filename, O_RDONLY);

   if (fd != (-1)) {
      return(fd);
   } else {
      printf("Could not open file:  %s\n", filename);
      exit(1);
   }
}

//////////////////////////////////////////////////////////////
//
//   Read the data from the file into a buffer and pass it
//   up to be inserted into a database.  There is nothing
//   fancy here; just read a number of bytes and insert.
//
char *readdata(int fd, int readsize, char *filename, int fileid)
{
char mychunk[READSZ + 1];
int amt, linecount, i;

   linecount = 0;

   for (i = 0; i < (READSZ + 1); i++) {
      mychunk[i] = '\0';
   }

   amt = read(fd, mychunk, readsize);
   while (amt == readsize) {
      insertdata(mychunk, amt, filename, linecount, readsize, fileid);
      for (i = 0; i < (READSZ + 1); i++) {
         mychunk[i] = '\0';
      }
      amt = read(fd, mychunk, readsize);
      linecount++;
   }
   if (amt > 0) {
      insertdata(mychunk, amt, filename, linecount, readsize, fileid);
   }
}

//////////////////////////////////////////////////////////////
int main(int argc, char *argv[])
{
extern char *optarg;
extern int optind;
int fd, c, readsize, fileid;
char *argfilename;
static char *optstring = "f:s:";

   argfilename = NULL;
   fileid = readsize = 0;

   while ((c = getopt(argc, argv, optstring)) != EOF) {
      switch (c) {
         case 'f':
                    argfilename = optarg;
                    break;
         case 's':
                    readsize = atoi(optarg);
                    break;
         default:
                    printf("Invalid argument:  %c\n", (char)c);
                    break;
      }
   }

   if (readsize == 0) {
      readsize = READSZ;
   }

   if (readsize > READSZ) {
      readsize = READSZ;
   }

   if (argfilename == NULL) {
      printf("Must specify a file to import\n");
      exit(0);
   }

   opendb("gaw", "mustang5");

   fd = openfile(argfilename);
   fileid = insertfileinfo(argfilename);

   readdata(fd, readsize, basename(argfilename), fileid);

   exit(0);
}
