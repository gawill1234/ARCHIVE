#include <stdio.h>
#include <time.h>
#include <sys/utsname.h>
#ifdef CRAY
#include <sys/target.h>
#endif

#include "struct.h"
#include "defs.h"


main(argc, argv)
int argc;
char **argv;
{
extern char *optarg;
extern int optind;

FILE *listfp, *openfile(), *noproc;
char *oneline, *fgets(), *malloc(), *dircheck();
struct prodstruct *aprod, *getparts(), *getpartsls();
struct exec_list *treeroot, *searchnadd();
struct utsname *osinfo, *get_os();
struct tm *today, *get_today();
struct target *machtarg, *get_target();
char *curdir, *getcwd();
char *iofile, *iostart, *newiostart, *dirnameuse;
int fileage, newdirflag;
int c, i, magicflag, sizeflag, driveronly, imadeit;
long timeinsec, problems;

static char *optstring = "smt:f:d:D";
static char usage[] = "Usage:  ivt [-m] [-s] [-f file_name] [-d start_directory] [-t max_file_age]";

/***********************************************************/
/*  START 1  */
/*  Initialize the stuff needed to process command line
    arguments.
*/
   treeroot = NULL;
   problems = 0;
   newdirflag = imadeit = driveronly = sizeflag = magicflag = fileage = 0;
   iofile = iostart = NULL;
   curdir = getcwd((char *)NULL, 256);
/*  END 1  */
/***********************************************************/

/***********************************************************/
/*  START 2  */
/*   Process the command line using getopt().
*/

   while ((c=getopt(argc, argv, optstring)) != EOF) {

      switch (c) {
         case 'd':
                   iostart = optarg;
                   break;
         case 'f':
                   iofile = optarg;
                   break;
         case 't':
                   fileage = atoi(optarg);
                   break;
         case 'm':
                   magicflag = 1;
                   break;
         case 's':
                   sizeflag = 1;
                   break;
         case 'D':
                   driveronly = 1;
                   break;
         default:
                   fprintf(stderr, "%s\n",usage);
                   exit(1);
      }

   }
/*  END 2  */
/***********************************************************/

/***********************************************************/
/*  START 3  */
/*   Initialize any arguments that were not initialized by the
     user to the default settings.
*/
   if (fileage == 0)
      fileage = 12;

   if (iofile == NULL) {
      iofile = malloc(4);
      strcpy(iofile, ".dt");
   }

   if (iostart == NULL) {
      iostart = curdir;
   }
/*  END 3  */
/***********************************************************/
/***********************************************************/
/*  START 4  */
/*   Check arguments to make sure they are valid and
     exist.
*/

   if (direxist(iostart) != 0) {
      fprintf(stderr,"Starting directory:  %s\n", iostart);
      fprintf(stderr,"Start point does not exist or is not a directory\n");
      fprintf(stderr, "%s\n",usage);
      exit(1);
   }

   if (fileexist2(iofile) != 0) {
      if (driveronly == 1) {
         newiostart = (char *)malloc(256);
         sprintf(newiostart, "ls -l %s > %s\0", iostart, iofile);
         system(newiostart);
         free(newiostart);
         imadeit = 1;
      }
      else {
         fprintf(stderr,"Input file name:  %s\n", iofile);
         fprintf(stderr,"Input file does not exist or name is not for a file\n");
         fprintf(stderr, "%s\n",usage);
         exit(1);
      }
   }
/*  END 4  */
/***********************************************************/
/***********************************************************/
/*  START 5  */
/*   Initialize what remains to be initialized and print out
     headings.
*/

   timeinsec = time((long *)0);
   today = get_today(timeinsec);
   osinfo = get_os();
#ifdef CRAY
   machtarg = get_target();
   prhder(iostart, osinfo, today, machtarg);
#else
   prhder(iostart, osinfo, today);
#endif
/*  END 5  */
/***********************************************************/

   listfp = openfile(iofile, "r");
   if (listfp != NULL) {
      noproc = openfile("inerrlog", "w+");
      fprintf(noproc,"THE FOLLOWING INPUT RECORDS WERE IGNORED:\n");
      oneline = (char *)malloc(LINELEN);
      dirnameuse = (char *)malloc(strlen(iostart) + 1);
      strcpy(dirnameuse, iostart);
      while ((oneline = fgets(oneline, LINELEN, listfp)) != NULL) {
         newiostart = (char *)dircheck(oneline, iostart, listfp);
         if (newiostart != NULL) {
            if (direxist(dirnameuse) == 0) {
               problems = problems + backcheck(dirnameuse, treeroot);
            }
            free(dirnameuse);
            dirnameuse = newiostart;
            newdirflag = 1;
         }
         else {
            aprod = getpartsls(oneline, curdir, dirnameuse);
         }
         if (aprod != NULL) {
            (void)all_do(aprod, today, machtarg, curdir, fileage,
                         timeinsec, magicflag, sizeflag);
            if (aprod->nameout != 0) {
               problems++;
               printf("___________________________________________________\n\n");
            }
            if ((aprod->notfound == 0)) {
               treeroot = searchnadd(aprod, treeroot);
            }
            freeaprod(aprod);
         }
         else {
            if (newdirflag != 1) {
               fprintf(noproc, "%s\n", oneline);
            }
            newdirflag = 0;
         }
         for (i = 0; i < LINELEN; i++)
            oneline[i] = '\0';
      }
      fclose(listfp);
      fclose(noproc);
      problems = problems + backcheck(dirnameuse, treeroot);
/*
      dumper(treeroot, 0);
*/
   }

   if (problems > 0)
      printf("TOTAL NUMBER OF PROBLEM UNITS:  %d\n", problems);

   exit(problems);
}

