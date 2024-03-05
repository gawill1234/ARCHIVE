#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <tfork.h>
#include <sys/wait.h>

/****************************************************/
/*  This program will create a file which can be accessed
    by two tasks (created using multitasking primitives) other
    than the main task.  The file can be locked in various 
    places or not locked at all.
*/


#define PASS 0
#define FAIL 1
#define LINELEN 80
#define WRDSZ 8

static long locked;
long task1res, task2res, mainres, readbackres;
long taskonelk, tasktwolk;
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
int i, c, random, randomfixed, is_a_child;
int inloop, outloop, infinite, endres, dupit;
char *direct, *getcwd(), **arglist;
static char dash_d_str[] = "-d";
static char dupit_str[] = "-D";
static char child_str[] = "-C";
static char *optstring = "CDnbamtp:l:id:";
static char usage[] = "Usage:  mtprimlb [-inbamt] [-p process per loop] [-l number of loops] [-d directory]";
static char usage2[] = "    -i     run in infinite mode";
static char usage3[] = "    -n     no locks on the file";
static char usage4[] = "    -b     locks placed on file before tasks called";
static char usage5[] = "    -a     locks placed on file after tasks called";
static char usage6[] = "    -m     locks placed on file between tasks";
static char usage7[] = "    -t     locks placed on file in one of the tasks";
static char usage8[] = "    -D     use dup system call on file descriptor";
static char usage9[] = "           Default of nbamt is to randomly choose";

union {
   struct {
      unsigned unused :48, sherr:8, sigid:8;
   } err;
   int retval;
} errstruct;

   inloop = outloop = 1;
   dupit = infinite = endres = randomfixed = is_a_child = 0;
   direct = NULL;

   srand48(time((long *)0));

   progname = argv[0];

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

            case 'D':
                      dupit = 1;
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
                      fprintf(stderr, "%s\n", usage9);
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
         endres = endres + dothework(random, direct, dupit);
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

            arglist = (char **)malloc(7 * WRDSZ);

            arglist[0] = progname;
            arglist[1] = randstr;
            arglist[2] = child_str;
            arglist[3] = dash_d_str;
            arglist[4] = direct;
            if (dupit == 1)
               arglist[5] = dupit_str;
            else
               arglist[5] = NULL;
            arglist[6] = NULL;

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
               _exit(dothework(random, direct, dupit));
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
         printf("mtprimlb:  TEST PASSED\n");
      }
      else {
         printf("mtprimlb:  TEST FAILED\n");
      }
   }


   exit(endres);
}

int dothework(random, direct, dupit)
int random, dupit;
char *direct;
{
int mode = 00600;
int fno, len, childpid, t1fno, t2fno, duprandom;
char fullpath[LINELEN];
char *filename, *curdir, *getcwd();
char lockloc[16], duptype[16];
FILE *fp;

char mainbuf[LINELEN] = {"MAIN  MAIN  MAIN  MAIN  MAIN\n\0"};
char task1buf[LINELEN] = {"ONE 1  ONE 1  ONE 1  ONE 1\n\0"};
char task2buf[LINELEN] = {"TWO 2  TWO 2  TWO 2  TWO 2\n\0"};

   readbackres = task1res = task2res = mainres = PASS;
   taskonelk = tasktwolk = 0;
   len = strlen(mainbuf);
   curdir = getcwd((char *)NULL, LINELEN);
   duprandom = (int)(drand48() * (double)100.0);

   /***************************************/
   /*  Open the file
   */

   filename = tempnam(direct, "mt");
   fno = open(filename, O_RDWR|O_CREAT, mode);
   if (dupit == 0) {
      t1fno = t2fno = fno;
      strcpy(duptype, "no dup\0");
   }
   else {
      if (duprandom < 33) {
         t1fno = t2fno = fno;
         strcpy(duptype, "no dup\0");
      }
      else {
         if (duprandom > 66) {
            t1fno = fno + 1;
            t2fno = fno + 2;
            dup2(fno, t1fno);
            dup2(t1fno, t2fno);
            strcpy(duptype, "dup2\0");
         }
         else {
            t1fno = dup(fno);
            t2fno = dup(t1fno);
            strcpy(duptype, "dup\0");
         }
      }
   }

   if (random != 0) {
      t_lock(&locked);
   }
   else {
      strcpy(lockloc, "no lock\0");
   }

   if (random == 1) {
      mainres = lockfile(fno);
      strcpy(lockloc, "before\0");
   }

   /***************************************/
   /*   Get the tasks going.
   */

   if ((childpid = t_fork(1)) == 0) {
      t_lock(&taskonelk);
      task1(t1fno, task1buf, random);
      t_unlock(&taskonelk);
      t_exit(0);
   }

   if (random == 2) {
      mainres = lockfile(fno);
      strcpy(lockloc, "between\0");
   }
   if ((childpid = t_fork(1)) == 0) {
      t_lock(&tasktwolk);
      task2(t2fno, task2buf, random);
      t_unlock(&tasktwolk);
      t_exit(0);
   }

   if (random == 3) {
      mainres = lockfile(fno);
      strcpy(lockloc, "after\0");
   }

   /***************************************/
   /*   Wait for the first writer to post
        that it is done.
   */

   if (random == 4) {
      t_lock(&locked);
      t_unlock(&locked);
      strcpy(lockloc, "during\0");
   }

   /***************************************/
   /*  Write another line to the file to
       make sure it can be done.
   */

   if (write(fno, mainbuf, len) != len)
      mainres = FAIL;

   /***************************************/
   /*   Close the file
   */

   
   t_lock(&taskonelk);
   t_lock(&tasktwolk);
   t_unlock(&taskonelk);
   t_unlock(&tasktwolk);

   close(fno);
   readbackres = readbackfile(mainbuf, task1buf, task2buf, filename);
   if (readbackres == PASS)
      unlink(filename);
   free(filename);

   sprintf(fullpath, "%s/mac_res\0", curdir);
  
   fp = fopen(fullpath, "a+");
   if ((readbackres + mainres + task1res + task2res) != PASS) {
      fprintf(fp, "Test Failed -- mtprimlb.%d  %s  %s\n",
                   getpid(), lockloc, duptype);
      fclose(fp);
      return(FAIL);
   }
   else {
      fprintf(fp, "Test Passed -- mtprimlb.%d  %s  %s\n",
                   getpid(), lockloc, duptype);
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

   t_unlock(&locked);
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
      if (random != 0) {
         t_lock(&locked);
         t_unlock(&locked);
      }
   }

   len = strlen(task1buf);

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

   if (random != 0) {
      t_lock(&locked);
      t_unlock(&locked);
   }

   len = strlen(task2buf);

   /***************************************/
   /*   Write to file opened in main
   */

   if (write(fno, task2buf, len) != len)
      task2res = FAIL;

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
