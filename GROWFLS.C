static char USMID[] = "@(#)uttmp/ss43/tests/growfiles.c	10.6	11/15/93 12:07:24";

/*
 *	(C) COPYRIGHT CRAY RESEARCH, INC.
 *	UNPUBLISHED PROPRIETARY INFORMATION.
 *	ALL RIGHTS RESERVED.
 */

/*
 * This program will grow a list of files.
 * Each file will grow by grow_incr before the same
 * file grows twice.  Each file is open and closed before next file is opened.
 *
 * To just verify file contents: growfiles -g 0 -c 1 filename
 *
 * link with file_size.o dataascii.o
 */
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <fcntl.h>
#include <sys/file.h>
#include <sys/unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/param.h>
#include <sys/map.h>
#include <sys/signal.h>
#include <errno.h>


#ifdef CRAY
#include <sys/panic.h>
#endif

extern int errno;
extern char *sys_errlist[];
void usage();
void help();
void prt_examples();
int set_sig();
void sig_handler();


#ifndef PATH_MAX
#define PATH_MAX	1023
#endif


#define DEF_DIR		"."
#define DEF_FILE	"gf"

#define SYSERR  sys_errlist[errno]

char *Progname;
int Debug  = 0;

int Pid;

int io_type = 0;				/* I/O type -sync */
int open_flags = O_RDWR|O_APPEND|O_CREAT;	/* open flags */

#define MAX_FC_READ	204800		/* 4096 * 50 - 50 blocks */

int num_files = 0;		/* num_auto_files + cmd line files */
char *filenames;		/* pointer to space containing filenames */
int remove_files = 0;		/* if set, cleanup default is not to cleanup */
int bytes_consumed = 0;		/* total bytes consumed, all files */
int bytes_to_consume = 0;   	/* non-zero if -B was specified, total bytes */
int Maxerrs = 100;

/***********************************************************************
 * MAIN
 ***********************************************************************/
