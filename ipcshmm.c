/*************************************************************************/
/*  O---------->O---------->O---------->O---------->O---------->O--->NULL
*id |0          |1          |2          |3          |4          |5
*   |           |           |           |           |           |
*   |<-buffer ->|<-buffer ->|<-buffer ->|<-buffer ->|<-buffer ->|
*   |   ptr     |   ptr     |   ptr     |   ptr     |   ptr     |
*   |        ---------------|           |           |           |  
*   |        |  |
*   |------------->-----------------------
*            |  |  |buffer               |
*            |  |  |                     |
*            |  |  |                     |
*            |  |  |                     |
*            |  |->|---------------------|
*            |     |buffer               |
*            |     |                     |
*            |     |                     |
*            |---->|---------------------|
*                  |buffer               |
*                  |                     |
*   Shared         |                     |
*   Memory         |                     |
*   Segment======> |                     |
*   (whole box)    |                     |
*   pointed to by  |                     |
*   node with      |                     |
*   buffer_id      |                     |
*   equal to 0     |                     |
*                  |                     |
*                  -----------------------
*
*   Above diagram represents only one partial buffer list.
*
*   There can be five shared memory segments(one for each of five 
*   buffer lists). (Default situation)
*
*   The number of lists and segments can be changed on the command
*   line.
*
*   Which of the above depends on what options are specified to
*   the test.
*
*   The number of shared memory segments defaults to five.
*   The number of buffers defaults to twenty(total, not per buffer list).
*/
/*************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/param.h>
#include <sys/signal.h>
#include <time.h>
#ifdef CRAY
#include <sys/iosw.h>
#include <sys/listio.h>
#endif
#include <sys/times.h>
#include <sys/stat.h>
#include <sys/ipc.h>
#include <sys/sem.h>
#include <sys/shm.h>

/**************************************/
/*  Defines of file size types:
       TiNY
       ^ ^^
       eXtra LarGe
        ^    ^  ^
       SMaLl
       ^^ ^
       MEDium
       ^^^
       LaRGe
       ^ ^^
    Also define of semaphore number for
    resource counting.  All of the above apply
    as well as:
       Buffer Pool Lock
*/
#define MED 0       /* 16384 bytes (4 blocks), 50% of total buffers */
#define SML 1       /* 4096 bytes (1 block),   25% of total buffers */
#define TNY 2       /* 128 bytes,              15% of total buffers */
#define LRG 3       /* 32768 bytes (8 blocks),  5% of total buffers */
#define XLG 4       /* 65536 bytes (16 blocks), 5% of total buffers */

#define TNY_SZ 128         /* 128 bytes */
#define XLG_SZ 65536       /* 65536 bytes (16 blocks) */
#define SML_SZ 4096        /* 4096 bytes (1 block) */
#define MED_SZ 16384       /* 16384 bytes (4 blocks) */
#define LRG_SZ 32768       /* 32768 bytes (8 blocks) */

#define TNY_PT 0.15
#define XLG_PT 0.05
#define SML_PT 0.25
#define MED_PT 0.50
#define LRG_PT 0.05

#define MAX_SEM 7          /* Number of semaphores to put with id */
#define CHILD_SEMA 6
#define PARENT_SEMA 5

#define LOCK_SEMA_BASE 300  /*  Key for lock semaphores  */
#define RSRC_SEMA_BASE 400  /*  Key for resource counter semaphores */

#define SHMM_BUF_BASE 500   /*  Shared memory key base  */
                           /*  Actual key becomes this plus an increment */
#define SHMM_LST_BASE 900

#define DEFAULT_SEGS 5     /*  Default shared memory segments */
#define DEFAULT_BUFS 20    /*  Default buffers */
#define DEFAULT_RUN 180

/**************************************/
/*  Defines of I/O types:
       Internal IO (copy a character string to the buffer)
       Asynchronous IO
       List IO
       Normal IO
*/
#define IIO 0
#define NIO 1
#define AIO 2
#define LIO 3
#define ALIO 4

#define PASS 0
#define FAIL -1

struct buffer_set {
   int buffer_id;
   char *buffer;
};

struct shm_buffer_str {
   int buffer_sz_type, offset;
   struct shm_buffer_str *next;
};

struct usr_buffer_str {
   int IO_type, read_amt, write_amt, read_pass, write_pass;
   int x_amt, buffer_sz_type;
   int parent_pid, child_pid;
   char *buffer;
   struct shm_buffer_str *shm_buffer;
};

struct shm_buffer_str **list_heads, *buffer_ptr;
struct buffer_set buffer_hld[5];
int list_heads_id = 0;
int glob_segs = 0;
int rsrc_id, lock_id;
int rsrc_arr[MAX_SEM] = {0, 0, 0, 0, 0, 20, 20};
int pcnt_ints[5] = {0, 0, 0, 0, 0};
int oldcode = 0, chiotype = 0, donttesthere = 0;
int LOCK_SEMA_KEY, RSRC_SEMA_KEY, SHMM_BUF_KEY, SHMM_LST_KEY;

int buffer_sz_arr[5] = {MED_SZ, SML_SZ, TNY_SZ, LRG_SZ, XLG_SZ};
float percent_arr[5] = {MED_PT, SML_PT, TNY_PT, LRG_PT, XLG_PT};

unsigned int num_attached;

double drand48();
void srand48();

#define PIECEOBLOCK 128
#define BLOCKSZ 4096
#define WORDSONLINE 16

#define UNLINKABLE 3
#define MAYBE 2
#define EXIST 1
#define NEW 0

#define CHOOSE_MED(x)  (x >= 0) && (x < pcnt_ints[0])      
#define CHOOSE_SML(x)  (x >= pcnt_ints[0]) && (x < pcnt_ints[1])
#define CHOOSE_TNY(x)  (x >= pcnt_ints[1]) && (x < pcnt_ints[2])
#define CHOOSE_LRG(x)  (x >= pcnt_ints[2]) && (x < pcnt_ints[3])
#define CHOOSE_XLG(x)  (x >= pcnt_ints[3]) && (x <= 100)

#define VALID_BUFFER_TYPE(x) (x >= 0) && (x < glob_segs)

