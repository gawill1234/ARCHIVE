#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/vfs.h>

#include "viv_goop.h"

#define LEN sizeof(struct statfs)

extern int errno;

/***************************************************/
/*   GETFSSZ

    This routine gets the approximate size of
    a file system.
*/
/*
   parameters:
      systofil     The name of the file system to get the size of

   return value:
      statvfs structure for the name file system or NULL
*/
struct statfs *getfssz(char *systofil)
{
struct statfs *buf;
int error = 0;

   buf = (struct statfs *)malloc(LEN);
   error = statfs(systofil, buf);
   if (error == 0) {
#ifdef DEBUG
      fprintf(stderr,"FILE SYSTEM IS:  %s\n", systofil);
      fprintf(stderr,"block size:    %ld\n", buf->f_bsize);
      fprintf(stderr,"total blocks:  %ld\n", buf->f_blocks);
      fprintf(stderr,"free blocks:   %ld\n", buf->f_bfree);
      fprintf(stderr,"  available:   %ld\n", buf->f_bavail);
      fprintf(stderr,"total inodes:  %ld\n", buf->f_files);
      fprintf(stderr,"free inodes:   %ld\n", buf->f_ffree);
#endif
      return(buf);
   }
   else {
      if (verbose)
         perror("statvfs");
      return(NULL);
   }
}
