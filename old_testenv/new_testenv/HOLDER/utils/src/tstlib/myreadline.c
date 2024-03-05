#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <errno.h>

//
//   Current limitation:  The line size you want
//   can not be greater than READSZ.  You can make
//   READSZ bigger, though.
//
#define READSZ 4096
#define POOLSIZE 4

#define CLEAN 0
#define DIRTY 1
#define FLUSH 2

#define NOTINUSE 0
#define INUSE 1

struct poolstruct {
   char *buffer;
   int lindex;
   int cindex;
   int size;
   int rsize;
   int csize;
   int inuse;
   int state;
   int seq;
   struct poolstruct *next;
};

//
//   Allocate buffer pool
//
struct poolstruct *allocatepool(int poolsize)
{
struct poolstruct *head, *follow, *tmp;
int i;

   head = follow = tmp = NULL;

   for (i = 0; i < poolsize; i++) {
      tmp = (struct poolstruct *)malloc(sizeof(struct poolstruct));
      tmp->buffer = (char *)calloc(READSZ + 1, 1);
      tmp->size = READSZ;
      tmp->rsize = READSZ;
      tmp->csize = 0;
      tmp->cindex = 0;
      tmp->lindex = 0;
      tmp->inuse = NOTINUSE;
      tmp->state = CLEAN;
      tmp->seq = i;

      if (head == NULL) {
         head = tmp;
         follow = head;
      } else {
         follow->next = tmp;
         follow = follow->next;
      }
   }

   follow->next = head;

#ifdef DEBUG
   follow = head;
   for (i = 0; i < 5; i++) {
      printf("buffer size:  %d\n", follow->size);
      printf("buffer seq:  %d\n", follow->seq);
      printf("buffer csize:  %d\n", follow->csize);
      printf("buffer inuse:  %d\n", follow->inuse);
      printf("buffer state:  %d\n", follow->state);
      follow = follow->next;
   }
#endif

   return(head);
}

//
//   Reinit buffer of buffer pool element
//
void cleanbuffer(char *buffer, int size)
{
static char flusher[READSZ + 1];
static int flushinit = 0;
int i;

   if (flushinit == 0) {
      flushinit = 1;
      for (i = 0; i < READSZ + 1; i++) {
         flusher[i] = '\0';
      }
   }

   memcpy(buffer, &flusher, size);

   return;
}

//
//   Clean buffer pool elements
//
struct poolstruct *clearthebuffer(struct poolstruct *pool)
{
   while ((pool->inuse == NOTINUSE) &&
          (pool->state == DIRTY)) {
      pool->state = CLEAN;
      pool->csize = 0;
      pool->rsize = READSZ;
      pool->cindex = 0;
      pool->lindex = 0;
      cleanbuffer(pool->buffer, pool->size);
      pool = pool->next;
   }

   return(pool);
}

void dumpstate(struct poolstruct *pool)
{
struct poolstruct *follow;
int count;

   follow = pool;
   count = 0;

   do {
      printf("seq:  %d\n", follow->seq);
      printf("state:  %d\n", follow->state);
      printf("inuse:  %d\n", follow->inuse);
      printf("cindex:  %d\n", follow->cindex);
      printf("lindex:  %d\n", follow->lindex);
      printf("rsize:  %d\n", follow->rsize);
      printf("csize:  %d\n", follow->csize);
      follow = follow->next;
      count++;
   } while (count < POOLSIZE);

   return;
}

//
//   Get one line from one or more buffers.
//
char *getaline(struct poolstruct *pool, char *line, int length)
{
int curlen;

   line[0] = '\0';
   curlen = 0;

   while ((pool->buffer[pool->cindex] != '\n') && 
          (pool->buffer[pool->cindex] != '\r') &&
          (pool->buffer[pool->cindex] != '\0') &&
          (pool->cindex < pool->csize)) {
      pool->cindex++;
      curlen++;
      if (pool->cindex >= pool->csize) {
         //
         //   current buffer empty.  go on to next.
         //
         strcpy(line, &pool->buffer[pool->lindex]);
         pool->inuse = NOTINUSE;
         pool = pool->next;
      } else {
         if (curlen >= length) {
            //
            //   Hit the max linke length.
            //
            strncat(line, &pool->buffer[pool->lindex], (pool->cindex - pool->lindex));
            pool->lindex = pool->cindex;
            return(line);
         }
      }
   }

   if (pool->buffer[pool->cindex] == '\r') {
      pool->cindex++;
   }

   if (pool->buffer[pool->cindex] == '\n') {
      pool->cindex++;
      curlen++;
      if ((curlen > 0) ||
          (pool->cindex >= pool->csize)) {
         strncat(line, &pool->buffer[pool->lindex], (pool->cindex - pool->lindex));
      }
   }

   pool->lindex = pool->cindex;

   if (pool->cindex >= pool->csize) {
      pool->inuse = NOTINUSE;
   }

   if (line[0] != '\0')
      return(line);
   else
      return(NULL);
}

char *myreadline(int fd, char *line, int linesize)
{
static struct poolstruct *head = NULL;
static struct poolstruct *currhead = NULL;
static struct poolstruct *currbuff = NULL;
int amt;
char *buffer;

   if (head == NULL) {
      head = allocatepool(POOLSIZE);
   }

   if (currhead == NULL) {
      currhead = head;
      currbuff = currhead;
   }

   amt = currbuff->csize - currbuff->lindex;
   if ((amt < linesize) && (currbuff->rsize > 0)) {
      if (currbuff->inuse) {
         currbuff = currbuff->next;
      }
      currbuff->csize = read(fd, currbuff->buffer, currbuff->size);
      if (currbuff->csize == -1) {
         perror("Read failed");
      } else {
         if (currbuff->csize > 0) {
            currbuff->rsize = currbuff->csize;
            currbuff->inuse = INUSE;
            currbuff->state = DIRTY;
         }
      }
   }

   buffer = getaline(currhead, line, linesize);

   if (currhead->inuse == NOTINUSE) {
      currhead = clearthebuffer(currhead);
   }

   //dumpstate(currhead);
   return(buffer);
}

