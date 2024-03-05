#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include <libgen.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <libEMF/wine/windef.h>
#include <libEMF/wine/winnt.h>
#include <w32api/sql.h>
#include <w32api/sqlext.h>
//
//  Included by sql.h
//#include <w32api/sqltypes.h>
//

//#include <sqlca.h>

//EXEC SQL INCLUDE SQLCA;

#define READSZ 4000
#define UIDINFOSZ 16

SQLHSTMT hstmt;
SQLHENV henv;
SQLHDBC hdbc;

int errorval = 0;
int notfound = 0;

//////////////////////////////////////////////////////////////
//
//   This program assume the following tables exist in your
//   postgres database:
//
//   file_info:
//   create table file_info (
//      file_id number not null,
//      file_name varchar(64) not null,
//      file_size number,
//      data_type varchar(64),
//      file_location varchar(256));
//
//   file_content:
//   create table file_content (
//      file_id number not null,
//      file_name varchar(64) not null,
//      seg_size number not null,
//      read_num number not null,
//      content varchar(4000));
//

//////////////////////////////////////////////////////////////
//
//   The odbc variant of an embedded sql program.
//
//   This needs cygwin installed
//   The sqltypes.h file needs to have the SQLUBIGINT type 
//   redifined to match SQLBIGINT(if it does not compile)
//   
//   Compilation:
//      gcc -o table_ins table_ins.odbc.c -L /lib/w32api -l odbc32
//

void mysql_error(char *from)
{
SQLCHAR state[6], text[128];
SQLINTEGER eptr;
SQLSMALLINT actlen;

   errorval = 1;
   printf("ERROR in:  %s\n", from);
   fflush(stdout);
   SQLGetDiagRec(SQL_HANDLE_STMT, hstmt, 1, &state[0],
                 &eptr, &text[0], 128, &actlen);
   printf("ERROR STATE:  %s\n", state);
   printf("ERROR TEXT:   %s\n", text);
   fflush(stdout);

   exit(0);
}

void notfoundfunc()
{
   notfound = 1;

   return;
}

//////////////////////////////////////////////////////////////
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
SQLRETURN retcode;

char *junk = "files";

   retcode = SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &henv);
   if (retcode == SQL_SUCCESS || retcode == SQL_SUCCESS_WITH_INFO) {
      retcode = SQLSetEnvAttr(henv, SQL_ATTR_ODBC_VERSION,
                              (void *)SQL_OV_ODBC3, 0);
      if (retcode == SQL_SUCCESS || retcode == SQL_SUCCESS_WITH_INFO) {
         retcode = SQLAllocHandle(SQL_HANDLE_DBC, henv, &hdbc);
         if (retcode == SQL_SUCCESS || retcode == SQL_SUCCESS_WITH_INFO) {
            SQLSetConnectAttr(hdbc, (void *)SQL_LOGIN_TIMEOUT, 5, 0);
            retcode = SQLConnect(hdbc, (SQLCHAR *)junk, SQL_NTS,
                                       (SQLCHAR *)user, SQL_NTS,
                                       (SQLCHAR *)psswd, SQL_NTS);
            if (retcode == SQL_SUCCESS || retcode == SQL_SUCCESS_WITH_INFO) {
               return(0);
            }
         }
      }
   }
   
   return(1);
}

