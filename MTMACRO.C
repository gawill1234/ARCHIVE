#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>

/****************************************************/
/*  This program will create a file which can be accessed
    by two tasks (created using macrotasking functions) other
    than the main task.  The file can be locked in various 
    places or not locked at all.
*/

/****************************************************/
/*   To whom it may concern:
        The macro/multitasking calls in this program include
            TSKSTART
            TSKWAIT
            EVWAIT
            EVASGN
            EVPOST

    All variables which are to shared between tasks
    must be global or passed to the task through
    TSKSTART.

    Macrotasking functions are a part of libu.
*/

#define PASS 0
#define FAIL 1
#define LINELEN 80
#define WRDSZ 8

int locked, wrotit, task1res, task2res, mainres, readbackres;
char *progname;

main(argc, argv)
int argc;
char **argv;
{ 
extern char *optarg;
extern int optind;

int childpid, fork();
double drand48();
void srand48();

char randstr[3], commandstr[LINELEN];
int i, c, random, randomfixed;
int inloop, outloop, infinite, endres, is_a_child;
char *direct, *getcwd(), **arglist;
static char dash_d_str[] = "-d";
static char child_str[] = "-C";
static char *optstring = "Cnbamtp:l:id:";
static char usage[] = "Usage:  mtmacro [-inbamt] [-p process per loop] [-l number of loops] [-d directory]";
static char usage2[] = "    -i     run in infinite mode";
static char usage3[] = "    -n     no locks on the file";
static char usage4[] = "    -b     locks placed on file before tasks called";
static char usage5[] = "    -a     locks placed on file after tasks called";
static char usage6[] = "    -m     locks placed on file between tasks";
static char usage7[] = "    -t     locks placed on file in one of the tasks";
static char usage8[] = "           Default of nbamt is to randomly choose";

union {
   struct {
      unsigned unused :48, sherr:8, sigid:8;
   } err;
   int retval;
} errstruct;


   inloop = outloop = 1;
   infinite = endres = randomfixed = is_a_child = 0;
   direct = NULL;

   srand48(time((long *)0));

   progname = argv[0];

   fprintf(stderr, "EXECUTING PROGRAM:  %s\n", progname);

   if (argc > 1) {
      while ((c=getopt(argc, argv, optstring)) != EOF) {
         switch (c) {
            case 'n':
                      random = 0;
                      randomfixed = 1;
                      break;

            case 'b':
                      random = 1;
                      randomfixed = 1;
                      break;

            case 'a':
                      random = 3;
                      randomfixed = 1;
                      break;

            case 'm':
                      random = 2;
                      randomfixed = 1;
                      break;

            case 't':
                      random = 4;
                      randomfixed = 1;
                      break;

            case 'l':
                      outloop = atoi(optarg);
                      break;
          
            case 'p':
                      inloop = atoi(optarg);
                      break;
  
            case 'd':
                      direct = (char *)malloc(strlen(optarg) + 1);
                      strcpy(direct, optarg);
                      break;
      
            case 'i':
                      infinite = 1;
                      break;

            case 'C':
                      is_a_child = 1;
                      break;

            default:
                      fprintf(stderr, "%s\n", usage);
                      fprintf(stderr, "%s\n", usage2);
                      fprintf(stderr, "%s\n", usage3);
                      fprintf(stderr, "%s\n", usage4);
                      fprintf(stderr, "%s\n", usage5);
                      fprintf(stderr, "%s\n", usage6);
                      fprintf(stderr, "%s\n", usage7);
                      fprintf(stderr, "%s\n", usage8);
                      exit(1);
         }
      }
   }

   if (direct != NULL) {
      if (direxist(direct) != 0) {
         fprintf(stderr, "Directory %s does not exist\n", direct);
         free(direct);
         exit(1);
      }
   }
   else {
      direct = getcwd((char *)NULL, LINELEN);
   }

   while (outloop) {

      if (randomfixed == 0) {
         random = (int)(drand48() * (double)10.0);
         random = random % 5;
      }

      if (inloop == 1) {
         endres = endres + dothework(random, direct);
      }
      else {
         switch (random) {
            case 0:
                    sprintf(randstr, "-n\0");
                    break;
            case 1:
                    sprintf(randstr, "-b\0");
                    break;
            case 2:
                    sprintf(randstr, "-m\0");
                    break;
            case 3:
                    sprintf(randstr, "-a\0");
                    break;
            case 4:
                    sprintf(randstr, "-t\0");
                    break;
         }

         for (i = 0; i < inloop; i++) {

            arglist = (char **)malloc(5 * WRDSZ);

            arglist[0] = progname;
            arglist[1] = randstr;
            arglist[2] = child_str;
            arglist[3] = dash_d_str;
            arglist[4] = direct;

            childpid = fork();
            if (childpid == 0)
               exit(execvp(progname, arglist));

            while (waitpid(0, &errstruct.retval, WNOHANG) > 0) {
               endres = endres + errstruct.err.sherr;
            }
/***************************************************/
/*  The multitasking stuff does not work with fork.
    It is a known bug.  So the mess above will have to do
    for now.

            childpid = fork();
            if (childpid == 0)
               _exit(dothework());
*/
         }
      }


      if (infinite != 1)
         outloop--;
      else
         outloop++;

      /********************************/
      /*  This is kludgy.  But for now it
          will have to do.  I have a control
          function but I have to get it and 
          put it in.
      */
      if (inloop > 75)
         sleep(1);
      else {
         if ((outloop % 5) == 0)
            while (waitpid(0, &errstruct.retval, WNOHANG) > 0) {
               endres = endres + errstruct.err.sherr;
            }
            sleep(1);
      }
   }
   if (inloop != 1) {
      while (waitpid(0, &errstruct.retval, WNOHANG) != (-1)) {
         endres = endres + errstruct.err.sherr;
      }
   }

   if (is_a_child == 0) {
      if (endres == 0) {
         printf("mtmacro:  TEST PASSED\n");
      }
      else {
         printf("mtmacro:  TEST FAILED\n");
      }
   }

   exit(endres);
}

