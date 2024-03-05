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
*    TEST IDENTIFIER : clstrfdg
*
*    COMPILE         : cc -o clstrfdg clstrfdg.c
*
*    TEST TITLE      : Create a file in random order with multiple
*                      processes and I/O types.
*
*    PARENT DOCUMENT : none
*
*    TEST CASE TOTAL : 1 (or 512 depending on how you look at it)
*                        (or even 2048 (512 * 4, see above))
*
*    WALL CLOCK TIME : 30
*
*    AUTHOR : Gary Williams
*
*    CO-PILOT: none
*
*    TEST CASES
*
*       Creates 512 files.  The first is 8 words long, the second is
*       16 words long, the third is 24 words long(8 word increments)
*       and so on up to a maximum file length of 8 blocks.  Each file
*       is written one word at a time in random order.  The contents
*       of each file are validated.  Any file which does not check out
*       will cause the test to terminate and the bad file will remain
*       in current working directory. All file names are like
*       "rndts...".
*       
*       When each file is complete, it should look like this when an
*       "od -d filename" is done:
*
*            0000000000000 0000000000000000000 0000000000000000001
*            0000000000002 0000000000000000002 0000000000000000003
*            0000000000004 0000000000000000004 0000000000000000005
*            0000000000006 0000000000000000006 0000000000000000007
*            0000000000008 0000000000000000008 0000000000000000009
*                 .
*                 .
*                 .
*            000000end
*
*       Test does async, listio, and normal I/O to the files it creates,
*       possibly all at the same time.
*
*    ENVIRONMENTAL NEEDS
*
*       Need to have a /tmp on the machine.
*
*    DETAILED DESCRIPTION
*
*       Self-documenting code so see below
*
*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#**/

/*************************************************/
#include <stdio.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/times.h>
#include <sys/stat.h>

#include <sys/iosw.h>

#include <sys/listio.h>

extern int errno;
extern char *sys_errlist[];

char *progname;

#define BYTESINWORD 8

#define BLOCKSZ 4096

int allthesame = 0;

struct randomstruct {
     long sequence;
     long used;
     long number;
     long seekamt;
     long writetype;
     long whohas;
};

int checkrandom(filename, filebytes)
char *filename;
int filebytes;
{
int error, retbytes, fno, placeerror;
int mode = 00600;
long placeholder;
int numwords, i, readerr;


   numwords = filebytes / BYTESINWORD;

   error = filebytes;

   readerr = fno = placeerror = 0;

   fno = open(filename, O_RDWR, mode);
   if (fno != (-1)) {
      for (i = 0; i < numwords; i++) {
         readerr = read(fno, &placeholder, BYTESINWORD);
         if (readerr != BYTESINWORD) {
            if (readerr == EOF)
               printf("%s:  Could not read file %s:  %s\n", 
                       progname, filename, sys_errlist[errno]);
            else {
               printf("%s:  File %s was not the correct size\n",
                       progname, filename);
               printf("%s:       Expected %d bytes\n",
                       progname, filebytes);
               printf("%s:       Actual   %d bytes\n",
                       progname, i * BYTESINWORD);
            }

            fno = close(fno);
            if (fno != 0) {
               printf("%s:  Could not close file %s:  %s\n",
                       progname, filename, sys_errlist[errno]);
            }
            error = -1;
            return(error);
         }
         if (placeholder != i) {
            error = -1;
            placeerror = 1;
         }
      }

      readerr = read(fno, &placeholder, BYTESINWORD);
      if (readerr != 0) {
         error = -1;
         printf("%s:  File %s is too large\n",
                 progname, filename);
         printf("%s:      Expected final value:  %d\n",
                 progname, numwords - 1);
         printf("%s:      Read a value of:       %d\n",
                 progname, placeholder);
      }

      fno = close(fno);
      if (fno != 0) {
         printf("%s:  Could not close file %s:  %s\n",
                 progname, filename, sys_errlist[errno]);
         error = -1;
      }
   }
   else {
      printf("%s:  Could not open file %s:  %s\n",
              progname, filename, sys_errlist[errno]);
   }

   if (placeerror == 1)
      printf("%s:  Contents of file %s are incorrect\n",
              progname, filename);

   return(error);
}