#define CHOOSE_IO_TYPE()  ((int)(drand48() * 49.0) / 10)


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
char *genstring(filename, processid, io_type)
char *filename;
int processid, io_type;
{
char *mystring = NULL;
char *endofit = NULL;
int i, j;

   mystring = (char *)malloc((PIECEOBLOCK + 1));
   endofit = &mystring[PIECEOBLOCK - 4];
   for (i = 0; i < (PIECEOBLOCK + 1); i ++)
      mystring[i] = '\0';

   if (io_type == AIO) {
      (void)sprintf(mystring,
                "asyncio      pid=%5d || %s >> ",processid, filename);
      (void)sprintf(endofit, "aio\n");
   }
   else if (io_type >= LIO) {
      if (io_type == LIO) {
         (void)sprintf(mystring,
                "listio       pid=%5d || %s >> ",processid, filename);
         (void)sprintf(endofit, "lio\n");
      }
      else {
         (void)sprintf(mystring,"async listio pid=%5d || %s >> ",
                 processid, filename);
         (void)sprintf(endofit, "ali\n");
      }
   }
   else {
      (void)sprintf(mystring,
                "normal io    pid=%5d || %s >> ",processid, filename);
      (void)sprintf(endofit, "nio\n");
   }

   j = 65;
   for (i = strlen(mystring); i < (PIECEOBLOCK - 4); i++) {
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

   Generate a block of 128 character strings which consists of the
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
char *genblock(filename, processid, io_type)
char *filename;
int processid, io_type;
{
char *mystring = NULL;
char *tempstring = NULL;
char *follow;
int sequence;

   sequence = 0;

   mystring = (char *)calloc(BLOCKSZ, 1);
   follow = mystring;

   tempstring = genstring(filename, processid, io_type);

   (void)memcpy(follow, tempstring, PIECEOBLOCK);

   while (sequence < 32) {
      sequence++;
      follow = follow + PIECEOBLOCK;
      if (sequence < 32) {
         (void)memcpy(follow, tempstring, PIECEOBLOCK);
      }
   }

   free(tempstring);
   return(mystring);
}

/****************************************************/
/*  Generate more than one block of characters
*/
char *genmultiblock(filename, processid, numblocks, io_type)
char *filename;
int processid, numblocks, io_type;
{

char *mystring = NULL;
char *multistring = NULL;
char *follow;
int i;

   multistring = (char *)calloc((numblocks * BLOCKSZ), 1);
   follow = multistring;

   for (i = 0; i < numblocks; i++) {
      mystring = genblock(filename, processid, io_type);
      (void)memcpy(follow, mystring, BLOCKSZ);
      follow = follow + BLOCKSZ;
      free(mystring);
   }

   return(multistring);
}

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

   (void)sprintf(holdpart, ">> %d  %d  %d <<\0", 
           (number * WORDSONLINE), (number * PIECEOBLOCK), number);

   i = strlen(holdpart);
   /*  11 -- 2 spaces, 5 chars, 4 hold from end of old line */
   i = PIECEOBLOCK - i - 6;

   string[i] = '\0';
   start2 = &string[PIECEOBLOCK - 4];

   (void)sprintf(mystring, "%s %s %s\0", string, holdpart, start2);

   free(string);

   return(mystring);
}

/***************************************************/
/*  Alter the blocks so that each string within the block
    is unique (to a degree anyway).
*/
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

   (void)strncpy(holdpart, string, 128);

   string[0] = '\0';

   for (j = 0; j < numblocks; j++) {
      for (i = 0; i < 32; i++) {
         localstring = alterstring(holdpart, number);
         (void)strcat(string, localstring);
         number++;
         holdpart = localstring;
      }
   }
   return(string);
}
/****************************************************/
/*   GENNAME

   generate a unique file name(full path)
*/
/*
   parameters:
      dirname       name of directory where file will reside
      itercount     number of times * 17000 that routine has been called

   return value:
      unique full path name in supplied directory
*/
char *genname(dirname,itercount, prefix)
char *dirname;
int itercount;
char *prefix;
{
char template[10];
char *filename;

   (void)sprintf(template,"%s-%d\0", prefix, itercount);
   filename = tempnam(dirname, template);
   return(filename);
}

#ifdef DEBUG
int debug_out(filename, syscall_number, value2, value3, value4)
char *filename;
int syscall_number, value2, value3, value4;
{
FILE *lfd;

   lfd = fopen("debug_data", "a+");
   switch (syscall_number) {
      case 4:
               (void)fprintf(lfd, "%s  WRITE  %d  %d  %d\n",
                       filename, (char *)&value2, value3, value4);
               break;

      case 19:
               (void)fprintf(lfd, "%s  LSEEK  %d  %d  %d\n",
                       filename, value2, value3, value4);
               break;
   }
   fclose(lfd);
}
#endif

/************************************************/
/*  Generate a random, valid flag set to send to
    the open() system call.
*/
int doopenflags(existornew)
int existornew;
{
int flagthing;
double drand48();
void srand48();

   srand48(time((long *)0));

   if (existornew == NEW)
      flagthing = O_CREAT | O_TRUNC;
   else if (existornew == MAYBE)
      flagthing = O_CREAT | O_APPEND;
   else if (existornew == UNLINKABLE)
      flagthing = O_CREAT;
   else {
      flagthing = 0;
      if (((int)(drand48() * (double)10.0)) < 2)
         flagthing = flagthing | O_APPEND;
   }

   if (((int)(drand48() * (double)10.0)) > 5)
      flagthing = flagthing | O_WRONLY;
   else
      flagthing = flagthing | O_RDWR;

   if (((int)(drand48() * (double)10.0)) > 7)
      flagthing = flagthing | O_SYNC;

#ifdef CRAY
   if (((int)(drand48() * (double)10.0)) < 3)
      flagthing = flagthing | O_RAW;
   if (((int)(drand48() * (double)10.0)) < 3)
      flagthing = flagthing | O_LDRAW;
#endif


   return(flagthing);
}

/************************************************/
/*  Create a new file using open() or create().
*/
int openwcreat(filename, from, flagthing)
char *filename, *from;
int flagthing;
{
int fno;
int mode = 0600;
double drand48();
void srand48();

   srand48(time((long *)0));

   if (((int)(drand48() * (double)10.0)) > 5) {
      /**************************************/
      /**  Should have been done by calling routine
       *      flagthing = doopenflags(NEW);
      */

      fno = open(filename, flagthing, mode);
   }
   else {
      fno = creat(filename, mode);
   }

   if (fno == (-1)) {
      (void)fprintf(stderr, "%s file not created\n", filename);
   }
   return(fno);
}
/************************************************/
/*  Open an existing file
*/
int openexisting(filename, from, flagthing)
char *filename, *from;
int flagthing;
{
int fno;
int mode = 0600;

   /**************************************/
   /**  Should have been done by calling routine
    *       flagthing = doopenflags(EXIST);
   */

   fno = open(filename, flagthing, mode);
   if (fno == (-1)) {
      if (access(filename, F_OK) == 0) {
         (void)fprintf(stderr, "%s File not opened\n", filename);
      }
   }
   return(fno);
}


int listiowrite(fno, buffer, amount, from, filename, io_type)
int fno, amount, io_type;
char *buffer, *from, *filename;
{
int error;
#ifdef CRAY
struct listreq request;
struct iosw reqstat, *statarray[1];;

   error = 0;

   if (amount != BLOCKSZ) {
      request.li_nbyte = amount;
      request.li_nstride = 1;
      request.li_filstride = amount;
   }
   else {
      request.li_nbyte = PIECEOBLOCK;
      request.li_nstride = BLOCKSZ / PIECEOBLOCK;
      request.li_filstride = PIECEOBLOCK;
   }

   request.li_flags = 0;
   request.li_offset = 0;
   request.li_signo = 0;
   request.li_memstride = 0;
   request.li_opcode = LO_WRITE;
   request.li_fildes = fno;
   request.li_buf = (char *)buffer;
   request.li_status = &reqstat;

   reqstat.sw_count = 0;
   reqstat.sw_error = 0;
   reqstat.sw_flag = 0;


   if (io_type == LIO) {
      error = listio(LC_WAIT, &request, 1);
   }
   else {
      error = listio(LC_START, &request, 1);
      statarray[0] = &reqstat;
      (void)recalls(1, statarray);
   }

   error = reqstat.sw_count;

   if (error != amount) {
      if (error == EOF)
         (void)fprintf(stderr, "%s No listio write\n", filename);
      else
         (void)fprintf(stderr, "%s Bad listio write\n", filename);
   }
#else
   error = normalwrite(fno, buffer, amount, from, filename);
#endif

   return(error);
}

int asyncwrite(fno, buffer, amount, from, filename)
int fno, amount;
char *buffer, *from, *filename;
{
int error = 0;
#ifdef CRAY
struct iosw status, *statarray[1];
int signo = 0;

   status.sw_count = 0;
   status.sw_error = 0;
   status.sw_flag = 0;


   error = writea(fno, buffer, amount, &status, signo);
   statarray[0] = &status;
   (void)recalls(1, statarray);


   error = status.sw_count;
   if (error != amount) {
      if (error == EOF)
         (void)fprintf(stderr, "%s No async write\n", filename);
      else
         (void)fprintf(stderr, "%s Bad async write\n", filename);
   }
#else
   error = normalwrite(fno, buffer, amount, from, filename);
#endif
   return(error);
}

