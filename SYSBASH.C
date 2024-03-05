#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
/* #include <category.h> */
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "sysbash.h"

/*
************************************************
* A very special declaration taken from unistd.h
************************************************
*/
extern char *getcwd(char *_Buf, size_t _Size);

/*
*****************************************
* level 0 = no debug
* level 1 = minimal messaging level
* level 2 = a tad more messaging level
* level 3 = medium messaging level
* level 4 = major messaging level
* level 5 = high messaging level
* level 6 = should I hold your hand too??
*****************************************
*/
int DEBUG_LEVEL=0;
#define DEBUG(a) if (a <= DEBUG_LEVEL)

#define ALARM_SEED             3
#define MAX_PARAM             20
#define SY_MAX_PATH        10000
#define MAX_PROCESS          100
#define RANGE               1000
#define DIRNAME             "RAM"
#define SYSCALL_DATA        "sysbash.dat"
#define OPTIONS             "hTNoR:a:b:c:d:e:f:F:i:l:n:p:r:s:S:t:w:x:z:"


void usage();
char *get_param_name(int ptype);

/*
**************************
* Declare global variables
**************************
*/
char *Pg, *FileName, *Dir_Name, *SyscallList, *ScriptName;
char MonitorScript[256];
int Alarm_Seed, Copies, Initial_Sc, End_Sc, Range_Value, Make_Test_Case;
int End_Seed_Value, Max_Range_Value, Sy_Param1, Scew_Value, Param_Num;
int Master_Pid, Sub_Level, Weight, Iterations, Init_Seed_Value, Cur_Seed_Value;
int My_Pid, Allow_Negatives, Sy_Data_Max, End_Usr_Sc, Fork_Counter, Fork_Limit;
int MonitorPid, Random_Filenames;
long Seed_Value;
struct tsy_data Sy_Data_Head;
struct tsy_data *Sy_Data_Current;
struct system_calls *Sy_Call_Ptrs[MAX_SYS_CALL];

extern int init_filenames(char *filename);

#define PT_UNKNOWN             1
#define PT_CHAR_S_PATH         2
#define PT_INT_FILDES          3
#define PT_CHAR_S_FNAME        4
#define PT_VOID                5
#define PT_SOCKADDR            6
#define PT_CONST_S_PATH        7
#define PT_MODE_T_MODE         8
#define PT_INT_STATUS          9
#define PT_INT_NAMELEN        10
#define PT_CHAR_S_BUF         11
#define PT_INT_LEN            12
#define PT_INT_BUFSIZE        13
#define PT_UID_T_UID          14
#define PT_STAT_S_BUF         15

struct tsy_data {
   int id;
   char *buffer;
   char *rc_type;
   char *name;
   int param[MAX_PARAM];
   struct tsy_data *next;
};

/*
*******************************************
* Define an monitor shell script controller
*******************************************
*/
static char *MonitorCode[] = {
 "zombie=$1\nshift 1\nwhile true\ndo\nsleep 30\n",
 "a=`ps -le | grep $zombie | awk '{print $4,$5}'`\n",
 "set $a\nfor x in $*\ndo\nif [ $x -eq 1 ]\nthen\n",
 "kill -9 $prev\nelse\nprev=$x\nfi\ndone\n" 
 "rm -rf `/bin/pwd`/core*\ndone\n" 
};

/*
**********************************
* handle_sigs - Catch signals here
**********************************
*/
void handle_sigs(int signo)
{
   static int howmany=0;
   /*
   *******************************
   * If we get siguser1 or sigint, 
   * kill the whole group
   *******************************
   */
   if (signo == SIGUSR1 || signo == SIGINT) {
      if (Master_Pid == getpid()) {
          fprintf(stdout, "About to kill(0, SIGKILL) : current process leader(%d)/group\n", Master_Pid);
          fflush(stdout);
          fflush(stderr);
          unlink(MonitorScript);
          kill(MonitorPid, SIGKILL);
          sprintf(MonitorScript, "rm -rf ./core*");
          system(MonitorScript);
      }
      kill(0, SIGKILL);
      exit(1);
   }
   
   /*
   *****************************
   * If we get SIGALRM, continue
   * for a few more times
   *****************************
   */
   if (signo == SIGALRM) {
      howmany++;
      DEBUG(3) { fprintf(stdout, "%s : PID %d : SIGALRM HIT\n", Pg, getpid());
                 fflush(stdout); }
      if (howmany < 5) {
         (void) signal(SIGALRM, handle_sigs);  /* reset signal handler */
         if (! Alarm_Seed)
            Alarm_Seed=ALARM_SEED;
         alarm(Alarm_Seed);
         return;
      }
   }
   exit(0);
}
 
