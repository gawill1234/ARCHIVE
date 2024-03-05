static char USMID[] = "@(#)cuts/src/pics/uts/fs/accord.c	80.1	01/14/93 08:07:19";

/*
 *  (c) Copyright Cray Research, Inc.  Unpublished Proprietary Information.
 *  All Rights Reserved.
 */
#include <stdio.h>
#include <errno.h>
#include <ctype.h>
#include <fcntl.h>
#include <memory.h>
#include <sys/types.h>
#include <sys/unistd.h>
#include <sys/signal.h>
#include <sys/panic.h>

#define OPTIONS "dDSmsia:p:b:r:B:t:u:o:"
#define DISKFILE "acc"
#define BYTES_TO_CONSUME 5000
#define BLK_SIZE sizeof(struct a_block)

long byte_offset=0; /* Disk and Memory common index */
int ctr_adjust=0;   /* Fudge for truncations, so we eventually get there */
int disk=0;         /* Disk activity flag */
int expect_zeros=0; /* do_compare() should find zeros */
int memory=0;       /* Memory activity flag */
int malloc_mem=0;
int debug=0;
int seed_offset=1;  /* lseek offset multiplier */
long frd_ctr=0;     /* Count of read(2) system calls */
long fwr_ctr=0;     /* Count of write(2) system calls */
long fsk_ctr=0;     /* Count of lseek(2) system calls */
long ftr_ctr=0;     /* Count of trunc(2) system calls */
long mrd_ctr=0;     /* Count of memcpy from memory into global struct */
long mwr_ctr=0;     /* Count of memcpy from global struct into memory */
long msk_ctr=0;     /* Count of memory pointer positioning */
long mtr_ctr=0;     /* Count of memory free(3) library calls */
int infinite=0;
int alarm_set=0;
int stats=0;
extern int errno, optind;
extern char *sys_errlist[], *optarg;
char pattern1 = 0X55;
char pattern2 = 0X55;
char *pg;
int fd;
char *filename = NULL;

struct a_block      /* Byte consumption Factor */
{
    int offset;
    int apattern1;
    int apattern2;
    char filler[4072];
} ablock;


struct a_block *head_ptr, *malloc_mem_ptr;  /* Memory pointers */
char *begin_sbrk_val, *sbrk_mem_ptr, *sbrk();

void sig_handler();
void cleanup();

/***********************************************************************
 * MAIN
 ***********************************************************************/
