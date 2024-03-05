#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>

#include "myincludes.h"

int build_the_dir_tree(char *fullpath, int fileordir)
{
char *working_copy, *newdir;

   working_copy = (char *)calloc(strlen(fullpath) + 1, 1);
   sprintf(working_copy, "%s\0", fullpath);


   if (fileordir == AFILE) {
      newdir = _dirname(working_copy);
   } else {
      newdir = working_copy;
   }

   if (access(newdir, F_OK) != 0) {
      working_copy = (char *)calloc(strlen(fullpath) + 1, 1);
      sprintf(working_copy, "%s\0", newdir);
      newdir = _dirname(newdir);
      if (strcmp(working_copy, newdir) != 0) {
         build_the_dir_tree(newdir, ADIR);
      }
#ifdef PLATFORM_WINDOWS
      mkdir(working_copy);
#else
      mkdir(working_copy, 0755);
#endif
      free(working_copy);
   }

   free(newdir);
   return(0);

}


//
//   Grab posted data and stick it in the
//   provided filename.
//
int get_data(int from, char *filename)
{
char holder[3] = {0};
char *tmp;
int i, newamt;
char *buf, *outbuf;
int fd, sin, amt, sout, err, totsize, filelen;
int rdsz, rmdr, cpy;

   filelen = totsize = err = 0;

   if (streq(getenv("REQUEST_METHOD"),"POST")) {
      build_the_dir_tree(filename, AFILE);
#ifdef PLATFORM_WINDOWS
      fd = open(filename, O_RDWR | O_CREAT | O_TRUNC | O_BINARY);
#else
      fd = open(filename, O_RDWR | O_CREAT | O_TRUNC);
#endif

      sin = fileno(stdin);
      fdopen(sin, "r+b");

      filelen = atoi(getenv("CONTENT_LENGTH"));
      printf("   <SIZE>%d</SIZE>\n", filelen);
      fflush(stdout);

      if (filelen == 0) {
         if (chmod(filename, 00666) == (-1)) {
            err = -1;
         }
         close(fd);
         return(0);
      }

      if (filelen < TRAN_READSIZE) {
         rdsz = filelen;
      } else {
         rdsz = TRAN_READSIZE;
      }

      buf = (char *)calloc(1, rdsz);
      outbuf = (char *)calloc(1, rdsz + 3);

      while (totsize < filelen) {
         if ((amt = read(sin, buf, rdsz)) > 0) {
            cpy = amt;
            i = 0;

            strcpy(outbuf, holder);
            rmdr = strlen(holder);

            holder[0] = '\0';
            holder[1] = '\0';
            if (buf[amt - 1] == '%') {
               cpy = amt - 1;
               holder[0] = buf[amt - 1];
            }
            if (buf[amt - 2] == '%') {
               cpy = amt - 2;
               holder[0] = buf[amt - 2];
               holder[1] = buf[amt - 1];
            }

            strncat(outbuf, buf, cpy);
            cpy = cpy + rmdr;

            tmp = (char *)calloc(1, cpy);
            newamt = url_decode(outbuf, tmp, cpy);

            if (write(fd, tmp, newamt) == (-1)) {
               err = -1;
            }
            free(tmp);
#ifdef PLATFORM_WINDOWS
            _flushall();
#else
            sync();
            sync();
#endif
            totsize = totsize + amt;
         }
      }

      if (amt == (-1)) {
         err = -1;
      }

      if (chmod(filename, 00666) == (-1)) {
         err = -1;
      }
      close(fd);
      free(buf);
      free(outbuf);
   } else {
      printf("   <ERROR>Request method is not POST</ERRORp>\n");
      fflush(stdout);
   }

   return(err);
}