/*
****************************************
* usage - Print out program capabilities
****************************************
*/
void usage()
{
    printf("\nusage: %s [-hTNoRT] [-a Alarm_Seed] [-b Start_Sc] [-c Copies] [-d Debug]\n", Pg);
    printf("            [-e End_Sc] [-f FileName] [-F Fork_Limit] [-i Number] [-l Level] [-n Dir_Name]\n");
    printf("            [-p Range] [-r Range] [-s Seed] [-S system_call[,system_call,...]]\n");
    printf("            [-t Script_FileName] [-w Weight] [-x Medium] [-z Seed]\n");
    printf("\n     where option meanings are:\n");
    printf("            -a      (Def=%d) Seconds Children Processes Are Active\n", ALARM_SEED);
    printf("            -b      (Def=0) Starting System Call Number\n");
    printf("            -c      (Def=1) Number Of Parallel Copies To Run\n");
    printf("            -d      (Def=0) Debug Level (Use 0 through 6)\n");
    printf("            -e      (Def=%d) Ending System Call Number\n", MAX_SYS_CALL);
    printf("            -f      FileName To Use For Disk File System Calls\n");
    printf("            -F      Maximum Concurrent Fork Limit Value\n");
    printf("            -h      The Help Message\n");
    printf("            -i      [DEF=1] Maximum Number Of Iterations(Looping Mode)\n");
    printf("            -l      [DEF=5] Levels Of Subdirs To Create\n");
    printf("            -n      [DEF=%s] Name Of Subdirs\n", DIRNAME);
    printf("            -N      Allow Negative Argument Values\n");
    printf("            -o      Toggle Number Of System Call Parameters To 11\n");
    printf("            -p      (Def=%d) Range For First Parameter To Sys_Call\n", RANGE);
    printf("            -r      (Def=%d) Range For Random Numbers\n", RANGE);
    printf("            -R      Use Random Number Generator For Disk Filenames\n");
    printf("            -s      (Def=1) Starting Seed For Random Number Generator\n");
    printf("            -S      Use coma delimited system call list only\n");
    printf("            -t      Use This To Create Test Script File\n");
    printf("            -T      Use Current Time As Seed For Random Number Generator\n");
    printf("            -w      [DEF=100] 0-100 Percent Weighting Towards Randoms\n");
    printf("            -x      Used To Scew Random Numbers Toward Zero\n");
    printf("            -z      (Def=0) Ending Seed, 0 Means Run Forever\n");
    printf("\n");
    exit(1);
}

/*
**************************************
* A function to select specific system
* calls for random number argument
* generations
**************************************
*/
int get_system_calls(char *sname)
{
   int a=0,b,i,len1,len2;
   char *ptr, *r;

   ptr=sname;

   /* bzero the array */
   for (i=0; i < MAX_SYS_CALL; i++) {
       Sy_Call_Ptrs[i]='\0';
   }
   while (*ptr) {
       /*
       ******************************************
       * Handle subset matches via string lengths
       * Should also speed up due to strlens
       * being done when necessary below
       ******************************************
       */
       if ((r=strchr(ptr,(int)','))) 
          len1=r-ptr;
       else
          len1=strlen(ptr);
       for (b=i=0; i < MAX_SYS_CALL; i++) {
           len2=strlen(scalls[i].sy_name); 
           if (len1 != len2)
              continue;
           /*
           ************************************************
           * Match system call name to name in scalls table
           ************************************************
           */
           if (strncmp(ptr, scalls[i].sy_name, strlen(scalls[i].sy_name)) == 0) {
              Sy_Call_Ptrs[a++]=&scalls[i];
              if (strchr(ptr,(int)','))
                 ptr+=(strlen(scalls[i].sy_name)+1);
              else
                 ptr+=strlen(scalls[i].sy_name);
              b=1;
              End_Usr_Sc++;
              break;
           }
       }
       /*
       ***************************
       * Not found in scalls table
       ***************************
       */
       if (! b) {
          fprintf(stdout, "%s NOT FOUND IN SYSTEM CALL TABLE\n", ptr);
          fflush(stdout);
          return(0);
       }
   }

   /*
   ************************************
   * If no matches at all, return error
   ************************************
   */
   if (! Sy_Call_Ptrs[0]) {
      return(0);
   } else {
      return(1);
   }
}



