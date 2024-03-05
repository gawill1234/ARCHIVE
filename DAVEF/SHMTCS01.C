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

#ifdef SUN
#define MAX_SEGS 6
#else
#define MAX_SEGS 2
#endif

int error = 0;

void shm_ga_fail(where, id, seg_size, key, what)
char *where, *what;
int id, seg_size, key;
{
char linea[100], lineb[100];
int pid;

   pid = getpid();
   error--;

   (void)sprintf(linea,
           "%d: %s: %s, %d:  FAILED, %d\n\0", pid, what, where,
           getppid(), errno);
   (void)sprintf(lineb,
          "%d: %s: %s:  ID = %d, SEGMENT_SIZE = %d, KEY = %d\n\0",
          pid, what, where, id, seg_size, key);

   (void)fprintf(stderr,"\n%s%s\0", linea, lineb);
}

int failcreate_shm_buffer(seg_size, key)
int seg_size, key;
{
int id;

   id = shmget(key, seg_size, 0666|IPC_CREAT|IPC_EXCL);

   if (id != -1) {
         shm_ga_fail("FAILCREATE SHM BUFFER", id,
                       seg_size, key, "shmget()");
         return(id);
   }
   return(0);
}

int create_shm_buffer(seg_size, key)
int seg_size, key;
{
int id;

   id = shmget(key, seg_size, 0666|IPC_CREAT|IPC_EXCL);

   if (id == -1) {
         shm_ga_fail("CREATE SHM BUFFER", id,
                       seg_size, key, "shmget()");
         return(-1);
   }
   return(id);
}

int failopen_shm_buffer(seg_size, key)
int seg_size, key;
{
int id;

   id = shmget(key, seg_size, 0);

   if (id != -1) {
         shm_ga_fail("FAILOPEN SHM BUFFER", id,
                       seg_size, key, "shmget()");
         return(id);
   }
   return(0);
}

int open_shm_buffer(seg_size, key)
int seg_size, key;
{
int id;

   id = shmget(key, seg_size, 0);

   if (id == -1) {
         shm_ga_fail("OPEN SHM BUFFER", id,
                       seg_size, key, "shmget()");
         return(-1);
   }
   return(id);
}


int faildtch_shm_buffer(buffer, id, seg_size, key)
char *buffer;
int id, seg_size, key;
{

   if (shmdt(buffer) == 0) {
      shm_ga_fail("FAILDETACH SHM BUFFER", id,
                    seg_size, key, "shmdt()");
      return(-1);
   }
   return(0);
}

int dtch_shm_buffer(buffer, id, seg_size, key)
char *buffer;
int id, seg_size, key;
{

   if (shmdt(buffer) != 0) {
      shm_ga_fail("DETACH SHM BUFFER", id,
                    seg_size, key, "shmdt()");
      return(-1);
   }
   return(0);
}


char *failget_shm_buffer(id, seg_size, key)
int id, seg_size, key;
{
char *buffer;

   buffer = shmat(id, (void *)0, 0);

   if (buffer != (char *) -1) {
      shm_ga_fail("FAILGET SHM BUFFER", id,
                    seg_size, key, "shmat()");
      return(buffer);
   }
   return((char *)0);
}

char *get_shm_buffer(id, seg_size, key)
int id, seg_size, key;
{
char *buffer;

   buffer = shmat(id, (void *)0, 0);

   if (buffer == (char *) -1) {
      shm_ga_fail("GET SHM BUFFER", id,
                    seg_size, key, "shmat()");
      return((char *)-1);
   }
   return(buffer);
}

int faildestroy_shm_buffer(id, seg_size, key)
int id, seg_size, key;
{
int err;

   err = shmctl(id, IPC_RMID, (struct shmid_ds *)0);
   if (err == 0) {
      shm_ga_fail("FAILDESTROY SHM BUFFER", id,
                    seg_size, key, "shmctl()");
      return(-1);
   }
   return(0);
}

int destroy_shm_buffer(id, seg_size, key)
int id, seg_size, key;
{
int err;

   err = shmctl(id, IPC_RMID, (struct shmid_ds *)0);
   if (err != 0) {
      shm_ga_fail("DESTROY SHM BUFFER", id,
                    seg_size, key, "shmctl()");
      return(-1);
   }
   return(0);
}