main(argc, argv)
int argc;
char **argv;
{
extern char *optarg;            /* used by getopt */
extern int optind;
extern int opterr;

int verbose = 0;
int ind;
int first_file_ind = 0;
int num_auto_files = 0;		/* files created by tool */
int seq_auto_files = 0;		/* auto files created by tool created by tool */
char *auto_dir = DEF_DIR;
char *auto_file = DEF_FILE;
int grow_incr = 4096;
int trunc_incr = 4096;
int trunc_inter = 0;		/* 0 means none, */
int write_check_inter = 1;	/* 0 means never, 1 means always */
int iterations = 1;		/* number of increments to be added */
int no_write = 0;
int num;
int error = 0;
int fd;				/* file descriptor */
int stop = 0;			/* loop stopper if set */
char chr;
int ret;
int pre_alloc_space = 0;
int upanic_after_write = 0;
int total_grow_value;		/* used in pre-allocations */
int backgrnd = 1;		/* return control to user */
struct stat statbuf;
int time_iterval = -1;
time_t start_time;
int oldsize;
int newsize;
char reason[40];		/* reason for loop termination */

char *errmsg;
char *write_buf;
char *read_buf;
char *strrchr();

char *filename;                 /* name of file specified by user */

	/*
	 * Determine name of file used to invoke this program
	 */
	if ((Progname=strrchr(argv[0], '/')) != NULL)
		Progname++;
	else
		Progname=argv[0];

	/*
	 * Process options
	 */
/***
auto_dir
auto_file
seq_auto_files
num_auto_files
Debug
write_check_inter
grow_incr
iterations
pre_alloc_space
upanic_after_write
trunc_incr
trunc_inter
no_write

 ****/

	while ((ind=getopt(argc, argv, "hB:Cc:bd:D:e:Ef:g:I:i:L:N:o:pPwt:S:T:u")) != EOF) {
		switch(ind) {

		case 'h' :
			help();
			exit(0);

		case 'B':
			switch (sscanf(optarg, "%i%c",
				   &bytes_to_consume, &chr)) {
			case 1: /* noop */
			        break;

			case 2:
				if (chr == 'b') {
				    bytes_to_consume *= BSIZE;
				} else {
				    fprintf(stderr, "%s:  --B option arg invalid\n");
				    usage();
				    exit(1);
				}
				break;

			default:
				fprintf(stderr, "%s: --B option arg invalid\n",
					Progname);
				usage();
				exit(1);
				break;
			}

			break;

		case 'E' :
			prt_examples(stdout);
			exit(0);

		case 'b' :	/* batch */
			backgrnd=0;
			break;

		case 'C':
			break;

		case 'd':
			auto_dir=optarg;
			unsetenv("TMPDIR");	/* force the use of auto_dir */
			if ( stat(auto_dir, &statbuf) == -1 ) {
			    if ( mkdir(auto_dir, 0777) == -1 ) {
				fprintf(stderr, "%s: Unable to make dir %s\n", 
				    Progname, auto_dir);
				exit(1);
			    }
			}
			else {
			    if ( ! (statbuf.st_mode & S_IFDIR) )  {
				fprintf(stderr,
				    "%s: %s already exists and is not a directory\n",
				    Progname, auto_dir);
				exit(1);
			    }
			}
			break;

		case 'D':
			if (sscanf(optarg, "%i", &Debug) != 1 ) {
				fprintf(stderr, "%s: --D option arg invalid\n",
					Progname);
				usage();
				exit(1);
			}
			break;

		case 'c':
			if (sscanf(optarg, "%i", &write_check_inter) != 1 ) {
				fprintf(stderr, "%s: --c option arg invalid\n",
					Progname);
				usage();
				exit(1);
			}
			break;

		case 'e':
			if (sscanf(optarg, "%i", &Maxerrs) != 1 ) {
				fprintf(stderr, "%s: --e option arg invalid\n",
					Progname);
				usage();
				exit(1);
			}
			break;

		case 'f':
			auto_file=optarg;
			break;

		case 'g':
			if ((ret=sscanf(optarg, "%i%c", &grow_incr, &chr)) < 1 ||
				grow_incr < 0 ) {

				fprintf(stderr, "%s: --g option arg invalid\n",
					Progname);
				usage();
				exit(1);
			}
			if ( ret == 2 ) {
				if ( chr == 'b' || chr == 'B' )
					grow_incr *= 4096;
				else {
					fprintf(stderr,
						"%s: --g option arg invalid\n",
						Progname);
					usage();
					exit(1);
				}
			}
			break;

		case 'i':
			if (sscanf(optarg, "%i", &iterations) != 1 ||
				iterations < 0 ) {

				fprintf(stderr, "%s: --n option arg invalid\n",
					Progname);
				usage();
				exit(1);
			}
			break;

		case 'I':
			if((io_type=parse_io_arg(optarg)) == -1 ) {
			    fprintf(stderr,
				"%s: --I arg is invalid, must be s, p, f or a.\n",
				Progname);
			    exit(1);
			}
			break;

		case 'L':
			if (sscanf(optarg, "%i", &time_iterval) != 1 ||
				time_iterval < 0 ) {
				fprintf(stderr, "%s: --L option arg invalid\n",
					Progname);
				usage();
				exit(1);
			}
			break;

		case 'N':
			if (sscanf(optarg, "%i", &num_auto_files) != 1 ||
				num_auto_files < 0 ) {

				fprintf(stderr, "%s: --N option arg invalid\n",
					Progname);
				usage();
				exit(1);
			}
			break;

		case 'o':
		    if ((open_flags=parse_open_arg(optarg, NULL)) == -1 ) {
		        fprintf(stderr, "%s: --o arg contains invalid flag\n", Progname);
		        exit(1);
		    }
		    break;


		case 'p' :	/* pre allocate space */
#ifdef CRAY
			pre_alloc_space++;
#else
			printf("%s: --p is illegal option on non-cray system\n",
                                Progname);
                        exit(1);

#endif
			break;

		case 'P':
#ifdef CRAY
			if (strcmp(optarg, "PANIC") != 0 ) {
				fprintf(stderr, "%s: --P arg must be PANIC\n", Progname);
				exit(1);
			}
			upanic_after_write++;
			printf("%s: Will call upanic after writes\n");
#else
			printf("%s: --P is illegal option on non-cray system\n",
				Progname);
			exit(1);
#endif
			break;

		case 'S':
			if (sscanf(optarg, "%i", &seq_auto_files) != 1 ||
				seq_auto_files < 0 ) {

				fprintf(stderr, "%s: --S option arg invalid\n",
					Progname);
				usage();
				exit(1);
			}
			break;

		case 't':
			if ((ret=sscanf(optarg, "%i%c", &trunc_incr, &chr)) < 1 ||
				trunc_incr < 0 ) {

				fprintf(stderr, "%s: --t option arg invalid\n",
					Progname);
				usage();
				exit(1);
			}
			if ( ret == 2 ) {
				if ( chr == 'b' || chr == 'B' )
					trunc_incr *= 4096;
				else {
					fprintf(stderr,
						"%s: --t option arg invalid\n",
						Progname);
					usage();
					exit(1);
				}
			}
			break;

		case 'T':	/* truncate interval */
			if (sscanf(optarg, "%i", &trunc_inter) != 1 ||
				trunc_inter < 0 ) {

				fprintf(stderr, "%s: --T option arg invalid\n",
					Progname);
				usage();
				exit(1);
			}
			break;

		case 'u':
			remove_files++;
			break;

		case 'w':
			no_write++;
			break;

		case '?':
			usage();
			exit(1);
			break;
		}
	}

	set_sig();

	if ( backgrnd )
	    background();	/* give user their prompt back */

	Pid=getpid();

/*** begin filename stuff *****/

	/*
	 * Determine the number of files to be dealt with
	 */
	if ( optind == argc ) {
		/*
		 * no cmd line files, therfore, set
		 * the default number of auto created files
		 */
		if ( ! num_auto_files && ! seq_auto_files )
			num_auto_files=1;
	}
	else {
		first_file_ind=optind;
		num_files += argc-optind;
	}

	if ( num_auto_files ) {
		num_files += num_auto_files;
	}

	if ( seq_auto_files ) {
		num_files += seq_auto_files;
	}

	if ( Debug > 1 ) 
		printf("%s: %d DEBUG1 num_files = %d\n", Progname, Pid, num_files);

	/*
	 * get space for file names
	 */
	if ((filenames=(char *)malloc(num_files*PATH_MAX)) == NULL) {
		fprintf(stderr, "%s: %d malloc(%d) failed: %s\n",
			Progname, Pid, num_files*PATH_MAX,
			sys_errlist[errno]);
		exit(1);
	}

	/*
	 * fill in filename cmd files then auto files.
	 */

	num=0;
	if ( first_file_ind ) {
		for(ind=first_file_ind; ind<argc; ind++, num++) {
			strcpy((char *)filenames+(num*PATH_MAX), argv[ind]);
		}
	}

/**** end filename stuff ****/

	if ( time_iterval > 0 )
		start_time=time(0);


	/*
	 * construct auto filename and insert them into filenames space
	 */
		
	for(ind=0;ind<num_auto_files; ind++, num++) {

		strcpy((char *)filenames+(num*PATH_MAX),
			tempnam(auto_dir, auto_file));
	}

	/*
	 * construct auto seq filenames
	 */
	for(ind=1; ind<=seq_auto_files; ind++, num++) {
		sprintf((char *)filenames+(num*PATH_MAX), "%s/%s%d",
			auto_dir, auto_file, ind);
	}

	/*
	 * get space for grow buffer
	 */
	if ( ! no_write && grow_incr > 0 ) {
		if ((write_buf=(char *)malloc(grow_incr)) == NULL) {
			fprintf(stderr, "%s: %d malloc(%d) failed: %s\n",
				Progname, Pid, grow_incr, sys_errlist[errno]);
			exit(1);
		}

	}

	if ( Debug > 2 ) {
		printf("%s: %d DEBUG2 num_files = %d, grow_incr = %d, trunc_incr = %d\n",
			Progname, Pid, num_files, grow_incr, trunc_incr);
	}

	if ( pre_alloc_space ) {
		if ( iterations == 0 ) {
			fprintf(stderr, "%s: %d can NOT pre-alloc and grow forever\n",
				Progname, Pid);
			exit(1);
		}

		total_grow_value=grow_incr * iterations;

		/*
		 * attempt to limit 
		 */
		if ( bytes_to_consume && bytes_to_consume < total_grow_value ) {
			total_grow_value=bytes_to_consume;
		}
	}

	for(num=0; ! stop ; num++) {

	    if ( iterations && num >= iterations ) {
		strcpy(reason, "Hit iteration value");
		stop=1;
		continue;
	    }

	    if (  (time_iterval > 0) && (start_time + time_iterval >= time(0)) ) {
		strcpy(reason, "Hit time value");
		stop=1;
		continue;
	    }

	    if ( Maxerrs && error >= Maxerrs ) {
		strcpy(reason, "Hit max errors value");
		stop=1;
                continue;
	    }

	    if ( bytes_to_consume && bytes_consumed >= bytes_to_consume) {
		strcpy(reason, "Hit bytes consumed value");
		stop=1;
                continue;
            }


	    for(ind=0; ind<num_files; ind++) {

		fflush(stdout);
		fflush(stderr);

		if ( ind == 0 && num != 0 && pre_alloc_space ) {
			num=-1;
			pre_alloc_space=0;
			break;	/* start outside loop */
		}

		filename=(char *)filenames+(ind*PATH_MAX);

		if ( Debug > 2 ) {
			printf("filename = %s\n", filename);
		}

		/*
		 * open file
		 */
		if ((fd=Open(filename, open_flags, 0777, &errmsg)) == -1 ) {

			fprintf(stderr,
			    "%s: pid=%d: %s\n", Progname, Pid, errmsg);
			error++;
			continue;
		}

		/*
		 * preallocation is only done once, if specified.
		 */
		if ( pre_alloc_space ) {
			if (pre_alloc(fd, total_grow_value) != 0 ) {
				cleanup();
				exit(2);
			}
			if ( Debug > 1 ) {
				printf("DEBUG pre_allocated %d for file %s\n",
					total_grow_value, filename);
			}
			close(fd);
			continue;
		}

		/*
		 * get exclusive file lock
		 */

		/*
		 * grow file by desired amount
		 */
		if (growfile(fd, filename, grow_incr,
			no_write, write_buf) != 0 ) {

			error++;
			close(fd);
			continue;
		}

		/*
		 * Check that whole file is not corrupted.
		 */
		if ( check_file(fd, write_check_inter, filename) != 0 ) {
		    error++;
		}

		/*
		 * shrink file by desired amount if it is time 
		 */

		if ( shrinkfile(fd, filename, trunc_incr, trunc_inter) != 0 ) {
			error++;
			close(fd);
			continue;
		}

		close(fd);
	    }
	}


	printf("%s: %d DONE after %d iterations to %d files. %s\n", Progname, Pid,
	    num-1, num_files, reason);
	fflush(stdout);
	fflush(stderr);

#ifdef CRAY
	if ( upanic_after_write ) {
	    upanic(PA_PANIC);
	}
#endif

	cleanup();

	if ( error )
		exit(1);
	exit(0);
}

