#include <stdio.h>
#include <string.h>

#include "test.h"

static long lastline = 0;

/***********************************************************/
/*   GENSTRING

   Generate a 128 character string which consists of the
   name of the file to hold the string, the process id which
   is creating the file, and the alphabet.  The alphabet will
   repeat until 128 characters are used.
*/
/*
   parameters:
      filename    full path name of file
      processid   process id

   return value:
      128 character string
*/
char *genstring(processid, filename)
int processid;
char *filename;
{
char *mystring = NULL;
char *endofit = NULL;
char localname[8];
int i, j;

   /*  Done for stupid compilers that don't allow aggregate initialization */
   sprintf(localname, "no name\0");

   if (filename == NULL)
      filename = localname;

   mystring = (char *)malloc((PIECEOBLOCK + 1));
   endofit = &mystring[PIECEOBLOCK - 6];
   for (i = 0; i < (PIECEOBLOCK + 1); i ++)
      mystring[i] = '\0';

   sprintf(mystring, "process_ID = %5d || %s >> ", processid, filename);
   sprintf(endofit, "%5d\n", processid);

   j = 65;
   for (i = strlen(mystring); i < (PIECEOBLOCK - 6); i++) {
      mystring[i] = (char)j;
      j++;
      if (j > 90) 
         j = 65;
   }
 
   mystring[PIECEOBLOCK - 1] = '\n';
  
   return(mystring);
}

/***********************************************************/
/***********************************************************/
/*   GENBLOCK
*/
/*
   parameters:
      filename    full path name of file
      processid   process id

*/
char *genblock(processid, filename)
int processid;
char *filename;
{
char *mystring = NULL;
char *tempstring = NULL;
int i, j, h, sequence, subtractit;

   sequence = 0;

   mystring = (char *)malloc(BLOCKSZ);
   for (i = 0; i < BLOCKSZ; i++)
      mystring[i] = '\0';

   tempstring = genstring(filename, processid);
   sprintf(mystring,"%s", tempstring);

   while (sequence < LINESINBLOCK) {
      sequence++;
      if (sequence < LINESINBLOCK) {
         sprintf(mystring,"%s%s",mystring, tempstring);
      }
   }

   free(tempstring);
   return(mystring);
}

char *genmultiblock(processid, numblocks, filename)
int processid, numblocks;
char *filename;
{

char *mystring = NULL;
char *multistring = NULL;
int i, j;

   multistring = (char *)malloc((numblocks * BLOCKSZ));
   for (i = 0; i < (numblocks * BLOCKSZ); i++)
      multistring[i] = '\0';

   for (i = 0; i < numblocks; i++) {
      mystring = genblock(filename, processid);
      strcat(multistring, mystring);
      free(mystring);
   }

   return(multistring);
}

/***********************************************************/
/***********************************************************/
/*   ALTERSTRING
 
   Take the first 80 characters of a string, append the sequence
   number of the string within a file, the total number of bytes which
   will have been written at the end of the string, and the total
   number of words which will have been written to the file at the
   end of the string.
*/
/*
   parameters:
      string     128 character string to be altered
      number     sequence number of string

   return value:
      128 character string
*/
char *alterstring(string, number)
char *string;
int number;
{
char *start2, *mystring;
char holdpart[90];
int i;

   mystring = (char *)malloc((PIECEOBLOCK + 1));

   for (i = 0; i < (PIECEOBLOCK + 1); i ++)
      mystring[i] = '\0';

   sprintf(holdpart, ">> %d  %d  %d <<\0", 
           (number * WORDSONLINE), (number * PIECEOBLOCK), number);

   i = strlen(holdpart);
   /*  11 -- 2 spaces, 5 chars, 4 hold from end of old line */
   i = PIECEOBLOCK - i - 8;

   string[i] = '\0';
   start2 = &string[PIECEOBLOCK - 6];

   sprintf(mystring, "%s %s %s\0", string, holdpart, start2);

   free(string);

   return(mystring);
}

char *alterblocks(string, number, numblocks)
char *string;
int number, numblocks;
{
char *holdpart = NULL;
char *localstring;
int i, j;

   holdpart = (char *)malloc((PIECEOBLOCK + 1));
   for (i = 0; i < (PIECEOBLOCK + 1); i ++)
      holdpart[i] = '\0';

   strncpy(holdpart, string, 128);

   string[0] = '\0';


   for (j = 0; j < numblocks; j++) {
      for (i = 0; i < LINESINBLOCK; i++) {
         localstring = alterstring(holdpart, number);
         strcat(string, localstring);
         number++;
         holdpart = localstring;
      }
   }
   return(string);
}
char *genremainder(remainder)
int remainder;
{
char *remstring;
int i;

   remstring = (char *)malloc(remainder + 1);

   for (i = 0; i < remainder; i++) {
      remstring[i] = 'z';
   }

   remstring[remainder] = '\0';
   return(remstring);
}