/*
******
* MAIN
******
*/

main(int argc, char **argv)
{
   extern int optind, opterr;
   extern char *optarg;
   char *args;                             /* ptr to string-rep of all args */
   int c;
   /* int Max_Range_Value = 1999999999; */       /* Do we really need this ? */
   int sy_pset = FALSE;

   if ((Pg = (char *) strrchr(argv[0], '/')) == NULL) {
       Pg = argv[0];
   } else {
      ++Pg;
   }
   /*
   *****************************************
   * Set up default run time variable values
   *****************************************
   */
   Alarm_Seed=0;           /* Seconds for anything to execute: 0 = infinite */
   Allow_Negatives=0;         /* Default Argument State */
   Copies=1;               /* Number of parallel copies */
   Dir_Name=DIRNAME;       /* Name to use for subdirectorys */
   End_Usr_Sc=0;           /* Default value when -S not utilized */
   End_Sc=MAX_SYS_CALL;    /* Ending system call number */
   End_Seed_Value=0;       /* Ending seed for random number generator */ 
   FileName=NULL;          /* No FileName specified */
   Fork_Counter=0;         /* Default Value */ 
   Fork_Limit=0;           /* Set via -F argument */ 
   Iterations=1;           /* Number of maximum Iterations */
   Initial_Sc=0;           /* Starting system call number */
   Make_Test_Case=FALSE;   /* Skip creating test case file */
   Master_Pid=getpid();    /* Original process pid */
   Param_Num=FALSE;
   Random_Filenames=0;     /* Default: -R option */
   Range_Value=1000;       /* Range for random numbers */
   Scew_Value=RANGE;       /* Set scew value to have no effect */
   Seed_Value=1;           /* Start seed for random number generator */
   Sub_Level=0;            /* Basically disables this option */
   Sy_Call_Ptrs[0]='\0';   /* Default: Use All system calls */
   SyscallList=NULL;       /* Default */
   Sy_Param1=RANGE;        /* Set parameter 1 to range */
   Weight=100;      


   while ((c = getopt(argc, argv, OPTIONS)) != -1) {
         switch(c) {
              case 'a':
                      Alarm_Seed = atoi(optarg);
                      break;
              case 'b':
                      Initial_Sc = atoi(optarg);
                      break;
              case 'c':
                      Copies = atoi(optarg);
                      break;
              case 'd':
                      DEBUG_LEVEL = atoi(optarg);
                      break;
              case 'e':
                      End_Sc = atoi(optarg);
                      break;
              case 'f':
                      FileName = optarg;
                      if (strlen(FileName) > MAX_FILESIZE) {
                         fprintf(stdout, "%s : -f %s > MAX File Name Length of %d\n", Pg, optarg, MAX_FILESIZE);
                         exit(1);
                      }
                      break;
              case 'F':
                      Fork_Limit = atoi(optarg);
                      if (Fork_Limit > MAX_PROCESS)
                         Fork_Limit=MAX_PROCESS;
                      break;
              case 'h':
                      usage();
                      break;
              case 'i':
                      Iterations = atoi(optarg);
                      break;
              case 'l':
                      Sub_Level = atoi(optarg);
                      break;
              case 'n':
                      Dir_Name = optarg;
                      break;
              case 'N':
                      Allow_Negatives++;
                      break;
              case 'o':
                      Param_Num = atoi(optarg);
                      break;
              case 'p':
                      Sy_Param1 = atoi(optarg);
                      sy_pset = TRUE;
                      break;
              case 'r':
                      Range_Value = atoi(optarg);
                      if (sy_pset == FALSE) Sy_Param1 = Range_Value;
                      break;
              case 'R':
                      Random_Filenames=1;
                      break;
              case 's':
                      Seed_Value = atoi(optarg);
                      break;
              case 'S':
                      if (! get_system_calls(optarg))
                         usage();
                      SyscallList=optarg;
                      break;
              case 't':
                      Make_Test_Case=TRUE;
                      ScriptName=optarg;
                      break;
              case 'T':
                      Seed_Value=time(0);
                      break;
              case 'w':
                      Weight = atoi(optarg);
                      break;
              case 'x':
                      Scew_Value = atoi(optarg);
                      break;
              case 'z':
                      End_Seed_Value = atoi(optarg);
                      break;
              default: usage();
         }
   }

   if (optind > argc ) {
      fprintf(stderr, "%s : argument missing --\n", Pg);
      usage();
   } else if (Initial_Sc >= End_Sc) {
      fprintf(stderr, "%s : -b (%d) Value Cannot Be >= -e (%d)\n", Pg, Initial_Sc, End_Sc);
      usage();
   }
   /*
   ***********************************************************
   * Read in param data and create structures for later usages
   ***********************************************************
   */
   init_data("SYSCALL_DATA");
   init_filenames(FileName);
   create_records();
   DEBUG(3) print_records();
   if (Make_Test_Case)
      /*
      *******************************
      * Create initial test case file
      *******************************
      */
      if (create_test_case() < 0)
         exit(1);

   /*
   *********************************
   * And away we go - start the show
   *********************************
   */
   start_up();               /* Is the heart of this program */
   handle_sigs(SIGUSR1);     /* This will kill ourself too */
   return 0;

}

