#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <libgen.h>
#include <ctype.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

//
//   These globals exist simply because this if far easier
//   than passing them to the myriad functions which will need
//   them.  Besides, who want to re-initialize an array every
//   time the initiating function is called.
//


#define READSZ 8192

void *addcalltemplatename(char *);
void *addtemplatename(char *);

struct lists {
   char *name;
   struct lists *next;
};

struct titles {
   int len;
   char *content;
   void *(*func_p)();
} lookfor[] = {
                  {13, "<xsl:template\0", addtemplatename},
                  {18, "<xsl:call-template\0", addcalltemplatename},
                  {9, "<function\0", addtemplatename},
                  {14, "<call-function\0", addcalltemplatename},
                  {0, NULL, NULL}
               };


struct lists *templatelist = NULL;
struct lists *calltemplatelist = NULL;

int headerdone = 0;

int notfound = 0;
int errorval = 0;

//
//   Add a template name to the list of
//   call-template names.
//
void *addcalltemplatename(char *name)
{
struct lists *tracit, *new;

   new = (struct lists *)malloc(sizeof(struct lists));
   new->name = name;
   new->next = NULL;

   if (calltemplatelist == NULL) {
      calltemplatelist = new;
   } else {
      tracit = calltemplatelist;
      while (tracit->next != NULL) {
         tracit = tracit->next;
      }
      tracit->next = new;
   }

   return;
}

//
//   Add a template name to the list of
//   defined template names.
//
void *addtemplatename(char *name)
{
struct lists *tracit, *new;

   new = (struct lists *)malloc(sizeof(struct lists));
   new->name = name;
   new->next = NULL;

   if (templatelist == NULL) {
      templatelist = new;
   } else {
      tracit = templatelist;
      while (tracit->next != NULL) {
         tracit = tracit->next;
      }
      tracit->next = new;
   }

   return;
}

//
//   searchlist2 and templatenameexists2 are used to
//   check and see if a defined template is ever called
//   by a call-template.  If not, an information message
//   is issued, but will not cause an error to be set.
//
int templatenameexists2(char *name)
{
struct lists *tracit;

   tracit = calltemplatelist;
   while (tracit != NULL) {
      if (strcmp(tracit->name, name) == 0) {
         return(1);
      }
      tracit = tracit->next;
   }

   return(0);
}

int searchlists2()
{
struct lists *tracit;
int count = 0;

   printf("TEMPLATES DEFINED BUT NEVER CALLED (INFO ONLY):\n");
   tracit = templatelist;
   while (tracit != NULL) {
      if (!templatenameexists(tracit->name)) {
         printf("   template never used:  %s\n", tracit->name);
         fflush(stdout);
         count++;
      }
      tracit = tracit->next;
   }

   if (count == 0) {
      printf("   None found\n");
      fflush(stdout);
   }

   return(count);
}

//
//   searchlists and templatenameexists are used to
//   check and see if a called template does indeed
//   exist as a defined template.  If not, an error is set.
//
int templatenameexists(char *name)
{
struct lists *tracit;

   tracit = templatelist;
   while (tracit != NULL) {
      if (strcmp(tracit->name, name) == 0) {
         return(1);
      }
      tracit = tracit->next;
   }

   return(0);
}

int searchlists()
{
struct lists *tracit;
int count = 0;

   printf("TEMPLATES CALLED BUT NEVER DEFINED (ERROR):\n");
   tracit = calltemplatelist;
   while (tracit != NULL) {
      if (!templatenameexists(tracit->name)) {
         printf("   missing template or function:  %s\n", tracit->name);
         fflush(stdout);
         count++;
      }
      tracit = tracit->next;
   }

   if (count == 0) {
      printf("   None found\n");
      fflush(stdout);
   }

   return(count);
}

void *dumplists()
{
struct lists *tracit;

   tracit = templatelist;
   while (tracit != NULL) {
      printf("tm:  %s\n", tracit->name);
      fflush(stdout);
      tracit = tracit->next;
   }

   tracit = calltemplatelist;
   while (tracit != NULL) {
      printf("calltm:  %s\n", tracit->name);
      fflush(stdout);
      tracit = tracit->next;
   }

}

