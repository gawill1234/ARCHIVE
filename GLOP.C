#include <stdio.h>
#include <sys/types.h>
#include <sys/times.h>
#include <sys/param.h>
#include <sys/file.h>
main()
{
FILE *fp, *fopen();
int filebytes, i;

  for (i = 1; i <= 10; i++) {
     filebytes = 4096 * i;
     fp = fopen("trash","w");
     printf("NUMBER OF BYTES = %d\n", filebytes);
     printf("Contiguous preallocation -- ");
     if (ialloc(fileno(fp),filebytes,IA_CONT, 0) != filebytes) {
        printf("did not do it block sized\n");
        printf("Non-Contiguous preallocation -- ");
        if (ialloc(fileno(fp), filebytes, 0, 0) != filebytes) {
           printf("did not do this either\n");
        }
        else {
           printf("did it\n");
        }
     }
     else {
        printf("Did it when block sized\n");
     }
     fclose(fp);
     unlink("trash");
  }

  printf("\n\n");

  for (i = 1; i <= 10; i++) {
     filebytes = 4000 * i;
     fp = fopen("trash","w");
     printf("NUMBER OF BYTES = %d\n", filebytes);
     printf("Contiguous preallocation -- ");
     if (ialloc(fileno(fp),filebytes,IA_CONT, 0) != filebytes) {
        printf("did not do it non-block sized\n");
        printf("Non-Contiguous preallocation -- ");
        if (ialloc(fileno(fp), filebytes, 0, 0) != filebytes) {
           printf("did not do this either\n");
        }
        else {
           printf("did it\n");
        }
     }
     else {
        printf("Did it when non-block sized\n");
     }
     fclose(fp);
     unlink("trash");
  }
}
