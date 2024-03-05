static char USMID[] = "@(#)uttmp/rrl/fs/tests/lkrm.c	10.2	05/25/94 15:06:19";

/*
 *	(C) COPYRIGHT CRAY RESEARCH, INC.
 *	UNPUBLISHED PROPRIETARY INFORMATION.
 *	ALL RIGHTS RESERVED.
 */

/**
 *
 * This program will tests that a lock is released when a file
 * is removed.  If the -S option is not used,  this test can be
 * run on non-SFS systems.
 *
 * This program will open (create) a file
 *	if -S option used, assign a semaphore
 *	either 1 or 2.
 *	1)   unlink file
 *	     close  file
 *
 *	2)   close file
 *	     unlink file
 */


#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/file.h>
//#include <sys/iosw.h>
//#include <sys/listio.h>
//#include <sys/panic.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
//#include <values.h>
#include <string.h>
#include <signal.h>
//#include <malloc.h>
#include <sys/wait.h>
#include <time.h>


/*
 *  One of these structures foreach file specified on cmd line.
 */
struct file_info_t {
   char *filename;
   int  fd;
   int  sema;
};

/*
 * Define struct that contains options defaults and user specified values
 */
typedef struct {
    int   background;           /* if set - background */
    int   num_procs;            /* num or procs (childern) */
    int   iterations;           /* main loop iterations */
    int   onerror;              /* exit on error if set */
    int   semaphore;            /* Use semaphore if set */
    int   verbose;
    int   unlink_first;		/* if set, unlink before close */
    int   num_files;            /* number of files */
    int   cleanup;
    int   time_iterval;
    int   allocspace;		/* amount of space to alloc */
    int   wsize;		/* amount of data to write to file */
    struct file_info_t *file_info; /* pointer to filename information */

  } options_t;

void checkerror();
void help();
void prt_examples();
void usage();
int cleanup();
void sig_handler();
// extern char *sys_errlist[];
/*
 * globals
 */

char *Progname;
options_t *options;

/***********************************************************************
 * main
 ***********************************************************************/