/***********************************************************************
 *
 ***********************************************************************/
set_sig()
{
   int sig;

	
        /*
         * now loop through all signals and set the handlers
         */

        for (sig = 1; sig < NSIG; sig++) {
            switch (sig) {
                case SIGKILL:
                case SIGINFO:
                case SIGSTOP:
                case SIGCONT:
                case SIGRECOVERY:
                case SIGCLD:
                    break;

                default:
                    signal(sig, sig_handler);
                break;
            }
        } /* endfor */



}

/***********************************************************************
 *
 ***********************************************************************/
void
sig_handler(sig)
int sig;
{
	fprintf(stderr, "%s: %d received unexpected signal: %d\n", Progname,
	    Pid, sig);
	cleanup();
	exit(2);
}


/***********************************************************************
 *
 ***********************************************************************/
cleanup()
{
    int ind;

	if ( remove_files )
	    for(ind=0; ind<=num_files; ind++) {
		unlink(filenames+(ind*PATH_MAX));
	    }

	return 0;
}

/***********************************************************************
 *
 ***********************************************************************/
void
usage()
{
	fprintf(stderr,
	"Usage: %s [-bhEu][[-g grow_incr][-i num][-t trunc_incr][-T trunc_inter]\n",
	Progname);
	fprintf(stderr,
	"[-d auto_dir][-e maxerrs][-f auto_file][-N num_files][-w][-c chk_inter][-D debug]\n");
	fprintf(stderr,
	"[-S seq_auto_files][-p][-P PANIC][-I io_type][-o open_flags][-B maxbytes]\n");
	fprintf(stderr,
	"[files]\n");

	return;

}	/* end of usage */