int dothework(random, direct)
int random;
char *direct;
{
int tskarry1[3], tskarry2[3];
extern int task1(), task2();
int mode = 00600;
int fno, len;
char fullpath[LINELEN];
char *filename, *curdir, *getcwd();
FILE *fp;

char mainbuf[LINELEN] = {"MAIN  MAIN  MAIN  MAIN  MAIN\n\0"};
char task1buf[LINELEN] = {"ONE 1  ONE 1  ONE 1  ONE 1\n\0"};
char task2buf[LINELEN] = {"TWO 2  TWO 2  TWO 2  TWO 2\n\0"};


   readbackres = task1res = task2res = mainres = PASS;
   len = strlen(mainbuf);
   curdir = getcwd((char *)NULL, LINELEN);

   /***************************************/
   /*   Initialize the task arrays.  array[0]
        is required, it is the number of elements.  
        int the array.  array[1] must exist for use
        by multitasking functions.
   */

   tskarry1[0] = 3;
   tskarry1[2] = (int)"task 1";

   tskarry2[0] = 3;
   tskarry2[2] = (int)"task 2";

   /***************************************/
   /*   Initialize the lock.  The lock variable must
        be global or the other functions will not know
        about it and something will core dump.
   */

   EVASGN(&wrotit);
   if (random != 0)
      EVASGN(&locked);

   /***************************************/
   /*  Open the file
   */

   filename = tempnam(direct, "mt");
   fno = open(filename, O_RDWR|O_CREAT, mode);

   if (random == 1) {
      mainres = lockfile(fno);
   }

   /***************************************/
   /*   Get the tasks going.
   */

   TSKSTART(&tskarry1, task1, fno, task1buf, random);

   if (random == 2) {
      mainres = lockfile(fno);
   }
   TSKSTART(&tskarry2, task2, fno, task2buf, random);

   if (random == 3) {
      mainres = lockfile(fno);
   }

   /***************************************/
   /*   Wait for the first writer to post
        that it is done.
   */

   if (random == 4)
      EVWAIT(&locked);

   EVWAIT(&wrotit);

   /***************************************/
   /*  Write another line to the file to
       make sure it can be done.
   */

   if (write(fno, mainbuf, len) != len)
      mainres = FAIL;

   /***************************************/
   /*   Make sure the tasks are done before
        closing the file so all data is present
   */

   TSKWAIT(&tskarry1);
   TSKWAIT(&tskarry2);

   /***************************************/
   /*   Close the file
   */

   close(fno);
   readbackres = readbackfile(mainbuf, task1buf, task2buf, filename);
   if (readbackres == PASS)
      unlink(filename);
   free(filename);

   sprintf(fullpath, "%s/mac_res\0", curdir);
  
   fp = fopen(fullpath, "a+");
   if ((readbackres + mainres + task1res + task2res) != PASS) {
      fprintf(fp, "Test Failed -- mtmacro.%d\n", getpid());
      fclose(fp);
      return(FAIL);
   }
   else {
      fprintf(fp, "Test Passed -- mtmacro.%d\n", getpid());
      fclose(fp);
      return(PASS);
   }
}