/*
****************************************************
* Create a unique shell script for monitoring orphan
* processes and disk file core files
****************************************************
*/
start_monitor()
{
   int a, rc;
   FILE *output;

   DEBUG(3) fprintf(stdout, "In start_monitor() : pid = %d\n", getpid());
   sprintf(MonitorScript, "./orphan-%d", getpid());

   if ((output=fopen(MonitorScript, "w")) != 0) {
      for(a=0; MonitorCode[a]; a++) {
         fprintf(output, MonitorCode[a]);
      }
      fclose(output);
      if (chmod(MonitorScript, 0755) == -1) {
         fprintf(stdout, "WARNING : %s FAILED TO CHMOD 755 Monitor SHELL SCRIPT\n", Pg);
         exit(1);
      }
      if ((rc=fork()) == 0) {
         char *cmd[3];
         cmd[0]=MonitorScript;
         cmd[1]=Pg;
         cmd[2]='\0';
         execvp(cmd[0], cmd);
         fprintf(stdout, "%s execvp of %s FAILED\n", Pg, MonitorScript);
         exit(1);
      } else if (rc == -1) {
         fprintf(stdout, "WARNING : %s FAILED TO FORK OFF MonitorScript SHELL SCRIPT\n", Pg);
         exit(1);
      } else {
         MonitorPid=rc;
      }
   } else {
      fprintf(stdout, "WARNING : %s FAILED TO CREATE orphan KILLER SHELL SCRIPT\n", Pg);
      exit(1);
   }
}