/***********************************************************************
 *
 ***********************************************************************/
void
help()
{
	usage();

	fprintf(stdout,
	"  -h             Specfied to print this help and exit.\n");
	fprintf(stdout,
	"  -b             Specfied to execute in batch mode.(def async mode)\n");
	fprintf(stdout,
	"  -B maxbytes    Max bytes to consume by all files.  growfiles exits when more\n");
        fprintf(stdout,
	"                 than maxbytes have been consumed. (def no chk)  If maxbytes ends\n");
	fprintf(stdout,
	"                 with the letter 'b', maxbytes is multiplied by BSIZE (%d)\n", BSIZE);
	fprintf(stdout,
	"  -e errs        The number errors that will terminate this program (def 100)\n");
	fprintf(stdout,
	"  -g grow_incr   Specfied to grow by incr for each num. (default 4096)\n");
	fprintf(stderr, "\t\t grow_inter may end in b for blocks\n");
	fprintf(stdout,
	"  -i num         Specfied to grow each file num times. (default 1)\n");
	fprintf(stdout, "  -I io_type Specifies io type: s - sync, p - polled async,\n");
	fprintf(stdout, "             a - async (def s)\n");

	fprintf(stdout,
	"  -t trunc_incr  Specfied the amount to shrink file. (default 4096)\n");
	fprintf(stdout,
	"  -T trunc_inter Specfied the how many grows happen before shrink. (default 0)\n");
	fprintf(stderr, "\t\t trunc_inter may end in b for blocks\n");
	fprintf(stdout,
	"  -w             Specfied to grow via lseek instead of writes.\n");

	fprintf(stdout,
	"  -d auto_dir    Specifies the directory to auto created files. (default .)\n");
	fprintf(stdout,
	"  -f auto_file   Specifies the base filename files created. (default \"gf\")\n");
	fprintf(stdout,
	"  -N num_files   Specifies the number of files to be created.\n");
	fprintf(stdout, "  -o op_type Specifies open flages:\n");
	fprintf(stdout, "             (def O_RDWR,O_APPEND,O_CREAT)\n");

	fprintf(stdout, "\t\t The default is zero if cmd line files.\n");
	fprintf(stdout, "\t\t The default is one if no cmd line files.\n");
	fprintf(stdout,
	"  -c chk_inter Specifies how often to check file via read. (default 0)\n");
	fprintf(stdout,
	"  -D debug_lvl   Specifies the debug level (default 0)\n");
	fprintf(stdout,
	"  -S seq_auto_files Specifies the number of seqental auto files (default 0)\n");
	fprintf(stdout,
	"  -p             Specifies to pre-allocate space\n");
	fprintf(stdout,
	"  -P PANIC       Specifies to call upanic after all writes are done.\n");
	fprintf(stdout, "  -E             Print examples and exit\n");
	fprintf(stdout, "  -u             unlink files before exit\n");
	

	return;
}

