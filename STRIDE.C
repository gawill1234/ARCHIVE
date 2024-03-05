static char USMID[] = "@(#)uttmp/whr/tools/stride.c	10.1	03/04/93 09:38:22";

/*
 *	(C) COPYRIGHT CRAY RESEARCH, INC.
 *	UNPUBLISHED PROPRIETARY INFORMATION.
 *	ALL RIGHTS RESERVED.
 */

#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <signal.h>
#include <sys/lock.h>

/* default it 1M */
#define DEFSIZE  (1024*1024)*8

void
usage(char *pn, FILE *fp)
{

    fprintf(fp, "Usage: %s [-lprv][-a nu][-i n][-c n][-b n][-s n]\n", pn);
}

void
help(char *pn)
{
    usage(pn, stderr);
    puts("");
    printf("-a nu :\tSet array size to n units, u=unit\n");
    printf("       \tValues for u are (k)ilobytes, (m)egabytes, (g)igabytes (Upper case = words)\n");
    printf("-b n :\tSet target blank to n.  Default is 0.\n");
    printf("-c n :\tNumber of copies to execute. Default is 1.\n");
    printf("-h :\tHelp. Print this message.\n");
    printf("-i n :\tIteration count. Default is 1.\n");
    printf("-l :\tPLOCK process in memory.\n");
    printf("-p n :\tPause prior at position n, in all copies, for SIGUSR1.\n");
    printf("-r :\tBecome Realtime.\n");
    printf("-s n :\tSet Stride length.  Default is number of banks installed.\n");
    printf("-v :\tVerbose mode.  Report all option settings prior to execution.\n");

}

void set_vals();

