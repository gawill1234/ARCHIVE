#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <ctype.h>
#include <time.h>
#include <signal.h>
#include <errno.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <sys/sem.h>
#include <sys/times.h>
#include <sys/errno.h>

#define KEY_BASE 700

#define LOCK_SEMA_BASE 300  /*  Key for lock semaphores  */
#define RSRC_SEMA_BASE 400  /*  Key for resource counter semaphores */

#define Q_NUM_Q_REF 0
#define Q_DAT_BYTE_REF 1
#define Q_NUM_MSG_REF 2

#define MAX_SEM 3

#define MAXMESGDATA (32768 - 1)
#define MAXMESSAGES 100
#define MAXQUEUES 40

#define MAXQDATA 4096
#define MAXMSGSIZE 2048

#define MAX_RCVRS MAXMESSAGES

#define MAL_AMT (MAXMSGSIZE - (sizeof(long) * 2))

struct mq_struct {
   long mtype;
   long rmtype;
   long msize;
   char text[MAL_AMT + 1];
};

int MSG_KEY = 0, RSRC_SEMA_KEY = 0;
int sleep_before_read = 0;

int nores = 0;
int quitonfail = 0;
int waitforever = 1;


/******************************************/
/*  Perform specified increment on specified semaphore.
*/
int sem_op(loc_id, value, which_sem)
int loc_id, value, which_sem;
{
struct sembuf op_op[1] = {
   0, 0, 0
};

   op_op[0].sem_op = value;
   op_op[0].sem_num = which_sem;

   if (semop(loc_id, &op_op[0], 1) != 0) {
      fprintf(stderr, "semop %d, %d, %d failed\n", loc_id, value, which_sem);
      return(-1);
   }
   return(0);
}

/*******************************************/
/*  Wait/Consume resources  (P)
*/
int pee(loc_id, which_sem)
int loc_id, which_sem;
{

   return(sem_op(loc_id, -1, which_sem));
}

int pee2(loc_id, which_sem, use_amt)
int loc_id, which_sem, use_amt;
{

   return(sem_op(loc_id, -(use_amt), which_sem));
}

void get_sem_vals(loc_id)
int loc_id;
{
int i;

   for (i = 0; i < MAX_SEM; i++) {
      printf("%d\n", semctl(loc_id, i, GETVAL, 0));
   }
}
   

/*******************************************/
/*  Free resources   (V)
*/
int vee(loc_id, which_sem)
int loc_id, which_sem;
{

   return(sem_op(loc_id, 1, which_sem));
}

int vee2(loc_id, which_sem, use_amt)
int loc_id, which_sem, use_amt;
{

   return(sem_op(loc_id, use_amt, which_sem));
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
   if (semop(loc_id, &op_lock[0], 2) != 0)
      return(-1);
   return(0);
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
   if (semop(loc_id, &op_unlock[0], 1) != 0)
      return(-1);
   return(0);
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
int rsrc_id;

   do {
      errno = 0;
      rsrc_id = semget(RSRC_SEMA_KEY, MAX_SEM, 0);
   } while ((errno == ENOENT) && (getppid() != 1));

   if (rsrc_id < 0) {
      fprintf(stderr, "semaphores NOT OPENED -- %d\n", errno);
      return(-1);
   }

   return(rsrc_id);
}

int sem_creat_all()
{
int rsrc_id;
ushort local[MAX_SEM];
union semun {
   int val;
   struct semid_ds *buf;
   ushort *array;
} geeky;

   local[Q_NUM_Q_REF] = MAXQUEUES;
   local[Q_DAT_BYTE_REF] = MAXMESGDATA;
   local[Q_NUM_MSG_REF] = MAXMESSAGES;


   if ((rsrc_id = semget(RSRC_SEMA_KEY, MAX_SEM, 0666 | IPC_CREAT)) < 0) {
      fprintf(stderr, "resource semaphores NOT CREATED -- %d\n", errno);
      return(-1);
   }

   geeky.array = local;

   if (semctl(rsrc_id, MAX_SEM, SETALL, geeky) < 0) {
      fprintf(stderr, "Semaphore initialization incorrect - %d\n", errno);
      return(-1);
   }

   return(rsrc_id);
}

