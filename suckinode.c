static char USMID[] = "%Z%%M%	%I%	%G% %U%";

/*
 *	(C) COPYRIGHT CRAY RESEARCH, INC.
 *	UNPUBLISHED PROPRIETARY INFORMATION.
 *	ALL RIGHTS RESERVED.
 */
/**********************************************************
*
*    UNICOS System Testing - Cray Research, Inc.
*
*    TEST IDENTIFIER : suckinode
*
*    TEST TITLE      : Create a bunch of inodes
*
*    PARENT DOCUMENT : NASA/AMES Alpha test e-mail
*
*    TEST CASE TOTAL : 1
*                     (or a whole bunch, depending on how you
*                      look at it)
*
*    WALL CLOCK TIME : 30
*
*    AUTHOR : Gary Williams
*
*    CO-PILOT: none
*
*    TEST CASES
*
*       Create a series of directories at multiple levels
*       and fill those directories with the specified number
*       inodes (0 length files).  Randomly unlink the specified
*       percentage of inodes.  Continue until all inodes created,
*       check inodes and directories, and exit.  Issue appropriate
*       error messages of course.
*
*    ENVIRONMENTAL NEEDS
*
*       Need a computer to run it on, a C compiler, libc
*       You must be careful when you use this test.
*       It shows EXPONENTIAL growth in the number of processes
*       it creates when levels are added.  For example, if you
*       specify 3 levels with 5 directories in each level, the
*       number of processes created would be:
*           5 + (5 * 5) + (5 * 5 * 5) = 155
*       If you specified 1000 files per directory it would be
*       155000 files (inodes) created.
*       The command line to do the above:
*           suckinode -f 1000 -d 5 -l 3
*       BE CAREFUL
*
*    DETAILED DESCRIPTION
*
*       Self-documenting code so see below
*
*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#**/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/fcntl.h>
#include <sys/stat.h>
#include <errno.h>

// extern char *sys_errlist[];
extern int errno;

#include <sys/wait.h>
#include <signal.h>

#define FNR 0001
#define FNC 0002
#define CNU 0004
#define RBS 0010
#define LNF 0020
#define DNU 0040
#define DNR 0100
#define CDN 0200

#define ZERO 0L
#define POS_VAL 1
#define NEG_VAL -1

#define PASS 1
#define FAIL -1
#define DIR_FAIL -2

#define THERE 0
#define NOT_THERE -1

double drand48();
void srand48();

struct f_list_t {
   char *full_name;
   char *file_name;
   int rmpassfail, level, did_create, do_rm, pid, exitstat, link_fail;
   int not_there, my_type;
   struct f_list_t *prev;
   struct f_list_t *next;
};

struct f_list_t *kill_head;

int dircount = ZERO;

/***********************************************/
/*  Child signal handler.  Removes files and exits
*/

void file_exit()
{

   while (kill_head != NULL) {
      if (kill_head->not_there == THERE) {
         if (kill_head->my_type == S_IFDIR)
            rmdir(kill_head->file_name);
         else
            unlink(kill_head->file_name);
      }
      kill_head = kill_head->next;
   }
   _exit(ZERO);

}


/***********************************************/
/*  Parent signal handler.  Passes SIGINT on to
    children, waits for them, removes directories
    and exits.
*/
void dir_exit()
{
struct f_list_t *tracit;

   fprintf(stderr, "INTERRUPT ... interrupt children ... ");
   tracit = kill_head;
   while (tracit != NULL) {
      kill(tracit->pid, SIGINT);
      tracit = tracit->next;
   }
   fprintf(stderr,"wait for children/clean up ... ");
   wait_for_kids(kill_head);
   fprintf(stderr, "EXITING\n");
   clean_up(kill_head);
   exit(POS_VAL);
}

/***********************************************/
/*  Clean up all of the loose directories at
    the end of a run.  Process any errors that may
    have been returned by the children.
*/

int clean_up(dir_head)
struct f_list_t *dir_head;
{
struct f_list_t *tracit;
int passfail = ZERO;

   tracit = dir_head->prev;
   dir_head->prev = NULL;
   while (tracit != NULL) {
      if (tracit->exitstat != ZERO)
         process_error(tracit);
      passfail = passfail + tracit->exitstat;
      if (rmdir(tracit->file_name) != ZERO) {
         passfail++;
         fprintf(stderr, "suckinode:  Could not remove directory %s\n",
                 tracit->file_name);
      }
      tracit = tracit->prev;
   }
   return(passfail);
}