char *genlastblock(lefttodo, filename, pid, linenumber)
int lefttodo, pid, linenumber;
char *filename;
{
char *lastblock = NULL;
char *remstring = NULL;
int i, iters, remainder, nullfrom;

   if (lefttodo >= PIECEOBLOCK) {
      lastblock = (char *)genblock(filename, pid);
      lastblock = (char *)alterblocks(lastblock, linenumber, 1);
   }

   iters = lefttodo / PIECEOBLOCK;
   nullfrom = iters * PIECEOBLOCK;
   remainder = lefttodo - (iters * PIECEOBLOCK);

   remstring = genremainder(remainder);

   if (lefttodo >= PIECEOBLOCK) {
      for (i = nullfrom; i < BLOCKSZ; i++)
         lastblock[i] = '\0';
      strcat(lastblock, remstring);
      free(remstring);
   }
   else {
      lastblock = remstring;
   }

   return(lastblock);

}

char *create_chr_data(num_bytes, pid)
int num_bytes, pid;
{
char *trash,  *all_data;
int remainder, num_blocks;

   all_data = trash = NULL;
   num_blocks = num_bytes / BLOCKSZ;
   remainder = num_bytes - (num_blocks * BLOCKSZ);

   all_data = (char *)calloc(num_bytes + 1, 1);
   all_data[0] = '\0';

   if (num_blocks > 0) {
      trash = (char *)genmultiblock(pid, num_blocks, NULL);
      trash = (char *)alterblocks(trash, lastline + 1, num_blocks);
      lastline = lastline + (num_blocks * LINESINBLOCK);
      strcpy(all_data, trash);
      free(trash);
   }
   if (remainder > 0) {
      trash = (char *) genlastblock(remainder, NULL, pid, (lastline + 1));
      lastline = lastline + ((remainder + (PIECEOBLOCK - 1)) / PIECEOBLOCK);
      strcat(all_data, trash);
      free(trash);
   }


   return(all_data);
}

void clear_data_amt()
{
   lastline = 0;
}

/***************************************************/
/*
   Find the next space, linefeed, or null in a line.
*/
char *findspace(line)
char *line;
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
         case '\t':
                    return(line);
         default:
                    line++;
      }
   }

   return(NULL);
}
/***************************************************/
/*
   Find the next non-space, linefeed, or null in a line.
*/
char *findnonspace(line)
char *line;
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
         case '\t':
                    line++;
                    break;
         default:
                    return(line);
      }
   }

   return(NULL);
}
/*******************************************************/
/*
   Return the last segment of a complete path.
*/
char *_basename(path)
register char *path;
{
        register int i;

        i = strlen(path);
        for (i--; i >= 0; i--)
                if (path[i] == '/')
                        break;
        i++;

        return(&path[i]) ;
}
/*******************************************************/
/*
   Return the directory name from a file path, or the
   preceding directory name from a directory path.
*/
char *_dirname(path)
register char *path;
{
        register int i;

        i = strlen(path);
        for (i--; i>= 0; i--)
                if (path[i] == '/')
                        break;
        path[i] = '\0';
        i++;

        return(path) ;
}
/***********************************************************/
/*   Driver to test genstring routines
     Commented out for general use.
*/
/*
main()
{
char *stringit = NULL;

   stringit = create_chr_data(5);
   fprintf(stderr, "LENGTH = %d\n\n", strlen(stringit));
   printf("%s", stringit);
   stringit = create_chr_data(1);
   fprintf(stderr, "LENGTH = %d\n\n", strlen(stringit));
   printf("%s", stringit);
   stringit = create_chr_data(1024);
   fprintf(stderr, "LENGTH = %d\n\n", strlen(stringit));
   printf("%s", stringit);
   stringit = create_chr_data(1025);
   fprintf(stderr, "LENGTH = %d\n\n", strlen(stringit));
   printf("%s", stringit);
   stringit = create_chr_data(1023);
   fprintf(stderr, "LENGTH = %d\n\n", strlen(stringit));
   printf("%s", stringit);
   stringit = create_chr_data(511);
   fprintf(stderr, "LENGTH = %d\n\n", strlen(stringit));
   printf("%s", stringit);
   stringit = create_chr_data(512);
   fprintf(stderr, "LENGTH = %d\n\n", strlen(stringit));
   printf("%s", stringit);
   stringit = create_chr_data(513);
   fprintf(stderr, "LENGTH = %d\n\n", strlen(stringit));
   printf("%s", stringit);
}
*/