int normalwrite(fno, buffer, amount, from, filename)
int fno, amount;
char *buffer, *from, *filename;
{
int error = 0;


   error = write(fno, buffer, amount);


   if (error != amount) {
      if (error == EOF)
         (void)fprintf(stderr, "%s No write\n", filename);
      else
         (void)fprintf(stderr, "%s Bad write\n", filename);
   }
   return(error);
}

/*******************************************************/
/*  Use io_type to decide what type of write we will do and
    go to the appropriate routine to do the setup and write.
*/
int writestuff(fno, buffer, amount, from, filename, io_type)
int fno, amount, io_type;
char *buffer, *from, *filename;
{
int error = 0;

   (void)lseek(fno, 0, SEEK_SET);

   if (io_type == AIO) {
      error = asyncwrite(fno, buffer, amount, from, filename);
   }
   else if (io_type >= LIO) {
      error = listiowrite(fno, buffer, amount, from, filename, io_type);
   }
   else {
      error = normalwrite(fno, buffer, amount, from, filename);
   }

   return(error);
}

int asyncread(fno, buffer, amount, from, filename)
int fno, amount;
char *buffer, *from, *filename;
{
int error = 0;
#ifdef CRAY
struct iosw status, *statarray[1];
int signo = 0;

   status.sw_count = 0;
   status.sw_error = 0;
   status.sw_flag = 0;


   error = reada(fno, buffer, amount, &status, signo);
   statarray[0] = &status;
   (void)recalls(1, statarray);


   error = status.sw_count;
   if (error != amount) {
      if (error == EOF)
         (void)fprintf(stderr, "%s No async read\n", filename);
#ifdef NITPICKY
      else
         (void)fprintf(stderr, "%s Bad async read\n", filename);
#endif
   }
#else
   error = normalread(fno, buffer, amount, from, filename);
#endif
   return(error);
}

int normalread(fno, buffer, amount, from, filename)
int fno, amount;
char *buffer, *from, *filename;
{
int error = 0;


   error = read(fno, buffer, amount);


   if (error != amount) {
      if (error == EOF)
         (void)fprintf(stderr, "%s No read\n", filename);
#ifdef NITPICKY
      else
         (void)fprintf(stderr, "%s Bad read\n", filename);
#endif
   }
   return(error);
}

int listioread(fno, buffer, amount, from, filename, io_type)
int fno, amount, io_type;
char *buffer, *from, *filename;
{
int error;
#ifdef CRAY
struct listreq request;
struct iosw reqstat, *statarray[1];;

   error = 0;

   request.li_flags = 0;
   request.li_offset = 0;
   request.li_nbyte = amount;
   request.li_memstride = 0;
   request.li_nstride = 1;
   request.li_signo = 0;
   request.li_opcode = LO_READ;
   request.li_fildes = fno;
   request.li_buf = (char *)buffer;
   request.li_status = &reqstat;

   reqstat.sw_count = 0;
   reqstat.sw_error = 0;
   reqstat.sw_flag = 0;

   if (io_type == LIO) {
      error = listio(LC_WAIT, &request, 1);
   }
   else {
      error = listio(LC_START, &request, 1);
      statarray[0] = &reqstat;
      (void)recalls(1, statarray);
   }

   error = reqstat.sw_count;

   if (error != amount) {
      if (error == EOF)
         (void)fprintf(stderr, "%s No listio read\n", filename);
#ifdef NITPICKY
      else
         (void)fprintf(stderr, "%s Listio bad read\n", filename);
#endif
   }
#else
   error = normalread(fno, buffer, amount, from, filename);
#endif
   return(error);
}

/************************************************************/
/*  Use io_type to decide what kind of read to perform and
    call the appropriate routine.
*/
int readstuff(fno, buffer, amount, from, filename, io_type)
int fno, amount;
char *buffer, *from, *filename;
{
int error = 0;

   if (io_type == AIO) {
      error = asyncread(fno, buffer, amount, from, filename);
   }
   else if (io_type >= LIO) {
      error = listioread(fno, buffer, amount, from, filename, io_type);
   }
   else {
      error = normalread(fno, buffer, amount, from, filename);
   }

   return(error);
}

/*******************************************/
/*  A debug routine to print out the
    values that were stored in a semaphore.
*/
void get_sem_vals(loc_id)
int loc_id;
{
int i;

   printf("VALUES FOR SEMAPHORE %d\n", loc_id);
   for (i = 0; i < MAX_SEM; i++) {
      (void)printf(" %d ", semctl(loc_id, i, GETVAL, 0));
   }
   (void)printf("\n");
   (void)fflush(stdout);
}

/******************************************/
/*  Perform specified increment on specified semaphore.
*/
void sem_op(loc_id, value, which_sem)
int loc_id, value, which_sem;
{
struct sembuf op_op[1] = {
/*   0, 0, SEM_UNDO */
     0, 0, 0
};

   op_op[0].sem_op = value;
   op_op[0].sem_num = which_sem;

   if (semop(loc_id, &op_op[0], 1) != 0) {
      (void)fprintf(stderr, "WARNING:  semop %d, %d, %d failed -- %d\n",
              loc_id, value, which_sem, errno);
      get_sem_vals(loc_id);
   }
}

/*******************************************/
/*  Wait/Consume resources  (P)
*/
void pee(loc_id, which_sem)
int loc_id, which_sem;
{

   sem_op(loc_id, -1, which_sem);
}

/*******************************************/
/*  Free resources   (V)
*/
void vee(loc_id, which_sem)
int loc_id, which_sem;
{

   sem_op(loc_id, 1, which_sem);
}

/*******************************************/
/*  Lock the specified semaphore
*/
void lockit(loc_id, which_sem)
int loc_id, which_sem;
{
struct sembuf op_lock[2] = {
   0, 0, 0,                   /* Wait for semaphore to be 0  */
   0, 1, SEM_UNDO             /* Increment semaphore by 1  */
};

   op_lock[0].sem_num = op_lock[1].sem_num = which_sem;
   if (semop(loc_id, &op_lock[0], 2) != 0) {
      (void)fprintf(stderr, "LOCKIT:  semop %d, 1, %d failed -- %d\n",
              loc_id, which_sem, errno);
      get_sem_vals(loc_id);
   }
}

/********************************************/
/*  Unlock the specified semaphore
*/
void unlockit(loc_id, which_sem)
int loc_id, which_sem;
{
struct sembuf op_unlock[1] = {
   0, -1, (IPC_NOWAIT | SEM_UNDO)  /* Decrement semaphore by 1 */
};                                 /* Return is immediate, SEM_UNDO */
                                   /* ensures decrement happens even */
                                   /* after process exits      */

   op_unlock[0].sem_num = which_sem;
   if (semop(loc_id, &op_unlock[0], 1) != 0) {
      (void)fprintf(stderr, "UNLOCKIT:  semop %d, -1, %d failed -- %d\n",
              loc_id, which_sem, errno);
      get_sem_vals(loc_id);
   }
}

/****************************************/
/*  Remove the semaphore specified by the
    local id
*/
int sem_rm_all(local_id)
int local_id;
{
   return(semctl(local_id, 0, IPC_RMID, 0));
}

int sem_open_all()
{

   do {
      errno = 0;
      rsrc_id = semget(RSRC_SEMA_KEY, MAX_SEM, 0);
   } while ((errno == ENOENT) && (getppid() != 1));

   do {
      errno = 0;
      lock_id = semget(LOCK_SEMA_KEY, MAX_SEM, 0);
   } while ((errno == ENOENT) && (getppid() != 1));

   if ((rsrc_id < 0) || (lock_id < 0)) {
      (void)fprintf(stderr, "semaphores NOT OPENED -- %d\n", errno);
      return(-1);
   }

   return(0);
}