#ifdef TESTIT
int main()
{
char buffer[257];
int fd, i, j, iread, lineread, iopend, cmpread, expected;
char *filearray[] = {"rock/d60c480e", "rock/49055d05", "DOES NOT EXIST",
                     "README", "readit.pc", "blues/21037703", NULL};
/*
char *filearray[] = {
"d60c480e", "49055d05", "7109140a", "8a0df80a", "a00e640c", "b810b20e", "d60c2d10", "fe12a413",
"24026303", "49055d06", "71091508", "8a0df80c", "a00e640d", "b810b30d", "d60c2d11", "fe12a511",
"24026304", "49055e06", "71091509", "8a0df90a", "a00e680c", "b810b31d", "d60c2e0f", "fe12a512",
"24026403", "49055e07", "7109150a", "8a0df90d", "a00e680d", "b810b50d", "d60c2f0f", "fe12a613",
"24026503", "49055f06", "7109170a", "8a0dfb0b", "a00e690d", "b810b50e", "d60c300f", "fe12a712",
"24026504", "49056106", "71091809", "8a0dfe0a", "a00e6a0d", "b810b90d", "d60c340f", "fe12ab10",
"24026604", "49056206", "71091b0a", "8a0dff0a", "a00e6b0c", "b810b90f", "d60c3410", "fe12ab13",
"24026b03", "49056207", "71091d0b", "8a0dff0b", "a00e6b0e", "b810ba0e", "d60c360f", "fe12ac12",
"24026b04", "49056506", "71091e09", "8a0e020a", "a00e6c0c", "b810bc1e", "d60c380f", "fe12ad13",
"24026c03", "49056507", "71091f08", "8a0e050b", "a00e6c0d", "b810bf0c", "d60c390e", "fe12ae11",
"24026d03", "49056806", "71092009", "8a0e0609", "a00e6d0b", "b810c00d", "d60c3a10", "fe12ae12",
"24027204", "49056907", "71092109", "8a0e060a", "a00e6d0d", "b810c01e", "d60c3b0f", "fe12af12",
"24027304", "49056a06", "7109220a", "8a0e060b", "a00e6e0a", "b810c10e", "d60c3d10", "fe12b012",
"24027503", "49056c05", "71092309", "8a0e0809", "a00e6f0b", "b810c11e", "d60c3e10", "fe12b111",
"24027504", "49056c06", "71092409", "8a0e0a1b", "a00e6f1d", "b810c20d", "d60c400f", "fe12b113",
"24027604", "49056c07", "7109250a", "8a0e0b0a", "a00e710b", "b810c30e", "d60c430e", "fe12b123",
"24027704", "49056d05", "71092609", "8a0e0c0a", "a00e710c", "b810c31e", "d60c430f", "fe12b211",
"24027804", "49056e06", "7109260a", "8a0e0d0a", "a00e710d", "b810c40d", "d60c4410", "fe12b413",
"24027903", "49056e07", "71092708", "8a0e0d1c", "a00e720c", "b810c50c", "d60c4511", "fe12b512",
"24027904", "49056f06", "71092709", "8a0e0e0a", "a00e721a", "b810c50d", "d60c470f", "fe12b514",
"24027b04", "49057006", "7109270a", "8a0e0e0b", "a00e730d", "b810c50e", "24026004", "fe12b611",
"24027c04", "49057106", "71092809", "8a0e0f0a", "a00e770b", "b810c60c", "d60c490f", "fe12b612",
"24027d04", "49057206", "7109280a", "8a0e100a", "a00e770e", "b810c80c", "d60c4911", "fe12b613",
"24027e04", "49057306", "71092908", "8a0e1109", "a00e780d", "b810c80d", "d60c4d10", "fe12b711",
NULL};
*/
int onewrite;

   onewrite = iopend = cmpread = lineread = iread = j = 0;
   expected = 58 + 32 + 41 + 25 + 1322;
   while (filearray[j] != NULL) {
      fd = open(filearray[j], O_RDONLY);

      if (fd >= 0) {
         for (i = 0; i < 257; i++) {
            buffer[i] = '\0';
         }
         iopend++;
         while (myreadline(fd, buffer, 256) != NULL) {
            lineread++;
            if (onewrite == 0) {
               printf("Reading %s\n", filearray[j]);
               onewrite++;
            }
            fflush(stdout);
            //printf("LINE, %d:  %s", strlen(buffer), buffer);
            //fflush(stdout);
            printf("%s", buffer);
            fflush(stdout);
            for (i = 0; i < 257; i++) {
               //printf("%c   %d\n", buffer[i], (int)buffer[i]);
               //fflush(stdout);
               buffer[i] = '\0';
            }
         }
         onewrite = 0;
         if (lineread > cmpread) {
            iread++;
            cmpread = lineread;
         }
         close(fd);
      } else {
         printf("Could not open %s\n", filearray[j]);
         fflush(stdout);
      }
      j++;
   }

   printf("Opened %d of %d files, expected 5 of 6\n", iopend, j);
   printf("Read   %d of %d files, expected 5 of 6\n", iread, j);
   printf("Read %d lines, expected %d\n", lineread, expected);
   fflush(stdout);
}
#endif