main(argc, argv)
int argc;
char **argv;
{
   int c, b, consume_bytes();
   int size=0,trunc_interval=0, update_interval=0, read_interval =0;

   pg = argv[0];

   while ((c = getopt(argc, argv, OPTIONS)) != EOF)
   {
       switch (c)
       {
            case 'a':
                    if (sscanf(optarg, "%i", &alarm_set) != 1) {
                       fprintf(stderr, "%s: ERROR: -a %s argument must be a valid integer\n", pg, optarg);
                       usage();
		    } else if (alarm_set == 0) {
                       fprintf(stderr, "%s: ERROR: -a %s argument must be a valid integer greater than zero\n", pg, optarg);
                       usage();
                    }
                    break;
            case 'D':
                    debug++;
                    break;
            case 'd':
                    disk++;
                    break;
            case 'p':
                    filename=optarg;
                    break;
            case 'b':
                    b=optarg[0];
                    switch (b)
                    {
                         case 'a':
                                 pattern1 = 0X55;
                                 pattern2 = 0X55;
                                 break;
                         case 'c':
                                 pattern1 = 0XFF;
                                 pattern2 = ~pattern1;
                                 break;
                         case 'r':
                                 pattern1 = ((rand () & 0177) | 0100);
                                 pattern2 = pattern1;
                                 break;
                         default:
                                fprintf(stderr, "%s: %c is an invalid byte pattern selection\n", pg, b);
                                usage();
                                break;
                    }
                    break;
            case 'i':
                    infinite++;
                    break;
            case 'm':
                    malloc_mem++;
                    memory++;
                    break;
            case 's':
                    memory++;
                    break;
            case 'r':
                    if (sscanf(optarg, "%i", &read_interval) != 1) {
                       fprintf(stderr, "%s: ERROR: -r %s argument must be a valid integer\n", pg, optarg);
                       usage();
		    }
                    break;
            case 'B':
                    if (sscanf(optarg, "%i", &size) != 1 ) {
                       fprintf(stderr, "%s: ERROR: -s %s argument must be a valid integer\n", pg, optarg);
                       usage();
                    }
                    break;
            case 'S':
                    stats++;
                    break;
            case 'o':
                    if (sscanf(optarg, "%i", &seed_offset) != 1) {
                       fprintf(stderr, "%s: ERROR: -o %s argument must be a valid integer\n", pg, optarg);
                       usage();
		    } else if (seed_offset == 0) {
                       fprintf(stderr, "%s: ERROR: -o %s argument must be greater than zero\n", pg, optarg);
                       usage();
                    }
                    break;
            case 't':
                    if (sscanf(optarg, "%i", &trunc_interval) != 1 ) {
                       fprintf(stderr, "%s: ERROR: -t %s argument must be a valid integer\n", pg, optarg);
                       usage();
                    }
                    break;
            case 'u':
                    if (sscanf(optarg, "%i", &update_interval) != 1 ) {
                       fprintf(stderr, "ERROR: -t %s argument must be a valid integer\n", pg, optarg);
                       usage();
                    }
                    break;
            default:
                    usage();
                    break;
       }
   }
   if ( (! disk) && (! memory) )   /* Default to disk activity */
      disk++;

   if (memory == 2) {
      fprintf(stderr, "%s: ERROR : cannot mix malloc and sbrk activities\n", pg);
      usage();
   }

   /*
   * Restrict seed_offset to only disk activity
   * or disk and sbrk activities.  No malloc activity
   * is supported
   */
   if (malloc_mem)
      seed_offset=1;

   if ( disk ) {
	signal(SIGHUP, sig_handler);
	signal(SIGINT, sig_handler);
	signal(SIGQUIT, sig_handler);
	signal(SIGTERM, sig_handler);
	signal(SIGHUP, sig_handler);
	signal(SIGCPULIM, sig_handler);
	signal(SIGABRT, sig_handler);
   }

   if (alarm_set) {
      signal(SIGALRM, sig_handler);
      alarm(alarm_set);
   }
   exit(consume_bytes(size, trunc_interval, update_interval, read_interval));
}

usage()
{
    fprintf(stderr, "Usage: %s [-m] [-dDiS][-p pathname][-b a|c|r byte pattern]\n", pg);
    fprintf(stderr, "\t      [-B size_in_blocks] [-t truncation_interval] [-u update_interval]\n\t      [-r read_interval]\n");
    fprintf(stderr, "       %s -s [-dDiS][-o zero_fill_offset] [-p pathname][-b a|c|r byte pattern]\n", pg);
    fprintf(stderr, "\t      [-B size_in_blocks] [-o zero_fill_offset] [-t truncation_interval] [-u update_interval]\n\t [-r read_interval]\n");
    fprintf(stderr, "  Where -d is for disk file activity (Default if no -d or -m option)\n");
    fprintf(stderr, "  Where -D is for debug mode\n");
    fprintf(stderr, "  Where -i is for infinite mode\n");
    fprintf(stderr, "  Where -m is for malloc(3) memory consumption activity\n");
    fprintf(stderr, "  Where -s is for sbrk(2) memory consumption activity\n");
    fprintf(stderr, "  Where -S is for read,write,seek,truncation totals\n");
    exit(1);
}