//
//   From a valid template or call-template line,
//   extract the name from the name="xxxx" portion.
//
char *extractname(char *data)
{
char *name;
char *front, *back;
int len;

   name = NULL;
   front = back = data;

   while (strncmp(" name=", front, 6) != 0) {
      front++;
   }

   while (*front != '"') {
      if (*front == '\0') {
         return(NULL);
      }
      front++;
   }

   front++;
   back = front;

   while (*back != '"') {
      if (*back == '\0') {
         return(NULL);
      }
      back++;
   }

   len = back - front;

   name = (char *)calloc(len + 1, 1);

   strncpy(name, front, len);

   return(name);
}

///////////////////////////////////////////////////
//
//   Find a particular character in a string and
//   return that location or NULL if not found.
//
char *findcharacter(char *data, char mychar)
{
char *domain;

   domain = data;
   while ((*domain != mychar) && (*domain != '\0')) {
      domain++;
   }

   if (*domain == '\0')
      return(NULL);
   else
      return(domain);
}

//////////////////////////////////////////////////////////////
//
//   Open a file for reading only.  If the file can not be
//   opened, exit the program.
//
int openfile(char *filename)
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

/////////////////////////////////////////////////////
//
//   Move unused data to the beginnning of the read
//   buffer and return the location that can be read
//   into without damaging the unused data.
//
char *saveleftovers(char *data, char *back)
{
char *tail;
int len;

   tail = &data[READSZ];

   len = tail - back;

   strncpy(data, back, len);

   return(&data[len]);
   
}

//
//   Check to see of our match terms occur in the chunk of data
//   passed in as "line".
//
int compareit(char *line, int found)
{
int i, len;
char comparer[32];

   for (i = 0; i < 32; i++) {
      comparer[i] = '\0';
   }
   len = strlen(line);
   if (len > 32)
      len = 32;

   strncpy(comparer, line, len);
   for (i = 0; i < len; i++) {
      comparer[i] = tolower(comparer[i]);
   }

   i = 0;

   do {
      if (memcmp(comparer, lookfor[i].content, lookfor[i].len) == 0) {
         found = i;
      }
      i++;
   } while (lookfor[i].content != NULL);

   return(found);
}

//
//   Does line contain the term " name=".
//
int hasnamestring(char *line)
{
char *trac;

   trac = line;

   while (*trac != '\0') {
      if (strncmp(trac, " name=", 6) == 0)
         return(1);
      trac++;
   }

   return(0);
}

//
//   Does line contain the term " match=".
//
int hasmatchstring(char *line)
{
char *trac;

   trac = line;

   while (*trac != '\0') {
      if (strncmp(trac, " match=", 7) == 0)
         return(1);
      trac++;
   }

   return(0);
}

//
//   find anything that is between < and > that matches
//   the terms we are looking for "<xsl:template" and
//   "<xsl:call-template".  If we get these, then processing
//   will proceed to look for a "name" attribute.  If one is
//   found, the name will be added to one of two linked lists.
//   One for template and one for call-template.  These lists
//   will be checked to make sure they "match".  In this case
//   "match" means that a name in one list exists in the other.
//
char *get_template(char *data)
{
char *front, *back;
char *line, *name;
int found = 0;
int count = 0;

   front = back = data;

   found = -1;

   //
   //   By doing the compare early I know we are possibly
   //   doing something unnecessary when we get to the
   //   end of a data block because there may not be
   //   enough data to make a match.  In that case, the
   //   remaining data will be saved and the match 
   //   attempted again.  This may create two attempts,
   //   but it greatly simplifies keeping track of 
   //   where the pointers are in the data block.
   //
   if (*front == '<') {
      found = compareit(front, found);
      if (found == 0) {
         front++;
      }
   }

   if (found < 0) {
      while ((*front != '<') && (*front != '\0') &&
             (*front != EOF)) {
         front++;
         if (*front == '<') {
            found = compareit(front, found);
            if (found < 0) {
               front++;
            }
         }
      }
   }

   back = front;

   if (found >= 0) {
      while ((*back != '>') && (*back != '\0') &&
             (*back != EOF)) {
         back++;
      }

      if (*back == '>') {
         count = ((int)back - (int)front) + 1;

         line = (char *)malloc(count + 1);
         strncpy(line, front, count);
         line[count] = '\0';
         //if (hasnamestring(line) && !hasmatchstring(line)) {
         if (hasnamestring(line)) {
            name = extractname(line);
            lookfor[found].func_p(name);
         }
         free(line);
         return(back);
      }
   }
 
   if ((*back == '\0') && (*back != EOF)) {
      return(NULL);
   }

   return(front);
}