int sem_creat_all(loc_array)
int *loc_array;
{
int i;
ushort local[MAX_SEM];
union semun {
   int val;
   struct semid_ds *buf;
   ushort *array;
} geeky;

   for (i = 0; i < MAX_SEM; i++) {
      local[i] = (ushort)loc_array[i];
   }

   if ((rsrc_id = semget(RSRC_SEMA_KEY, MAX_SEM, 0666 | IPC_CREAT)) < 0) {
      (void)fprintf(stderr, "resource semaphores NOT CREATED -- %d\n", errno);
      return(-1);
   }

   if ((lock_id = semget(LOCK_SEMA_KEY, MAX_SEM, 0666 | IPC_CREAT)) < 0) {
      (void)fprintf(stderr, "lock semaphores NOT CREATED -- %d\n", errno);
      return(-1);
   }

   geeky.array = local;

   if (semctl(rsrc_id, MAX_SEM, SETALL, geeky) < 0) {
      (void)fprintf(stderr, "Semaphore initialization incorrect\n");
      return(-1);
   }

   return(0);
}
/*************************************************/
/*  Create the node which points at and tells me about
    my shared memory buffers.
*/
struct shm_buffer_str *new_shm_buffer(sz_type)
int sz_type;
{
struct shm_buffer_str *new_one;

   /*  buffer_ptr is global  */
   new_one = buffer_ptr;
   buffer_ptr++;

   new_one->buffer_sz_type = sz_type;
   new_one->offset = 0;
   new_one->next = NULL;

   return(new_one);
}

/*************************************************/
/*  Add the node created above to a list of buffers.
*/
void add_to_list(new_one)
struct shm_buffer_str *new_one;
{
struct shm_buffer_str *local_trac;

   if (list_heads[new_one->buffer_sz_type] == NULL)
      list_heads[new_one->buffer_sz_type] = new_one;
   else {
      local_trac = list_heads[new_one->buffer_sz_type];
      while (local_trac->next != NULL)
         local_trac = local_trac->next;
      local_trac->next = new_one;
   }
      
}

/*************************************************/
/*  Create each shared memory buffer pointer node using
    the above routines.
*/
void construct_shm_buffer(num_segs)
int num_segs;
{
int i, j;
struct shm_buffer_str *tracit;

   for (i = 0; i < num_segs; i++) {
      for (j = 0; j < rsrc_arr[i]; j++) {
         tracit = new_shm_buffer(i);
         add_to_list(tracit);
      }
   }

}

/*************************************************/
/*  Divide shared memory segments into the smaller
    buffers which are pointed at by the nodse created
    above.
*/
void divide_buffer(num_segs)
int num_segs;
{
int i, j;
struct shm_buffer_str *prev, *current;

   for (i = 0; i < num_segs; i++) {
      prev = list_heads[i];
      for (j = 1; j < rsrc_arr[i]; j++) {
         current = prev->next;
         current->offset = prev->offset + buffer_sz_arr[i];
         prev = current;
      }
   }
}

void shm_ga_fail(where, id, seg_size, key, what)
char *where, *what;
int id, seg_size, key;
{
char linea[100], lineb[100], linec[100];
int pid;

   pid = getpid();

   (void)sprintf(linea,
           "%d: %s: %s, %d:  FAILED, %d\n\0", pid, what, where,
           getppid(), errno);
   (void)sprintf(lineb,
          "%d: %s: %s:  ID = %d, SEGMENT_SIZE = %d, KEY = %d\n\0",
          pid, what, where, id, seg_size, key);
   (void)sprintf(linec,
          "%d: %s: %s:  NUM_ATTACHED = %d\n\0", pid, what, where,
           num_attached);

   (void)fprintf(stderr,"%s%s%s", linea, lineb, linec);
}


/*************************************************/
/*  Open all segments of shared memory for use.
*/
#ifdef TRITON
int open_all_shm_buffer_segs(num_segs, destroyer)
int num_segs, destroyer;
#else
int open_all_shm_buffer_segs(num_segs)
int num_segs;
#endif
{
int i, seg_size, errcode = 0;
#ifdef TRITON
int j;
#endif

   for (i = 0; i < num_segs; i++) {
#ifdef TRITON
      if (num_attached >= 2) {
         (void)fprintf(stderr,
               "OPEN ALL BUFFERS:  num_attached: E(1)A(%d):  %d\n",
         num_attached, getpid());
      }
#endif

      seg_size = buffer_sz_arr[i] * rsrc_arr[i];

      buffer_hld[i].buffer_id =
                     shmget(SHMM_BUF_KEY + i,seg_size, 0);
      if (buffer_hld[i].buffer_id ==  -1) {
         shm_ga_fail("OPEN ALL BUFFERS", buffer_hld[i].buffer_id,
                       seg_size, SHMM_BUF_KEY + i, "shmget()");
         errcode--;
      }

      buffer_hld[i].buffer =
           shmat(buffer_hld[i].buffer_id, (void *)0, 0);

      num_attached++;
#ifdef DEBUG
      fprintf(stderr, "Incremented num_attached -- %d\n", num_attached);
#endif
      if (buffer_hld[i].buffer == (char *) -1) {
         num_attached--;
#ifdef DEBUG
         fprintf(stderr, "Decremented num_attached -- %d\n", num_attached);
#endif
         shm_ga_fail("OPEN ALL BUFFERS", buffer_hld[i].buffer_id,
                       seg_size, SHMM_BUF_KEY + i, "shmat()");
         errcode--;
      }
#ifdef TRITON
     else {
        if (destroyer == 1) {
           if (shmdt(buffer_hld[i].buffer) != 0) {
              errcode--;
              (void)fprintf(stderr,
                      "DESTROY_B:  detach of shared memory failed\n");
           }
           else {
              num_attached--;
#ifdef DEBUG
      fprintf(stderr, "Decremented num_attached -- %d\n", num_attached);
#endif
           }
           j = shmctl(buffer_hld[i].buffer_id, IPC_RMID, (struct shmid_ds *)0);
           if (j != 0) {
              (void)fprintf(stderr,
                      "DESTROY_B:  Could not remove shared segment\n");
              errcode--;
           }
        }
     }
#endif
   }
#ifdef TRITON
   if (destroyer == 1) {
      if (shmdt(list_heads) != 0) {
         errcode--;
         (void)fprintf(stderr, "DESTROY:  detach of shared memory failed\n");
      }
      else {
         num_attached--;
#ifdef DEBUG
      fprintf(stderr, "Decremented num_attached -- %d\n", num_attached);
#endif
      }
      j = shmctl(list_heads_id, IPC_RMID, (struct shmid_ds *)0);
      if (j != 0) {
         (void)fprintf(stderr, "DESTROY:  Could not remove shared segment\n");
         errcode--;
      }
   }
#endif
   return(errcode);
}

/***************************************************/
/*  Open a single shared memory segment
*/
int open_one_shm_buffer_segs(i)
int i;
{
int seg_size;

   errno = 0;

#ifdef TRITON
   if (num_attached >= 2) {
      (void)fprintf(stderr, "OPEN BUFFER:  num_attached: E(1)A(%d):  %d\n",
      num_attached, getpid());
   }
#endif

   seg_size = buffer_sz_arr[i] * rsrc_arr[i];
   buffer_hld[i].buffer_id =
                  shmget(SHMM_BUF_KEY + i,seg_size, 0);
   if (buffer_hld[i].buffer_id == -1) {
      shm_ga_fail("OPEN BUFFER", buffer_hld[i].buffer_id,
                       seg_size, SHMM_BUF_KEY + i, "shmget()");
      return(-1);
   }

   buffer_hld[i].buffer =
        shmat(buffer_hld[i].buffer_id, (void *)0, 0);

   if (buffer_hld[i].buffer == (char *) -1) {
      shm_ga_fail("OPEN BUFFER", buffer_hld[i].buffer_id,
                       seg_size, SHMM_BUF_KEY + i, "shmat()");
      return(-1);
   }
   else {
      num_attached++;
#ifdef DEBUG
      fprintf(stderr, "Incremented num_attached -- %d\n", num_attached);
#endif
   }

   return(0);
}

