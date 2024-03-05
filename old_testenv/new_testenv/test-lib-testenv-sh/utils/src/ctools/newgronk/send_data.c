#include "myincludes.h"

//
//   Send local data from the specified file back
//   to the remote user.
//
int send_data(int from, char *filename)
{
char buf[4096];
int fd, sin, amt, sout, err;

   err = 0;

   if (access(filename, F_OK) == 0) {

#ifdef PLATFORM_WINDOWS
      fd = open(filename, O_RDONLY | O_BINARY);
#else
      fd = open(filename, O_RDONLY);
#endif

      sout = fileno(stdout);

      while ((amt = read(fd, buf, 4096)) > 0) {
         if (write(sout, buf, amt) == (-1)) {
            err = -1;
         }
      }
      if (amt == (-1)) {
         err = -1;
      }

      close(fd);
   }

   return(err);
}