/**************************************************/
/*   Create a message queue.
*/
int creat_msg_q()
{
int id;

   if ((id = msgget(MSG_KEY, 0666 | IPC_CREAT)) < 0) {
      fprintf(stderr, "ipcmsgq, CREATE MESSAGE QUEUE:  create failed\n");
   }

   return(id);
}

/**************************************************/
/*   Open a message queue.
*/
int open_msg_q()
{
int id;

   if ((id = msgget(MSG_KEY, 0)) < 0) {
      fprintf(stderr, "ipcmsgq, OPEN MESSAGE QUEUE:  open failed\n");
   }

   return(id);
}

/**************************************************/
/*  Send a message through a message queue
*/
int send_msg(goofy, q_id)
struct mq_struct *goofy;
int q_id;
{

#ifdef DEBUG
   printf("SND: %d   %d   %d   :%s:\n",
           goofy->mtype, goofy->rmtype, goofy->msize, goofy->text);
   fflush(stdout);
#endif

   if (msgsnd(q_id, (char *)&(goofy->mtype), goofy->msize, 0) != 0) {
      fprintf(stderr, "ipcmsgq, SEND MESSAGE:  send failed\n");
      return(-1);
   }
   return(0);
}

/**************************************************/
/*  Read a message from a message queue
*/
int recv_msg(goofy, q_id, buffer, mess_type)
struct mq_struct *goofy;
int q_id, mess_type;
char *buffer;
{
int size, loc_size;

   size = msgrcv(q_id, (char *)&(goofy->mtype), MAXMESGDATA, mess_type, 0);
   loc_size = strlen(goofy->text);

#ifdef DEBUG
   printf("RCV: %d   %d   %d   ->%s<-\n",
           goofy->mtype, goofy->rmtype, goofy->msize, goofy->text);
   fflush(stdout);

   if (loc_size != (goofy->msize - (sizeof(long) * 2))) {
     fprintf(stderr,"ipcmsgq/RECV:  String returned is wrong size\n");
   }

#endif

   if (loc_size < MAL_AMT) {
      memcpy(buffer, goofy->text, loc_size);
      buffer[loc_size] = '\0';
   }
   else {
      memcpy(buffer, goofy->text, MAL_AMT);
      buffer[MAL_AMT] = '\0';
   }

   if (size != goofy->msize) {
      if (size == (-1)) {
         fprintf(stderr, "ipcmsgq, RECV MESSAGE:  receive failed\n");
         return(size);
      }
      else {
         fprintf(stderr,"ipcmsgq/RECV:  structure is wrong size\n");
      }
   }  


   return(goofy->rmtype);
}

/**************************************************/
/*  Remove a message queue
*/
int destroy_msg_q(id)
int id;
{
  if (msgctl(id, IPC_RMID, (struct msqid_ds *)0) < 0) {
     fprintf(stderr, "ipcmsgq, DESTROY MESSAGE QUEUE:  remove failed\n");
     return(-1);
  }
  return(0);
}

/***************************************************/
/*  Set up and read from message queue.
*/
int read_from_q(sem_id, mess_type, q_id, buffer, send_back_type, from)
int sem_id, mess_type, q_id, send_back_type, from;
char *buffer;
{
int ret_type, i;
struct mq_struct goofy;

   goofy.mtype = mess_type;
   goofy.msize = 0;
   goofy.rmtype = send_back_type;

   for (i = 0; i < (MAL_AMT + 1); i++)
      goofy.text[i] = '\0';

   if (sleep_before_read > 0)
      sleep(sleep_before_read);

   ret_type = recv_msg(&goofy, q_id, buffer, mess_type);
   vee(sem_id, Q_NUM_MSG_REF);
   vee2(sem_id, Q_DAT_BYTE_REF, goofy.msize);
   if (from == 0)
      return((goofy.msize - (sizeof(long) * 2)));
   else
      return(goofy.rmtype);
}