/********************************************************/
/*  Open the common shared memory segment, the one shared
    by all processes, which contains all necessary offsets
    and stuff.
*/
int open_list_heads(num_buffs)
int num_buffs;
{
int seg_size;

#ifdef TRITON
   if (num_attached >= 1) {
      (void)fprintf(stderr,
             "OPEN LIST HEADS:  num_attached: E(0)A(%d):  %d\n",
              num_attached, getpid());
   }
#endif

   seg_size = sizeof(list_heads) * 5;
   seg_size = seg_size + (sizeof(struct shm_buffer_str) * num_buffs);

   list_heads_id = shmget(SHMM_LST_KEY, seg_size, 0);
   if (list_heads_id == -1) {
      shm_ga_fail("OPEN LIST", list_heads_id,
                       seg_size, SHMM_LST_KEY, "shmget()");
      (void)fprintf(stderr, "OPEN LIST:  NUMBER_BUFFERS = %d\n", num_buffs);
      return(-1);
   }

   list_heads = shmat(list_heads_id, (void *)0, 0);

   if (list_heads == (struct shm_buffer_str **) -1) {
      shm_ga_fail("OPEN LIST", list_heads_id,
                       seg_size, SHMM_LST_KEY, "shmat()");
      (void)fprintf(stderr, "OPEN LIST:  NUMBER_BUFFERS = %d\n", num_buffs);
      return(-1);
   }
   else {
      num_attached++;
#ifdef DEBUG
      fprintf(stderr, "Incremented num_attached -- %d\n", num_attached);
#endif
   }

   return(0);
}


/********************************************************/
/*  Create the common shared memory segment, the one shared
    by all processes, which contains all necessary offsets
    and stuff.
*/
int creat_list_heads(num_buffs)
int num_buffs;
{
int seg_size;

#ifdef TRITON
   if (num_attached != 0) {
      (void)fprintf(stderr,
                "CREAT_LIST_HEADS:  num_attached: E(0)A(%d):  %d\n",
                num_attached, getpid());
   }
#endif

   seg_size = sizeof(list_heads) * 5;
   seg_size = seg_size + (sizeof(struct shm_buffer_str) * num_buffs);

   list_heads_id = shmget(SHMM_LST_KEY, seg_size, 0666|IPC_CREAT|IPC_EXCL);
   if (list_heads_id == -1) {
      shm_ga_fail("CREATE LIST", list_heads_id,
                       seg_size, SHMM_LST_KEY, "shmget()");
      (void)fprintf(stderr, "CREATE LIST:  NUMBER_BUFFERS = %d\n", num_buffs);
      return(-1);
   }

   list_heads = shmat(list_heads_id, (char *)0, 0);

   if (list_heads == (struct shm_buffer_str **) -1) {
      shm_ga_fail("CREATE LIST", list_heads_id,
                       seg_size, SHMM_LST_KEY, "shmat()");
      (void)fprintf(stderr, "CREATE LIST:  NUMBER_BUFFERS = %d\n", num_buffs);
      return(-1);
   }
   else {
      num_attached++;
#ifdef DEBUG
      fprintf(stderr, "Incremented num_attached -- %d\n", num_attached);
#endif
   }

   buffer_ptr = (struct shm_buffer_str *)&list_heads[5];
   return(0);
}




/*************************************************/
/*  Create the shared memory segments and attach
    them to the head of the lists.  These segments will
    be broken up into smaller buffers.
*/
int creat_shm_buffer_segs(num_segs)
int num_segs;
{
int i, seg_size;
int errcode = 0;

   for (i = 0; i < num_segs; i++) {
#ifdef TRITON
   if (num_attached >= 2) {
      (void)fprintf(stderr,
                "CREATE ALL BUFFERS:  num_attached: E(1)A(%d):  %d\n",
                num_attached, getpid());
   }
#endif
      seg_size = buffer_sz_arr[i] * rsrc_arr[i];

      buffer_hld[i].buffer_id =
                shmget(SHMM_BUF_KEY + i,seg_size, 0666|IPC_CREAT|IPC_EXCL);
      if (buffer_hld[i].buffer_id == -1) {
         shm_ga_fail("CREATE ALL BUFFERS", buffer_hld[i].buffer_id,
                       seg_size, SHMM_BUF_KEY + i, "shmget()");
         errcode--;
         return(errcode);
      }

      if (donttesthere == 0) {

         buffer_hld[i].buffer =
                        shmat(buffer_hld[i].buffer_id, (void *)0, 0);

         if (buffer_hld[i].buffer == (char *) -1) {
            shm_ga_fail("CREATE ALL BUFFERS", buffer_hld[i].buffer_id,
                       seg_size, SHMM_BUF_KEY + i, "shmat()");
            errcode--;
            return(errcode);
         }
         else {
            num_attached++;
#ifdef DEBUG
            fprintf(stderr, "Incremented num_attached -- %d\n", num_attached);
#endif
         }
#ifdef TRITON
         if (shmdt(buffer_hld[i].buffer) != 0) {
            errcode--;
            (void)fprintf(stderr,
                   "CREATE ALL BUFFERS:  Could not detach new buffer\n");
         }
         else {
            num_attached--;
#ifdef DEBUG
         fprintf(stderr, "Decremented num_attached -- %d\n", num_attached);
#endif
         }
#endif
      }
   }
   return(errcode);
}

/*************************************************/
/*  Find the buffer node pointing at the shared memory
    segment and detach and remove it.
*/
int destroy_shm_buffer_segs(num_segs, cd)
int num_segs, cd;
{
int i, errcode = 0, j;


   if (donttesthere == 0) {
      for (i = 0; i < num_segs; i++) {
         if (shmdt(buffer_hld[i].buffer) != 0) {
            errcode--;
            (void)fprintf(stderr, "DESTROY:  detach of shared memory failed\n");
         }
         else {
            num_attached--;
#ifdef DEBUG
            fprintf(stderr, "Decremented num_attached -- %d\n", num_attached);
#endif
         }
         if (cd != 0) {
            j = shmctl(buffer_hld[i].buffer_id, IPC_RMID, (struct shmid_ds *)0);
            if (j != 0) {
               (void)fprintf(stderr,
                     "DESTROY:  Could not remove shared segment\n");
               errcode--;
            }
         }
      }
   }

   if (shmdt(list_heads) != 0) {
      errcode--;
      (void)fprintf(stderr, "DESTROY:  detach of shared memory failed\n");
   }
   else {
      num_attached--;
#ifdef DEBUG
      fprintf(stderr, "Decremented num_attached -- %d\n", num_attached);
#endif
   }
   if (cd != 0) {
      j = shmctl(list_heads_id, IPC_RMID, (struct shmid_ds *)0);
      if (j != 0) {
         (void)fprintf(stderr, "DESTROY:  Could not remove shared segment\n");
         errcode--;
      }
   }
   return(errcode);
}