/***********************************************/
/*  Create a file/directory information node
*/

struct f_list_t *cr_new_f_list_node()
{
struct f_list_t *new_f_list_node;

   new_f_list_node = (struct f_list_t *)malloc(sizeof(struct f_list_t));
   new_f_list_node->file_name = NULL;
   new_f_list_node->full_name = NULL;
   new_f_list_node->rmpassfail = PASS;
   new_f_list_node->level = NEG_VAL;
   new_f_list_node->did_create = ZERO;
   new_f_list_node->do_rm = ZERO;
   new_f_list_node->pid = NEG_VAL;
   new_f_list_node->exitstat = ZERO;
   new_f_list_node->link_fail = ZERO;
   new_f_list_node->my_type = S_IFREG;
   new_f_list_node->not_there = NOT_THERE;
   new_f_list_node->prev = NULL;
   new_f_list_node->next = NULL;
   return(new_f_list_node);
}

/***********************************************/
/*  Put file/directory information node into a list
    and set SIGINT signal handler for file creator
    children.  Also set signal handler for directory
    creating parent, but that gets changed pretty quickly.
*/
struct f_list_t *put_in_file_list(file_head, new_f_list_node)
struct f_list_t *file_head;
struct f_list_t *new_f_list_node;
{
struct f_list_t *f_list_trac;
struct sigaction act, oact;
void file_exit();

   if (file_head == NULL) {
      /********************************************/
      /*  Create head of list if necessary
       */
      file_head = new_f_list_node;
      kill_head = file_head;
      /********************************************/
      /*  Set the signal handler.  I could have set it
       *  any number of places.  Set it here so anyone
       *  could see where the global value it depends 
       *  on is set.  kill_head above.
       */
      act.sa_handler = file_exit;
      act.sa_mask = ZERO;
      act.sa_flags = ZERO;
      sigaction(SIGINT, &act, &oact);
   }
   else {
      /********************************************/
      /*  If head of list exist, add node to list.
       */
      f_list_trac = file_head;
      while (f_list_trac->next != NULL)
         f_list_trac = f_list_trac->next;
      f_list_trac->next = new_f_list_node;
      file_head->prev = new_f_list_node;
      new_f_list_node->prev = f_list_trac;
   }
   return(file_head);
}

/***********************************************/
/*  Generate a unique file/directory name.
*/
char *genname(dirname,itercount, prefix)
char *dirname;
int itercount;
char *prefix;
{
char template[10];

   sprintf(template,"%s-%d\0", prefix, itercount);
   return(tempnam(dirname, template));
}

/***********************************************/
/*  Generate a random valid open flag.
*/
int doopenflags()
{
int random, flagthing;

   flagthing = O_CREAT;

   if (((int)(drand48() * (double)10.0)) < 5)
      flagthing = flagthing | O_TRUNC;

   if (((int)(drand48() * (double)10.0)) < 5)
      flagthing = flagthing | O_APPEND;

   if (((int)(drand48() * (double)10.0)) > 5)
      flagthing = flagthing | O_WRONLY;
   else
      flagthing = flagthing | O_RDWR;

   if (((int)(drand48() * (double)10.0)) > 7)
      flagthing = flagthing | O_SYNC;

    if (((int)(drand48() * (double)10.0)) > 6)
      flagthing = flagthing | O_EXCL;

#ifndef SUN
   if (((int)(drand48() * (double)10.0)) < 3)
      flagthing = flagthing | O_SYNC;
#endif

   return(flagthing);
}

/***********************************************/
/*  Create the file
*/
int openwcreat(filename)
char *filename;
{
int fno, flagthing;
int mode = 0600;

   flagthing = doopenflags();

   if (((int)(drand48() * (double)10.0)) > 4) {
      /**************************************/
      /**  Should have been done by calling routine
       *      flagthing = doopenflags(NEW);
      */

      fno = open(filename, flagthing, mode);
   }
   else {
      fno = creat(filename, mode);
   }

   if (fno == (NEG_VAL)) {
      logit("Could not open file", filename);
   }
   return(fno);
}

