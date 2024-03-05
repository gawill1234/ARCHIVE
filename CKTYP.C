/********************************************************/
/*  Makes sure that a file is the type that is expected.
    If the expected type (file, directory, socket ...) is not
    the same as the actual type, an error message is printed.
*/
#include <sys/types.h>
#include <sys/stat.h>

#include "struct.h"
#include "defs.h"

int check_type(aprod, buf)
struct prodstruct *aprod;
struct stat *buf;
{
char mybuf[256];
int i, error;

   switch (aprod->dirorfile[0]) {

      case 'd':
                if ((S_IFMT & buf->st_mode) != S_IFDIR) {
                   fileis(aprod, buf, "DIRECTORY");
                }
                break;

      case 'p':
                if ((S_IFMT & buf->st_mode) != S_IFIFO) {
                   fileis(aprod, buf, "FIFO (pipe)");
                }
                break;

      case 'b':
                if ((S_IFMT & buf->st_mode) != S_IFBLK) {
                   fileis(aprod, buf, "BLOCK SPECIAL");
                }
                break;

      case 'c':
                if ((S_IFMT & buf->st_mode) != S_IFCHR) {
                   fileis(aprod, buf, "CHARACTER SPECIAL");
                }
                break;

      case 's':
                if ((S_IFMT & buf->st_mode) != S_IFSOCK) {
                   fileis(aprod, buf, "SOCKET");
                }
                break;

      case 'l':
                if ((S_IFMT & buf->st_mode) != S_IFLNK) {
                   fileis(aprod, buf, "SYMBOLIC LINK");
                }
                for (i = 0; i < 256; i++)
                   mybuf[i] = '\0';
                error = readlink(aprod->fullpath, mybuf, 256);
                if (error < 0) {
                   if (aprod->nameout == 0)
                      nameit(aprod);
                   printf("                  COULD NOT READ LINK\n\n");
                }
                else {
                   if (strcmp(mybuf, aprod->linkto) != 0) {
                      if (aprod->nameout == 0)
                         nameit(aprod);
                      printf("  LINK TO     --  EXPECTED:  %s\n",aprod->linkto);
                      printf("                  ACTUAL:    %s\n\n", mybuf);
                   }
                }
                break;

      case 'm':
      case '-':
                if ((S_IFMT & buf->st_mode) != S_IFREG) {
                   fileis(aprod, buf, "FILE");
                }
                break;

      default:
                aprod->notfound = 1;
                fileis(aprod, buf, "UNKNOWN");
                printf("   CANNOT verify %s\n", aprod->location);
                printf("      check mode field in input file\n");
                break;
   }


}