char *findtemplate(char *data, int amt)
{
static int found = -1;
int count;
char *back, *front, *line;

   front = data;
   while ((back = get_template(front)) != NULL) {
      front = back + 1;
   }

   if (back == NULL) {
      if (front == data) {
         front = data + READSZ;
      }
   }

   return(front);

}

//////////////////////////////////////////////////////////////
//
//   Read the data from the file into a buffer and pass it
//   on to be processed by findtemplate().  Any leftover
//   data (trailing data that is incomplete and can not be
//   processed yet) is moved to the front of the buffer and
//   enough data is read to refill the buffer to capacity.
//
char *readdata(int fd, char *filename)
{
char *mychunk;
char *end, *back, *readto;
int amt, thing, i, dynreadsize;

   mychunk = (char *)malloc(READSZ + 1);
   thing = 0;
   dynreadsize = READSZ;
   end = &mychunk[READSZ];
   readto = mychunk;

   for (i = 0; i < READSZ + 1; i++) {
      mychunk[i] = '\0';
   }

   amt = read(fd, mychunk, READSZ);
   //printf("Read:  %d\n", amt);
   //fflush(stdout);
   while (amt == READSZ) {
      back = findtemplate(mychunk, amt);
      if (back < end) {
         readto = saveleftovers(mychunk, back);
         dynreadsize = (int)end - (int)readto;
         thing = READSZ - dynreadsize;
      } else {
         dynreadsize = READSZ;
         thing = 0;
         readto = mychunk;
      }
      for (i = thing; i < READSZ + 1; i++) {
         mychunk[i] = '\0';
      }
      amt = read(fd, readto, dynreadsize);
      //printf("Read:  %d, %d\n", amt, thing);
      //fflush(stdout);
      amt = amt + thing;
   }
   if (amt > 0) {
      back = findtemplate(mychunk, amt);
      //
      //   This chunk of code handles situations
      //   where the file being read has no eol/eof
      //   which causes the tail of the file to not
      //   be written in normal flow.  This writes
      //   that chunk of the file.
      //
      if (back < end) {
         readto = saveleftovers(mychunk, back);
         dynreadsize = (int)end - (int)readto;
         thing = amt - dynreadsize;

         for (i = thing; i < READSZ + 1; i++) {
            mychunk[i] = '\0';
         }
         back = findtemplate(mychunk, thing);
      }
   }

   free(mychunk);
   
}

int main(int argc, char *argv[])
{
int fd, count, count2, c, filesize;
char *argfilename;
extern char *optarg;
extern int optind;
static char *optstring = "f:";

   argfilename = NULL;
   fd = count = count2 = 0;

   while ((c = getopt(argc, argv, optstring)) != EOF) {
      switch (c) {
         case 'f':
                    argfilename = optarg;
                    break;
         default:
                    printf("Invalid argument:  %c\n", (char)c);
                    break;
      }
   }

   if (argfilename == NULL) {
      printf("You must specify a file\n");
      printf("valid_repo -f <filename>\n");
      fflush(stdout);
      exit(1);
   }

   fd = openfile(argfilename);
   readdata(fd, argfilename);
   close(fd);

   //dumplists();

   count = searchlists();
   count2 = searchlists2();

   exit(count);
}