/****************************************************/
/*  Generate directories per level
*/
struct f_list_t *make_all_dirs(num_dirs, level_num, dir_head, workdir)
int num_dirs, level_num;
struct f_list_t *dir_head;
char *workdir;
{
int i, err;
char *genname();
struct f_list_t *tracit, *put_in_file_list(), *f_list_node;

   for (i = ZERO; i < num_dirs; i++) {

      /****************************************************/
      /*  Get a new directory/file  information node and
       *  add it to the directory list.
       */
      f_list_node = cr_new_f_list_node();
      dir_head = put_in_file_list(dir_head, f_list_node);

      /****************************************************/
      /*  Generate a unique directory name
       */
      f_list_node->full_name = genname(workdir, 9, "DIR");
      f_list_node->file_name = f_list_node->full_name;

      /****************************************************/
      /*  Make the directory, update counters if successful
       */
      err = mkdir(f_list_node->file_name, 0777);
      if (fileexist(f_list_node->file_name, S_IFDIR) == ZERO) {
         f_list_node->my_type = S_IFDIR;
         dircount++;
         f_list_node->did_create = PASS;
         f_list_node->not_there = THERE;
      }
      else {
         f_list_node->did_create = FAIL;
         f_list_node->not_there = NOT_THERE;
      }
   }

   /****************************************************/
   /*  Mark all the new directories as to the level they
    *  are supposed to be at.
    */
   tracit = dir_head;
   while (tracit != NULL) {
      if (tracit->level == (NEG_VAL))
         tracit->level = level_num;
      tracit = tracit->next;
   }
   return(dir_head);
}

/***********************************************/
/*  Generate all directories for each level
*/
struct f_list_t *gen_dir_levels(num_levels, dir_per_level, dir_head, workdir)
int num_levels, dir_per_level;
struct f_list_t *dir_head;
char *workdir;
{
int i;
char *curdir;
struct f_list_t *tracit, *make_all_dirs();

   /****************************************************/
   /*  Make the base level of directories.
    */
   dir_head = make_all_dirs(dir_per_level, 0, dir_head, workdir);

   /****************************************************/
   /*  Make any additional directory levels if additional
    *  levels are requested.
    */
   for (i = POS_VAL; i < num_levels; i++) {
      tracit = dir_head;
      while (tracit != NULL) {
         if (tracit->level == (i - POS_VAL)) {
            dir_head = make_all_dirs(dir_per_level, i, dir_head, tracit->file_name);
         }
         tracit = tracit->next;
      }
   }
   return(dir_head);
}

/***********************************************/
/*  Randomly choose some files to unlink and 
    create a process to do the unlink.
*/
int do_unlinkit(file_head, percent_unlink)
struct f_list_t *file_head;
int percent_unlink;
{
struct f_list_t *tracit;
int childpid, fork(), err;

   /*************************************************/
   /*  Choose the inodes to be unlinked
    */
   tracit = file_head;
   while (tracit != NULL) {

      if (tracit->not_there == THERE) {
         if (((int)(drand48() * (double)100)) < percent_unlink)
            tracit->do_rm = POS_VAL;
      }

      tracit = tracit->next;
   }

   /*************************************************/
   /*  Fork off the child which will actually unlink the
    *  inode.
    */
   while ((childpid = fork()) < ZERO);

   if (childpid == ZERO) {
      tracit = file_head;
      while (tracit != NULL) {
         if (tracit->do_rm == POS_VAL) {

            if (tracit->my_type == S_IFDIR)
               err = rmdir(tracit->file_name);
            else
               err = unlink(tracit->file_name);

            if (err != ZERO)
               logit("do_unlinkit, unlink/rmdir failed", tracit->file_name);
         }
         tracit = tracit->next;
      }
      _exit(ZERO);
   }
   return(childpid);
}

struct f_list_t *it_failed(tracit)
struct f_list_t *tracit;
{
   if (tracit->my_type == S_IFDIR)
      tracit->rmpassfail = DIR_FAIL;
   else
      tracit->rmpassfail = FAIL;
   return(tracit);
}