/*
********************************************************
* start_up - Main engine to start Copies of this program
*            and keep them running
********************************************************
*/
int start_up()
{
   int count, rc, x;
   int wait_pid, plist=0, children=TRUE;
   int process[MAX_PROCESS];
   time_t begin_time;

   DEBUG(3) fprintf(stdout, "In start_up() : pid = %d\n", getpid());
   if (DEBUG_LEVEL) {
      fprintf(stdout, "\n%s : WARNING : Because a debug level was selected, CHILD PROCESS\n", Pg);
      fprintf(stdout, "random system calls can infinitely block on STDIN, STDOUT, STDERR\n\n");
      fflush(stdout);
   }
   /* Seed the random number generator */
   srand48(Seed_Value); 

   /* Create subdirectorys */
   if (Sub_Level)
      long_path(Dir_Name, Sub_Level);

   /* Make ourself are own process group leader */
   setpgrp();
   
   /* Setup to catch SIGUSR1/SIGINT signals */
   (void) signal(SIGUSR1, handle_sigs);
   (void) signal(SIGINT, handle_sigs);

   /* Start up our environment monitor */
   start_monitor();

   /* Fork them children off */
   for (count=0; count < Copies; count++) {
       if (Fork_Limit)
          Fork_Counter++;
       if ((rc=fork()) == -1) { /* fork error */
          fprintf(stderr, "%s : Initial Error Trying To Fork A Child\n", Pg);
          Fork_Counter--;
       } else if (rc == 0) { /* Children do random system calls */
          My_Pid=getpid();
          if (! Alarm_Seed)
             Alarm_Seed=ALARM_SEED;   /* Seconds for children to execute */
          exit(syscall_test());
       } else { /* Parent adds childs pid to run list and loops again */
          process[plist]=rc;
          plist++;
          DEBUG(6) fprintf(stdout, "%s : %d pid forked %d pid\n", Pg, getpid(), rc);
       }
   }
   /*
   *********************************************************************
   * Ok, children are off and bashing the operating system.  Parent is
   * here. Now, looping on wait.  If any child dies, give birth again
   * unless we are at our wits end(max limit or tolerance if you prefer)
   *********************************************************************
   */
   DEBUG(6) { fprintf(stdout, "%s waiting on %d children deaths\n", Pg, count);
              fflush(stdout); }

   begin_time=time(0);
   while (children) {
       wait_pid=wait(0);
       
       plist=-1;
       /* Find dead child on our run list */
       for (x=0; x < MAX_PROCESS; x++) {
           if (process[x] == wait_pid) {
              plist=x;
              if (Fork_Limit)
                 Fork_Counter--;
              break;
           }
       }
       /* If found, give birth again */
       if ((plist < MAX_PROCESS)&&(children)) {
          srand48(Seed_Value++);   /* Seed the random number generator */ 

          if (End_Seed_Value) {
             if (Seed_Value >= End_Seed_Value)
                if ((time(0)-begin_time) > Alarm_Seed) {
                   children=FALSE;    /* At our limit, no more births */
                   DEBUG(2) fprintf(stdout, "%s : INFO : children=FALSE ONE\n", Pg, Pg);
                }
          } else if (Alarm_Seed) {
             if ((time(0)-begin_time) > Alarm_Seed) {
                children=FALSE;    /* At our limit, no more births */
                DEBUG(2) fprintf(stdout, "%s : INFO : children=FALSE TWO\n", Pg, Pg);
             }
          }
          DEBUG(2) fprintf(stdout, "%s : INFO : process %d DIED : Birthing again with %d Seed Value\n", Pg, wait_pid, Seed_Value);

          if (Make_Test_Case)
             change_test_case();

          if (Fork_Limit)
             if (Fork_Counter > Fork_Limit)
                continue;

          Fork_Counter++;
          if ((rc=fork()) == -1) { /* fork error */
             fprintf(stderr, "%s : Initial Error Trying To Fork A Child\n", Pg);
             Fork_Counter--;
          } else if (rc == 0) { /* Children do random system calls */
             My_Pid=getpid();
             if (! Alarm_Seed)
                Alarm_Seed=ALARM_SEED;   /* Seconds for children to execute */
                exit(syscall_test());
          } else { /* Parent adds childs pid to run list and loops again */
             process[plist]=rc;
             DEBUG(2) fprintf(stdout, "%s : %d rebirthed dead pid %d as forked pid %d\n", Pg, getpid(), wait_pid, rc);
          }
       }
   }
   DEBUG(1) { fprintf(stdout, "%s : INFO : %s IS ENDING\n", Pg, Pg);
              fflush(stdout); }
   return 0;
}

