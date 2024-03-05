#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <sys/ipc.h>
#include <sys/sem.h>

#define MAX_FILES 8

char *filelist[MAX_FILES];
char camefrom[2][7] = {'C', 'L', 'I', 'E', 'N', 'T', '\0',
                       'S', 'E', 'R', 'V', 'E', 'R', '\0'};

int num_files, glob_id, client_pid, param_proc, param_max_proc;
int num_passes, PROC_SEM, SEMA_SEM, MAX_SEM;
key_t KEY;

/******************************************/
/*  Perform specified increment on specified semaphore.
*/
int sem_op(loc_id, value, which_sem)
int loc_id, value, which_sem;
{
struct sembuf op_op[1] = {
/*   0, 0, SEM_UNDO */
   0, 0, 0
};

   op_op[0].sem_op = value;
   op_op[0].sem_num = which_sem;

   semop(loc_id, &op_op[0], 1);
}

/*******************************************/
/*  Wait/Consume resources  (P)
*/
int pee(loc_id, which_sem)
int loc_id, which_sem;
{

   sem_op(loc_id, -1, which_sem);
}

/*******************************************/
/*  Free resources   (V)
*/
int vee(loc_id, which_sem)
int loc_id, which_sem;
{


   sem_op(loc_id, 1, which_sem);
}

/*******************************************/
/*  Lock the specified semaphore
*/
int lockit(loc_id, which_sem)
int loc_id, which_sem;
{
struct sembuf op_lock[2] = {
   0, 0, 0,                   /* Wait for semaphore to be 0  */
   0, 1, SEM_UNDO             /* Increment semaphore by 1  */
};

   op_lock[0].sem_num = op_lock[1].sem_num = which_sem;
   semop(loc_id, &op_lock[0], 2);
}

/********************************************/
/*  Unlock the specified semaphore
*/
int unlockit(loc_id, which_sem)
int loc_id, which_sem;
{
struct sembuf op_unlock[1] = {
   0, -1, (IPC_NOWAIT | SEM_UNDO)  /* Decrement semaphore by 1 */
};                                 /* Return is immediate, SEM_UNDO */
                                   /* ensures decrement happens even */
                                   /* after process exits      */

   op_unlock[0].sem_num = which_sem;
   semop(loc_id, &op_unlock[0], 1);
}

/****************************************/
/*  Remove the semaphore specified by the
    local id
*/
int sem_rm_all(local_id)
int local_id;
{
   semctl(local_id, 0, IPC_RMID, 0);
}

/****************************************************/
/*  The file that is created will always have a size of 0
    unless there is a semaphore problem.  If there is a problem,
    the failure data will be put into the file and the file will
    not be unlinked.
*/
int do_child_stuff(source)
int source;
{
int loc_pid, id, ppid, proc_val, flckval, pass;
char filename[80];
FILE *fp;

   pass = 0;
   loc_pid = getpid();
   ppid = getppid();

   id = loc_pid % num_files;
   sprintf(filename, "%s\0", filelist[id]);

   lockit(glob_id, id);
   fp = fopen(filename, "a+");

   if (fp == NULL) {
      unlockit(glob_id, id);
      printf("Could not open file\n");
      return(-1);
   }

   proc_val = semctl(glob_id, PROC_SEM, GETVAL, 0);
   flckval = semctl(glob_id, id, GETVAL, 0);

   chmod(filename, 0660);

   if ((proc_val > (param_max_proc - 2)) || (proc_val < 0) || (flckval != 1)) {
      fprintf(fp, "FAIL   PID = %d/%d,  NUM SEMS = %d,  LOCK SEM = %d, ID = %d, %s\n",
           loc_pid, ppid, proc_val, flckval, id, camefrom[source]);
      pass--;
   }
#ifdef DEBUG
   else {
      fprintf(fp, "PASS   PID = %d/%d,  NUM SEMS = %d,  LOCK SEM = %d, %s\n",
           loc_pid, ppid, proc_val, flckval, camefrom[source]);
   }
#endif

   fclose(fp);
   unlockit(glob_id, id);

   return(pass);
}

int do_fork_loop(source)
int source;
{
int i, childpid, retpid, pass;
union {
   struct {
#ifdef NOTCRAY
      unsigned unused:16, sherr:8, sigid:8;
#else
      unsigned unused:48, sherr:8, sigid:8;
#endif
   } err;
   int retval;
} errstruct;

   pass = 0;
 
   for (i = 0; i < param_proc; i++) {
      while (semctl(glob_id, PROC_SEM, GETVAL, 0) <= 0) {
         retpid = waitpid(0, &errstruct.retval, WNOHANG);
         if (retpid > 0) {
            if (retpid != client_pid)
               vee(glob_id, PROC_SEM);
            if (errstruct.err.sherr != 0)
               pass--;
         }
      }
      pee(glob_id, PROC_SEM);
      if ((childpid = fork()) == 0) {
         _exit(do_child_stuff(source));
      }
      if (childpid < 0)
         vee(glob_id, PROC_SEM);

      while ((retpid = waitpid(0, &errstruct.retval, WNOHANG)) > 0) {
         if (retpid != client_pid)
            vee(glob_id, PROC_SEM);
         if (errstruct.err.sherr != 0)
            pass--;
      }
   }

   while((retpid = wait(&errstruct.retval)) > 0) {
      if (retpid != client_pid)
         vee(glob_id, PROC_SEM);
      if (errstruct.err.sherr != 0)
         pass--;
   }

   return(pass);
}


