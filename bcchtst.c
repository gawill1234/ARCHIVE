/******************************************************/
/*  Combined io_byte and io_byter from Steve Luzmoor.
    Also combined with what was previously a shell script called
    go_io_byte.  Added a bunch of options so is can run in the 
    original manner, or can be set to run for a much shorter 
    length of time.  Future changes will allow a better regulation
    of the buffer size multiplier(# of blocks per write).
*/
/*  Comments from go_io_byte shell script
 *
 * Starts up io runs with various buffer sizes and stream counts.  The
 * "io_byte" program puts the pid, "record number" and word offset into each
 * word in the output data array.  The buffer sizes are multiples of
 * 4096 bytes adjusted by -1, 0 and +1 to test for buffer cache end
 * cases.
 *
 */
#include <stdio.h>
#include <sys/types.h>
#include <sys/fcntl.h>

#define ORIG_MEDFILESZ 20000
#define ORIG_BIGFILESZ 200000

#define MEDFILESZ 2000
#define BIGFILESZ 20000

#define ORIG_STREAM_NUM 7
#define ORIG_BUF_NUM 35

#define PATTERN(word_offset, block) \
   ((word_offset + (block * (datasize / 8))) | (block << 32) | (pid << 48))

int num_streams[7] = {1,2,3,4,5,6,7};

int buf_size[35] = {1,2,3,5,7,8,10,13,16,17,29,21,23,24,27,31,32,33,
                  64,65,128,129,248,249,250,251,252,999,1000,1001,
                  1024,1025,2047,2048,2049};

int off_by_one[3] = {-1, 0, 1};

main(argc, argv)
int argc;
char *argv[];
{
int datasize, bufs, pid, i, j, k, l, openflag, errorcode;
int streams, num_bufs, mfs, bfs, c, mixed;
char *dirname = NULL;
union {
   struct {
      unsigned unused :16, sherr:8, sigid:8;
   } exit_error;
   int status;
} errstruct;

extern char *optarg;
static char *optstring = "d:mM:B:s:b:rhH";

   mixed = 0;
   streams = 4;
   num_bufs = 20;
   mfs = MEDFILESZ;
   bfs = BIGFILESZ;
   openflag = O_RDWR|O_CREAT;
   errorcode = 0;

   while ((c=getopt(argc, argv, optstring)) != EOF) {

      switch (c) {
         case 'd':
                 dirname = optarg;
                 if (access(dirname, 00) != 0) {
                      (void)fprintf(stderr,
                              "No such directory - %s\n", dirname);
                      exit(0);
                 }
                 break;

         case 'r':
                 openflag = O_RDWR|O_CREAT|O_SYNC;
                 break;

         case 'm':
                 mixed = 1;
                 break;

         case 's':
                 streams = atoi(optarg);
                 if (streams > 7)
                    streams = 7;
                 break;

         case 'b':
                 num_bufs = atoi(optarg);
                 if (num_bufs > 35)
                    num_bufs = 35;
                 break;

         case 'M':
                 mfs = atoi(optarg);
                 if (mfs > ORIG_MEDFILESZ)
                    mfs = ORIG_MEDFILESZ;
                 break;

         case 'B':
                 bfs = atoi(optarg);
                 if (bfs > ORIG_BIGFILESZ)
                    bfs = ORIG_BIGFILESZ;
                 break;

         case 'H':
         case 'h':
         default:
                 explain_tool();
                 break;
      }
   }

   if (dirname == NULL) {
      dirname = (char *)malloc(5);
      sprintf(dirname, "/tmp\0");
   }

   for ( i = 0; i < streams; i ++) {
      /****************************************************/
      /*   run through various blocksizes (4096 byte blocks)
      */
      for (j = 0; j < num_bufs; j++) {
         /***********************************************/
         /*  Set end cases and execute file I/O.
         */
         for (k = 0; k < 3; k++) {

            if (buf_size[j] <= 256)
               bufs = mfs;
            else
               bufs = bfs;

            datasize = buf_size[j] * 4096 + off_by_one[k];

            printf("STARTING: buffer_size = %d,  buffers = %d,  streams = %d\n",
                    datasize, bufs, num_streams[i]);
            fflush(stdout);

            for (l = 0; l < num_streams[i]; l++) {
               if (fork() == 0) {
                  if (mixed == 1) {
                     if ((getpid()%2) == 0)
                        openflag = O_CREAT|O_RDWR;
                     else
                        openflag = O_CREAT|O_RDWR|O_SYNC;
                  }
                  _exit(do_the_io(datasize, bufs, dirname, openflag));
               }
            }

            /**************************************************/
            /*  Wait for file streams to terminate.  End the test
                if there was a problem.
            */
            while (wait(&errstruct.status) != -1) {
               if (errstruct.exit_error.sherr != 0)
                  errorcode++;
            }

            printf("DONE\n");
            fflush(stdout);

            if (errorcode != 0)
               test_done(errorcode);
         }
      }
   }
   test_done(errorcode);
}