/*
*****************************************************
* Syscall_test - Create random input for system calls
*****************************************************
*/
int syscall_test()
{
   int true=1, s, j, k, rc, i, fd, x, loop;
   long param[MAX_PARAM];
   struct system_calls *scptr;

   DEBUG(6) fprintf(stdout, "In syscall_test() : pid = %d\n", My_Pid);

   (void) signal (SIGUSR1, handle_sigs);   /* Setup for SIGUSR1 */
   (void) signal (SIGALRM, handle_sigs);   /* Setup for SIGALRM */

   /*
   ******************************************************
   * Close off STDIN, STDOUT, STDERR unless in DEBUG mode
   * so system calls using file descriptors do not block
   ******************************************************
   */ 
   if (DEBUG_LEVEL == 0) {
      close(0);
      close(1);
      close(2);
   }
   /* for (i=0; i< 10; i++) fd = open("test", 0312); */

   alarm(Alarm_Seed);
   while (true) {
       s=j=0;
       if (End_Usr_Sc) {
          s = ((int) (((float)End_Usr_Sc * (float)drand48()))%(int)End_Usr_Sc);
          scptr= Sy_Call_Ptrs[s];
       } else { 
          x=End_Sc-Initial_Sc;
          s = ((int) (((float)x * (float)drand48()))%(int)x);
          scptr=scalls + (Initial_Sc + s);
       }
       if (scptr->sy_valid == YES) {
           DEBUG(4) { fprintf(stdout, "%s CHILD pid %d : trying system call[%d] = %s\n", Pg, My_Pid, s, scptr->sy_name); fflush(stdout); }
           loop=1;
           if ((scptr->sy_loop==YES)&&(Iterations > 1))
              loop=(int)((float)Iterations * (float)drand48());
           DEBUG(5) { fprintf(stdout, "%s: CHILD pid %d :looping %d times\n", Pg, My_Pid, loop);
                    fflush(stdout); }
           for (x=0; x < loop; x++) {
              /*
              *******************************************
              * Create enough random numbers as arguments
              *******************************************
              */
              for (j=0; j < MAX_PARAM; j++) param[j] = 0;
              for (j=0; j < scptr->sy_nargs; j++) {
                  if (mrand48() > 0) {
                     k = (int)((float)Range_Value * (float)drand48());
                  } else {
                     k = (int)((float)Scew_Value * (float)drand48());
                  }
                  if (mrand48() < 0) k = k - (k*2);
                  if (Allow_Negatives)
                      if (k<0) k = k * -1;
                  param[j]=k;
              }
              k = (int)((float)Sy_Param1 * (float)drand48());
              if (mrand48() < 0) k = k - (k*2);
              /* Put in parameter 1 special */
              if (! Allow_Negatives)
                  if (k<0) k = k * -1;
              param[0]=k;
              DEBUG(4) { fprintf(stdout, "%s: CHILD pid %d : trying ck_reality()\n", Pg, My_Pid);
                         fflush(stdout); }
              ck_reality(scptr, param);
              DEBUG(4) { fprintf(stdout, "%s: CHILD pid %d : doing okay_params()\n", Pg, My_Pid);
                         fflush(stdout); }
              if (okay_params(scptr,param)) {
                 DEBUG(4) fprintf(stdout, "%s: CHILD pid %d : okay_params() is ok\n", Pg, My_Pid);
                 do_syscall(scptr,param);
              }
           } 
       }
   }
   return 0;
}

/*
********************************************************
* okay_params - do localized modifications to parameters
********************************************************
*/
int okay_params(struct system_calls *s, long *param)
{
   DEBUG(6) fprintf(stdout, "In okay_params() : pid = %d\n", My_Pid);

   /* Prevent foot shoot type of situations */

   if (((strcmp(s->sy_name, "kill")) == 0) && (param[0] < 1))
      return FALSE;   /* DO NOT KILL ALL OF US */

   return TRUE;
}