int *ARRAY;
main(int ac, char *av[])
{
    
    int n,
    i,
    ch, 
    cnt=1,
    pid,
    children=1,
    expsum,
    infinite=0,
    bank=-1,	/* default to all */
    max_banks,
    stride=0,
    array_size=DEFSIZE,
    verbose=0,
    pattern=1,
    r_time=0,
    p_lock=0;
    
    float in_size;
    char sp[2];
    char unit;
    char *msg;
    int SUM;
    int pause_flag=0;
    int start_bank, end_bank;

    /* externals for getopt */
    extern int opterr;
    extern char *optarg;
    extern int errno;
    extern char *sys_errlist[];

    /* get default stride and max_banks */
    stride=max_banks=sysconf(_SC_CRAY_NBANKS);
    
    /*
     * Parse the options
     */
    while ((ch = getopt(ac, av, "rlhp:i:c:b:s:a:v")) != -1) {
	switch(ch) {
	   case 'h':        /* help */
	    help(av[0]);
	    exit(0);
	    break;
	    
	   case 'r':        /* Realtime */
	    r_time=1;
	    break;
	    
	   case 'l':        /* plock in nmemory */
	    p_lock=1;
	    break;
	    
	   case 'p':        /* Pause before after fan and before loops */
	    if ( sscanf(optarg, "%i%c", &pause_flag, sp) != 1) {
		fprintf(stderr,
			"Invalid argument for -p option.  Must be a valid number.\n");
		usage(av[0], stderr);
		exit(1);
	    }
	    break;
	    
	   case 'v':        /* verbose output */
	    verbose=1;
	    break;
	    
	   case 'i':	/* test iteration count */
	    if ( sscanf(optarg, "%i%c", &cnt, sp) != 1) {
		fprintf(stderr,
			"Invalid argument for -i option.  Must be a valid number.\n");
		usage(av[0], stderr);
		exit(1);
	    }
	    if ( cnt == 0 ) 
		infinite=1;
	    break;
	    
	   case 'c':	/* Number of children */
	    if ( sscanf(optarg, "%i%c", &children, sp) != 1) {
		fprintf(stderr,
			"Invalid argument for -c option.  Must be a valid number.\n");
		usage(av[0], stderr);
		exit(1);
	    }
	    if ( children <= 0 ) {
		fprintf(stderr,
			"Invalid argument for -c option.  Must be a Positive number.\n");
		usage(av[0], stderr);
		exit(1);
	    }
	    break;
	    
	   case 'b':	/* starting bank number */
	    if ( sscanf(optarg, "%i%c", &bank, sp) != 1) {
		fprintf(stderr,
			"Invalid argument for -b option.  Must be a valid number.\n");
		usage(av[0], stderr);
		exit(1);
	    }
	    if ( bank < 0 || bank >= max_banks) {
		fprintf(stderr,
			"Invalid argument for -b option.  Must be in range  0-%d.\n",
			max_banks-1);
		usage(av[0], stderr);
		exit(1);
	    }
	    break;
	    
	   case 's':	/* stride length to use */
	    if ( sscanf(optarg, "%i%c", &stride, sp) != 1) {
		fprintf(stderr,
			"Invalid argument for -s option.  Must be a valid number.\n");
		usage(av[0], stderr);
		exit(1);
	    }
	    if ( stride < 0 ) {
		fprintf(stderr,
			"Invalid argument for -s option.  Must be a Positive number.\n");
		usage(av[0], stderr);
		exit(1);
	    }
	    break;
	    
	   case 'a':	/* Buffer size */
	    if ( sscanf(optarg, "%f%c%c", &in_size, &unit, sp) != 2) {
		fprintf(stderr,
			"Invalid argument for -a option.\n");
		usage(av[0], stderr);
		exit(1);
	    }
	    if ( in_size <= 0 ) {
		fprintf(stderr,
			"Invalid argument for -a option.  Must be a Positive number.\n");
		usage(av[0], stderr);
		exit(1);
	    }
	    switch (unit) {
	      case 'k':
		array_size=(int)in_size*1024;
		break;
	      case 'm':
		array_size=(int)in_size*(1024*1024);
		break;
	      case 'g':
		array_size=(int)in_size*((1024*1024)*1024);
		break;
	      case 'K':
		array_size=(int)(in_size*1024)*8;
		break;
	      case 'M':
		array_size=(int)(in_size*(1024*1024))*8;
		break;
	      case 'G':
		array_size=(int)(in_size*((1024*1024)*1024))*8;
		break;
	      default:
		fprintf(stderr, "Unknown unit type: -%c\n", unit);
		usage(av[0], stderr);
		exit(1);

	    }
	    break;
	    
	   default:		/* invalid option */
	    fprintf(stderr, "Unknown Option: -%c\n", ch);
	    usage(av[0], stderr);
	    exit(1);
	    break;
	    
	}
    }
    
   
    /* Make array_size = a multiple of the stride size */
    if ( (array_size/8)%stride )
	array_size=( ( ((array_size/8)/stride)+1 )*stride )*8;	/* round it up */

    if (verbose) {
	printf("Array size=%d (words).\n", array_size/8);
	if (bank == -1)
	    printf("Bank target=ALL.\n");
	else
	    printf("Bank target=%d.\n", bank);
	printf("Children count=%d.\n", children);
	printf("Iteration count=%d infinite flag=%d.\n", cnt, infinite);
	printf("Pause flag=%d.\n", pause_flag);
	if (p_lock)
	    printf("Going to attempt to plock in memory.\n");
	if (r_time)
	    printf("Going to attempt to become a realtime process.\n");
	printf("Stride=%d\n", stride);
	fflush(stdout);
    }
    
     /* fork children */
    setpgrp();
    for (i=1; i<children; i++) {
	if ( (pid=fork()) == -1 ) {
	    fprintf(stderr, "Fork error, going with %d copies.\n", i);
	} else {
	    if (pid==0)	/* child */
		break;;
	}
    }

    /* pause location 1 */
    if (pause_flag==1) {
	int old_action;
	old_action = sigctl(SCTL_REG, SIGUSR1, 0);
	pause();
	sigctl(old_action, SIGUSR1, 0);
   }

    /* Plock process in memory */
    if (p_lock) {
	if ( plock(PROCLOCK) != 0) {
	    fprintf(stderr, "%s (%d) plock(PROCLOCK) errno=%d %s\n",
		    av[0],getpid(),
		    errno, sys_errlist[errno]);
	}
	printf("Pid(%d) is now PLOCKED!!\n", getpid());
    }
    
    /* Become realtime */
    if (r_time) {
	if ( (i=realtime(1)) != 0){
	    fprintf(stderr,
		    "%s (%d) Unable to become realtime on process (return=%d)!!\n",
		    av[0],getpid(),i);
	    exit(1);
	}
	printf("Pid(%d) is now running realtime!!\n", getpid());
    }
    
    /* compute expected sum of elements */
    expsum=((array_size/8)/stride) * pattern;
    
    if ( (ARRAY=(int *)malloc(array_size)) == (int *) NULL ) {
	fprintf(stderr,
		"Unable to malloc %d bytes (%d words)\n",
		array_size*8, array_size);
	exit(2);
    }
    /* pause location 2 */
    if (pause_flag==2) {
	int old_action;
	old_action = sigctl(SCTL_REG, SIGUSR1, 0);
	pause();
	sigctl(old_action, SIGUSR1, 0);
   }

    if (verbose) {
	fprintf(stderr, "Address=%d\n", ARRAY);
	fflush(stderr);
    }
    
	if (bank == -1) {
	    /* stride through all banks */
	    start_bank=0;
	    end_bank=max_banks-1;
	} else {
	    /* stride through specified bank */
	    start_bank=bank;
	    end_bank=bank;
	}
	
    while (cnt || infinite) {
	cnt--;

	for (bank=start_bank; bank<=end_bank; bank++) {
	    SUM=0;
	    
	    /* set the values in the target bank */
	    set_vals(ARRAY, array_size, bank, stride, pattern);
	    
	    /* sum the values in the target bank */
	    for(n=bank; n<(array_size/8); n+=stride)
		SUM+=ARRAY[n];
	    
	    /* check the SUM */
	    if ( SUM != expsum ) {
		fprintf(stderr, "Expected sum of %d, got %d on bank %d\n", expsum, SUM, bank);
	    }
	}

	/* pause location 3 after 1 pass through the bank(s) */
	if (pause_flag==3) {
	    int old_action;
	    old_action = sigctl(SCTL_REG, SIGUSR1, 0);
	    pause();
	    sigctl(old_action, SIGUSR1, 0);
	}
    }
    printf("Complete! (Pid=%d)\n", getpid());
}

void
set_vals(int ARRAY[], int array_size, int bank, int stride, int pattern)
{
int n;

    for(n=bank; n<array_size/8; n+=stride)
	ARRAY[n]=pattern;
	
}