/**************************************************/
/*  Close one shared memory segment, and the common use
    shared memory segment.
*/
void close_singles(i)
int i;
{

   if (shmdt(buffer_hld[i].buffer) != 0) {
      (void)fprintf(stderr, "RM_SINGLE:  Could not remove shared buffer\n");
   }
   else {
      num_attached--;
#ifdef DEBUG
      fprintf(stderr, "Decremented num_attached -- %d\n", num_attached);
#endif
   }
   if (shmdt(list_heads) != 0) {
      (void)fprintf(stderr,
               "RM_SINGLE:  Could not remove shared common area\n");
   }
   else {
      num_attached--;
#ifdef DEBUG
      fprintf(stderr, "Decremented num_attached -- %d\n", num_attached);
#endif
   }
}

/*************************************************/
/*  Create the buffer pool by getting the shared memory
    segments and dividing them up into separate buffers.
*/
int creat_shm_buffer_pool(num_buffers, num_segs)
int num_buffers, num_segs;
{

   if (creat_list_heads(num_buffers) == 0) {
      construct_shm_buffer(num_segs);

      if (creat_shm_buffer_segs(num_segs) == 0)
         divide_buffer(num_segs);
      else
         num_buffers = -1;
#ifdef TRITON
      if (shmdt(list_heads) != 0) {
         (void)fprintf(stderr,
              "CREAT_SHM_BUFFER_POOL:  Could not remove shared common area\n");
      }
      else {
         num_attached--;
#ifdef DEBUG
      fprintf(stderr, "Decremented num_attached -- %d\n", num_attached);
#endif
      }
#endif
   }
   else {
      num_buffers = -1;
   }

   return(num_buffers);
}

int what_size(x)
int x;
{
   
   if (CHOOSE_MED(x))
      return(MED);

   if (CHOOSE_SML(x))
      return(SML);

   if (CHOOSE_TNY(x))
      return(TNY);

   if (CHOOSE_LRG(x))
      return(LRG);

   if (CHOOSE_XLG(x))
      return(XLG);

   (void)fprintf(stderr,
       "WARNING: what_size(), %d is out of range, returning MEDIUM type\n", x);

   return(MED);
}

/**************************************************/
/*  Return a shared memory buffer chunk that is not
    currently in use.
*/
struct shm_buffer_str *get_shm_buffer(sz_type)
int sz_type;
{
struct shm_buffer_str *tracit;

   pee(rsrc_id, sz_type);
   lockit(lock_id, sz_type);

   tracit = list_heads[sz_type];
   list_heads[sz_type] = tracit->next;
   tracit->next = NULL;

   unlockit(lock_id, sz_type);

   return(tracit);
}

/*****************************************************/
/*  Put the shared memory buffer chunk "back" into
    the pool of buffers available.
*/
void put_back_shm_buffer(tracit)
struct shm_buffer_str *tracit;
{
   lockit(lock_id, tracit->buffer_sz_type);

   tracit->next = list_heads[tracit->buffer_sz_type];
   list_heads[tracit->buffer_sz_type] = tracit;

   unlockit(lock_id, tracit->buffer_sz_type);
   vee(rsrc_id, tracit->buffer_sz_type);

}

/******************************************************/
/*  Fill a buffer with ascii data.
*/
void fill_buffer(copyarea, usr_buffer, pid, filename)
char *copyarea;
struct usr_buffer_str *usr_buffer;
int pid;
char *filename;
{
char *mloc_mem, *genmultiblock(), *alterblocks();
int blockstogen;

   blockstogen = ((usr_buffer->x_amt + BLOCKSZ) / BLOCKSZ);

   mloc_mem = genmultiblock(filename, pid, blockstogen, usr_buffer->IO_type);
   mloc_mem = alterblocks(mloc_mem, 1, blockstogen);

   (void)memcpy(copyarea, mloc_mem, usr_buffer->x_amt);
   free(mloc_mem);
}

struct usr_buffer_str *build_usr()
{
int random;
struct usr_buffer_str *usr_buffer;

   srand48(time((long *)0) + getpid());

   usr_buffer=(struct usr_buffer_str *)malloc(sizeof(struct usr_buffer_str));

   if (chiotype != 0)
      usr_buffer->IO_type = CHOOSE_IO_TYPE();
   else
      usr_buffer->IO_type = NIO;

   random = (int)(drand48() * 100.0);
   usr_buffer->buffer_sz_type = what_size(random);

   if (!(VALID_BUFFER_TYPE(usr_buffer->buffer_sz_type)))
      usr_buffer->buffer_sz_type = MED;

   usr_buffer->x_amt =
      (int)(drand48() * (double)buffer_sz_arr[usr_buffer->buffer_sz_type]);

   usr_buffer->read_amt = usr_buffer->write_amt = 0;
   usr_buffer->read_pass = usr_buffer->write_pass = PASS;
   usr_buffer->parent_pid = getpid();
   usr_buffer->child_pid = 0;

   usr_buffer->shm_buffer = NULL;
   usr_buffer->buffer = NULL;

   return(usr_buffer);
}

/**********************************************************/
/*  Attach shared memory segments and get the offset from the 
    offset node and remove the offset node from the available
    list
*/
int common_setup(usr_buffer, num_buffers)
struct usr_buffer_str *usr_buffer;
int num_buffers;
{
struct shm_buffer_str *get_shm_buffer();
int errcode = 0;

   if (open_list_heads(num_buffers) == 0) {
      if (open_one_shm_buffer_segs(usr_buffer->buffer_sz_type) == 0) {
         usr_buffer->shm_buffer = get_shm_buffer(usr_buffer->buffer_sz_type);
         usr_buffer->buffer =
                       buffer_hld[usr_buffer->buffer_sz_type].buffer +
                       usr_buffer->shm_buffer->offset;
      }
      else {
         if (shmdt(list_heads) != 0) {
            (void)fprintf(stderr,
                     "SETUP:  Could not detach shared common area\n");
         }
         else {
            num_attached--;
#ifdef DEBUG
      fprintf(stderr, "Decremented num_attached -- %d\n", num_attached);
#endif
         }
         errcode--;
      }
   }
   else {
      errcode--;
   }
   return(errcode);
}

/**********************************************************/
/*  Put the offset node back on the list and detach the shared
    memory segments
*/
void common_cleanup(usr_buffer)
struct usr_buffer_str *usr_buffer;
{
   put_back_shm_buffer(usr_buffer->shm_buffer);
   close_singles(usr_buffer->buffer_sz_type);
}

/**********************************************************/
/*  Write to file
*/
int common_write(usr_buffer, filename)
struct usr_buffer_str *usr_buffer;
char *filename;
{
int fno, flagthing, pid;

   pid = getpid();

   fill_buffer(usr_buffer->buffer, usr_buffer, pid, filename);

   flagthing = doopenflags(UNLINKABLE);
   fno = openexisting(filename, "do_child", flagthing);

   if (fno != (-1)) {
      usr_buffer->write_amt =
         writestuff(fno, usr_buffer->buffer, usr_buffer->x_amt,
                    "common_write", filename, usr_buffer->IO_type);
      (void)close(fno);
   }

   if (usr_buffer->write_amt != usr_buffer->x_amt) {
      (void)fprintf(stderr, "Bad write to %s\n", filename);
      usr_buffer->write_pass--;
   }
   return(usr_buffer->write_pass);
}

/**********************************************************/
/*  Read from file and verify expected data.
*/
int common_read(usr_buffer, filename, copyarea, from)
struct usr_buffer_str *usr_buffer;
char *filename, *copyarea, *from;
{
int fno, flagthing, cpyval, error = 0;

   flagthing = O_RDWR;
   fno = openexisting(filename, "do_child", flagthing);

   if (fno != (-1)) {
      usr_buffer->read_amt =
         readstuff(fno, usr_buffer->buffer,
                     buffer_sz_arr[usr_buffer->buffer_sz_type],
                    "common_read", filename, usr_buffer->IO_type);
      (void)close(fno);
   }

   if (usr_buffer->read_amt != usr_buffer->x_amt) {
      (void)fprintf(stderr,
                "%s:  Read wrong amout from %s\n", from, filename);
      error--;
   }

   cpyval = memcmp(copyarea, usr_buffer->buffer, usr_buffer->x_amt);

   if (cpyval != 0) {
      (void)fprintf(stderr, "%s:%d:%d:%d  Bad read from %s\n",
              from, usr_buffer->buffer_sz_type,
              usr_buffer->x_amt, usr_buffer->read_amt, filename);
      error--;
   }

   usr_buffer->read_pass = error;
   return(error);
}

