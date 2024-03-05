#include <sys/types.h>
#include <sys/stat.h>

#include "struct.h"

int fileis(aprod, buf, expected)
struct prodstruct *aprod;
struct stat *buf;
char *expected;
{

   if (aprod->nameout == 0)
      nameit(aprod);

   printf("  UNIT TYPE   --  EXPECTED:  %s\n", expected);

   switch (buf->st_mode & S_IFMT) {

      case S_IFDIR:
                   printf("                  ACTUAL:    DIRECTORY\n");
                   break;

      case S_IFREG:

                   printf("                  ACTUAL:    FILE\n");
                   break;

      case S_IFCHR:
                   printf("                  ACTUAL:    CHARACTER SPECIAL\n");
                   break;

      case S_IFBLK:
                   printf("                  ACTUAL:    BLOCK SPECIAL\n");
                   break;

      case S_IFLNK:
                   printf("                  ACTUAL:    SYMBOLIC LINK\n");
                   break;

      case S_IFSOCK:
                   printf("                  ACTUAL:    SOCKET\n");
                   break;

      case S_IFIFO:
                   printf("                  ACTUAL:    FIFO (pipe)\n");
                   break;

      default:
                   printf("                  ACTUAL:    UNKNOWN\n");
                   break;
   }

   printf("\n");
}
int sizeis(aprod, buf)
struct prodstruct *aprod;
struct stat *buf;
{
         if (aprod->nameout == 0)
            nameit(aprod);
         printf("  SIZE        --  EXPECTED:  %s\n", aprod->size);
         printf("                  ACTUAL:    %d\n\n", buf->st_size);
}