int get_existing_one_twice(buffer, id, SHMM_BUF_KEY, seg_size)
char **buffer;
int *id, SHMM_BUF_KEY, seg_size;
{

   fprintf(stderr, "   open (shmget()) --           ");
   if ((id[MAX_SEGS] = open_shm_buffer(seg_size, SHMM_BUF_KEY)) < 0)
      fprintf(stderr, "fail\n");
   else
      fprintf(stderr, "pass\n");

   fprintf(stderr, "   attach (shmat()) --          ");
   buffer[MAX_SEGS] =
         failget_shm_buffer(id[MAX_SEGS], seg_size, SHMM_BUF_KEY + MAX_SEGS);
   if (buffer[MAX_SEGS] != (char *)0)
      fprintf(stderr, "fail\n");
   else
      fprintf(stderr, "pass\n");
}

int create_and_attach_one_extra(buffer, id, SHMM_BUF_KEY, seg_size)
char **buffer;
int *id, SHMM_BUF_KEY, seg_size;
{

   fprintf(stderr, "   create (shmget()) --         ");
   if ((id[MAX_SEGS] = create_shm_buffer(seg_size,SHMM_BUF_KEY+MAX_SEGS)) < 0)
      fprintf(stderr, "fail\n");
   else
      fprintf(stderr, "pass\n");

   fprintf(stderr, "   attach (shmat()) --          ");
   buffer[MAX_SEGS] =
         failget_shm_buffer(id[MAX_SEGS], seg_size, SHMM_BUF_KEY + MAX_SEGS);
   if (buffer[MAX_SEGS] != (char *)0)
      fprintf(stderr, "fail\n");
   else
      fprintf(stderr, "pass\n");

   fprintf(stderr, "   detach (shmdt()) --          ");
   if (faildtch_shm_buffer(buffer[MAX_SEGS], id[MAX_SEGS], seg_size, SHMM_BUF_KEY + MAX_SEGS) != 0)
      fprintf(stderr, "fail\n");
   else
      fprintf(stderr, "pass\n");

   fprintf(stderr, "   destroy (shmctl()) --        ");
   if (destroy_shm_buffer(id[MAX_SEGS], seg_size, SHMM_BUF_KEY + MAX_SEGS) != 0)
      fprintf(stderr, "fail\n");
   else
      fprintf(stderr, "pass\n");
}

int detach_and_get_twice(buffer, id, SHMM_BUF_KEY, seg_size)
char **buffer;
int *id, SHMM_BUF_KEY, seg_size;
{

   fprintf(stderr, "   detach(shmdt()) --           ");
   if (dtch_shm_buffer(buffer[0], id[0], seg_size, SHMM_BUF_KEY) != 0)
      fprintf(stderr, "fail\n");
   else
      fprintf(stderr, "pass\n");

   fprintf(stderr, "   reattach(shmat()) --         ");
   if ((buffer[0] = get_shm_buffer(id[0],seg_size,SHMM_BUF_KEY)) == (char *)-1)
      fprintf(stderr, "fail\n");
   else
      fprintf(stderr, "pass\n");

   fprintf(stderr, "   attach again(shmat()) --     ");
   if (failget_shm_buffer(id[0], seg_size, SHMM_BUF_KEY) != 0)
      fprintf(stderr, "fail\n");
   else
      fprintf(stderr, "pass\n");
}