/***************************************************/
/*  Set up and write from message queue.
*/
int write_to_q(sem_id, mess_type, q_id, buffer, send_back_type)
int sem_id, mess_type, q_id, send_back_type;
char *buffer;
{
int ret_type, lenb;
struct mq_struct goofy;

   lenb = strlen(buffer);
   memcpy(goofy.text, buffer, lenb);
   goofy.text[lenb] = '\0';
   goofy.mtype = mess_type;
   goofy.rmtype = send_back_type;
   goofy.msize = strlen(buffer) + (sizeof(long) * 2);

   pee2(sem_id, Q_DAT_BYTE_REF, goofy.msize);
   pee(sem_id, Q_NUM_MSG_REF);
   ret_type = send_msg(&goofy, q_id);
   return(ret_type);
}
char *set_res(buffer, i_in, send_back_type)
char *buffer;
int i_in, send_back_type;
{
int i, j;

   for (i = 0; i < MAL_AMT; i ++)
      buffer[i] = '\0';

   sprintf(buffer, "->%d %d<-", i_in, send_back_type);


   j = 65;
   for (i  = strlen(buffer); i < MAL_AMT; i++) {
      buffer[i] = (char)j;
      j++;
      if (j > 90)
         j = 65;
   }

#ifdef DEBUG_DETAIL
   printf("SET_UP_STRING: %d  :%s:\n", strlen(buffer), buffer);
   fflush(stdout);
#endif

   return(buffer);
}


void alarm_hndlr()
{
   fprintf(stderr, "ipcmsgq:  Queue read/write time for child expired\n");
   _exit(-1);
}

/**************************************************************/
/*  Check the length and contents of the sent and returned
    string to make sure they match.
*/
int check_res(buffa, buffb, location)
char *buffa, *buffb, *location;
{
int lena, lenb, pass;

   pass = 0;

   lena = strlen(buffa);
   lenb = strlen(buffb);
   if (lena != lenb) {
      if (nores == 0)
         fprintf(stderr,
              "ipcmsgq/%s: Problem with data length, A%d/E%d\n",
               location, lena, lenb);
      pass--;
   }

   if (strcmp(buffa, buffb) != 0) {
      if (nores == 0) {
         fprintf(stderr, "ipcmsgq/%s: Problem with data content\n", location);
         fprintf(stderr, "  %s/MESG Q BUFFER DATA:  :%s:\n", location, buffa);
         fprintf(stderr, "  %s/STORED BUFFER DATA:  :%s:\n", location, buffb);
      }
      pass--;
   }

   return(pass);
}

/**************************************************************/
/*  This is the child that reads a message from the queue
    (of the proper type, of course) and rewrites it to the
    queue for the parent to reread.
*/
int youngest_child(sem_id, mess_type, send_back_type, runtime)
int sem_id, mess_type, send_back_type, runtime;
{
int id, pass, elen;
char *buffer, *calc_buffer;
void alarm_hndlr();

   pass = 0;
   if ((id = open_msg_q()) == (-1)) {
      return(-1);
   }
   else {

      if (waitforever == 0) {
         signal(SIGALRM, &alarm_hndlr);
         if (runtime < 30)
            runtime = runtime * 2;
         alarm(runtime);
      }

      buffer = (char *)calloc(MAL_AMT + 1, 1);
      calc_buffer = (char *)calloc(MAL_AMT + 1, 1);
      calc_buffer = set_res(calc_buffer, mess_type - 1, send_back_type);

      /*******************************************/
      /*  Read the message off the queue
      */
      elen = read_from_q(sem_id, mess_type, id, buffer, send_back_type, 0);
      calc_buffer[elen] = '\0';

      /*******************************************/
      /*  check the content of the message
      */
      if (check_res(buffer, calc_buffer, "YC") != 0) {
         free(buffer);
         buffer = calc_buffer;
      }
      else {
         free(calc_buffer);
      }

      /*******************************************/
      /*  Rewrite it to the queue
      */
      write_to_q(sem_id, send_back_type, id, buffer, mess_type);

      free(buffer);
   }
   return(pass);
}


/**************************************************************/
/*
*/
int do_youngest(sem_id, send_back_type, start_val, num_rcvrs, runtime)
int sem_id, send_back_type, start_val, num_rcvrs, runtime;
{
int i;

   if (start_val < 0)
      start_val = 0;
   if (num_rcvrs < 0)
      num_rcvrs = 0;

   for (i = start_val; i < num_rcvrs; i++) {
      if (fork() == 0) {
         _exit(youngest_child(sem_id, i + 1, send_back_type, runtime));
      }
   }
   return(0);
}