int sem_open_all()
{
int i;

   do {
      errno = 0;
      glob_id = semget(KEY, MAX_SEM, 0);
   } while ((errno == ENOENT) && (getppid() != 1));

   if (glob_id < 0) {
      printf("NOT OPENED -- %d\n", errno);
      _exit(-1);
   }
}

int sem_creat_all()
{
FILE *idfp;
union semun {
   int val;
   struct semid_ds *buf;
   ushort *array;
} geeky;


   if ((glob_id = semget(KEY, MAX_SEM, 0666 | IPC_CREAT)) < 0) {
      printf("NOT CREATED -- %d/%d/%d\n", errno, KEY, glob_id);
      _exit(-1);
   }

   idfp = fopen("id_file", "a+");
   if (idfp != NULL) {
      fprintf(idfp, "KEY/ID = %d/%d\n", KEY, glob_id);
      fflush(idfp);
      fclose(idfp);
   }

   geeky.val = param_max_proc;
   if (semctl(glob_id, PROC_SEM, SETVAL, geeky) < 0)
      return(-1);
}

client_main()
{
   sem_open_all();
   pee(glob_id, SEMA_SEM);
   pee(glob_id, PROC_SEM);

   _exit(do_fork_loop(0));
}

int server_main()
{
int pass = 0;
union {
   struct {
#ifdef NOTCRAY
      unsigned unused:16, sherr:8, sigid:8;
#else
      unsigned unused:48, sherr:8, sigid:8;
#endif
   } err;
   int retval;
} errstruct;

   sem_creat_all();
   vee(glob_id, SEMA_SEM);
   pee(glob_id, PROC_SEM);

   pass = pass + do_fork_loop(1);

   while(wait(&errstruct.retval) > 0) {
      vee(glob_id, PROC_SEM);
      if (errstruct.err.sherr != 0)
         pass--;
   }
   vee(glob_id, PROC_SEM);
   sem_rm_all(glob_id);

   return(pass);
}

int individual_run()
{
int i, pass = 0;
struct stat buf;
char *getcwd();


   KEY = 400 + getpid();

   for (i = 0; i < num_files; i++) {
      filelist[i] = (char *)tempnam(getcwd((char *)NULL, 80), "sem");
   }

   for (i = 0; i < num_passes; i++) {
      if ((client_pid = fork()) == 0)
         client_main();

      pass = pass + server_main();
   }

   for (i = 0; i < num_files; i++) {
      stat(filelist[i], &buf);
      if (buf.st_size != 0)
        pass--;
      else
        unlink(filelist[i]);
   }

   return(pass);
}

main(argc, argv)
int argc;
char **argv;
{
int i, pass = 0, num_run;
static char *optstring = "f:P:p:t:r:";
int c;

extern char *optarg;
extern int optind, optopt;

union {
   struct {
#ifdef NOTCRAY
      unsigned unused:16, sherr:8, sigid:8;
#else
      unsigned unused:48, sherr:8, sigid:8;
#endif
   } err;
   int retval;
} errstruct;

   glob_id = -1;
   client_pid = 0;

   num_run = num_passes = num_files = 5;

   param_max_proc = 50;
   param_proc = 100;

   while ((c=getopt(argc, argv, optstring)) != EOF) {
      switch (c) {
         case 'P':
                   param_proc = atoi(optarg);
                   break;

         case 'p':
                   param_max_proc = atoi(optarg);
                   break;

         case 't':
                   num_passes = atoi(optarg);
                   break;

         case 'r':
                   num_run = atoi(optarg);
                   break;

         case 'f':
                   num_files = atoi(optarg);
                   break;

         default:
                   fprintf(stderr,
                       "ipcsema:  Bad option - %c. Continuing with defaults\n",
                        optopt);
                   break;
      }
   }

   if (num_files > MAX_FILES)
      num_files = MAX_FILES;

   PROC_SEM = num_files;
   SEMA_SEM = num_files + 1;
   MAX_SEM = num_files + 2;

   if (param_max_proc > param_proc)
      param_max_proc = param_proc;

   for (i = 0; i < num_run; i++) {
      if (fork() == 0) {
         _exit(individual_run());
      }
   }

   while (wait(&errstruct.retval) != (-1)) {
      if (errstruct.err.sherr != 0)
         pass--;
   }

   if (pass == 0) {
      unlink("id_file");
      printf("ipcsema:  Test Passed\n");
   }
   else {
      printf("ipcsema:  Test Failed\n");
   }

   exit(pass);
}

