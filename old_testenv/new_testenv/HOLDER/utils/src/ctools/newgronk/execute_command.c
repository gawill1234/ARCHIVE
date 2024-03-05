#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <dirent.h>
#include <string.h>

#define BLOCK_SIZE 4096

char *finddot(char *line)
{
   if (line == NULL) 
      return(NULL);

   while (*line != '\0') {
      switch (*line) {
         case '\0':
         case '\n':
                    *line = '\0'; 
                    return(NULL);
         case ' ':
                    return(line);
         default:
                    line++;
      }
   }

   return(NULL);
}

int doCopy(char *infile, char *outfile, int dumpstatus)
{
int fno, fno2, readnum, writenum, status_interval;
char mychunk[BLOCK_SIZE];

#ifdef DEBUG
   printf("doCopy():  copying %s  to  %s\n", infile, outfile);
   fflush(stdout);
#endif

   status_interval = 0;

#ifdef PLATFORM_WINDOWS
   /************************************/
   /*   Open infile for reading
   */
   if ((fno = open(infile, O_RDONLY|O_BINARY, 00666)) == (-1)) {
      return(fno);
   }

   /************************************/
   /*   Open outfile for writing
   */
   if ((fno2 = open(outfile, O_RDWR|O_CREAT|O_BINARY,00666)) == (-1)) {
      return(fno2);
   }
#else
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
#endif

   /*************************************/
   /*  Read file a block a time and write
       to the output file.
   */
   readnum = read(fno, mychunk, BLOCK_SIZE);
   while (readnum == BLOCK_SIZE) {
      writenum = write(fno2, mychunk, BLOCK_SIZE);
      status_interval += 1;
      if ( status_interval % 100000 == 0 ) {
         printf("<copy-status type=\"progress-in-bytes\">%d</copy-status>\n", status_interval * BLOCK_SIZE);
         fflush(stdout);
      }
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

char **parse_line(char *myline)
{
int len, cnt, i;
char *lineCopy, *tmp;
static char *a[10];

   cnt = 0;
   len = strlen(myline);
   lineCopy = (char *)calloc(1, len + 1);

   strcpy(lineCopy, myline);

   tmp = lineCopy;
   while (tmp != NULL) {
      a[cnt] = tmp;
      //printf ("TMP:  %s\n", tmp);
      //fflush(stdout);
      tmp = finddot(tmp);
      if (tmp != NULL) {
         *tmp = '\0';
         tmp++;
      }
      cnt++;
   }

   return(a);
}

//
//   Execute a command.
//
int execute_command(int from, char *ecmd)
{
int err = 0, len, i;
char **a;
char *greeb, *new_ld, *get_install_dir();
//char *junk;
char base_ld[] = "LD_LIBRARY_PATH=/usr/local/lib";

   if (ecmd != NULL) {
      len = strlen(ecmd);
      for (i = 0; i < len; i++) {
         if ((ecmd[i] == '{') || (ecmd[i] == '}'))
            ecmd[i] = '"';
      }
#ifndef PLATFORM_WINDOWS
      greeb = get_install_dir("/lib");
      len = strlen(base_ld) + strlen(greeb) + 5;
      new_ld = (char *)calloc(len, 1);
      sprintf(new_ld, "%s:%s\0", base_ld, greeb);
      putenv(new_ld);
#endif
     
      a = parse_line(ecmd);
      if (a[0] != NULL) {
         if ((strcmp(a[0], "copy") == 0) || (strcmp(a[0], "cp") == 0)) {
            if (a[1] != NULL) {
               if (a[2] != NULL) {
                  err = doCopy(a[1], a[2], 0);
               }
            }
         } else {
            //junk = getenv("LD_LIBRARY_PATH");
            //printf("LD_LIBRARY_PATH:  %s\n", junk);
            //fflush(stdout);
            //printf("COMMAND:  %s\n", ecmd);
            //fflush(stdout);
            err = system(ecmd);
         }
         free(a[0]);
      }
#ifdef PLATFORM_WINDOWS
      _flushall();
      _flushall();
      _flushall();
#else
      //
      //   Seems that the output generated by whatever
      //   system command was executed may not have made
      //   it to disk.  Force it, so the data becomes
      //   available to subsequent commands.
      //
      sync();
      sync();
#endif
   } else {
      err = -1;
   }

   return(err);

}

//int main()
//{
//int err;
//char *blarg = "copy c:\\cygwin\\home\\Administrator\\gronk.exe c:\\cygwin\\home\\Administrator\\junkfie";
//
//   err = execute_command(1, &blarg[0]);
//
//   printf("ERR:  %d\n", err);
//   fflush(stdout);
//
//}