/* 
**********************************************************************
* This function consumes disk and or memory bytes based on options
* selected and emulates an accordion in that expansions and shrinkages
* occur along the way until the block size specified is consumed
**********************************************************************
*/
int
consume_bytes(size, trunc_interval, update_interval, read_interval)
int size;
int trunc_interval;
int update_interval;
int read_interval;
{
   int ctr, r_ctr, t_ctr, u_ctr, do_byte_truncates(), do_byte_updates(), do_byte_writes(), do_byte_reads();
   char pathname[1024];
   char *malloc();
   char *tmppath;

   if ( ! filename)
   {
      sprintf(pathname, "%s.%d", DISKFILE, getpid());
      filename = pathname;
   }
   if ( ! size)
      size =  BYTES_TO_CONSUME;
   if (disk)
   {
      if (trunc_interval > size)
      {
         fprintf(stderr, "%s: ERROR -t %d greater than %s file size of %d\n",
	     pg, trunc_interval, filename, size);
         return(1);
      }
      if (update_interval > size)
      {
         fprintf(stderr, "%s: ERROR -u %d greater than %s file size of %d\n",
	     pg, update_interval, filename, size);
         return(1);
      }
      if (read_interval > size)
      {
         fprintf(stderr, "%s: ERROR -r %d greater than %s file size of %d\n",
	     pg, read_interval, filename, size);
         return(1);
      }
   }
   if (memory)
   {
      if (trunc_interval > size)
      {
         fprintf(stderr, "%s: ERROR -t %d greater than memory size of %d\n", pg, trunc_interval, size);
         return(1);
      }
      else if (! malloc_mem)
      {
         if ((int)(begin_sbrk_val=sbrk(0)) == -1)
         {
            fprintf(stderr, "%s: sbrk(0) Failure : errno=%d %s \n", pg,
		errno, sys_errlist[errno]);
            return(1);
         }
      }
   }
again:
   /*
   ***************************
   *  Finally, some executable
   ***************************
   */
   if (disk)
   {
      if ((fd = open(filename, O_CREAT | O_EXCL | O_RDWR, 0644)) == -1)
      {
         fprintf(stderr, "%s: open((%s, O_CREAT | O_EXCL | O_RDWR) ERROR : errno = %d or %s\n",
	     pg, filename, errno, sys_errlist[errno]);
         return(1);
      }
   }
   if (memory)
   {
      if (malloc_mem) /* Establish first dynamic block chunk */
      {
         if ((head_ptr=(struct a_block *)malloc(BLK_SIZE)) == NULL)
         {
            fprintf(stderr, "%s: malloc(%d) error\n", pg, BLK_SIZE);
            return(1);
         }
      }
   }

   for (ctr=t_ctr=u_ctr=r_ctr=0; ctr < size; ctr++, t_ctr++, u_ctr++, r_ctr++)
   {
      if ( t_ctr == trunc_interval-1 )   /* Time to truncate? */
      {
         t_ctr=-1;
         if (do_byte_truncates(fd, trunc_interval) == -1)
            return(1);
         else if (ctr)
            ctr -= ctr_adjust;
      }
      if ( u_ctr == update_interval-1 )  /* Time to update? */
      {
         u_ctr=-1;
         if (do_byte_updates(fd) == -1)
            return(1);
      }
      if (do_byte_writes(fd) == -1)     /* Time to write */
            return(1);
      else if (read_interval)           /* Time to read */
      {
         if ( r_ctr == read_interval-1 )
         {
            r_ctr=-1;
            if (do_byte_reads(fd) == -1)
                return(1);
         }
      }
      else if (do_byte_reads(fd) == -1) /* If no -r option/arg */
            return(1);                  /* read after every write */
   }
   if (stats)
   {
      if (disk)
      {
         fprintf(stdout, "  Total %s file reads = %ld\n", pg, frd_ctr);
         fprintf(stdout, "  Total %s file writes = %ld\n", pg, fwr_ctr);
         fprintf(stdout, "  Total %s file seeks = %ld\n", pg, fsk_ctr);
         fprintf(stdout, "  Total %s file truncations = %ld\n", pg, ftr_ctr);
      }
      if (memory)
      {
         fprintf(stdout, "  Total %s memory reads = %ld\n", pg, mrd_ctr);
         fprintf(stdout, "  Total %s memory writes = %ld\n", pg, mwr_ctr);
         fprintf(stdout, "  Total %s memory seeks = %ld\n", pg, msk_ctr);
         fprintf(stdout, "  Total %s memory reallocates = %ld\n", pg, mtr_ctr);
      }
   }
   if (disk)
   {
      if (close(fd) == -1)
      {
         fprintf(stderr, "%s: close((%s) ERROR : errno = %d or %s\n",
	     pg, fd, errno, sys_errlist[errno]);
         return(1);
      }
      if (unlink(filename) == -1)
      {
         fprintf(stderr, "%s: unlink(%s) ERROR : errno = %d or %s\n",
	     pg, filename, errno, sys_errlist[errno]);
         return(1);
      }
   }
   if (memory)
   {
      if (malloc_mem)
      {
         free(head_ptr);
      }
      else if (((int)sbrk(-(sbrk(0) - begin_sbrk_val))) == -1)
      {
         fprintf(stderr, "%s: sbrk(-(sbrk(0) - begin_sbrk_val)) Failure : %d %s \n", pg, errno, sys_errlist[errno]);
         return(1);
      }
   }
   if (infinite)
   {
      byte_offset=0;
      ctr_adjust=0;
      fprintf(stdout, "%s : PASS : File Growing/Shrinking Operations Check out Ok\n", pg);
      goto again;
   }
   return(0);
}

