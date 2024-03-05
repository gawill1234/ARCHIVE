#include <stdio.h>
#include <time.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/signal.h>
#include <sys/param.h>
#ifdef __alpha
#include <sys/vol.h>
#endif

#define ROWS  64
#define COLS  256
#define RNC   ROWS * COLS

extern char *syslogfile;
char syslogfp[ROWS][COLS];
int row = 0;

char logcalls(filename, from, funcstr, btime, etime, retval, reset)
char *filename, *from, *funcstr;
long btime, etime;
int retval, reset;
{
float exectime;
int elapsed, ino_num;
struct stat buf;

  if (reset == 1) {
     row = 0;
     return;
  }

  ino_num = (-1);
  if (reset != 0) {
     elapsed = fstat(reset, &buf);
     if (elapsed == 0)
        ino_num = buf.st_ino;
  }

  elapsed = etime - btime;
  exectime = (float)elapsed / (float)HZ;

  if (retval < 0)
     sprintf(syslogfp[row],"%5d  %#21.17f  %-15s  FAIL  %6d  %6d  %s  %s\n\0\0",
             getpid(), exectime, from, ino_num, reset, funcstr, filename);
  else
     sprintf(syslogfp[row],"%5d  %#21.17f  %-15s  PASS  %6d  %6d  %s  %s\n\0\0",
             getpid(), exectime, from, ino_num, reset, funcstr, filename);

   row++;

   if (row >= ROWS)
      dodump();
}

int dodump()
{
int fno, start, i;
struct flock flk;
char outline[RNC];
sigset_t set;

   sigfillset(&set);

   for (i = 0; i < RNC; i++)
      outline[i] = '\0';

   for (i = 0; i < row; i++) {
      strcat(outline, syslogfp[i]);
      syslogfp[i][0] = '\0';
   }
   

   flk.l_type = F_WRLCK;
   flk.l_whence = 0;
   flk.l_start = 0;
   flk.l_len = 0;

   fno = open(syslogfile, O_RDWR | O_CREAT, 00600);
   if (fno != (-1)) {

      sigprocmask(SIG_BLOCK, &set, NULL);

      fcntl(fno, F_SETLKW, &flk);
      flk.l_type = F_UNLCK;
      start = lseek(fno, 0, 2);
     
      write(fno, outline, strlen(outline));
      fsync(fno);
      
      fcntl(fno, F_SETLKW, &flk);

      sigprocmask(SIG_UNBLOCK, &set, NULL);

      close(fno);
   }
   row = 0;
}