/**************************************************************/
/*  Generate the string to send to children and copy it
    into a compare buffer to be used in check_res().  Send
    the buffer to the message queue.
*/
int send_shit(buffer_arr, sem_id, id, send_back_type, num_rcvrs)
char **buffer_arr;
int sem_id, id, send_back_type, num_rcvrs;
{
int i, pass;

   pass = 0;

   for (i = 0; i < num_rcvrs; i++) {
      /********************************************/
      /*  Write a buffer to a message queue.
      */
      if (write_to_q(sem_id, i + 1, id, buffer_arr[i], send_back_type) != 0)
         pass--;
   }

   if (pass != 0)
      fprintf(stderr, "ipcmsgq: Some data senders failed\n");

   return(pass);
}

/**************************************************************/
/*  Read the string sent from the child to the parent.  Call 
    check_res() using the returned buffer and the compare buffer
    created above.  Free buffers.  Make sure the correct number
    of children returned data.
*/

int get_shit(buffer_arr, sem_id, id, send_back_type, num_sent, cpid)
char **buffer_arr;
int sem_id, id, send_back_type, num_sent, cpid;
{
int ret_cnt = 0, pass = 0, chk_type, apid;
char *buffer;
union {
   struct {
#ifdef CRAY
      unsigned unused:48, sherr:8, sigid:8;
#else
      unsigned unused:16, sherr:8, sigid:8;
#endif
   } err;
   int retval;
} errstruct;


   buffer = (char *)calloc(MAL_AMT + 1, 1);

   while ((apid = wait(&errstruct.retval)) != (-1)) {
      if (apid != cpid) {
         if (errstruct.err.sherr == 0) {
            /********************************************/
            /*  Read the data from the message queue
            */
            chk_type = read_from_q(sem_id, send_back_type, id, buffer, 99, 1);

            if (chk_type > 0) {
               /********************************************/
               /*  Compare received data with data stored for comparison
                   purposes.
               */
               pass = pass + check_res(buffer, buffer_arr[chk_type - 1], "GS");
   
               /********************************************/
               /*  Free the memory holding the stored compare string
               */
               free(buffer_arr[chk_type - 1]);
            }
            else {
               pass--;
            }
         }
         else {
            pass--;
         }
         ret_cnt++;
      }
   }

   free(buffer);

   if (ret_cnt != num_sent) {
      fprintf(stderr, "ipcmsgq: Wrong number of queues reread - %d/%d/%d\n",
              ret_cnt, num_sent, send_back_type);
      pass--;
   }

   return(pass);
}