/*
*******************************************************
* do_syscall - runs system call with random parameters
*******************************************************
*/
int do_syscall(struct system_calls *s, long *p)
{
   int rc=0, okay=TRUE, number;
   DEBUG(6) fprintf(stdout, "In do_syscall() : pid = %d\n", My_Pid);

   if (Param_Num == TRUE)
       number=11;
   else
       number=s->sy_nargs;

   switch (number) {
        case 0:
              rc = (s->sy_call)(p[0]);
              DEBUG(3) { fprintf(stdout, "%s : CHILD pid %d : ** %s()** return code = %d\n", Pg, My_Pid, s->sy_name,
              rc); fflush(stdout); }
              break;
        case 1:
              rc = (s->sy_call)(p[0]);
              DEBUG(3) { fprintf(stdout, "%s : CHILD pid %d : ** %s(%d)** return code = %d\n", Pg, My_Pid, s->sy_name,
              p[0],rc); fflush(stdout); }
              break;
        case 2:
              rc = (s->sy_call)(p[0],p[1]);
              DEBUG(3) { fprintf(stdout, "%s : CHILD pid %d : ** %s(%d,%d)** return code = %d\n", Pg, My_Pid, s->sy_name,
              p[0],p[1],rc); fflush(stdout); }
              break;
        case 3:
              rc = (s->sy_call)(p[0],p[1],p[2]);
              DEBUG(3) { fprintf(stdout, "%s : CHILD pid %d : ** %s(%d,%d,%d)** return code = %d\n", Pg, My_Pid, s->sy_name,
              p[0],p[1],p[2],rc); fflush(stdout); }
              break;
        case 4:
              rc = (s->sy_call)(p[0],p[1],p[2],p[3]);
              DEBUG(3) { fprintf(stdout, "%s : CHILD pid %d : ** %s(%d,%d,%d,%d)** return code = %d\n", Pg, My_Pid, s->sy_name,
              p[0],p[1],p[2],p[3],rc); fflush(stdout); }
              break;
        case 5:
              rc = (s->sy_call)(p[0],p[1],p[2],p[3],p[4]);
              DEBUG(3) { fprintf(stdout, "%s : CHILD pid %d : ** %s(%d,%d,%d,%d,%d)** return code = %d\n", Pg, My_Pid, s->sy_name,
              p[0],p[1],p[2],p[3],p[4],rc); fflush(stdout); }
              break;
        case 6:
              rc = (s->sy_call)(p[0],p[1],p[2],p[3],p[4],p[5]);
              DEBUG(3) { fprintf(stdout, "%s : CHILD pid %d : ** %s(%d,%d,%d,%d,%d,%d)** return code = %d\n", Pg, My_Pid, s->sy_name,
              p[0],p[1],p[2],p[3],p[4],p[5],rc); fflush(stdout); }
              break;
        case 7:
              rc = (s->sy_call)(p[0],p[1],p[2],p[3],p[4],p[5],p[6]);
              DEBUG(3) { fprintf(stdout, "%s : CHILD pid %d : ** %s(%d,%d,%d,%d,%d,%d,%d)** return code = %d\n", Pg, My_Pid, s->sy_name,
              p[0],p[1],p[2],p[3],p[4],p[5],p[6],rc); fflush(stdout); }
              break;
        case 8:
              rc = (s->sy_call)(p[0],p[1],p[2],p[3],p[4],p[5],p[6],p[7]);
              DEBUG(3) { fprintf(stdout, "%s : CHILD pid %d : ** %s(%d,%d,%d,%d,%d,%d,%d,%d)** return code = %d\n", Pg, My_Pid, s->sy_name,
              p[0],p[1],p[2],p[3],p[4],p[5],p[6],p[7],rc); fflush(stdout); }
              break;
        case 9:
              rc = (s->sy_call)(p[0],p[1],p[2],p[3],p[4],p[5],p[6],p[7],p[8]);
              DEBUG(3) { fprintf(stdout, "%s : CHILD pid %d : ** %s(%d,%d,%d,%d,%d,%d,%d,%d,%d)** return code = %d\n", Pg, My_Pid, s->sy_name,
              p[0],p[1],p[2],p[3],p[4],p[5],p[6],p[7],p[8],rc); fflush(stdout); }
              break;
        case 10:
              rc = (s->sy_call)(p[0],p[1],p[2],p[3],p[4],p[5],p[6],p[7],p[8],p[9]);
              DEBUG(3) { fprintf(stdout, "%s : CHILD pid %d : ** %s(%d,%d,%d,%d,%d,%d,%d,%d,%d,%d)** return code = %d\n", Pg, My_Pid, s->sy_name,
              p[0],p[1],p[2],p[3],p[4],p[5],p[6],p[7],p[8],p[9],rc); fflush(stdout); }
              break;
        case 11:
              rc = (s->sy_call)(p[0],p[1],p[2],p[3],p[4],p[5],p[6],p[7],p[8],p[9],p[10]);
              DEBUG(3) { fprintf(stdout, "%s : CHILD pid %d : ** %s(%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d)** return code = %d\n", Pg, My_Pid, s->sy_name,
              p[0],p[1],p[2],p[3],p[4],p[5],p[6],p[7],p[8],p[9],p[10],rc); fflush(stdout); }
              break;
        case 12:
              rc = (s->sy_call)(p[0],p[1],p[2],p[3],p[4],p[5],p[6],p[7],p[8],p[9],p[10],p[11]);
              DEBUG(3) { fprintf(stdout, "%s : CHILD pid %d : ** %s(%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d)** return code = %d\n", Pg, My_Pid, s->sy_name,
              p[0],p[1],p[2],p[3],p[4],p[5],p[6],p[7],p[8],p[9],p[10],p[11],rc); fflush(stdout); }
              break;
        default:
              fprintf(stderr, "%s : WARNING : %s needs more than 11 parameters\n",
                     Pg, s->sy_name); fflush(stderr);
              okay=FALSE;
              break;
   }
   if (okay) {
      s->sy_ncalls++;
      if (rc < 0)
         s->sy_failures++;
      else
         s->sy_passes++;
   }
   return 0;
}