/**********************************************************/
/*  Verify parent write, write child data
*/
int do_child(usr_buffer, filename, copyarea, num_buffers)
struct usr_buffer_str *usr_buffer;
char *filename, *copyarea;
int num_buffers;
{
int errcode = 0;

   if (sem_open_all() != 0) {
      errcode--;
      return(errcode);
   }

   if (common_setup(usr_buffer, num_buffers) == 0) {

      errcode = common_read(usr_buffer, filename, copyarea, "CHILD");
      free(copyarea);

      errcode = common_write(usr_buffer, filename);
      common_cleanup(usr_buffer);
   }
   else {
      (void)fprintf(stderr, "Child failed:  %d, %d\n", getpid(), getppid());
      errcode--;
   }
   return(errcode);
}

/**********************************************************/
/*  Initial set up.  Write parent data.  Spawn child
    Verify child write.  Final cleanup.
*/
int do_parent(num_buffers)
int num_buffers;
{
struct usr_buffer_str *usr_buffer, *build_usr();
char *filename, *curdir, *getcwd(), *copyarea;
int errcode = 0;
union {
   struct {
#ifdef CRAY
      unsigned unused :48, sherr:8, sigid:8;
#else
      unsigned unused :16, sherr:8, sigid:8;
#endif
   } err;
   int retval;
} errstruct;

   curdir = getcwd((char *)NULL, 80);
   filename = (char *)genname(curdir, 0, "shm");

   usr_buffer = build_usr();
   copyarea = (char *)malloc(buffer_sz_arr[usr_buffer->buffer_sz_type]);

   if (sem_open_all() != 0) {
      errcode--;
      free(usr_buffer);
      free(filename);
      free(curdir);
      _exit(errcode);
   }

   if (common_setup(usr_buffer, num_buffers) == 0) {
      common_write(usr_buffer, filename);

      (void)memcpy(copyarea, usr_buffer->buffer, usr_buffer->x_amt);

      common_cleanup(usr_buffer);

      pee(rsrc_id, CHILD_SEMA);
      if ((usr_buffer->child_pid = fork()) == 0) {
         if (do_child(usr_buffer,filename,copyarea,num_buffers) == 0) {
            errcode = usr_buffer->write_pass + usr_buffer->read_pass;
         }
         else {
            errcode--;
         }
         free(usr_buffer);
         free(filename);
         free(curdir);
         _exit(errcode);
      }
      wait(&errstruct.retval);
      vee(rsrc_id, CHILD_SEMA);
      if (errstruct.err.sherr != 0)
         errcode--;
   }
   else {
      (void)fprintf(stderr, "Parent A failed:  %d\n", getpid());
      errcode--;
   }

   if (common_setup(usr_buffer, num_buffers) == 0) {
      fill_buffer(copyarea, usr_buffer, usr_buffer->child_pid, filename);
      errcode = common_read(usr_buffer, filename, copyarea, "PARENT");
      common_cleanup(usr_buffer);
   }
   else {
      (void)fprintf(stderr, "Parent B failed:  %d\n", getpid());
      errcode--;
   }

   if (errcode == 0)
      (void)unlink(filename);

   free(copyarea);
   free(usr_buffer);
   free(filename);
   free(curdir);

   return(errcode);
}

void done_routine(errcode, num_run, ran)
int errcode, num_run, ran;
{
   if (errcode == 0)
      (void)printf(
             "ipcshmm:  Test Passed, %d files, %d seconds\n", num_run, ran);
   else
      (void)printf(
             "ipcshmm:  Test Failed, %d files, %d seconds\n", num_run, ran);

   exit(errcode);
}

void explain_tool()
{
static char usage0[]="Usage:  ipcshmm [-b buffsz[:buffsz:...]]";
static char usage1[]="                 [-p pcntex[:pcntex:...]]";
static char usage2[]="                 [-n numbuffs[:numbuffs:...]]";
static char usage3[]="                 [-f number_of_files]";
static char usage4[]="                 [-N number_of_segments]";
static char usage5[]="                 [-P max_processes_running]";
static char usage6[]="                 [-t run_time] (elapsed secs)";
static char usage7[]="                 [-d run_directory]";
static char usage8[]="                 [-r](IO type becomes random)";
static char usage9[]="                 [-D](Exclude some preliminary tests)";

(void)printf("Default for this test are as follows:  \n\n");
(void)printf("Buffer     Buffer     Buffer        Number of    Segment\n");
(void)printf("Type     Size(bytes)  Percent       Buffers       Size\n");
(void)printf("---------------------------------------------------------\n");
(void)printf("MEDIUM     16384        50            10          163840\n");
(void)printf("SMALL       4096        25             5           20480\n");
(void)printf("TINY         128        15             3             384\n");
(void)printf("LARGE      32768         5             1           32768\n");
(void)printf("X-LARGE    65536         5             1           65536\n\n");
(void)printf("You can change the number of segments, the size\n");
(void)printf("associated with each buffer, the number of buffers\n");
(void)printf("carried by each segment, and the percent of time a\n");
(void)printf("given segment will be chosen.\n\n");
(void)printf("All changes must be given in order on the command line.\n");
(void)printf("Example:\n");
(void)printf("   You want to change everything:\n");
(void)printf(
      "   ipcshmm -b 100:200:300:400:500 -p 10:20:30:30:10 -n 1:2:3:3:1\n");
(void)printf(
      "   You will get 1 buffer 100 bytes chosen 10 percent of the time,\n");
(void)printf(
      "   2 buffers of 200 bytes chosen 20 percent of the time etc.\n");
(void)printf("   Segment sizes will be 100, 400, 900, 1200, 500.\n\n");
(void)printf("Segment size will automatically adjust to accomodate\n");
(void)printf("the new buffer size and number of buffers.  You may specify\n");
(void)printf("fewer than 5 segments, but not more.\n");

(void)printf("%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n",
          usage0, usage1, usage2, usage3,
          usage4, usage5, usage6, usage7, usage8, usage9);
}

void check_errcode(errcode, from)
int errcode;
char *from;
{
   if (errcode != oldcode) {
      printf("errcode changed:  %d   %d, %s\n", errcode, oldcode, from);
   }
   oldcode = errcode;
}