/***********************************************************************
 * signal handler
 ***********************************************************************/
void
sig_handler(sig)
int sig;
{
    if (alarm_set) {
       cleanup();
       exit(0);
    }

    fprintf(stderr, "%s: unexpected signal received %d\n", pg, sig);
    cleanup();
    exit(sig);
}

/***********************************************************************
 * cleanup
 ***********************************************************************/
void
cleanup()
{
   if (disk)
   {
      if (close(fd) == -1)
      {
         fprintf(stderr, "%s: close((%d) ERROR : errno = %d or %s\n",
	     pg, fd, errno, sys_errlist[errno]);
      }
      if (unlink(filename) == -1)
      {
         fprintf(stderr, "%s: unlink(%s) ERROR : errno = %d or %s\n",
	     pg, filename, errno, sys_errlist[errno]);
      }
   }
   return;

}

/*
*********************************************************************
* This function adjusts the file pointer index position and or the
* dynamic memory index to the location specified by the temp argument
*********************************************************************
*/
int
do_seek(fd, temp)
int fd;
long temp;
{
   if (debug)
   {
      if (memory && (! malloc_mem))
         fprintf(stdout, "%s: In do_seek routine : byte_offset = %d : current offset = %d :  beg brk = %o octal : sbrk(0) = %o octal\n",
	    pg, byte_offset, temp, begin_sbrk_val, sbrk(0));
      else
         fprintf(stdout, "%s: In do_seek routine : byte_offset = %d : current offset = %d\n",
	   pg, (byte_offset*seed_offset), temp);
      fflush(stdout);
   }

   if (disk)
   {
      if (lseek(fd, 0L, 0) == -1)
      {
         fprintf(stderr, "%s: lseek(fd, 0L, 0) Failure : errno = %d %s\n",
	    pg, errno, sys_errlist[errno]);
         fflush(stderr);
         return(-1);
      }
      else if (lseek(fd, temp, 0) == -1)
      {
         fprintf(stderr, "%s: lseek(fd, %d, 0) Failure : errno = %d %s\n",
	     pg, temp, errno, sys_errlist[errno]);
         fflush(stderr);
         return(-1);
      }
   }
   if (memory)
   {
      if (malloc_mem)
         malloc_mem_ptr = head_ptr + (temp/BLK_SIZE);
      else
         sbrk_mem_ptr = begin_sbrk_val + temp;
   }

   if (stats)
   {
      if (disk)
         fsk_ctr += 2;
      if (memory)
         msk_ctr += 1;
   }
   if (debug)
   {
      if (memory && (! malloc_mem))
         fprintf(stdout, "%s: Leaving do_seek routine : mem-ptr - begin_sbrk_val = %o octal\n",
	     pg, (sbrk_mem_ptr - begin_sbrk_val));
      else
         fprintf(stdout, "%s: Leaving do_seek routine\n", pg);
      fflush(stdout);
   }
   return(0);
}