/***********************************************************************
 *
 ***********************************************************************/
void
prt_examples(FILE *stream)
{
	/* This example creates 200 files in directory dir1.  It writes */
	/* 4090 bytes 100 times then truncates 408990 bytes off the file */
	/* The file contents are checked every 1000 grow. */
	fprintf(stream, "%s -i 0 -g 4090 -T 100 -t 408990 -c 1000 -d dir1 -S 200\n", Progname);

	/* same as above with 5000 byte grow and a 499990 byte tuncate */
	fprintf(stream, "%s -i 0 -g 5000 -T 100 -t 499990 -c 1000 -d dir2 -S 200\n", Progname);

	/* This example beats on opens and closes */
	fprintf(stream, "%s -i 0 -g 0 -c 0 ocfile\n", Progname);

	/* This example creates 2 files, and runs until the cumulative */
        /* bytes consumed is 50 blocks                                 */

	fprintf(stream, "%s -i 0 -g 4096 -t 2048 -B 50b file1 file2\n", Progname);

	return;
}

/***********************************************************************
 *
 * The file descriptor current offset is assumed to be the end of the
 * file.  
 ***********************************************************************/
growfile(fd, file, grow_incr, no_write, buf)
int fd;
char *file;
int grow_incr;
int no_write;
char *buf;
{
   int offset;
   int ret;
   char *errmsg;

	if ( no_write ) {
		if (lseek(fd, grow_incr, SEEK_END) == -1 ) {
			fprintf(stderr, "%s: lseek failed: %s\n",
				Progname, sys_errlist[errno]);
			return -1;
		}
		write(fd, "w", 1);
	}
	else {
		if ((offset=lseek(fd, 0 , SEEK_END)) == -1 ) {
			fprintf(stderr, "%s: %s lseek failed: %s\n",
				Progname, Pid, sys_errlist[errno]);
			return -1;
		}

		dataasciigen(buf, grow_incr, offset);

/*****
		if (write(fd, buf, grow_incr) != grow_incr) {
			fprintf(stderr, "%s: write failed: %s\n",
				Progname, sys_errlist[errno]);
			return -1;
		}
*****/
		if ((ret=write_buffer(fd, io_type, buf,
			grow_incr, 0, &errmsg)) != 0 ) {
			fprintf(stderr, "%s: %d %s\n", Progname, Pid, errmsg);
			if ( ret == -ENOSPC ) {
				cleanup();
				exit(2);
			}
		}
	}


	if ( Debug > 0) {
		fprintf(stdout, "%s: %s DEBUG grew file by %d bytes\n",
			Progname, Pid, grow_incr);
	}

    	bytes_consumed += grow_incr;
	return 0;

}	/* end of growfile */