int lockfile(fno)
int fno;
{
struct flock flk;
int lockres;

   lockres = PASS;

   /***************************************/
   /*   Initialize the lock structure.
        All 0's after the lock type means
        lock the whole file.
   */

   flk.l_type = F_WRLCK;
   flk.l_whence = 0;
   flk.l_start = 0;
   flk.l_len = 0;

   /***************************************/
   /*  Lock the file and inform the tasks
   */

   if (fcntl(fno, F_SETLK, &flk) == (-1)) {
      printf("File lock failed\n");
      lockres = FAIL;
   }

   EVPOST(&locked);
   return(lockres);
}

/********************************************/
/*  Check the contents of the file created by the
    tasks.  We can not be sure which line is where, 
    but all of the data should be there.
*/
readbackfile(mainbuf, task1buf, task2buf, filename)
char *mainbuf, *task1buf, *task2buf, *filename;
{
FILE *fp;
char readbuf[LINELEN];
int i, foundmain, foundtask1, foundtask2;


   foundmain = foundtask1 = foundtask2 = FAIL;

   /***************************************/
   /*   Open the file
   */

   if ((fp = fopen(filename, "r")) == NULL) {
      return(FAIL);
   }


   /***************************************/
   /*   Loop through three times, one for
        each line in the file and check that
        the line matches one of the expected strings
   */

   for (i = 0; i < 3; i++) {
      if (fgets(readbuf, LINELEN, fp) == NULL) {
         fclose(fp);
         return(FAIL);
      }

      if (strcmp(readbuf, mainbuf) != 0) {
         if (strcmp(readbuf, task1buf) != 0) {
            if (strcmp(readbuf, task2buf) != 0) {
               fclose(fp);
               return(FAIL);
            }
            else {
               foundtask2 = PASS;
            }
         }
         else {
            foundtask1 = PASS;
         }
      }
      else {
         foundmain = PASS;
      }
   }
 

   /***************************************/
   /*   Close the file and return
        Not concerned with the result of close.
        If test passed to this point, close is another
        test.  What this test was supposed to check passed.
   */

   fclose(fp);
   if ((foundmain + foundtask1 + foundtask2) == PASS)
      return(PASS);
   else
      return(FAIL);
}

int task1(fno, task1buf, random)
int fno, random;
char *task1buf;
{
int len;

   if (random == 4) {
      task1res = lockfile(fno);
   }
   else {
      if (random != 0)
         EVWAIT(&locked);
   }

   len = strlen(task1buf);

   /***************************************/
   /*   Wait for the first writer to post
        that it is done.
   */

   EVWAIT(&wrotit);

   /***************************************/
   /*  Write another line to the file to
       make sure it can be done.
   */

   if (write(fno, task1buf, len) != len)
      task1res = FAIL;
}

int task2(fno, task2buf, random)
int fno, random;
char *task2buf;
{
int len;

   if (random != 0)
      EVWAIT(&locked);

   len = strlen(task2buf);

   /***************************************/
   /*   Write to file opened in main
   */

   if (write(fno, task2buf, len) != len)
      task2res = FAIL;

   /***************************************/
   /*   Post that write is done so other tasks
        can continue
   */

   EVPOST(&wrotit);
}
/*********************************************************/
/*
   Check to see if a directory name exists and that it is
   a directory.
*/
int direxist(filename)
char *filename;
{
struct stat buf;
int value;

   value = stat(filename, &buf);
   if ((S_IFMT & buf.st_mode) != S_IFDIR)
      value = (-1);
   return(value);
}