/***********************************************/
/*  If the unlink process is done, check the
    result and reset the do_unlflag.
*/
int check_unlink(file_head, do_unlflag)
struct f_list_t *file_head;
int do_unlflag;
{
struct f_list_t *tracit;

   /****************************************************/
   /*  If the process doing the unlinks is not done,
    *  just return.
    */
   if (waitpid(do_unlflag, (int *)ZERO, WNOHANG) != do_unlflag)
      return(do_unlflag);

   /****************************************************/
   /*  Check to see if the files (inodes) marked for unlinking
    *  did get unlinked.  If so, mark the flag in the 
    *  file/directory information node.
    */
   tracit = file_head;
   while (tracit != NULL) {
      if (tracit->do_rm == POS_VAL) {
         if (tracit->not_there == THERE) {
            if (fileexist(tracit->file_name, tracit->my_type) == NOT_THERE) {
               tracit->do_rm = ZERO;
               tracit->rmpassfail = PASS;
               tracit->not_there = NOT_THERE;
            }
            else {
               tracit = it_failed(tracit);
            }
         }
      }
      tracit = tracit->next;
   }
   return(ZERO);
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

int do_error_data(f_list_node, linktofile, fno)
struct f_list_t *f_list_node, *linktofile;
int fno;
{
   logit("FILE TO LINK:  ", f_list_node->file_name);
   logit("FULL FILE NAME:", f_list_node->full_name);
   if (fileexist(f_list_node->file_name, f_list_node->my_type) == THERE)
      logit("EXISTENCE:     ", "file exists");
   else
      logit("EXISTENCE:     ", "file does NOT exist");
   if (f_list_node->not_there == THERE)
      logit("PERCEIVED:     ", "file exists");
   else
      logit("PERCEIVED:     ", "file does NOT exists");

   logit("LINK NAME:     ", linktofile->file_name);
   logit("FULL LINK NAME:", linktofile->full_name);
   if (fileexist(linktofile->file_name, linktofile->my_type) == THERE)
      logit("EXISTENCE:     ", "link exists");
   else
      logit("EXISTENCE:     ", "link does NOT exist");
   if (linktofile->not_there == THERE)
      logit("PERCEIVED:     ", "link exists");
   else
      logit("PERCEIVED:     ", "link does NOT exists");

   if (linktofile->my_type == S_IFREG)
      logit("LINK TYPE:     ", "HARD");
   else
      logit("LINK TYPE:     ", "SYMBOLIC");

   if (fno == ZERO)
      logit("APARENT ERROR: ", "none");
   else
      logit("APARENT ERROR: ", "link failed");

   logit("ERROR:         ", sys_errlist[errno]);
   logit("---------------", "----------------------------------");

   return(0);
}

int dolinkstuff(f_list_node, linktofile, gotlink, maxlink)
struct f_list_t *f_list_node, *linktofile;
int gotlink, maxlink;
{
int fno;

   if (linktofile->do_rm == POS_VAL)
      return(maxlink);

   if (linktofile->not_there == THERE) {

      if (linktofile->my_type == S_IFDIR) {
         if (unlink(linktofile->file_name) != ZERO)
            fno = rmdir(linktofile->file_name);
         else
            linktofile = it_failed(linktofile);
      }
      else {
         if (rmdir(linktofile->file_name) != ZERO)
            fno = unlink(linktofile->file_name);
         else
            linktofile = it_failed(linktofile);
      }
         
      if (fno != ZERO) {
         linktofile = it_failed(linktofile);
      }
      else {
         if (fileexist(linktofile->file_name, linktofile->my_type) == NOT_THERE)
            linktofile->not_there = NOT_THERE;
      }
   }

   if (linktofile->not_there == NOT_THERE) {

      if (f_list_node->my_type == S_IFDIR) {
         if (link(f_list_node->file_name, linktofile->file_name) == ZERO) {
            linktofile->not_there = THERE;
            linktofile->link_fail = FAIL;
            fno = NEG_VAL;
         }
         else {
            fno = symlink(f_list_node->file_name, linktofile->file_name);
            linktofile->my_type = S_IFLNK;
         }
      }
      else {
         if (((int)(drand48() * (double)1000)) > 500) {
            fno = link(f_list_node->file_name, linktofile->file_name);
            linktofile->my_type = S_IFREG;
         }
         else {
            fno = symlink(f_list_node->file_name, linktofile->file_name);
            linktofile->my_type = S_IFLNK;
         }
      }

      if (fno == ZERO) {
         if (fileexist(linktofile->file_name, linktofile->my_type) == THERE) {
            linktofile->not_there = THERE;
            linktofile->link_fail = PASS;
            gotlink++;
         }
         else {
            linktofile->link_fail = FAIL;
         }
      }
      else {
         linktofile->link_fail = FAIL;
      }

   }

   if ((linktofile->link_fail == FAIL) ||
       (linktofile->not_there == NOT_THERE)) {
      gotlink = maxlink;
      do_error_data(f_list_node, linktofile, fno);
   }

   return(gotlink);
}


/**************************************************/
/*   SUCKINODE

    this routine creates a bunch of 0 length
    files in an attempt to us up all of the
    inodes in a file system.
*/

struct f_list_t *suckinode(homedir, numinode, percent_unlink,
                           percent_dirs, dir_head, dircount, percent_alt_dirs)
char *homedir;
int numinode, percent_unlink, percent_dirs, dircount, percent_alt_dirs;
struct f_list_t *dir_head;
{
int error, itercount, main_did_create, fno, do_unlflag, fno2;
int maxlink, gotlink, dir_file_choice, i, goofy_number;
char *genname(), *workdir, **name_list;
struct f_list_t *f_list_node, *cr_new_f_list_node(), *put_in_file_list();
struct f_list_t *linktofile, *tracit;
struct f_list_t *file_head = NULL;

   name_list = (char **)malloc(dircount * sizeof(name_list));
   i = 0;
   tracit = dir_head;
   while (tracit != NULL) {
      name_list[i] = tracit->file_name;
      tracit = tracit->next;
      i++;
   }

   maxlink = gotlink = do_unlflag = main_did_create = itercount = ZERO;
   goofy_number = 17000;

   while (numinode > ZERO) {

      workdir = homedir;

      if (((int)(drand48() * (double)100.0)) < percent_alt_dirs) {
         workdir = name_list[((int)(drand48() * ((double)dircount + .8)))];
      }

      dir_file_choice = ((int)(drand48() * (double)100.0));

      /*******************************************************/
      /*  Create a node and add to file list 
       */
      f_list_node = cr_new_f_list_node();
      file_head = put_in_file_list(file_head, f_list_node);

      if (main_did_create > goofy_number) {
         itercount = (int)(main_did_create / 17000);
         goofy_number = 17000 * (itercount + 1);
      }

      /*******************************************************/
      /*  Generate a file name  
       */
      if (dir_file_choice > percent_dirs)
         f_list_node->file_name = genname(workdir, itercount, "ino");
      else
         f_list_node->file_name = genname(workdir, itercount, "dir");

      f_list_node->full_name = f_list_node->file_name;
      if (gotlink >= maxlink) {
         gotlink = 0;
         maxlink = (int)(drand48() * (double)10.0);
         linktofile = f_list_node;
      }

      /*******************************************************/
      /*  Since we are in the working directory, about half of
       *  the files we are working with will have their path
       *  names reduced to only the file name.  Just to start to
       *  make things interesting.
       */
      if (workdir == homedir) {
         if (((int)(drand48() * (double)100.0)) < 50) {
            f_list_node->file_name = _basename(f_list_node->full_name);
         }
      }

      /*******************************************************/
      /*  Create the file (inode)  
       */
      fno2 = openwcreat(f_list_node->file_name);
      unlink(f_list_node->file_name);
      close(fno2);
      if (dir_file_choice > percent_dirs) {
         fno = openwcreat(f_list_node->file_name);
         close(fno);
      }
      else {     
         fno = mkdir(f_list_node->file_name, 0777);
         f_list_node->my_type = S_IFDIR;
      }

      /*******************************************************/
      /*  If file successfully created, increment counters, 
       *  decrement loop control, close the file, flag file
       *  as created in inode info structure.             
       */
      if (fno != NEG_VAL) {

         main_did_create++;
         f_list_node->did_create = PASS;
         f_list_node->not_there = THERE;
         numinode--;

         if (((int)(drand48() * (double)100.0)) < percent_dirs) {
            if (mkdir(f_list_node->file_name, 0777) == ZERO) {
               f_list_node->my_type = S_IFDIR;
               f_list_node->did_create = DIR_FAIL;
            }
         }

         if (linktofile != f_list_node) {
            if (((int)(drand48() * (double)100.0)) > 96) {
               gotlink = dolinkstuff(f_list_node, linktofile, gotlink, maxlink);
            }
         }
      }
      else {
         f_list_node->did_create = FAIL;
         f_list_node->not_there = NOT_THERE;
      }

      /*******************************************************/
      /*  Maybe create a grandchild to do some unlinks  
       */
      if (percent_unlink != ZERO) {
         if (((int)(drand48() * (double)100)) > 96) {
            if (do_unlflag == ZERO) {
               do_unlflag = do_unlinkit(file_head, percent_unlink);
            }
         }
         /*******************************************************/
         /*  See if grandchild is done and reset flag if done  
          */
         if (do_unlflag != ZERO) {
            do_unlflag = check_unlink(file_head, do_unlflag);
         }
      }
   }

   /*******************************************************/
   /*  Make sure all grandchildren are done  
    */
   if (percent_unlink != ZERO) {
      while (do_unlflag != ZERO)
         do_unlflag = check_unlink(file_head, do_unlflag);
   }

   return(file_head);
}

/***********************************************/
/*  Find the pid that finished in the directory list
    and set the exit value to the process return value.
*/
int set_ex_stat(ret_pid, retval, dir_head)
int ret_pid, retval;
struct f_list_t *dir_head;
{
struct f_list_t *tracit;

   tracit = dir_head;
   while (tracit != NULL) {
      if (tracit->pid == ret_pid) {
         tracit->exitstat = retval;
         return(0);
      }
      tracit = tracit->next;
   }
   return(NEG_VAL);
}

/***********************************************/
/*  Parent waits for all file creation children
*/
int wait_for_kids(dir_head)
struct f_list_t *dir_head;
{
int ret_pid;
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

   while ((ret_pid = wait(&errstruct.retval)) != (NEG_VAL)) {
      set_ex_stat(ret_pid, errstruct.err.sherr, dir_head);
   }
}

/*********************************************************/
/*
   Check to see if a file name exists and that it is
   a file.
*/
int fileexist(filename, my_type)
char *filename;
int my_type;
{
struct stat buf;
int value = THERE;


   switch (my_type) {
      case S_IFLNK:
                    value = lstat(filename, &buf);
                    if ((S_IFMT & buf.st_mode) != S_IFLNK)
                       value = NOT_THERE;
                    break;

      case S_IFDIR:
                    value = stat(filename, &buf);
                    if ((S_IFMT & buf.st_mode) != S_IFDIR)
                       value = NOT_THERE;
                    break;

      case S_IFREG:
      default:
                    value = stat(filename, &buf);
                    if ((S_IFMT & buf.st_mode) != S_IFREG)
                       value = NOT_THERE;
                    break;
   }
   return(value);
}

int logit(filename, reason)
char *filename, *reason;
{
FILE *fp;

   fp = fopen("locerror", "a+");
   if (fp != NULL) {
      fprintf(fp, "%s:  %s\n", filename, reason);
      fclose(fp);
   }
   return(0);
}

/*****************************************************/
/*  Compare returned status with known flags to see
    if any errors were generated by the children and
    relayed to the parent (this process) in the exit
    status of the child.

     define FNR 001
     define FNC 002
     define CNU 004
     define RBS 010
*/

int check_status(file_head, file_type)
struct f_list_t *file_head;
int file_type;
{
struct f_list_t *tracit;
int error_status;

   error_status = ZERO;

   tracit = file_head;
   while (tracit != NULL) {

      /****************************************************/
      /*  Set File Not Removed error
       */
      if (tracit->rmpassfail == FAIL) {
         error_status = error_status | FNR;
         logit(tracit->file_name, "FLY:  File Not Removed");
      }

      if (tracit->rmpassfail == DIR_FAIL) {
         error_status = error_status | DNR;
         logit(tracit->file_name, "FLY:  Directory Not Removed");
      }

      /****************************************************/
      /*  Set File Not Created error
       */
      if (tracit->did_create != PASS) {
         if (tracit->did_create == DIR_FAIL) {
            error_status = error_status | CDN;
            logit(tracit->file_name, "Created Directory Over Existing Node");
         }
         else {
            error_status = error_status | FNC;
            logit(tracit->file_name, "File/Directory Not Created");
         }
      }

      /****************************************************/
      /*  Set Returned Bad file/directory Status error
       */

      /****************************************************/
      /*  Set link not created error
       */
      if (tracit->link_fail == FAIL) {
         error_status = error_status | LNF;
         logit(tracit->file_name, "Link Not Created");
      }

      /****************************************************/
      /*  If file allegedly exists ...
       */
      if (tracit->not_there == THERE) {

         /****************************************************/
         /*  Check the status
          */
         if (fileexist(tracit->file_name, tracit->my_type) != THERE) {
            error_status = error_status | RBS;
            logit(tracit->file_name, "File/Directory/Link Bad Status");
         }

         /****************************************************/
         /*  Try and remove inode.  If unlink fails, set
          *  Could Not Unlink error.
          */
         if (tracit->my_type == S_IFDIR) {
            if (rmdir(tracit->file_name) != ZERO) {
               error_status = error_status | DNU;
               logit(tracit->file_name, "END:  Directory Not Removed");
            }
         }
         else {
            if (unlink(tracit->file_name) != ZERO) {
               error_status = error_status | CNU;
               logit(tracit->file_name, "END:  File Not Unlinked");
            }
         }
      }
      /****************************************************/
      /*  If file allegedly does not exist ...
       */
      else {
         /****************************************************/
         /*  Check the status
          */
         if (fileexist(tracit->file_name, tracit->my_type) == THERE) {
            error_status = error_status | RBS;
            logit(tracit->file_name, "File/Directory Exists, Should Not");
         }
      }

      tracit = tracit->next;
   }
   return(error_status);
}

/***********************************************/
/*  Generate all of the files at each of the
    various subdirectory levels using a seperate
    process for each created directory.
*/
int gen_files(file_per_level, percent_unlink, dir_head, percent_dirs,
              dircount, percent_alt_dirs)
int file_per_level, percent_unlink, percent_dirs, dircount, percent_alt_dirs;
struct f_list_t *dir_head;
{
struct f_list_t *tracit, *file_head, *suckinode();
int childpid, fork(), ex_status = ZERO;

   tracit = dir_head;
   while (tracit != NULL) {
      if (tracit->did_create == POS_VAL) {
         childpid = fork();
         if (childpid == ZERO) {
            srand48(time((long *)0) + getpid());
            if (((int)(drand48() * (double)100)) > 25) {
               setsid();
            }
            else {
               setpgrp();
            }
            chdir(tracit->file_name);
            tracit->pid = getpid();
            file_head =
                   suckinode(tracit->file_name, file_per_level,
                             percent_unlink, percent_dirs, dir_head,
                             dircount, percent_alt_dirs);
            ex_status = check_status(file_head, ZERO);
            _exit(ex_status);
         }
         else {
            tracit->pid = childpid;
         }
      }
      tracit = tracit->next;
   }
   wait_for_kids(dir_head);
}

/***********************************************/
/*  Figure out how many directories to expect.
    Also tells how many process will be generated
    by the parent to create files in the directories.
*/
int calc_dirs(dir_per_level, num_levels)
int dir_per_level, num_levels;
{
int i, j, k, ex_num_dirs;

   ex_num_dirs = ZERO;

   for (i = ZERO; i < num_levels; i++) {
      k = dir_per_level;
      for (j = ZERO; j < i; j++) {
         k = k * dir_per_level;
      }
      ex_num_dirs = ex_num_dirs + k;
   }
   return(ex_num_dirs);
}

/***********************************************/
/*  If error statuses were returned by the children,
    generate appropriate error messages for each
    directory process.
*/
int process_error(tracit)
struct f_list_t *tracit;
{
   if (tracit->exitstat & FNR)
      fprintf(stderr, "suckinode: File(s) not removed in directory %s\n",
              tracit->file_name);

   if (tracit->exitstat & FNC)
      fprintf(stderr, "suckinode: File(s) not created in directory %s\n",
              tracit->file_name);

   if (tracit->exitstat & CNU)
      fprintf(stderr, "suckinode: File(s) not unlinked in directory %s\n",
              tracit->file_name);

   if (tracit->exitstat & RBS)
      fprintf(stderr, "suckinode: Bad file status(es) in directory %s\n",
              tracit->file_name);

   if (tracit->exitstat & LNF)
      fprintf(stderr, "suckinode: Link(s) not created in directory %s\n",
              tracit->file_name);

   if (tracit->exitstat & DNU)
      fprintf(stderr, "suckinode: Directory(s) not removed in directory %s\n",
              tracit->file_name);

   if (tracit->exitstat & DNR)
      fprintf(stderr, "suckinode: Directory(s) not removed in directory %s\n",
              tracit->file_name);

   if (tracit->exitstat & CDN)
      fprintf(stderr, "suckinode: Created directory over existing node %s\n",
              tracit->file_name);
}

int explain_tool()
{
   printf("suckinode -f [files_per_directory] -d [diretories_per_level]\n");
   printf("          -l [number_of_levels] -u [percent_of_files_to_unlink]\n");
   printf("          -D [percent_to_be_dirs] -A [percent_in_other_dirs]\n");
   printf("          -F [run_directory] -h\n\n");
   printf("-f [files_per_directory]         if not specified, default 25\n");
   printf("-d [diretories_per_level]        default 2\n");
   printf("-l [number_of_levels]            default 2\n");
   printf("-u [percent_of_files_to_unlink]  default 0\n");
   printf("-D [percent_to_be_dirs]          default 0\n");
   printf("-A [percent_in_other_dirs]       default 0\n");
   printf("-F [run_directory]               default /tmp\n");
   printf("-h                               print this help\n\n");

   printf("command:         suckinode\n");
   printf("is the same as:  suckinode -f 25 -d 2 -l 2 -u 0 -F /tmp\n");
   exit(POS_VAL);
}

main(argc, argv)
int argc;
char **argv;
{ 
struct f_list_t *dir_head = NULL;
struct sigaction act, oact;
struct f_list_t *gen_dir_levels(), *tracit;
int c, dir_per_level, file_per_level, num_levels, percent_unlink;
int percent_dirs, passfail, percent_alt_dirs, ex_num_dirs = ZERO;
char *workdir;

static char *optstring = "?d:f:l:u:F:D:A:";
extern char *optarg;
void dir_exit();

   workdir = (char *)malloc(5);
   sprintf(workdir, "/tmp\0");

   dir_per_level = num_levels = 2;
   file_per_level = 25;
   percent_alt_dirs = percent_dirs = percent_unlink = ZERO;

   while ((c=getopt(argc, argv, optstring)) != EOF) {
      switch (c) {
         case 'A':
                   if ( sscanf(optarg, "%d%c", &percent_alt_dirs) != 1) {
                      fprintf(stderr, "ERROR:  -D argument must be numeric\n");
                      explain_tool();
                   }
                   percent_alt_dirs = atoi(optarg);
                   break;

         case 'F':
                   free(workdir);
                   workdir = optarg;
                   if (fileexist(workdir, S_IFDIR) != 0) {
                      fprintf(stderr, "ERROR:  directory %s does not exist\n",
                              workdir);
                      explain_tool();
                   }
                   break;

         case 'D':
                   if ( sscanf(optarg, "%d%c", &percent_dirs) != 1) {
                      fprintf(stderr, "ERROR:  -D argument must be numeric\n");
                      explain_tool();
                   }
                   percent_dirs = atoi(optarg);
                   break;

         case 'd':
                   if ( sscanf(optarg, "%d%c", &dir_per_level) != 1) {
                      fprintf(stderr, "ERROR:  -d argument must be numeric\n");
                      explain_tool();
                   }
                   dir_per_level = atoi(optarg);
                   break;

         case 'f':
                   if ( sscanf(optarg, "%d%c", &file_per_level) != 1) {
                      fprintf(stderr, "ERROR:  -f argument must be numeric\n");
                      explain_tool();
                   }
                   file_per_level = atoi(optarg);
                   break;

         case 'l':
                   if ( sscanf(optarg, "%d%c", &num_levels) != 1) {
                      fprintf(stderr, "ERROR:  -l argument must be numeric\n");
                      explain_tool();
                   }
                   num_levels = atoi(optarg);
                   break;

         case 'u':
                   if ( sscanf(optarg, "%d%c", &percent_unlink) != 1) {
                      fprintf(stderr, "ERROR:  -u argument must be numeric\n");
                      explain_tool();
                   }
                   percent_unlink = atoi(optarg);
                   break;

         case 'h':
         default:
                   explain_tool();
                   exit(POS_VAL);
      }
   }

   ex_num_dirs = calc_dirs(dir_per_level, num_levels);

   dir_head = gen_dir_levels(num_levels, dir_per_level, dir_head, workdir);

   act.sa_handler = dir_exit;
   act.sa_mask = ZERO;
   act.sa_flags = ZERO;
   sigaction(SIGINT, &act, &oact);

   printf("NUMBER OF DIRECTORIES -- EXPECTED:  %d\n", ex_num_dirs);
   printf("                         ACTUAL:    %d\n", dircount);
   printf("NUMBER OF FILES TO BE CREATED:      %d\n",
           file_per_level * dircount);

   srand48(time((long *)0));

   gen_files(file_per_level, percent_unlink, dir_head, percent_dirs,
             dircount, percent_alt_dirs);

   passfail = clean_up(dir_head);

   if (passfail == ZERO)
      printf("suckinode:  Test Passed\n");
   else
      printf("suckinode:  Test Failed\n");

   exit(passfail);
}