/*
********************************************************************
* This function truncates to two thirds of the existing bytes within
* a disk file and or of the consumed memory allocated
********************************************************************
*/
int
do_byte_truncates(fd, trunc_interval)
int fd;
int trunc_interval;
{
   long temp;
   static int adj_trunc_ctr=0;
   static int adj_trunc_interval=1;

   if (debug)
   {
      if (memory && (! malloc_mem))
         fprintf(stdout, "%s: In do_byte_truncates routine : byte_offset = %d : beg brk = %o octal : sbrk(0) = %o octal\n",
	     pg, byte_offset, begin_sbrk_val, sbrk(0));
      else
         fprintf(stdout, "%s: In do_byte_truncates routine : byte_offset = %d\n",
	     pg, (byte_offset*seed_offset));
      fflush(stdout);
   }

    /*
    ****************************************************************
    * Insure that truncations do no keep bytes consumed from ever
    * growing to the defined byte consumption size.  Otherwise, this
    * process may never end.  Do not truncate again until the number
    * of bytes previously truncated plus the truncation interval
    * value has been written again
    ****************************************************************
    */
    temp=byte_offset/BLK_SIZE;
    if (debug) {
       fprintf(stdout, "temp=byte_offset)/BLK_SIZE = %d\n", temp);
    }
    if (temp)
    {
       adj_trunc_ctr++;
       if (adj_trunc_ctr < adj_trunc_interval)
       {
          ctr_adjust=0;
          return(0);
       }
       adj_trunc_ctr=0;
       temp=(temp*2)/3;
    }
    temp *= BLK_SIZE;
    if (debug) {
       fprintf(stdout, "temp *= BLK_SIZE = %d\n", temp);
    }
    ctr_adjust=(byte_offset-temp)/BLK_SIZE;
    adj_trunc_interval=ctr_adjust+trunc_interval;
    if (do_seek(fd, (temp*seed_offset)) == -1)
       return(-1);
    if (disk)
    {
       if (trunc(fd) == -1)
       {
           fprintf(stderr, "%s: trunc(2) Error : errno = %d %s",
	       pg, errno, sys_errlist[errno]);
           return(-1);
       }
    }
    if (memory)
    {
       if (malloc_mem) {
          free(malloc_mem_ptr);
       } else if (((int)sbrk(-(sbrk(0) - sbrk_mem_ptr))) == -1) {
          fprintf(stderr, "%s : sbrk(-(sbrk(0) - sbrk_mem_ptr)) Failure : %d %s \n",
	      pg, errno, sys_errlist[errno]);
          return(-1);
       }
    }
    if (stats) {
       if (disk)
          ftr_ctr += 1;
       if (memory)
          mtr_ctr += 1;
    }
    byte_offset=temp;
    if (debug)
    {
      if (memory && (! malloc_mem))
         fprintf(stdout, "%s: Leaving do_byte_truncates routine : byte_offset = %d : beg brk = %o octal : sbrk(0) = %o octal\n",
	     pg, byte_offset, begin_sbrk_val, sbrk(0));
      else
      fprintf(stdout, "%s: Leaving do_byte_truncates routine : byte_offset = %d\n",
	   pg, byte_offset);
       fflush(stdout);
    }
    return(0);
}

