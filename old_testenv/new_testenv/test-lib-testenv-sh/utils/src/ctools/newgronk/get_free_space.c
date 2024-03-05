#include "myincludes.h"

#ifdef PLATFORM_WINDOWS
float getfssz(char *systofil)
{
DWORD dwSectPerClust, dwBytesPerSect, dwFreeClusters, dwTotalClusters;
BOOL fResult;
float free_bytes;

   fResult = GetDiskFreeSpace(systofil, &dwSectPerClust,
                              &dwBytesPerSect, &dwFreeClusters,
                              &dwTotalClusters);

   free_bytes = (float)dwFreeClusters * (float)dwSectPerClust * (float)dwBytesPerSect;
#ifdef DEBUG
   printf("\nUsing GetDiskFreeSpace()...\n");

   printf("The return value: %d, error code: %d\n", fResult, GetLastError());

   printf("Sector per cluster = %ul\n", dwSectPerClust);

   printf("Bytes per sector = %ul\n", dwBytesPerSect);

   printf("Free cluster = %ul\n", dwFreeClusters);

   printf("Total cluster = %ul\n", dwTotalClusters);

   //Using GetDiskFreeSpace() need some calculation for the

   //free bytes on disk

   printf("Total free bytes = %-20.2\n", free_bytes);
#endif

   return(free_bytes);

}

float get_free_gb(char *systofil)
{
float free_bytes = 0;
float free_gb = 0.0;
float ttf3 = 1024.0 * 1024.0 * 1024.0;

   free_bytes = (float)getfssz(systofil);
   free_gb = free_bytes / ttf3;

   //printf("%s FREE GB:  %-14.2f\n",  systofil, free_gb);

   return(free_gb);
}

float get_free_mb(char *systofil)
{
float free_bytes = 0;
float free_mb = 0.0;
float ttf2 = 1024.0 * 1024.0;

   free_bytes = (float)getfssz(systofil);
   free_mb = free_bytes / ttf2;

   //printf("%s FREE MB:  %-14.2f\n",  systofil, free_mb);

   return(free_mb);
}
#endif

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
#ifdef __SUNOS__
struct statvfs *getfssz(char *systofil)
{
struct statvfs *buf;
int error = 0;

   buf = (struct statvfs *)malloc(sizeof(struct statvfs));
   error = statvfs(systofil, buf);
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
      return(NULL);
   }
}
#endif

#ifdef __LINUX__
struct statfs *getfssz(char *systofil)
{
struct statfs *buf;
int error = 0;
float gb = 0.0;
float total_bytes = 0;
float free_bytes = 0;
float ttf3 = 1024.0 * 1024.0 * 1024.0;
//float ttf3 = 1000.0 * 1000.0 * 1000.0;

   buf = (struct statfs *)malloc(sizeof(struct statfs));
   error = statfs(systofil, buf);
   if (error == 0) {
#ifdef DEBUG
      total_bytes = ((float)buf->f_blocks / .95) * (float)buf->f_bsize;
      free_bytes = ((float)buf->f_bfree / .95) * (float)buf->f_bsize;


      printf("FILE SYSTEM IS:  %s\n", systofil);
      printf("fs type:       0x%lx\n", buf->f_type);
      printf("fs sid:        %lu\n", buf->f_fsid);
      printf("block size:    %lu\n", buf->f_bsize);
      printf("total blocks:  %lu\n", buf->f_blocks);
      printf("free blocks:   %lu\n", buf->f_bfree);

      printf("free percent:  %lf\n", ((float)buf->f_bfree / (float)buf->f_blocks) * 100.0);
      printf("used percent:  %lf\n\n", 100.0 - (((float)buf->f_bfree / (float)buf->f_blocks) * 100.0));

      printf("free gbytes:   %-14.2f\n", (free_bytes / ttf3));
      printf("total gbytes:  %-14.2f\n", (total_bytes / ttf3));
      printf("free bytes:    %-14.0f\n", free_bytes);
      printf("total bytes:   %-14.0f\n\n\n", total_bytes);
#endif
      return(buf);
   }
   else {
      //perror("statfs");
      return(NULL);
   }
}
#endif

#if defined(__LINUX__) || defined(__SUNOS__)
float get_free_gb(char *systofil)
{
#ifdef __LINUX__
struct statfs *buf;
#endif
#ifdef __SUNOS__
struct statvfs *buf;
#endif
float free_bytes = 0.0;
float free_gb = 0.0;
float ttf3 = 1024.0 * 1024.0 * 1024.0;

   buf = getfssz(systofil);
   if (buf != NULL) {
      free_bytes = ((float)buf->f_bfree / .95) * (float)buf->f_bsize;
      free_gb = free_bytes / ttf3;
      free(buf);
   }

   //printf("%s FREE GB:  %-14.2f\n",  systofil, free_gb);

   return(free_gb);
}

float get_free_mb(char *systofil)
{
#ifdef __LINUX__
struct statfs *buf;
#endif
#ifdef __SUNOS__
struct statvfs *buf;
#endif
float free_bytes = 0.0;
float free_mb = 0.0;
float ttf2 = 1024.0 * 1024.0;

   buf = getfssz(systofil);
   if (buf != NULL) {
      free_bytes = ((float)buf->f_bfree / .95) * (float)buf->f_bsize;
      free_mb = free_bytes / ttf2;
      free(buf);
   }

   //printf("%s FREE MB:  %-14.2f\n",  systofil, free_mb);

   return(free_mb);
}
#endif