/*
****************************************
* make_message - put together output for
* test case file
****************************************
*/
int make_message(char *message)
{
   char tpath[1024];
   char command[1000];

   sprintf(command, "%s -d %d -c %d -b %d -e %d -s %d -z %d -r %d -p %d ", Pg, DEBUG_LEVEL, Copies, Initial_Sc, End_Sc, Init_Seed_Value,
          Cur_Seed_Value, Range_Value, Sy_Param1);
   if (FileName) {
      sprintf(tpath, "-f %s ", FileName);
      strcat(command, tpath);
   }
   if (Allow_Negatives)
      strcat(command, "-N ");
   if (SyscallList) {
      sprintf(tpath, "-S %s ", SyscallList);
      strcat(command, tpath);
   }
   if (Param_Num)
      strcat(command, "-o ");
   if (Sub_Level) {
      sprintf(tpath, "-l %d ", Sub_Level);
      strcat(command, tpath);
   }
   if (Dir_Name) {
      sprintf(tpath, "-n %d ", Dir_Name);
      strcat(command, tpath);
   }
   if (Alarm_Seed) {
      sprintf(tpath, "-a %d ", Alarm_Seed);
      strcat(command, tpath);
   }
   if (Iterations) {
      sprintf(tpath, "-i %d ", Iterations);
      strcat(command, tpath);
   }
   if (Weight) {
      sprintf(tpath, "-w %d ", Weight);
      strcat(command, tpath);
   }
   if (Scew_Value) {
      sprintf(tpath, "-x %d ", Scew_Value);
      strcat(command, tpath);
   }
   strcat(message, "#!/bin/sh");
   sprintf(tpath, "\n# %s Version 1.0\n\n", Pg);
   strcat(message, tpath);
   strcat(message,command);
   strcat(message, "\n");
}

/*
*************************************************
* creat_test_case - Create initial test case file
*************************************************
*/
int create_test_case()
{
   int a, rc;
   FILE *output;
   char message[2000];

   DEBUG(6) fprintf(stdout, "In create_test_case() : pid = %d\n", getpid());
   
   Init_Seed_Value=Seed_Value;
   Cur_Seed_Value=End_Seed_Value;

   for (a=0; a < sizeof(message); message[a++]='\0');

   make_message(message);
   
   if ((output=fopen(ScriptName, "w")) != 0) {
      if ((rc=fprintf(output, message)) < 0 ) {
         fprintf(stdout, "%s : WARNING : Failed to create test case file!\n", Pg);
         fclose(output);
         return(-1);
      }
   } else {
      fprintf(stdout, "%s : WARNING : Failed to create test case file!\n", Pg);
      fclose(output);
      return(-1);
   }
   fflush(output);
   fclose(output);
   return 0;
}

/*
******************************************
* change_test_case - Update test case file
******************************************
*/
int change_test_case()
{
   DEBUG(6) fprintf(stdout, "In change_test_case() : pid = %d\n", getpid());
   return 0;
}

/*
*******************************************
* long_path - create a really big directory
*******************************************
*/

int long_path(char *dirname, int length)
{
   int x,y;

   DEBUG(6) fprintf(stdout, "In long_path() : pid = %d\n", getpid());

   for (x=0; x< length; x++) {
       mkdir(dirname, 0777);
       chdir(dirname);
   }
   return 0;
}

int set_parameters(struct system_calls *s, long *param)
{
   DEBUG(6) fprintf(stdout, "In set_parameters() : pid = %d\n", getpid());
   return 0;
}

/*
*****************************************
* ck_reality - do the weighting and stuff
*****************************************
*/
int ck_reality(struct system_calls *s, long *param)
{
   int x,y;

   DEBUG(6) fprintf(stdout, "In ck_reality() : pid = %d\n", getpid());
   
   x=(int)(100.0 * (float)drand48());
 
   if (x > Weight) {
      set_parameters(s, param);
   }
   return 0;
}

/*
*********************************************
* create_records - create system call records
*********************************************
*/
int create_records()
{
   DEBUG(6) fprintf(stdout, "In create_records() : pid = %d\n", getpid());
   return 0;
}

/*
****************************************
* print_records - print system call data
****************************************
*/
int print_records()
{
   DEBUG(6) fprintf(stdout, "In print_records() : pid = %d\n", getpid());
   return 0;
}

/*
*************************************************
* init_data - Initialize and read in SYSCALL_DATA
*************************************************
*/
int init_data(char *datafile)
{
   DEBUG(6) fprintf(stdout, "In init_data() : pid = %d\n", getpid());
   return 0;
}