/**************************************************************/
/*
*/
int do_middle(runtime, num_rcvrs)
int runtime, num_rcvrs;
{
int sem_id, send_back_type, id, i, pass, loops, random;
char *buffer_arr[MAX_RCVRS];
int elapsed, fixed_time, realtime, done, cpid;
struct tms tbuffer;
void srand48();
double drand48();

   srand48(time((long *)0));

   cpid = loops = done = pass = 0;

   /********************************************/
   /*  Open all semaphores.
   */
   if ((sem_id = sem_open_all()) < 0)
      return(sem_id);

   /********************************************/
   /*  Message queue return trip data type.
   */
   send_back_type = getpid();

   /********************************************/
   /*  Decrement the number of available message queues
   */
   pee(sem_id, Q_NUM_Q_REF);

   /********************************************/
   /*  Create a message queue
   */
   if ((id = creat_msg_q()) == (-1)) {
      pass--;
   }
   else {

      fixed_time = times(&tbuffer);
      do {
         loops++;
         /********************************************/
         /*  Start the children which will receive and
             return the message queue data. (We're multiplexing
             here.  This group will open the queue BEFORE data
             is sent to it.
         */
         do_youngest(sem_id, send_back_type, 0, num_rcvrs - 2, runtime);
   
         /********************************************/
         /*  Put space in the compare buffer array.
         */
         for (i = 0; i < num_rcvrs; i++) {
            /********************************************/
            /*  Get length of this message.
            */
            random = (int)(drand48() * (float)MAL_AMT);

            /********************************************/
            /*  Get initialized memory for this message.
            */
            buffer_arr[i] = (char *)calloc(MAL_AMT + 1, 1);

           /********************************************/
           /*  Put data to a storage buffer to be used
               to compare sent and incoming data.
           */
            buffer_arr[i] = set_res(buffer_arr[i], i, send_back_type);

            /********************************************/
            /*  Set length of this message.
            */
            buffer_arr[i][random] = '\0';
         }

         /********************************************/
         /*  Send data over the message queue
         */
         do {
            if ((cpid = fork()) == 0) {
               send_shit(buffer_arr, sem_id, id, send_back_type, num_rcvrs);
               _exit(0);
            }
         } while (cpid < 0);

         /********************************************/
         /*  Start the children which will receive and
             return the message queue data. (We're multiplexing
             here.  This group will open the queue AFTER data
             is sent to it.
         */
         do_youngest(sem_id, send_back_type, num_rcvrs - 2, num_rcvrs, runtime);

         /********************************************/
         /*  Get data from the message queue
         */
         pass = pass +
              get_shit(buffer_arr, sem_id, id, send_back_type, num_rcvrs, cpid);

         realtime = times(&tbuffer);
         elapsed = realtime - fixed_time;
         if ((elapsed / CLOCKS_PER_SEC) >= runtime)
            done++;

         if (quitonfail == 0)
            if (pass != 0)
               done++;

      } while (!done);

      /********************************************/
      /*  Destroy a message queue.
      */
      pass = pass + destroy_msg_q(id);
   }

   /********************************************/
   /*   Increment the number of available message queues.
   */
   vee(sem_id, Q_NUM_Q_REF);

   printf("ipcmsgq:  %d completed %d loops\n", send_back_type, loops);

   return(pass);
}


/**************************************************************/
/*
*/
int fork_msg_ctrl(num_to_fork, runtime, num_rcvrs)
int num_to_fork, runtime, num_rcvrs;
{
int pass, sem_id, i;
union {
   struct {
#ifdef CRAY
      unsigned unused:48, sherr:8, sigid:8;
#else
      unsigned unused:16, sherr:8, sigid:8;
#endif
   } err;
   int retval;
} errstruct;


   pass = 0;

   RSRC_SEMA_KEY = getpid() + RSRC_SEMA_BASE;
   sem_id = sem_creat_all();

   for (i = 0; i < num_to_fork; i++) {
      if (fork() == 0) {
         MSG_KEY = getpid() + KEY_BASE;

         _exit(do_middle(runtime, num_rcvrs));
      }
   }

   while (wait(&errstruct.retval) != (-1)) {
      if (errstruct.err.sherr != 0)
         pass--; 
   }

   sem_rm_all(sem_id);
   return(pass);
}

/**************************************************************/
/*
*/
main(argc, argv)
int argc;
char **argv;
{
int num_to_fork, pass, runtime, num_rcvrs;
int getopt(), c;

extern char *optarg;
extern int optind;

static char *optstring = "t:f:r:RQS:W";

   pass = 0;

   num_to_fork = 5;
   runtime = 30;
   num_rcvrs = 10;

   while ((c=getopt(argc, argv, optstring)) != EOF) {
      switch (c) {
         case 'W':
                   waitforever = 0;
                   break;

         case 'S':
                   sleep_before_read = atoi(optarg);
                   break;
                   
         case 'R':
                   nores = 1;
                   break;

         case 'Q':
                   quitonfail = 1;
                   break;

         case 't':
                   runtime = atoi(optarg);
                   break;

         case 'f':
                   num_to_fork = atoi(optarg);
                   break;

         case 'r':
                   num_rcvrs = atoi(optarg);
                   break;

         default:
                   fprintf(stderr, "ipcmsgq:  bad option\n");
                   exit(1);
      }
   }

   if (num_rcvrs > MAX_RCVRS)
      num_rcvrs = MAX_RCVRS;

   pass = fork_msg_ctrl(num_to_fork, runtime, num_rcvrs);
   if (pass == 0)
      fprintf(stdout, "ipcmsgq - Test Passed\n");
   else
      fprintf(stdout, "ipcmsgq - Test Failed\n");

   exit(pass);
}