//////////////////////////////////////////////////////////////
//
//   Gather some data on the file and insert it into the
//   file_info table.  If the file name already exists,
//   exit the routine.
//
int insertfileinfo(char *argfilename)
{
SQLINTEGER fileid, filesize, cbStatus, cbfile_id, rescols;
SQLCHAR *filename;
SQLRETURN retcode;

   cbStatus = SQL_NTS;
   filename = basename(argfilename);
   filesize = getfilesize(argfilename);
   fileid = 0;

   if (filesize <= 0) {
      printf("File contains no data; exiting\n");
      exit(0);
   }

   //EXEC SQL WHENEVER NOT FOUND DO notfoundfunc();
   //EXEC SQL SELECT file_id into :fileid
   //         FROM file_info
   //         WHERE file_name = :filename;

   if (SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt) == SQL_ERROR) {
      mysql_error("insertfileinfo");
   }
   retcode = SQLPrepare(hstmt,
                        "SELECT file_id FROM file_info WHERE file_name = ?",
                        SQL_NTS);

   if (retcode == SQL_SUCCESS || retcode == SQL_SUCCESS_WITH_INFO) {
      SQLBindParameter(hstmt, 1, SQL_PARAM_INPUT, 
                       SQL_C_CHAR, SQL_CHAR, strlen(filename), 0,
                       filename, 0, &cbStatus);
      retcode = SQLExecute(hstmt);
      if (retcode == SQL_SUCCESS) {
         retcode = SQLFetch(hstmt);
         if (retcode == SQL_ERROR) {
            mysql_error("insertfileinfo");
         }
         if (retcode == SQL_NO_DATA) {
            notfoundfunc();
         }
         if (retcode == SQL_SUCCESS || retcode == SQL_SUCCESS_WITH_INFO) {
            SQLGetData(hstmt, 1, SQL_C_SLONG, &fileid, 0, &cbfile_id);
         }
      }
   }
   // SQLFreeStmt(hstmt, SQL_RESET_PARAMS);
   SQLFreeHandle(SQL_HANDLE_STMT, hstmt);

   if (notfound == 1) {
      //EXEC SQL SELECT max(file_id) into :fileid
      //         FROM file_info;
      if (SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt) == SQL_ERROR) {
         mysql_error("insertfileinfo");
      }
      retcode = SQLExecDirect(hstmt,
                           "SELECT MAX(file_id) FROM file_info\0", SQL_NTS);

      if (retcode == SQL_SUCCESS || retcode == SQL_SUCCESS_WITH_INFO) {
         retcode = SQLFetch(hstmt);
         if (retcode == SQL_ERROR) {
            mysql_error("insertfileinfo");
         }
         if (retcode == SQL_SUCCESS || retcode == SQL_SUCCESS_WITH_INFO) {
            SQLGetData(hstmt, 1, SQL_C_SLONG, &fileid, 0, &cbfile_id);
         }
      } else {
         mysql_error("insertfileinfo");
      }
      // SQLFreeStmt(hstmt, SQL_RESET_PARAMS);
      SQLFreeHandle(SQL_HANDLE_STMT, hstmt);

      if (retcode == SQL_NO_DATA)
         fileid = 0;
      else
         fileid++;

      //EXEC SQL INSERT INTO file_info
      //   (file_id, file_name, file_size)
      //   VALUES (:fileid, :filename, :filesize);

      //EXEC SQL COMMIT;

      if (SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt) == SQL_ERROR) {
         mysql_error("insertfileinfo");
      }
      retcode = SQLPrepare(hstmt,
                           "INSERT INTO file_info (file_id, file_name, file_size) VALUES(?, ?, ?)",
                           SQL_NTS);

      if (retcode == SQL_SUCCESS || retcode == SQL_SUCCESS_WITH_INFO) {
         SQLBindParameter(hstmt, 1, SQL_PARAM_INPUT, 
                          SQL_C_SLONG, SQL_INTEGER, 0, 0,
                          &fileid, 0, NULL);
         SQLBindParameter(hstmt, 2, SQL_PARAM_INPUT, 
                          SQL_C_CHAR, SQL_CHAR, strlen(filename), 0,
                          filename, 0, &cbStatus);
         SQLBindParameter(hstmt, 3, SQL_PARAM_INPUT, 
                          SQL_C_SLONG, SQL_INTEGER, 0, 0,
                          &filesize, 0, NULL);
         if (SQLExecute(hstmt) == SQL_ERROR) {
            mysql_error("insertfileinfo");
         }
      }

      // SQLFreeStmt(hstmt, SQL_RESET_PARAMS);
      SQLFreeHandle(SQL_HANDLE_STMT, hstmt);

      notfound = 0;
 
   }

   return(fileid);
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
SQLINTEGER pgfileid, pgreadsize, pglinecount, cbStatus;
SQLCHAR *pgfilename, *pgdata;

   cbStatus = SQL_NTS;
   pgfileid = fileid;
   pgreadsize = readsize;
   pglinecount = linecount;
   pgdata = data;
   pgfilename = filename;

   // fdout = fileno(stdout);
   // printf("\nREAD COUNT:  %d\n", linecount);
   // write(fdout, data, datasz);
   //EXEC SQL INSERT INTO file_content
   //   (file_id, file_name, seg_size, read_num, content)
   //   VALUES (:pgfileid, :pgfilename, :pgreadsize, :pglinecount, :pgdata);

   //EXEC SQL COMMIT;

   SQLBindParameter(hstmt, 1, SQL_PARAM_INPUT, 
                    SQL_C_SLONG, SQL_INTEGER, 0, 0,
                    &pgfileid, 0, NULL);
   SQLBindParameter(hstmt, 2, SQL_PARAM_INPUT, 
                    SQL_C_CHAR, SQL_CHAR, strlen(filename), 0,
                    pgfilename, 0, &cbStatus);
   SQLBindParameter(hstmt, 3, SQL_PARAM_INPUT, 
                    SQL_C_SLONG, SQL_INTEGER, 0, 0,
                    &pgreadsize, 0, NULL);
   SQLBindParameter(hstmt, 4, SQL_PARAM_INPUT, 
                    SQL_C_SLONG, SQL_INTEGER, 0, 0,
                    &pglinecount, 0, NULL);
   SQLBindParameter(hstmt, 5, SQL_PARAM_INPUT, 
                    SQL_C_CHAR, SQL_CHAR, readsize, 0,
                    pgdata, 0, NULL);
   if (SQLExecute(hstmt) == SQL_ERROR) {
      mysql_error("insertdata");
   }

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
SQLRETURN retcode;

   linecount = 0;

   for (i = 0; i < (readsize + 1); i++) {
      mychunk[i] = '\0';
   }

   if (SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt) == SQL_ERROR) {
      mysql_error("readdata");
   }
   retcode = SQLPrepare(hstmt,
                        "INSERT INTO file_content (file_id, file_name, seg_size, read_num, content) VALUES(?, ?, ?, ?, ?)",
                        SQL_NTS);

   if (retcode == SQL_SUCCESS || retcode == SQL_SUCCESS_WITH_INFO) {

      amt = read(fd, mychunk, readsize);
      while (amt == readsize) {
         insertdata(mychunk, amt, filename, linecount, readsize, fileid);
         for (i = 0; i < (readsize + 1); i++) {
            mychunk[i] = '\0';
         }
         amt = read(fd, mychunk, readsize);
         linecount++;
      }
      if (amt > 0) {
         insertdata(mychunk, amt, filename, linecount, readsize, fileid);
      }
   }

   // SQLFreeStmt(hstmt, SQL_RESET_PARAMS);
   SQLFreeHandle(SQL_HANDLE_STMT, hstmt);
}

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
      fflush(stdout);
      exit(0);
   }

   if (opendb("gaw", "mustang5") != 0) {
      printf("DB open:  failure??\n");
      fflush(stdout);
      exit(1);
   }

   fd = openfile(argfilename);
   fileid = insertfileinfo(argfilename);

   readdata(fd, readsize, basename(argfilename), fileid);

   exit(0);
}