int
main(int ac, char **av, char **ep)
{
  int ret;              /* function ret value */
  int ii, jj;           /* tmp indexes or counter */
  int fd;               /* current file descriptor */
  int loop_cnt;         /* loop counter */
  int lkind;            /* lock index */
  int find;             /* file index */
  int exind;            /* exit index */
  options_t *parse_command_line();
  int pid;              /* current pid */
  char *errmsg;         /* error/info message */
  long lkcnt = 0;       /* number of file locks thus far */
  char *fname;          /* filename currently dealing with */
  char *desc;           /* description of lock currently working on */
  int error = 0;
  struct stat statbuf;
  int nfiles;
  time_t start_time;
  char *dataspace;


  /*
   * start execution
   */

  Progname=av[0];

  options = parse_command_line(ac, av);

  if ( options->background )
    background();                       /* give user their prompt back */

  pid=getpid();


/****  Have to fix problem using the same filename first
  forker(options->num_procs, 1);
*****/

  pid=getpid();

  signal(SIGINT, sig_handler);
  signal(SIGQUIT, sig_handler);
  // signal(SIGCPULIM, sig_handler);
  // signal(SIGSHUTDN, sig_handler);

  nfiles = options->num_files;

  start_time = time(0);

  if ( options->wsize > 0 ) {
	if ( (dataspace=(char *)malloc(options->wsize)) == NULL ) {
	    fprintf(stderr, "%s: Unable to malloc(%d), no data written to the files\n",
		Progname, options->wsize);
	    options->wsize=0;
	}
  }

  /*
   * Loop the specified number of iterations
   */

  for (loop_cnt = 0; options->iterations == 0 || options->time_iterval == 0 ||
    loop_cnt < options->iterations ||
    ((options->time_iterval > 0) &&
    (start_time + options->time_iterval > time(0) )); loop_cnt++) {


    /*
     * Loop on each file
     */
    for (find = 0; find < options->num_files; find++) {

	fname = options->file_info[find].filename;

/****
printf("fname = %s\n", fname);
****/

	/*
	 * open file/create
	 */
	if ( options->file_info[find].fd == -1 ) {
		continue;	/* skipping file couldn't open before */
	}

	if ((fd = open(fname, O_RDWR|O_APPEND|O_CREAT|O_EXCL, 0666, NULL)) == -1){

	    printf("skipping file %s\n", fname);
	    options->file_info[find].fd=-1;	/* skip from now on */

	    /*
	     * detect that no files can be opened
	     */
	    nfiles--;
	    if ( nfiles == 0 ) {
	        fprintf(stderr, "%s: pid=%d No files can be opened, stopping\n",
	            Progname, pid);
	        cleanup();
	        exit(5);
	    }
	    continue;		/* skipping since couldn't open it */
	} 
	options->file_info[find].fd=fd;	 /* done only for cleanup and signals */

	/*
	 * Assign semaphore
	 */
/******
/**	if ( options->semaphore ) {
/**
/**	    if (file_sema(fd, F_ASSEMA, &errmsg) < 0 ) {
/**             fprintf(stderr, "%s: pid=%d file=%s (assigning) %s\n", Progname,
/**		    pid, fname, errmsg);
/**		options->file_info[find].sema=0;
/**	        error=1;
/**	    }
/**	    else if ( options->verbose ) {
/**		fprintf(stdout, "%s: (assigning) %s\n", Progname, errmsg);
/**		options->file_info[find].sema=1;
/**	    }
/**
/**	    /*
/**	     * Get inum and dev - used to determine if sema is released
/**	     */
/**	    if ( fstat(fd, &statbuf) < 0 ) {
/**	        fprintf(stderr, "%s: Unable to fstat(%d, &statbuf) errno=%d %s\n",
/**		    Progname, fd, errno, sys_errlist[errno]);
/**	        error=1;
/**	    }
/**	}
/**********/

	if ( options->allocspace > 0 ) {
	    if ( ialloc(fd, options->allocspace, 0, 0) == -1 ) {
                fprintf(stderr, "%s: Unable to ialloc(fd, %d, 0, 0) errno=%d %s\n",
		    Progname, options->allocspace, errno, sys_errlist[errno]);
	        error=1;
	    }
	}

	if ( options->wsize > 0 ) {
	    if ( write(fd, dataspace, options->wsize) == -1 ) {
                fprintf(stderr, "%s: Unable to write(fd, data, %d) errno=%d %s\n",
		    Progname, options->wsize, errno, sys_errlist[errno]);
	        error=1;
	    }
	}
	
	/*
	 * unlink file
	 */

	if ( options->unlink_first ) {
	    if ( unlink(fname) != 0 ) {
	        fprintf(stderr, "%s: Unable to unlink(%s) errno=%d %s\n", Progname,
		    fname, errno, sys_errlist[errno]);
	        error=1;
	    }
	}

/*****
idea: do writes  - Especially after unlink has happened
What about file locks on unlinked file.
record file locks on file - on SFS - only get file locks
*****/

	/*
	 * close file
	 */
	close(fd);

	if ( ! options->unlink_first ) {
            if ( unlink(fname) != 0 ) {
                fprintf(stderr, "%s: Unable to unlink(%s) errno=%d %s\n", Progname,
                    fname, errno, sys_errlist[errno]);
                error=1;
            }
        }


        fflush(stdout);
        fflush(stderr);

     } /* end of file loop */
  } /* end iterations loop */

  printf("%s: PASS %d iterations, %d files\n", Progname, options->iterations, nfiles);
  fflush(stdout);

  exit(0);
}

/***********************************************************************
 * Cleanup - release semaphores and close files
 ***********************************************************************/