int explain_tool()
{

   printf("USAGE:  io_byte [-r] [-M SIZE] [-B SIZE] [-s max_streams]\n");
   printf("                [-b max_buffers] [-d directory] [-h][-H]\n");
   printf("\n");
   printf("-r              Open files for raw I/O\n");
   printf("-m              Mixed, some raw I/O, some not\n");
   printf("-s max_streams  Maximum number of files operated on at one time\n");
   printf("                Max is 7(goes from 1 to chosen max)\n");
   printf("-b max_buffers  Maximum number of 4096 byte blocks per write\n");
   printf("                increments to allow.  Number of blocks per write\n");
   printf("                is actually controlled by a fixed array.  This\n");
   printf("                lets you choose how far into the array you want\n");
   printf("                to go.  Max is 35\n");
   printf("-M SIZE         Number of writes if number of buffers per write\n");
   printf("                is less than or equal to 256\n");
   printf("-B SIZE         Number of writes if number of buffers per write\n");
   printf("                is greater than 256\n");
   printf("-d directory    Directory to write to, default is /tmp\n");
   printf("-h              this help\n");
   printf("-H              this help\n");
   exit(0);
}

int test_done(errorcode)
int errorcode;
{
   if (errorcode == 0) {
      printf("io_byte:  Test Passed\n");
   }
   else {
      printf("io_byte:  Test Failed\n");
   }
   fflush(stdout);
   exit(errorcode);
}

int do_the_io(datasize, bufs, dirname, openflag)
int datasize, bufs, openflag;
char *dirname;
{
int i, j, k, c, ret, filesize, pat, pid;
long *data;
char *filename;
char *cp_pat, *cp_buf;
int fd;

   /*
       * Add one word to be safe - we write data pattern on word boundary
       * below.
       */

   pid = getpid();
   filename = tempnam(dirname, "iobyt");
   data = (long *) malloc(datasize + 8);
   filesize = bufs * datasize;

   if (data == NULL) {
      fprintf(stderr, "malloc failed\n");
      return(1);
   }

   fd = open(filename, openflag, 0644);
   if (fd == -1) {
      perror("open");
      free(data);
      return(1);
   }

   printf("bufs %d, filesize %d, datasize %d\n", bufs, filesize, datasize);

   for (j = 0; j < bufs; j++) {
      for (i = 0; i < (datasize / 8) + 1; i++)
         data[i] = PATTERN(i, j);
      if ((ret = write(fd, data, datasize)) != datasize) {
         fprintf(stderr, "write returned %d\n", ret);
         perror("write failed");
         fprintf(stderr, "failure at offset %d\n", j);
         close(fd);
         free(data);
         unlink(filename);
         return(1);
      }
   }

   if (lseek(fd, 0, 0) == -1) {
      fprintf(stderr, "lseek");
      close(fd);
      free(data);
      unlink(filename);
      return(1);
   }

   for (j = 0; j < bufs; j++) {
      if ((ret = read(fd, data, datasize)) != datasize) {
         fprintf(stderr, "read returned %d\n", ret);
         perror("read failed");
         fprintf(stderr, "failure at off %d\n", j);
         close(fd);
         free(data);
         unlink(filename);
         return(1);
      }
      for (i = 0; i < (datasize / 8); i++) {
         if (data[i] != PATTERN(i, j)) {
            fprintf(stderr,
                "%s: error at word %d at off %d : got %x, expected %x\n",
                filename, i, j, data[i], PATTERN(i, j));
            close(fd);
            free(data);
            unlink(filename);
            return(1);
         }
      }
      if (!(datasize % 8))
         continue;   /* no extra bytes at end */

      pat = PATTERN(i, j);
      cp_pat = (char *) &pat;
      cp_buf = (char *) &data[i];
      /* Check up to 7 bytes at end of buffer */
      for (c = 0; c < datasize % 8; c++) {
         if (*cp_pat != *cp_buf) {
            fprintf(stderr,
                "%s: error at word %d at off %d byte %d: got %x, expected %x\n",
                filename, i, j, c, *cp_buf, *cp_pat);
            close(fd);
            free(data);
            unlink(filename);
            return(1);
         }
         cp_pat++;
         cp_buf++;
      }
   }
   close(fd);
   free(data);
   unlink(filename);
   return(0);
}
