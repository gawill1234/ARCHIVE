#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/signal.h>
#include <sys/param.h>

#define ITERATIONS 4
#define INSTANCES 10
#define MAX_CLICKS 10000
#define OPTIONS "va:c:i:I:"
#define USAGE "mem_holer : [-a loop_for_seconds] [-c memory_clicks] [-i children] [-I loop_iterations] [-v] -> for validating memory initializations\n"
#define MAX_CHILDREN 300
#define MAX_CHILD_SIGNAL_WAIT 60

int parent_pid=0;
int verify=0;
int Hz=0;
int lfs=0;                     /* Loop for seconds value */
struct tblk {
    long btime;
    long ctime;
};
struct tblk tblk;

char pattern[] = { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z' };

main(argc,argv)
int argc;
char *argv[];
{
        char *begin_sbrk_val;
	int c, counter, syscall_ret, wait_code, tmptime;
        int iterations=ITERATIONS;
        int instances=INSTANCES;
        int maxclicks=MAX_CLICKS;
        int child_pids[MAX_CHILDREN];
        void signal_trapper();

        while ((c = getopt(argc, argv, OPTIONS)) != EOF) {
            switch (c)
            {
                 case 'a':
                         if ( ck_for_non_numeric_arg(optarg) != 0) {
                            fprintf(stderr, "ERROR : -a : %s argument is an invalid integer\n", optarg);
                            usage();
                         }
                         sscanf(optarg, "%d", &counter);
                         if (counter < 1) {
                            fprintf(stderr, "ERROR : -a : %s argument must be greater than zero\n", optarg);
                            usage();
                         }
                         lfs=counter;
                         break;
                 case 'c':
                         if ( ck_for_non_numeric_arg(optarg) != 0) {
                            fprintf(stderr, "ERROR : -c : %s argument is an invalid integer\n", optarg);
                            usage();
                         }
                         sscanf(optarg, "%d", &maxclicks);
                         if (MAX_CLICKS < maxclicks) {
                            fprintf(stderr, "%s USAGE LIMIT ERROR: %d > %d MAXCLICKS", argv[0], maxclicks, MAX_CLICKS);
                            usage();
                         }
                         break;
                 case 'i':
                         if ( ck_for_non_numeric_arg(optarg) != 0) {
                            fprintf(stderr, "ERROR : -i : %s argument is an invalid integer\n", optarg);
                            usage();
                         }
                         sscanf(optarg, "%d", &iterations);
                         break;
                 case 'I':
                         if ( ck_for_non_numeric_arg(optarg) != 0) {
                            fprintf(stderr, "ERROR : -I : %s argument is an invalid integer\n", optarg);
                            usage();
                         }
                         sscanf(optarg, "%d", &instances);
                         if (MAX_CHILDREN < instances) {
                            fprintf(stderr, "%s USAGE LIMIT ERROR: %d > %d MAX CHILD PROCESSES", argv[0], instances, MAX_CHILDREN);
                            usage();
                         }
                         break;
                 case 'v':
                         verify=1;
                         break;
                 default:
                         usage();
                         break;
            }
        }
        if ((Hz=sysconf(_SC_CLK_TCK)) < 0 ) {
           fprintf(stderr, "%s : sysconf(_SC_CLK_TCK) Failure\n", argv[0]);
           exit(1);
        }
        parent_pid=getpid();
        if ((int)(begin_sbrk_val=sbrk(0)) == -1) {
           fprintf(stderr, "%s : sbrk(0) Failure\n", argv[0]);
           exit(1);
        }
        signal(SIGUSR1, signal_trapper);
        bzero((char *)&child_pids, sizeof(child_pids));
        if (lfs) {
           tblk.btime=0;
           tblk.ctime=0;
        }

	for (counter=0; counter < iterations; counter++) {
		if ((syscall_ret=fork()) == 0) {
                        char *p;
                        int i, j, index, how_many=1;

                        signal(SIGUSR1, signal_trapper);
                        kill(getppid(), SIGUSR1); 
                        pause();
			while ((how_many < instances) || lfs) {
				i=rand();
				/* max of maxclicks clicks */
				i=(i%maxclicks)*512;
                                if (lfs) {
                                   tblk.ctime = _rtc();
                                   if ( ! tblk.btime) {
                                      tblk.btime = tblk.ctime;
                                   } else {
                                      tmptime=tblk.ctime-tblk.btime;
                                      if ((float)tmptime/(float) Hz >= (float) lfs) {
                                         break;
                                      }
                                   }
                                }
				sbrk(+i);
                                if (lfs) {
                                   tblk.ctime = _rtc();
                                   tmptime=tblk.ctime-tblk.btime;
                                   if ((float)tmptime/ (float) Hz >= (float) lfs) {
                                        break;
                                   }
                                }
                                if (verify) {
                                   index = (counter + parent_pid) % sizeof(pattern);
                                   memset(begin_sbrk_val, pattern[index], (i*8));
                                   for (j=0, p=begin_sbrk_val; j < (i*8); j++, p++) { 
                                       if (memcmp((void *)pattern[index], (void *)*p, sizeof(pattern[index])) != 0 ) {
                                          fprintf(stderr, "%s : memcmp FAIL at offset %d : Expected %c : Actual = %c\n", argv[0], j, pattern[index], *p);
                                          exit(1);
                                       }
                                   }
                                }
				sbrk(-i);
                                how_many++;
			}
                        exit(0);
                        
		} else if (syscall_ret == -1) {
                       do_bailout(&child_pids, counter);
                } else {
                  pause();
                  child_pids[counter]=syscall_ret;
                }
	}
        /*
        *******************************************
        * Let Children get close to their own pause
        * before semi-staggered start
        *******************************************
        */
        sleep(1);
        /*
        ******************
        * Fire children up
        ******************
        */
	for (counter=0; counter < iterations; counter++) {
            kill(child_pids[counter],SIGUSR1);
        }
        /*
        **************************
        * Wait for children deaths
        **************************
        */
        signal(SIGCHLD, SIG_IGN);
        syscall_ret=wait(&wait_code);

}

do_bailout(pids, hmany)
int *pids;
int hmany;
{
    int counter;
    
    for (counter=0; counter < hmany; counter++) {
        if (pids[counter] != 0 ) {
           kill(pids[counter],SIGKILL);
        }
    }
    exit(1);

}

void signal_trapper(sig_val)
int sig_val;
{
    if (parent_pid == getpid()) {
       signal(SIGUSR1, signal_trapper);
    }
}

usage()
{
     fprintf(stderr, USAGE);
     exit(1);
}

/*
* This functios verifies ptr contains a digit string
*/


ck_for_non_numeric_arg(ptr)
char *ptr;
{
    while (*ptr)
    {
        if ( ! isdigit(*ptr))
           return(1);
        ptr++;
    }
    return(0);
}