struct randomstruct *genit(numwords, numprocs)
int numwords;
{
struct randomstruct *numlist;
int biggness, i, j, k;
double drand48();

   srand48(time((long *)0));
   biggness = sizeof(struct randomstruct);
   numlist = (struct randomstruct *)malloc(numwords * biggness);
   for (i = 0; i < numwords; i++) {
      numlist[i].sequence = i;
      numlist[i].used = 0;
      numlist[i].number = -1;
      numlist[i].seekamt = -1;
      numlist[i].whohas = 0;
      numlist[i].writetype = (int)(drand48() * (double)(numwords)) % 4;
   }

   for (i = 0; i < numwords; i++) {
      j = (int)(drand48() * (double)(numwords));
      if (numlist[j].used == 1) {
         j = 0;
         while ((j < numwords) && (numlist[j].used == 1))
            j++;
      }
      numlist[j].used = 1;
      numlist[i].number = j;
      numlist[i].seekamt = numlist[i].number * BYTESINWORD;
   }

   for (i = (numwords - 1); i > 0; i--) {
      j = numlist[i - 1].seekamt + BYTESINWORD;
      numlist[i].seekamt = numlist[i].seekamt - j;
   }

   if (allthesame == 0) {
      if (numprocs > 1) {
         k = numwords / numprocs;
         for (i = 1; i < numprocs; i++) {
            numlist[i * k].seekamt = numlist[i * k].number * BYTESINWORD;
            for (j = (i * k); j < ((i * k) + k); j++) {
               numlist[j].whohas = i;
            }
         }
      }
   }

#ifdef DEBUG
   printf("NUMWORDS = %d,  NUMPROCS = %d, %d\n", numwords, numprocs, k);
   for (i = 0; i < numwords; i++) {
      printf("%d    %d     %d    %d\n", numlist[i].sequence,
              numlist[i].whohas, numlist[i].number, numlist[i].seekamt);
   }
#endif

   return(numlist);
}

int dowrite(fno, buffer, writetype)
int fno, writetype;
char *buffer;
{
int error = 0;
struct listreq request;

int signo = 0;
struct iosw status, *statarray[1];

   if (writetype > 0) {
      status.sw_count = 0;
      status.sw_error = 0;
      status.sw_flag = 0;

      if (writetype > 1) {
         request.li_nbyte = BYTESINWORD;
         request.li_nstride = 1;
         request.li_filstride = BYTESINWORD;
         request.li_flags = 0;
         request.li_offset = 0;
         request.li_signo = 0;
         request.li_memstride = 0;
         request.li_opcode = LO_WRITE;
         request.li_fildes = fno;
         request.li_buf = (char *)buffer;
         request.li_status = &status;
      }

      if (writetype == 3) {
         error = listio(LC_WAIT, &request, 1);
         error = status.sw_count;
      }
      else {
         if (writetype == 2) 
            error = listio(LC_START, &request, 1);

         if (writetype == 1)
            error = writea(fno, buffer, BYTESINWORD, &status, signo);

         statarray[0] = &status;
         recalls(1, statarray);
         error = status.sw_count;
      }

   }
   else {
      error = write(fno, buffer, BYTESINWORD);
   }

   return(error);
}

void dowhohas(filename, filebytes, numlist, numwords, procnum)
char *filename;
int filebytes, numwords, procnum;
struct randomstruct *numlist;
{
int error, fno;
int mode = 00600;
long *placeholder;
int getppid(), badcount;
int i, seekloc;


   badcount = error = fno = 0;

   fno = open(filename, O_CREAT|O_RDWR, 0600);
   if (fno != (-1)) {

      for (i = 0; i < numwords; i++) {

         if (procnum == numlist[i].whohas) {

            placeholder = &numlist[i].number;

#ifdef DEBUG
         debug_out(filename, 19, fno, numlist[i].seekamt, SEEK_CUR);
         debug_out(filename, 4, fno, *placeholder, BYTESINWORD);
#endif

            seekloc = lseek(fno, numlist[i].seekamt, SEEK_CUR);
            if (seekloc == (-1)) {
               printf("%s:  File seek incorrect:  %s\n", 
                       progname, sys_errlist[errno]);
               badcount++;
               if (badcount >= 2) {
                  free(numlist);
                  fno = close(fno);
                  if (fno != 0) {
                     printf("%s:  Could not close file:  %s\n", 
                             progname, filename, sys_errlist[errno]);
                  }
                  return;
               }
            }

            error = dowrite(fno, placeholder, numlist[i].writetype);

            if (error != BYTESINWORD) {
               printf("%s:  Could not write file %s:  %s\n",
                       progname, filename, sys_errlist[errno]);
               free(numlist);
               fno = close(fno);
               if (fno != 0) {
                  printf("%s:  Could not close file %s:  %s\n", 
                          progname, filename, sys_errlist[errno]);
               }
               return;
            }
         }

         if ((i % 50) == 0) {
            if (getppid() == 1) {
               free(numlist);
               fno = close(fno);
               if (fno != 0) {
                  printf("%s:  Could not close file %s:  %s\n", 
                          progname, filename, sys_errlist[errno]);
               }
               error = unlink(filename);
               if (error != 0)
                  printf("%s:  Unable to unlink file %s:  %s\n", 
                          progname, filename, sys_errlist[errno]);
               return;
            }
         }
      }
      fno = close(fno);
      if (fno != 0) {
         printf("%s:  Could not close file %s:  %s\n", 
                 progname, filename, sys_errlist[errno]);
      }
   }
   else {
      printf("%s:  Could not open file %s:  %s\n", 
              progname, filename, sys_errlist[errno]);
   }
 