/*
*******************************************************************
* This function updates the block which is located at the one third
* block location within already consumed bytes.  This is for disk
* block locations and or memory click locations
*******************************************************************
*/
int
do_byte_updates(fd)
int fd;
{
    int ret;
    long temp;

    if (debug)
    {
       if (memory && (! malloc_mem))
          fprintf(stdout, "%s: In do_byte_updates routine : byte_offset = %d : beg brk = %o octal : sbrk(0) = %o octal\n",
	      pg, byte_offset*seed_offset, begin_sbrk_val, sbrk(0));
       else
          fprintf(stdout, "%s: In do_byte_updates routine : byte_offset = %d\n", pg, (byte_offset*seed_offset));
       fflush(stdout);
    }

    temp=byte_offset/BLK_SIZE;
    if (temp)
       temp=(temp*2)/6;
    temp *= BLK_SIZE;
    if (do_seek(fd, (temp*seed_offset)) == -1)
       return(-1);
    ablock.offset=temp/BLK_SIZE;
    ablock.apattern1=pattern1 | ablock.offset;
    ablock.apattern2=pattern2 ^ ablock.offset;
    if (disk)
    {
       if ((ret=write(fd, (char *)&ablock, BLK_SIZE)) == -1)
       {
          fprintf(stderr, "%s: write(fd, ablock, %d) Error : errno=%d %s\n",
	      pg, BLK_SIZE, errno, sys_errlist[errno]); 
          return(-1);
       }
       else if (ret != BLK_SIZE)
       {
          fprintf(stderr, "%s: write(fd, ablock, %d) Error : Only wrote %d bytes\n",
	      pg, BLK_SIZE, ret); 
          return(-1);
       }
    }
    if (memory)
    {
       if (malloc_mem)
          memcpy(malloc_mem_ptr, (char *)&ablock, sizeof(ablock));
       else 
          memcpy(sbrk_mem_ptr, (char *)&ablock, sizeof(ablock));
    }

    if (stats)
    {
      if (disk)
         fwr_ctr += 1;
      if (memory)
         mwr_ctr += 1;
    }
    /*
    ********************************************
    * Get back to location of last consumed byte
    ********************************************
    */
    if (do_seek(fd, (byte_offset*seed_offset)) == -1)
       return(-1);
    else if (! byte_offset)
       byte_offset += BLK_SIZE;

    if (debug)
    {
       if (memory && (! malloc_mem))
          fprintf(stdout, "%s: Leaving do_byte_updates routine : byte_offset = %d : beg brk = %o octal : sbrk(0) = %o octal\n",
	     pg, byte_offset, begin_sbrk_val, sbrk(0));
       else
          fprintf(stdout, "%s: Leaving do_byte_updates routine : byte_offset = %d\n",
	     pg, byte_offset);
       fflush(stdout);
    }
    return(0);
}