void main(argc, argv)
int argc;
char *argv[];
{
int c, ctr, iterations, SHMM_BUF_KEY, id[MAX_SEGS + 1], seg_size, i;
int nopass;
char *pg, *buffer[MAX_SEGS + 1];
extern char *optarg;
extern int optind;


   iterations=1;
   pg=argv[0];
   SHMM_BUF_KEY = getpid();
   seg_size = 256;

   while ((c=getopt(argc, argv, "c:")) != EOF) {
      switch (c) {
         case 'c':
                   iterations = atoi(optarg);
                   if (iterations == 0) {
                      fprintf(stdout, "%s : 1 BROK: -c option must be greater than zero\n", pg);
                      exit(1);
                   }
                   break;
         default:
                   fprintf(stdout, "%s:  1 BROK : bad option -%c\n", pg, optarg);
                   exit(1);
      }
   }
   
   /*  invalid_id_or_arguments();  */

   for (ctr=0, ctr < iterations; ctr++) {
       c=1;
       /*
       * attach_non_existent()
       */
       if (failget_shm_buffer(SHMM_BUF_KEY, 0, 0) != 0)
          fprintf(stdout, "%s : %d FAIL : Attach non-exisent segment SUCCEEDED\n", pg, c++);
       else
          fprintf(stdout, "%s : %d PASS : Attach non-exisent segment failed as expected\n", pg, c++);
       /*
       * detach_non_existent()
       */
       if (faildtch_shm_buffer(buffer[0], SHMM_BUF_KEY, 0, 0) != 0)
          fprintf(stdout, "%s : %d FAIL : Detach non-exisent segment SUCCEEDED\n", pg, c++);
       else
          fprintf(stdout, "%s : %d PASS : Detach non-exisent segment failed as expected\n", pg, c++);

       /*
       * destroy_non_existent()
       */
       if (faildestroy_shm_buffer(SHMM_BUF_KEY, 0, 0) != 0)
          fprintf(stdout, "%s : %d FAIL : Destroy non-exisent segment SUCCEEDED\n", pg, c++);
       else
          fprintf(stdout, "%s : %d PASS : Destroy non-exisent segment failed as expected\n", pg, c++);

       /*
       * create segments 
       */
       for (i = 0, nopass=0; i < MAX_SEGS; i++) {
           if ((id[i] = create_shm_buffer(seg_size, SHMM_BUF_KEY + i)) == -1) {
              nopass=1;
              break;
           }
       }
       if (nopass) {
          fprintf(stdout, "%s : %d FAIL : Creating %d shared memory segment Failed\n", pg, c++, MAX_SEGS);
          exit(1);
       } else {
          fprintf(stdout, "%s : %d PASS : Creating %d shared memory segment Failed\n", pg, c++, MAX_SEGS);
       }

       /*
       * Attach segments 
       */
       for (i = 0, nopass=0; i < MAX_SEGS; i++) {
           if ((buffer[i] = get_shm_buffer(id[i], seg_size, SHMM_BUF_KEY + i)) == (char *)-1) {
              nopass=1;
              break;
           }
       }
       if (nopass) {
          fprintf(stdout, "%s : %d FAIL : Attaching %d shared memory segment Failed\n", pg, c++, MAX_SEGS);
          exit(1);
       } else {
          fprintf(stdout, "%s : %d PASS : Attaching %d shared memory segment Failed\n", pg, c++, MAX_SEGS);
       }

       /*
       * Get one segment twice
       */
       if (failget_shm_buffer(id[1], seg_size, SHMM_BUF_KEY + 1) != 0)
          fprintf(stdout, "%s : %d FAIL : Getting %d shared memory segments Twice Failed\n", pg, c++, MAX_SEGS);
       else
          fprintf(stdout, "%s : %d PASS : Getting %d shared memory segments Twice\n", pg, c++, MAX_SEGS);

/********************************************************/

   fprintf(stderr, "Create and attach an extra segment --\n");
   create_and_attach_one_extra(buffer, id, SHMM_BUF_KEY, seg_size);

/********************************************************/

   fprintf(stderr, "Get existing segment twice --\n");
   get_existing_one_twice(buffer, id, SHMM_BUF_KEY, seg_size);

/********************************************************/

   fprintf(stderr, "Create existing segment twice --\n");
   fprintf(stderr, "   create (shmget()) --         ");
   if ((id[MAX_SEGS] = failcreate_shm_buffer(seg_size, SHMM_BUF_KEY)) != 0)
      fprintf(stderr, "fail\n");
   else
      fprintf(stderr, "pass\n");

/********************************************************/

   fprintf(stderr, "Detach and reattach twice --\n");
   detach_and_get_twice(buffer, id, SHMM_BUF_KEY, seg_size); 

/********************************************************/

   fprintf(stderr, "Detach segments(%d results) --\n", MAX_SEGS);
   fprintf(stderr, "   detach (shmdt()) --          ");
   for (i = 0; i < MAX_SEGS; i++) {
      if (dtch_shm_buffer(buffer[i], id[i], seg_size, SHMM_BUF_KEY + i) != 0)
         fprintf(stderr, "fail ");
      else
         fprintf(stderr, "pass ");
   }
   fprintf(stderr, "\n");

/********************************************************/

   fprintf(stderr, "Reattach segments(%d results) --\n", MAX_SEGS);
   fprintf(stderr, "   attach (shmat()) --          ");
   for (i = 0; i < MAX_SEGS; i++) {
      if ((buffer[i] = get_shm_buffer(id[i], seg_size, SHMM_BUF_KEY + i)) == (char *)-1)
         fprintf(stderr, "fail ");
      else
         fprintf(stderr, "pass ");
   }
   fprintf(stderr, "\n");

/********************************************************/

   fprintf(stderr, "Detach segments(%d results) --\n", MAX_SEGS);
   fprintf(stderr, "   detach (shmdt()) --          ");
   for (i = 0; i < MAX_SEGS; i++) {
      if (dtch_shm_buffer(buffer[i], id[i], seg_size, SHMM_BUF_KEY + i) != 0)
         fprintf(stderr, "fail ");
      else
         fprintf(stderr, "pass ");
   }
   fprintf(stderr, "\n");

/********************************************************/

   /* detach_detached(); */
   fprintf(stderr,"Detach detached segments(%d results) --\n",MAX_SEGS);
   fprintf(stderr, "   detach (shmdt()) --          ");
   for (i = 0; i < MAX_SEGS; i++) {
     if (faildtch_shm_buffer(buffer[i], id[i], seg_size, SHMM_BUF_KEY + i) != 0)
         fprintf(stderr, "fail ");
      else
         fprintf(stderr, "pass ");
   }
   fprintf(stderr, "\n");

/********************************************************/

   fprintf(stderr, "Destroy segements(%d results) --\n", MAX_SEGS);
   fprintf(stderr, "   destroy (shmctl()) --        ");
   for (i = 0; i < MAX_SEGS; i++) {
      if (destroy_shm_buffer(id[i], seg_size, SHMM_BUF_KEY + i) != 0)
         fprintf(stderr, "fail ");
      else
         fprintf(stderr, "pass ");
   }
   fprintf(stderr, "\n");

/********************************************************/

   /* destroy_destroyed(); */
   fprintf(stderr, "Destroy destroyed segements(%d results) --\n", MAX_SEGS);
   fprintf(stderr, "   destroy (shmctl()) --        ");
   for (i = 0; i < MAX_SEGS; i++) {
      if (faildestroy_shm_buffer(id[i], seg_size, SHMM_BUF_KEY + 0) != 0)
         fprintf(stderr, "fail ");
      else
         fprintf(stderr, "pass ");
   }
   fprintf(stderr, "\n");

/********************************************************/

   /* detach_destroyed(); */
   fprintf(stderr, "Detach destroyed segments(%d results) --\n", MAX_SEGS);
   fprintf(stderr, "   detach (shmdt()) --          ");
   for (i = 0; i < MAX_SEGS; i++) {
     if (faildtch_shm_buffer(buffer[i], id[i], seg_size, SHMM_BUF_KEY + i) != 0)
         fprintf(stderr, "fail ");
      else
         fprintf(stderr, "pass ");
   }
   fprintf(stderr, "\n");

/********************************************************/

   /*  attach_destroyed(); */
   fprintf(stderr, "Attach destroyed segments(%d results) --\n", MAX_SEGS);
   fprintf(stderr, "   attach (shmat()) --          ");
   for (i = 0; i < MAX_SEGS; i++) {
      if (failget_shm_buffer(id[i], seg_size, SHMM_BUF_KEY + i) != 0)
         fprintf(stderr, "fail ");
      else
         fprintf(stderr, "pass ");
   }
   fprintf(stderr, "\n");

/********************************************************/

   fprintf(stderr, "Open destroyed segments(%d results) --\n", MAX_SEGS);
   fprintf(stderr, "   open (shmget()) --           ");
   for (i = 0; i < MAX_SEGS; i++) {
      if ((id[i] = failopen_shm_buffer(seg_size, SHMM_BUF_KEY + i)) == -1)
         fprintf(stderr, "fail ");
      else
         fprintf(stderr, "pass ");
   }
   fprintf(stderr, "\n");

/********************************************************/

   fprintf(stderr, "Recreate segments(%d results) --\n", MAX_SEGS);
   fprintf(stderr, "   create (shmget()) --         ");
   for (i = 0; i < MAX_SEGS; i++) {
      if ((id[i] = create_shm_buffer(seg_size, SHMM_BUF_KEY + i)) == -1)
         fprintf(stderr, "fail ");
      else
         fprintf(stderr, "pass ");
   }
   fprintf(stderr, "\n");

/********************************************************/

   fprintf(stderr, "Destroy segements(%d results) --\n", MAX_SEGS);
   fprintf(stderr, "   destroy (shmctl()) --        ");
   for (i = 0; i < MAX_SEGS; i++) {
      if (destroy_shm_buffer(id[i], seg_size, SHMM_BUF_KEY + i) != 0)
         fprintf(stderr, "fail ");
      else
         fprintf(stderr, "pass ");
   }
   fprintf(stderr, "\n");

/********************************************************/

   if (error == 0) 
      printf("shmem_basics -- Test Passed\n");
   else
      printf("shmem_basics -- Test Failed\n");
 
   fflush(stdout);
   exit(error);
}

  
