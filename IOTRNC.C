#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <signal.h>

#define NUM_LINES 640
#define ONE_LINE 64

//  If the system stays up, this test passes.

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
int i, file_size;

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
}

void MYIO::readit()
{
int i, retval;
 
   lseek(fno, 0, SEEK_SET);
   for (i = 0; i < NUM_LINES; i++) {
      retval = read(fno, in_text, text_size);
      if (retval > 0) {
         if (strncmp(in_text, out_text, retval) != 0) {
            fprintf(stderr, "io_trunc:  File read failed -- yuk\n");
            fprintf(stderr, "io_trunc,READ:   %s", in_text);
            fprintf(stderr, "io_trunc,WROTE:  %s", out_text);
         }
      }
   }
}

void MYIO::writeit()
{
int i;

   lseek(fno, 0, SEEK_SET);
   for (i = 0; i < NUM_LINES; i++) {
      write(fno, out_text, text_size);
   }

}

void goofy(int signo)
{
   return;
}

main()
{
MYIO afile;
int i = 0, c1, parent, stat_loc;
void goofy(int signo);

   parent = getpid();

 
   while (i < 100) {
      signal(SIGUSR1, goofy);
      signal(SIGALRM, goofy);
      afile.writeit();
      afile.closeit();

      if ((c1 = fork()) == 0) {
         afile.openit();
         alarm(1);
         pause();
         kill(parent, SIGUSR1);
         afile.cutit();
         _exit(0);
      }

      afile.openit();
      kill(SIGUSR1, c1);
      alarm(1);
      pause();
      afile.readit();
      while (waitpid(c1, &stat_loc, WUNTRACED) != -1);
      i++;
   }

   printf("io_trunc:  Test Passed\n");
   fflush(stdout);
   exit(0);
}