/*
***************************************************************
* This function consumes disk and or memory bytes and or clicks
***************************************************************
*/
int
do_byte_writes(fd)
int fd;
{
    int ret;
    long temp;

    if (debug)
    {
       if (memory && (! malloc_mem))
          fprintf(stdout, "%s: In do_byte_writes routine : beg brk = %o octal : sbrk(0) = %o octal\n",
		pg, begin_sbrk_val, sbrk(0));
       else
          fprintf(stdout, "%s: In do_byte_writes routine\n", pg);
       fflush(stdout);
    }

    /* if (memory)
    * {
    */
    if (do_seek(fd, (byte_offset*seed_offset)) == -1)
       return(-1);
    /* } */
    ablock.offset = byte_offset/BLK_SIZE;
    ablock.apattern1 = pattern1 | ablock.offset;
    ablock.apattern2 = pattern2 ^ ablock.offset;

    if (disk)
    {
       if ((ret=write(fd, (char *)&ablock, BLK_SIZE)) == -1)
       {
          fprintf(stderr, "%s: write(fd, ablock, %d) Error : errno=%d %s\n",
	     pg, BLK_SIZE, errno, sys_errlist[errno]); 
          return(-1);
       }
       else if (ret != BLK_SIZE)
       {
          fprintf(stderr, "%s: write(fd, ablock, %d) Error : Only wrote %d bytes\n", pg, BLK_SIZE, ret); 
          return(-1);
       }
    }
    byte_offset += BLK_SIZE;
    if (memory)
    {
       if (malloc_mem)
       {
          memcpy((char *)malloc_mem_ptr, (char *)&ablock, sizeof(ablock));
          if (debug)
          {
             fprintf(stdout, "BEFORE REALLOC head_ptr = %o : size = %d\n", head_ptr, ((byte_offset*seed_offset)+BLK_SIZE));
             fflush(stdout);
          }
          /*
          *********************************************************
          * Reallocate next chunk of blocks for writing upon end of
          * dynamic memory location.  realloc may move memory from
          * one spot to another so adjust head_ptr to reflect new
          * memory starting addresses.
          *********************************************************
          */
          if ((head_ptr=(struct a_block *)realloc(head_ptr, ((byte_offset) + BLK_SIZE))) == NULL)
          {
             fprintf(stderr, "%s: realloc(%d) errno=%d %s\n",
	         pg, ((byte_offset*seed_offset) + BLK_SIZE), errno, sys_errlist[errno]);
             return(-1);
          }
          if (debug)
          {
             fprintf(stdout, "%s: AFTER REALLOC head_ptr = %o : size = %d\n", pg,
		 head_ptr, ((byte_offset*seed_offset)+BLK_SIZE));
             memcpy((char *)&ablock, (char *)malloc_mem_ptr, BLK_SIZE);
             fprintf(stdout, "\nhead_ptr points at the following\n");
             fprintf(stdout, "ablock.offset = %d\n", ablock.offset);
             fprintf(stdout, "ablock.apattern1 = %o\n", ablock.apattern1);
             fprintf(stdout, "ablock.apattern2 = %o\n", ablock.apattern2);
             fflush(stdout);
          }
       }
       else
       {
          if (debug)
          {
             fprintf(stdout, "BEFORE sbrk(BLK_SIZE) : sbrk(0) = %o octal\n", sbrk(0));
             fflush(stdout);
          }
          if ((int)sbrk((BLK_SIZE*seed_offset)) == -1)
          {
             fprintf(stderr, "\n\n%s : sbrk(BLK_SIZE) Failure : %d %s\n", pg, errno, sys_errlist[errno]);
             return(-1);
          }
          memcpy((char *)sbrk_mem_ptr, (char *)&ablock, sizeof(ablock));
          if (debug)
          {
             memcpy((char *)&ablock, (char *)sbrk_mem_ptr, BLK_SIZE);
             fprintf(stdout, "\n AFTER sbrk(BLK_SIZE): sbrk(0) = %o octal\n", sbrk(0));
             fprintf(stdout, "ablock.offset = %d\n", ablock.offset);
             fprintf(stdout, "ablock.apattern1 = %o\n", ablock.apattern1);
             fprintf(stdout, "ablock.apattern2 = %o\n", ablock.apattern2);
             fflush(stdout);
          }
       }
    }


    if (stats)
    {
       if (disk)
          fwr_ctr += 1;
       if (memory)
          mwr_ctr += 1;
    }
    if (debug)
    {
       if (memory && (! malloc_mem))
          fprintf(stdout, "%s: Leaving do_byte_writes routine : byte_offset = %d: beg brk = %o octal : sbrk(0) = %o octal\n",
	      pg, byte_offset, begin_sbrk_val, sbrk(0));
       else
          fprintf(stdout, "%s: Leaving do_byte_writes routine : byte_offset = %d\n",
	      pg, byte_offset);
       fflush(stdout);
    }
    return(0);
}

/*
***************************************************************
* This function compares read bytes to expected values based on
* offset argument or index locational value
***************************************************************
*/
int
do_compare(ptr, index)
char *ptr;
long index;
{
    if (debug) {
       fprintf(stdout, "In do_compare : expect_zeros = %d : index = %d : index/BLK_SIZE = %d\n", expect_zeros, index, index/BLK_SIZE);
    }
    if (expect_zeros) {
       if (ablock.offset != 0) {
           fprintf(stderr, "%s: Error : Expected %s block offset indicator to be 0, but it was %d\n", pg, ptr, ablock.offset); 
           upanic(PA_PANIC);
           return(-1);
       } else if (strncmp(ptr, "disk", 4) == 0) {
           if (ablock.apattern1 != 0) {
              fprintf(stderr, "%s: Error : Expected %s block offset pattern number one at block offset location %d to be 0, but it was %c\n",
	      pg, ptr, ablock.offset, ablock.apattern1); 
              upanic(PA_PANIC);
              return(-1);
           } else if (ablock.apattern2 != 0) {
              fprintf(stderr, "%s Error : Expected %s block offset pattern number one at block offset location %d to be 0, but it was %c\n",
	      pg, ptr, ablock.offset, ablock.apattern2); 
              upanic(PA_PANIC);
              return(-1);
           }
       }
       
    } else if (ablock.offset != (index/(BLK_SIZE*seed_offset))) {
        fprintf(stderr, "%s: Error : Expected %s block offset indicator to be %d, but it was %d\n", pg, ptr, index/BLK_SIZE, ablock.offset); 
        upanic(PA_PANIC);
        return(-1);
    } else if (ablock.apattern1 != (pattern1 | ablock.offset)) {
        fprintf(stderr, "%s: Error : Expected %s block offset pattern number one at block offset location %d to be %c, but it was %c\n",
	    pg, ptr, ablock.offset, (pattern1 | ablock.offset), ablock.apattern1); 
        upanic(PA_PANIC);
        return(-1);
    } else if (ablock.apattern2 != (pattern2 ^ ablock.offset)) {
        fprintf(stderr, "%s Error : Expected %s block offset pattern number one at block offset location %d to be %c, but it was %c\n",
	    pg, ptr, ablock.offset, (pattern2 ^ ablock.offset), ablock.apattern2); 
        upanic(PA_PANIC);
        return(-1);
    }
    if (debug) {
       fprintf(stdout, "Leaving do_compare : index = %d : index/BLK_SIZE = %d\n", index, index/BLK_SIZE);
    }
    return(0);
}