void go_go_go(num_segs, num_buffers, runtime, num_files)
int num_segs, num_buffers, runtime, num_files;
{
int errcode, num_run, childpid, done;
int elapsed, fixed_time, realtime;
int i;
struct tms buffer;
union {
   struct {
#ifdef CRAY
      unsigned unused :48, sherr:8, sigid:8;
#else
      unsigned unused :16, sherr:8, sigid:8;
#endif
   } err;
   int retval;
} errstruct;

   done = num_run = errcode = 0;

   /*************************************/
   /*  Create the shared memory segments and
       the lock and resource semaphores
       If either of these two steps fails, no point
       in continuing.  Clean up what we've got
       and exit.
   */
   if (creat_shm_buffer_pool(num_buffers, num_segs) < num_buffers) {
      destroy_shm_buffer_segs(num_segs, 1);
      errcode--;
      done_routine(errcode, 0, 0);
   }

   if (sem_creat_all(&rsrc_arr[0]) != 0) {
      destroy_shm_buffer_segs(num_segs, 1);
      errcode--;
      done_routine(errcode, 0, 0);
   }

#ifdef DEBUG
   for (i = 0; i < num_segs; i++) {
      (void)printf("%d   %d\n", rsrc_arr[i], buffer_sz_arr[i]);
      (void)fflush(stdout);
   }
#endif

   /*************************************/
   /*  Detach the shared memory segments
       Only children will use them now.
   */
#ifndef TRITON
      errcode = destroy_shm_buffer_segs(num_segs, 0);
#endif

   /*************************************/
   /*  Kick off the children which will use
       the shared memory segments.
   */
   fixed_time = times(&buffer);
   do {

      while (semctl(rsrc_id, PARENT_SEMA, GETVAL, 0) <= 0) {
         if (waitpid(0, &errstruct.retval, WNOHANG) > 0) {
            vee(rsrc_id, PARENT_SEMA);
            if (errstruct.err.sherr != 0)
               errcode--;
         }
      }

      pee(rsrc_id, PARENT_SEMA);
      if ((childpid = fork()) == 0) {
         _exit(do_parent(num_buffers));
      }

      if (childpid < 0)
         vee(rsrc_id, PARENT_SEMA);
      else
         num_run++;

      while (waitpid(0, &errstruct.retval, WNOHANG) > 0) {
         vee(rsrc_id, PARENT_SEMA);
         if (errstruct.err.sherr != 0)
            errcode--;
      }

      realtime = times(&buffer);
      elapsed = realtime - fixed_time;

      if (num_files > 0) {
         if (num_run >= num_files)
            done++;
      }
      else {
         if ((elapsed / CLK_TCK) >= runtime)
            done++;
      }

   } while (!done);

   while (wait(&errstruct.retval) != (-1)) {
      vee(rsrc_id, PARENT_SEMA);
      if (errstruct.err.sherr != 0)
         errcode--;
   }
   check_errcode(errcode, "file processing");

   /*************************************/
   /*  Attach all shared memory segments, and then
       detach and remove them.  Destroy all semaphores.
       Does a final check of ability to attach and all that
       crap.
   */
   errcode = errcode + open_list_heads(num_buffers);
   check_errcode(errcode, "open common shared segment");
#ifdef TRITON
   errcode = errcode + open_all_shm_buffer_segs(num_segs, 1);
   check_errcode(errcode, "open shared segments");
#else
   errcode = errcode + open_all_shm_buffer_segs(num_segs);
   check_errcode(errcode, "open shared segments");
   if (donttesthere != 0)
      donttesthere = 0;
   errcode = errcode + destroy_shm_buffer_segs(num_segs, 1);
   check_errcode(errcode, "destroy shared segments");
#endif
   errcode = errcode + sem_rm_all(rsrc_id);
   check_errcode(errcode, "remove resource semaphore");
   errcode = errcode + sem_rm_all(lock_id);
   check_errcode(errcode, "remove lock semaphore");

   done_routine(errcode, num_run, elapsed/CLK_TCK);
}

int setrsrcarray(num_buffers, num_segs)
int num_buffers, num_segs;
{
int i, used = 0, current = 0;

   if (rsrc_arr[0] == 0) {
      for (i = 0; i < num_segs; i++) {
         current = (int)(percent_arr[i] * (float)num_buffers);
         if (current <= 0)
            current = 1;
         used = used + current;
         rsrc_arr[i] = current;
      }
   }
   else {
      for (i = 0; i < num_segs; i++)
         used = used + rsrc_arr[i];
   }
   return(used);
}

void setpcntints(num_segs)
int num_segs;
{
int i;

   pcnt_ints[0] = (int)(percent_arr[0] * 100.0);
   for (i = 1; i < num_segs; i++) {
      pcnt_ints[i] = pcnt_ints[i - 1] + (int)(percent_arr[i] * 100.0);
   }
}

void process_the_thing(in_string, which)
char *in_string;
int which;
{
char *each[5], *strchr();
int i = 0, j;

   while (in_string != NULL) {
      each[i] = in_string;
      in_string = strchr(in_string, ':');
      if (in_string != NULL) {
         *in_string = '\0';
         in_string++;
      }
      i++;
      if (i >= 5)
         break;
   }

   for (j = 0; j < i; j++) {
      switch (which) {
         case 0:
                 buffer_sz_arr[j] = atoi(each[j]);
                 break;
         case 1:
                 rsrc_arr[j] = atoi(each[j]);
                 break;
         case 2:
                 percent_arr[j] = (float)(atoi(each[j]) / 100.0);
                 break;
         default:
                 break;
      }
   }

}

void main(argc, argv, envp)
int argc;
char **argv, **envp;
{
int num_segs, num_buffers, runtime, num_files, c;
char *goto_dir, *bufferlist, *seglist, *pcntlist, *numbufflist;
struct stat buf;

extern char *optarg;

static char *optstring = "P:t:d:b:p:n:s:N:Hhf:rD";

   goto_dir = bufferlist = seglist = pcntlist = numbufflist = NULL;

   num_segs = DEFAULT_SEGS;
   num_buffers = DEFAULT_BUFS;
   runtime = DEFAULT_RUN;
   num_files = 0;
   num_attached = 0;

   LOCK_SEMA_KEY = getpid() + LOCK_SEMA_BASE;
   RSRC_SEMA_KEY = getpid() + RSRC_SEMA_BASE;
   SHMM_BUF_KEY = getpid() + SHMM_BUF_BASE;
   SHMM_LST_KEY = getpid() + SHMM_LST_BASE;

   while ((c=getopt(argc, argv, optstring)) != EOF) {

      switch (c) {
         case 'D':
                   donttesthere = 1;
                   break;

         case 'r':
                   chiotype = 1;
                   break;

         case 'P':
                   rsrc_arr[PARENT_SEMA] =
                   rsrc_arr[CHILD_SEMA] = atoi(optarg) / 2;
                   break;
       
         case 'f':
                   num_files = atoi(optarg);
                   break;

         case 't':
                   runtime = atoi(optarg);
                   if (runtime > 300) {
                      (void)fprintf(stderr,
                             "WARNING: run is for %5.2f minutes\n",
                              (float)runtime / 60.0);
                      (void)fprintf(stderr,
                             "Go have a drink, you've got time\n");
                   }
                   break;

         case 'd':
                   goto_dir = optarg;
                   (void)stat(goto_dir, &buf);
                   if ((S_IFMT & buf.st_mode) != S_IFDIR) {
                      (void)fprintf(stderr,
                              "No such directory - %s\n", goto_dir);
                      exit(0);
                   }
                   break;

         case 'b':
                   bufferlist = optarg;
                   break;

         case 'N':
                   num_segs = atoi(optarg);
                   if (num_segs > DEFAULT_SEGS) {
                      (void)fprintf(stderr, "Number of segments exceeds 5\n");
                      explain_tool();
                      exit(0);
                   }
                   break;

         case 'p':
                   pcntlist = optarg;
                   break;

         case 'n':
                   numbufflist = optarg;
                   break;
         case 's':
                   seglist = optarg;
                   (void)fprintf(stderr,"-s not implemented, skipping ...\n");
                   break;
         case 'h':
         case 'H':
                   explain_tool();
                   exit(0);
                   break;

         default:
                   break;

      }
   }

   if (numbufflist != NULL)
      process_the_thing(numbufflist, 1);
   if (pcntlist != NULL)
      process_the_thing(pcntlist, 2);
   if (bufferlist != NULL)
      process_the_thing(bufferlist, 0);

   glob_segs = num_segs;
   setpcntints(num_segs);
   num_buffers = setrsrcarray(num_buffers, num_segs);

   if (goto_dir != NULL)
      (void)chdir(goto_dir);

   go_go_go(num_segs, num_buffers, runtime, num_files);
}
