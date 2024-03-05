#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <signal.h>

#define NUM_LINES 640
#define ONE_LINE 64

//  If this test runs to completion, it passes.
//  If it fails, the system probably went down.
//  Test does (tries to anyway) read, write and 
//  truncation on the same file at the same time.
//  Data is not checked because it will be in an
//  unknown state most of the time.

class MYIO {

   public:
      MYIO();
      ~MYIO();

      void closeit();
      void writeit();
      void readit();
      void cutit();
      void openit();

   private:
      char *in_text, *out_text, *file_name;
      int text_size, cur_loc, fno;
};


MYIO::~MYIO()
{
   unlink(file_name);
   free(in_text);
   free(file_name);
   free(out_text);
   close(fno);
}

MYIO::MYIO()
   :cur_loc(NUM_LINES)
{
int i;

   text_size = ONE_LINE;
   in_text = (char *)malloc(text_size + 1);
   out_text = (char *)malloc(text_size + 1);
   for (i = 0; i < ONE_LINE; i++) 
      out_text[i] = (char)(i + 60);

   out_text[63] = '\n';

   file_name = tempnam(getcwd((char *)NULL, 80), "tr-io");

   fno = open(file_name, O_RDWR | O_CREAT, 0666);
   if (fno == -1) {
      fprintf(stderr, "io_trunc:  File open failed -- exiting\n");
      exit(-1);
   }
}

void MYIO::openit()
{
   fno = open(file_name, O_RDWR, 0666);
   if (fno == -1) {
      fprintf(stderr, "io_trunc:  File open failed -- exiting\n");
      exit(-1);
   }
}

void MYIO::closeit()
{
   close(fno);
}

void MYIO::cutit()
{
int i, file_size, j;

   for (j = 0; j < 100; j++) {
      for (i = 0; i < NUM_LINES; i++) {
         file_size = text_size * cur_loc;
         lseek(fno, file_size, SEEK_SET);
#ifdef SUN
         ftruncate(fno, file_size);
#else
         trunc(fno);
#endif
         cur_loc--;
      }
      cur_loc = NUM_LINES;
   }
}

void MYIO::readit()
{
int i, j, retval;
 
   for (j = 0; j < 100; j++) {
      lseek(fno, 0, SEEK_SET);
      for (i = 0; i < NUM_LINES; i++) {
         retval = read(fno, in_text, text_size);
//         if (retval > 0) {
//            if (strncmp(in_text, out_text, retval) != 0) {
//               fprintf(stderr, "io_trunc:  File read failed -- yuk\n");
//               fprintf(stderr, "io_trunc,READ:   %s", in_text);
//               fprintf(stderr, "io_trunc,WROTE:  %s", out_text);
//            }
//         }
      }
   }
}

void MYIO::writeit()
{
int i, j;

   for (j = 0; j < 100; j++) {
      lseek(fno, 0, SEEK_SET);
      for (i = 0; i < NUM_LINES; i++) {
         write(fno, out_text, text_size);
      }
   }

}

main()
{
MYIO afile;
int i = 0;

   afile.writeit();

   while (i < 10) {
      if (fork() == 0) {
         afile.openit();
         afile.readit();
         _exit(0);
      }

      if (fork() == 0) {
         afile.openit();
         afile.cutit();
         _exit(0);
      }
      if (fork() == 0) {
         afile.openit();
         afile.writeit();
         _exit(0);
      }

      while (wait((int *)0) != -1);
      i++;
   }

   printf("io_trunc2:  Test Passed\n");
   fflush(stdout);
   exit(0);
}