/*
*******************************************************************
* This function reads bytes that have been written from either disk
* and or memory in preparation for data comparisons
*******************************************************************
*/
int
do_byte_reads(fd)
int fd;
{
    int a, ret, hmany, do_compare();
    long temp;

    if (debug)
    {
       if (memory && (! malloc_mem))
          fprintf(stdout, "%s: In do_byte_reads routine : byte_offset = %d : beg brk v= %o octal : sbrk(0) = %o octal\n",
	     pg, byte_offset, begin_sbrk_val, sbrk(0));
       else
          fprintf(stdout, "%s: In do_byte_reads routine : byte_offset = %d\n",
	     pg, (byte_offset*seed_offset));
       fflush(stdout);
    }

    /* 
    *************************************
    * For all bytes written, validate all
    *************************************
    */
    hmany=byte_offset*seed_offset;
    for (temp=ret=0; temp < hmany; temp += BLK_SIZE)
    {
        if (do_seek(fd, temp) == -1)
           return(-1);
        if (temp == 0) {
           expect_zeros=0;
           a=1;
        } else if (a != seed_offset) {
           expect_zeros=1;
           a++;
        } else {
           expect_zeros=0;
           a=1;
        }
        if (disk) {
           if ((ret=read(fd, (char *)&ablock, BLK_SIZE)) == -1) {
              fprintf(stderr, "%s: read(fd, ablock, %d) Error : errno=%d %s\n",
		  pg, BLK_SIZE, errno, sys_errlist[errno]); 
              return(-1);
           } else if (ret != BLK_SIZE) {
              if ((ret==0) && (hmany -(BLK_SIZE*(seed_offset-1)) == temp))
                 return(0);
              fprintf(stderr, "%s: read(fd, ablock, %d) Error : Only read %d bytes\n", pg, BLK_SIZE, ret); 
              return(-1);
           } else {
              if (stats)
                 frd_ctr += 1;
              
              if (do_compare("file", temp) < 0)
                 return(-1);
           }
        }
        if (memory) {
           if (malloc_mem)
              memcpy((char *)&ablock, (char *)malloc_mem_ptr, BLK_SIZE);
           else
              memcpy((char *)&ablock, (char *)sbrk_mem_ptr, BLK_SIZE);
           if (stats)
              mrd_ctr += 1;
           if (do_compare("memory", temp) < 0) {
              fprintf(stdout, "Val of ablock.offset = %d\n", ablock.offset);
              fflush(stdout);
              return(-1);
           }
           if (debug) {
              fprintf(stdout, "Val of ablock.offset = %d\n", ablock.offset);
              fflush(stdout);
           }
        }
    }
    if (debug) {
       if (memory && (! malloc_mem))
          fprintf(stdout, "%s: Leaving do_byte_reads routine : byte_offset = %d : beg brk = %o octal : sbrk(0) = %o octal\n",
	      pg, byte_offset, begin_sbrk_val, sbrk(0));
       else
          fprintf(stdout, "%s: Leaving do_byte_reads routine : byte_offset = %d\n",
	      pg, byte_offset);
       fflush(stdout);
    }

    return(0);
}
