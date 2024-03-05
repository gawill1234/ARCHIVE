#include "myincludes.h"

//
//   Import the "importfile" into "filename".
//   filename is a repository file, expected to be
//   repository.xml
//
//   returns -1 on fail and 0 on success.
//
int test_import(char *importfile, char *filename)
{
char repotail[] = "</vce>";
char repohead[] = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?><vce version=\"7.x\" >\n";
char buf1[32], buf2[8192];
int size, fd, seekto, readret, tlen, maxback, fd2, usehead;
int maxgoback;

   maxgoback = 30;

   usehead = maxback = 0;
   size = get_file_size(filename);

   if (size > maxgoback) {
      maxgoback = size;
   }

   tlen = strlen(repotail);
   seekto = size - tlen;

   if (size > 0) {
      fd = openreadwrite(filename);
      if (fd <= 0)
         return(-1);
   } else {
      return(-1);
   }

   lseek(fd, seekto, SEEK_SET);

   readret = read(fd, buf1, tlen);
   while ((strncmp(buf1, repotail, tlen) != 0) && (usehead != 1)) {
      seekto--;
      maxback++;
      if (maxback > maxgoback)
         return(-1);
      lseek(fd, seekto, SEEK_SET);
      readret = read(fd, buf1, tlen);
      if (strncmp(buf1, "<vce", 4) == 0) {
         usehead = 1;
         seekto = 0;
      }
   }

   lseek(fd, seekto, SEEK_SET);

   fd2 = openfile(importfile);
   if (fd2 > 0) {
      if (usehead == 1) {
         write(fd, repohead, strlen(repohead));
      }
      do {
         readret = read(fd2, buf2, 8192);
         write(fd, buf2, readret);
      } while (readret == 8192);

      write(fd, repotail, tlen);
      close(fd2);
   }

   close(fd);

   return(0);
}