/***********************************************************************
 * shrinkfile file by trunc_incr.  file can not be made smaller than
 * size zero.  Therefore, if trunc_incr is larger than file size,
 * file will be truncated to zero.
 * The file descriptor current offset is assumed to be the end of the
 * file.
 *
 ***********************************************************************/
shrinkfile(fd, filename, trunc_incr, trunc_inter)
int fd;
char *filename;
int trunc_incr;
int trunc_inter;	/* interval */
{
    static shrink_cnt = 0;
    int cur_offset;
    int new_offset;

	if ( Debug > 3) {
		fprintf(stdout, "%s: DEBUG4 entering shrinkfile\n", Progname);
	}

	shrink_cnt++;

	if ( trunc_inter == 0 || (shrink_cnt % trunc_inter != 0)) 
		return 0;	/* not this time */

	if ((cur_offset=tell(fd)) == -1 ) {
		fprintf(stderr, "%s: %d tell failed: %s\n",
			Progname, Pid, sys_errlist[errno]);
		return -1;
	}

	new_offset = cur_offset-trunc_incr;

	if ( new_offset < 0 )
		new_offset=0;
	
#ifndef CRAY
	if ( ftruncate(fd, new_offset) == -1) {
		fprintf(stderr, "%s: truncate failed: %s\n",
			Progname, sys_errlist[errno]);
		return -1;
	}
#else
	if ( lseek(fd, new_offset, SEEK_SET) == -1 ) {
		fprintf(stderr, "%s: %d: lseek failed: %s\n",
			Progname, Pid, sys_errlist[errno]);
		return -1;
	}

	if ( trunc(fd) == -1 ) {
		fprintf(stderr, "%s: %d: trunc failed: %s\n",
			Progname, Pid, sys_errlist[errno]);
		return -1;
	}
#endif
	if ( Debug > 0) {
		printf("%s: DEBUG1 trunc file by %d bytes\n",
			Progname, cur_offset-new_offset);
	}

        bytes_consumed -= (cur_offset - new_offset);
	return 0;

}	/* end of shrinkfile */

/***********************************************************************
 *
 * The file descriptor current offset is assumed to be the end of the
 * file.  The offset will be restored by the read.
 ***********************************************************************/