   return;
}
/*****************************************************************/
/*   DOAFILE

   Create and write a file.  This routine also determines if the file
   will be appendable, truncatable, neither or both.
*/
/*
   parameters:
      filename         Name of file to create
      pipelock         Name of data pipe lock file
      filebytes        Number of bytes to write to file
      pfp              FILE pointer to data pipe or file
      preallocflag     preallocate(don't preallocate) file space
      fileordm         file space use or data migration use
      pipename         Name of data pipe

   return value:
      error            Supposed to be 0.  1 if number of bytes written
                       is incorrect or some other file operation like
                       close fails.
*/

int dorandom(filename, filebytes, numprocs)
char *filename;
int filebytes, numprocs;
{
int error, retbytes, numwords, i;
struct randomstruct *numlist;

   numwords = (filebytes + (BYTESINWORD - 1)) / BYTESINWORD;
   filebytes = numwords * BYTESINWORD;
   numlist = genit(numwords, numprocs);

   error = retbytes = 0;

   for (i = 1; i < numprocs; i++) {
      if (fork() == 0) {
         if (allthesame == 0)
            (void)dowhohas(filename, filebytes, numlist, numwords, i);
         else
            (void)dowhohas(filename, filebytes, numlist, numwords, 0);
         _exit(0);
      }
   }

   (void)dowhohas(filename, filebytes, numlist, numwords, 0);

   free(numlist);

   if (numprocs > 1)
      while (wait((int *)0) != -1);

   if ((retbytes = checkrandom(filename, filebytes)) == filebytes) {
      error = unlink(filename);
      if (error != 0)
        printf("%s:  Unable to unlink file %s:  %s\n", 
                progname, filename, sys_errlist[errno]);
   }

   return(retbytes);
}
#ifdef DEBUG
int debug_out(filename, syscall_number, value2, value3, value4)
char *filename;
long syscall_number, value2, value3, value4;
{

   switch (syscall_number) {
      case 4:
               printf("%s:  %s  WRITE  %d  %d  %d\n",
                       progname, filename, value2, value3, value4);
               break;

      case 19:
               printf("%s:  %s  LSEEK  %d  %d  %d\n",
                       progname, filename, value2, value3, value4);
               break;
   }
}
#endif

main(argc, argv)
char **argv;
int argc;
{
int retbytes, passfail, i, numprocs, c;
char *filename, *getcwd(), filename2[32];

extern char *optarg;
extern int optind;

static char *optstring = "an:";

   passfail = 0;
   progname = argv[0];
   sprintf(filename2, "%s-output\0", progname);
   /* numprocs can be 1, 2, 4, or 8; nothing else. */
   numprocs = 4;

   while ((c=getopt(argc, argv, optstring)) != EOF) {
      switch (c) {
         case 'a':
                   allthesame = 1;
                   break;
         case 'n':
                   numprocs = atoi(optarg);
                   switch (numprocs) {
                      case 1:   break;
                      case 2:   break;
                      case 3: 
                      case 4:
                      case 5:
                                numprocs = 4;
                                break;

                      case 6:
                      case 7:
                      case 8:
                                numprocs = 8;
                                break;

                      default:
                                if (numprocs > 8)
                                   numprocs = 8;

                                if (numprocs < 1)
                                   numprocs = 1;
                                break;
                   }
                   break;
         default:
                   fprintf(stderr, "Running in default mode\n");
                   break;
      }
   }


   for (i = (BYTESINWORD * 8); i <= (BLOCKSZ * 8); i = i + (BYTESINWORD * 8)) {
      filename = tempnam(getcwd((char *)NULL, 64), "rndts");
      if (filename != NULL) {
         retbytes = dorandom(filename, i, numprocs);
      }
      else {
         printf("%s:  Generated FILENAME was NULL\n", progname);
         fflush(stdout);
         retbytes = dorandom(filename2, i, numprocs);
      }
      if (retbytes != i) {
         passfail = i;
         break;
      }
      if (filename != NULL)
         free(filename);
   }

   if (passfail != 0) {
      printf("%s:  Test FAIL \n", progname);
      printf("%s:       %d byte file attempted\n", progname, passfail);
      printf("%s:       %s is last file written\n", progname, filename);
      free(filename);
   }
   else {
      printf("%s:  Test PASS \n", progname);
   }
   exit(passfail);
}