int
cleanup ()
{
    int ind;
    char *msg;

/****
    if ( options->semaphore ) {
        for ( ind=0; ind < options->num_files; ind++)
	    if ( options->file_info[ind].sema ) {
                file_sema(options->file_info[ind].fd, F_RLSEMA, &msg);
                fprintf(stderr, "%s: pid=%d (releasing) %s\n", Progname, getpid(), msg);
	    }
    }
****/

    for ( ind=0; ind < options->num_files; ind++)
        if ( options->file_info[ind].fd > 0 )
            close(options->file_info[ind].fd);


    if ( options->cleanup ) {
	for ( ind=0; ind < options->num_files; ind++)
	    unlink(options->file_info[ind].filename);
    }
    return 0;
}

/***********************************************************************
 * Sig_handler - prints error message and calls cleanup
 ***********************************************************************/
void
sig_handler(sig)
int sig;
{
    fprintf(stderr, "%s: Received unexpected signal %d\n", Progname, sig);
    cleanup();
    exit(sig);
}

/***********************************************************************
 * parse_command_line - Sets defaults on options and parses command
 * line options.  It will fill in the options structure.
 ***********************************************************************/
options_t *
  parse_command_line(int ac, char **av)
{

  int c;
  static options_t options;
  int nfiles;
  int errors = 0;
  char *chrptr;
  int msize;
  int lock_type = 0;
  int ind;

  extern char *optarg;
  extern int optind;

  /*
   * set default values
   */
  options.num_procs = 1;
  options.iterations = 1;
  options.background = 1;
  options.onerror = 0;
  options.semaphore = 0;
  options.verbose = 0;
  options.unlink_first = 1;
  options.cleanup = 0;
  options.time_iterval = -1;
  options.wsize = 0;
  options.allocspace = 0;

  while ((c = getopt(ac, av, "a:bCchEw:i:I:Ot:v")) != -1)
    switch(c) {

    case 'C':
	options.cleanup++;
	break;

    case 'b':   /* batch */
        options.background=0;
        break;

    case 'E' :
        prt_examples(stdout);
        exit(0);
        break;

    case 'h':
        help();
        exit(0);
        break;

    case 'c':	/* close first */
	options.unlink_first=0;
	break;

    case 'i':
        if (sscanf(optarg, "%i", &options.iterations) != 1 ) {
            fprintf(stderr, "%s: --i option arg is invalid, must integer\n",
                Progname);
            exit(1);
        }
      break;

    case 'a':
        if (sscanf(optarg, "%i", &options.allocspace) != 1 ) {
            fprintf(stderr, "%s: --a option arg is invalid, must integer\n",
                Progname);
            exit(1);
        }
      break;

    case 'w':
        if (sscanf(optarg, "%i", &options.wsize) != 1 ) {
            fprintf(stderr, "%s: --s option arg is invalid, must integer\n",
                Progname);
            exit(1);
        }
      break;

/*     case 'l':   /* lock types: s - shared, e -exclusive */
/*                 /*   p - polled, b - blocked */
/*         chrptr=optarg;
/*         while ( *chrptr ) {
/*            switch( *chrptr ) {
/*                 case 'e':
/*                     lock_type |= LOCK_EXCL;
/*                     break;
/* 
/*                 case 's':
/*                     lock_type |= LOCK_SHARED;
/*                     break;
/* 
/*                 case 'p':
/*                     lock_type |= LOCK_USER_POLL;
/*                     break;
/* 
/*                 case 'b':
/*                     lock_type |= LOCK_BLOCKED;
/*                     break;
/* 
/*                 default:
/*                     fprintf(stderr,
/*                        "%s: -l arg invalid: s-shar, e-excl, p-poll, b-blked\n");
/*                     exit(1);
/*                     break;
/*            }
/*            chrptr++;
/*         }
/*         if ( lock_type ) {
/*             for (ind=0; Lock_info[ind].desc; ind++)
/*                 if ( lock_type != (Lock_info[ind].lock_type & lock_type ))
/*                     Lock_info[ind].use=0;
/*         }
/*         break;
/* 
/*     case 'n':                   /* # dupicate processes */
/*         if (sscanf(optarg, "%i", &options.num_procs) != 1 ) {
/*             fprintf(stderr, "%s: --n option arg is invalid, must integer\n",
/*                 Progname);
/*             exit(1);
/*         }
/*       break;
/* ***/

    case 'O':
	options.onerror++;
	break;

    case 't':
	if ( sscanf(optarg, "%i", &options.time_iterval) != 1 ||
	    options.time_iterval < 0 ) {
	    fprintf(stderr, "%s: --t option must be a number\n", Progname);
	    exit(1);
        }
	break;


    case 'v':
	options.verbose++;
	break;

    case '?':
	++errors;
	break;
    }

    if ((nfiles = ac - optind) == 0) {
        fprintf(stderr, "%s: need at least one file name\n",*av);
      ++errors;
    }

    if (errors) {
        usage(stderr, Progname);
        errno = EINVAL;
      exit(errno);
    }

    /*
     * get space for file information
     */
    msize=(nfiles+1)*sizeof(struct file_info_t);

/****
printf("nfiles = %d, optind = %d, ac = %d\n", nfiles, optind, ac);
printf("msize = %d, sizeof(struct file_info_t) = %d\n", msize,
       sizeof(struct file_info_t))
;
****/

    if ((options.file_info = (struct file_info_t *)malloc(msize)) == NULL) {
        perror("malloc(ptrs for file_info)");
        exit(errno);
    }


    for (c=0; optind < ac; c++,optind++) {
        options.file_info[c].filename = av[optind];
        options.file_info[c].fd = 0;
    }

    options.file_info[c].filename = NULL;
    options.num_files = nfiles;

    return &options;

}       /* end of parse_command_line */