/* check_write(fd, filename, grow_incr, wrbuf, rdbuf)
/* int fd;
/* char *filename;
/* int grow_incr;
/* char *wrbuf;
/* char *rdbuf;
/* {
/* 
/*     long cur_offset;
/*     int ret;
/* 
/* 	if ( Debug > 3) {
/* 		fprintf(stdout, "%s: DEBUG4 entering check_write\n", Progname);
/* 	}
/* 
/* 	if ((cur_offset=tell(fd)) == -1 ) {
/* 		fprintf(stderr, "%s: %d: tell failed: %s\n",
/* 			Progname, Pid, sys_errlist[errno]);
/* 		return -1;
/* 	}
/* 	
/* 	/*
/* 	 * back up to beginning of write
/* 	 */
/* 
/* 	if ( lseek(fd, cur_offset-grow_incr, SEEK_SET) == -1 ) {
/* 		fprintf(stderr, "%s: %d: lseek failed: %s\n",
/* 			Progname, Pid, sys_errlist[errno]);
/* 		return -1;
/* 	}
/* 
/* 	if ((ret=read(fd, rdbuf, grow_incr)) == -1 ) {
/* 		fprintf(stderr, "%s: %d: read failed: %s\n",
/* 			Progname, Pid, sys_errlist[errno]);
/* 		return -1;
/* 	}
/* 
/* 	if ( ret != grow_incr ) {
/* 		fprintf(stderr,
/* 			"%s: %d: read %d bytes when trying to read %d bytes\n",
/* 			Progname, Pid, ret, grow_incr);
/* 		return -1;
/* 	}
/* 
/* 	/*
/* 	 * compare rdbuf to wrbuf
/* 	 */
/* 
/* 	if ( memcmp(rdbuf, wrbuf, grow_incr) != 0) {
/* 		fprintf(stderr, "%s: %d: Did not read what was just written\n",
/* 			Progname, Pid);
/* 		return -1;
/* 	}
/* 
/* 	if ( Debug > 0) {
/* 		fprintf(stdout, "%s: DEBUG1 read of last write was ok\n",
/* 			Progname);
/* 	}
/* 
/* 	return 0;
/* 
/* }	/* end of check_write */


/***********************************************************************
 *
 ***********************************************************************/
check_file(fd, cf_inter, filename)
int fd;
int cf_inter;	/* check file interval */
char *filename;	/* needed for error messages */
{
    int fsize;
    static int cf_count = 0;
    char *buf;
    int ret;
    int ret_val = 0;
    int rd_cnt;
    int rd_size;
    char *errmsg;

	cf_count++;

	if ( cf_inter == 0 || (cf_inter % cf_count != 0))
		return 0;	 /* no check done */
	
	if ((fsize=file_size(fd)) == -1 ) 
		return -1;

	if ( fsize > MAX_FC_READ ) {
		if ((buf=(char *)malloc(MAX_FC_READ)) == NULL ) {
			fprintf(stderr, "%s: malloc(%d) failed: %s\n", Progname,
				MAX_FC_READ, sys_errlist[errno]);
			return -1;
		}

		lseek(fd, 0, SEEK_SET);

		rd_cnt=0;
		while (rd_cnt < fsize ) {
			if ( fsize - rd_cnt > MAX_FC_READ )
				rd_size=MAX_FC_READ;
			else
				rd_size=fsize - rd_cnt;
				
			read(fd, buf, rd_size);

			if ((ret=dataasciichk(buf, rd_size, rd_cnt )) >= 0 ) {
				fprintf(stderr,
					"%s: %d data mismatch at offset %d in file %s\n",
					Progname, Pid, ret, filename);
				fflush(stderr);
				ret_val=1;
				break;
			}
			rd_size += rd_size;
		}

		free(buf);
	
	}
	else if ( fsize > 0 ) {
		if((buf=(char *)malloc(fsize)) == NULL ) {
			fprintf(stderr, "%s: malloc(%d) failed: %s\n", Progname,
				fsize, sys_errlist[errno]);
			fflush(stderr);
			return -1;
		}

		lseek(fd, 0, SEEK_SET);

/****
		read(fd, buf, fsize);
****/

		if (read_buffer(fd, io_type, buf, fsize, 0, &errmsg) != 0 ) {
			fprintf(stderr, "%s: %d %s\n", Progname, Pid, errmsg);
			ret_val=1;
		}
		else if ((ret=dataasciichk(buf, fsize, 0 )) >= 0 ) {
			fprintf(stderr, "%s: %d data mismatch at offset %d in file %s\n",
				Progname, Pid, ret, filename);
			fflush(stderr);
			ret_val=1;
		}
		free(buf);
	}

	return ret_val;

}	/* end of check_file */

/***********************************************************************
 *
 ***********************************************************************/
pre_alloc(fd, size)
int fd;
int size;
{
    long avl;

#ifdef CRAY
        if ( ialloc(fd, size, IA_CONT, &avl) == -1 ) {
                fprintf(stderr, "Unable to pre-alloc space: ialloc failed: %s\n",
                        sys_errlist[errno]);
                return -1;
        }
#else
        return -1;
#endif

}