/***********************************************************************
 * Usage
 ***********************************************************************/
void
usage(FILE *stream, char *progname)
{

  fprintf(stream, "Usage: %s [-hbCcEOSv]", progname);
  fprintf(stream, "\t[-a allocsz][-i iterations][-t seconds][-w writesz] file [file..]\n");
/***
  fprintf(stream, "\t[-f outfile][-i iterations][-n copies]  file [file..]\n");
***/


  return;

}       /* end of usage */

/***********************************************************************
 * help
 ***********************************************************************/
void
help()
{
  usage(stdout, Progname);
  printf("  -a allocsz Amount of space to alloc to file (def 0)\n");
  printf("  -h         print this help message and exit\n");
  printf("  -b         Specified to run command in batch mode\n");
  printf("  -C         Cleanup when done\n");
  printf("  -c         Specified to close file before unlink (def unlink first)\n");
  printf("  -E         print example command lines\n");
  printf("  -i iter    The number of iterations (def 1)\n");
  printf("  -O         exit on error flag is set\n");
/***
  printf("  -f outfile The stderr output filename (def stderr)\n");
  printf("  -l lock_type  Specifies which type of locks are used (def bpse)\n");
  printf("              s - shared, e -exclusive && b - blocked, p - polled\n");
  printf("  -n copies  Number of childern doing same thing (def 1)\n");
  printf("  -S         Use semaphore locking when possible\n");

***/
  printf("  -w wsize   Amount of data written to files (def 0)\n");
  printf("  -t seconds loop for seconds seconds\n");
  printf("  -v         verbose mode - prt sema assignments\n");

  return;

}       /* end of help */

/***********************************************************************
 * prt_examples - prints examples cmd lines
 ***********************************************************************/
void
prt_examples(FILE *stream)
{
   fprintf(stream, "%s -i 0 /tmp/rmfile1\n", Progname);
   fprintf(stream, "%s -t 600 -i 100000 -C /tmp/rmfile2\n", Progname);
   fprintf(stream, "%s -i 0 -S /sfs/rmfile1\n", Progname);
   fprintf(stream, "%s -i 0 -a 5000 rmfile3\n");
   fprintf(stream, "%s -i 0 -w 4097 rmfile4\n");
   return;

}       /* end of prt_examples */

/***********************************************************************
 * checkerror - exits/panics if specified by user
 ***********************************************************************/
void
checkerror()
{

   fflush(stderr);
   if(options->onerror) {
     cleanup();
     exit(9);
   }
   return;
}




