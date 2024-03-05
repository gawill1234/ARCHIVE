#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pwd.h>
#include <time.h>

#include "struct.h"

int nameit(aprod)
struct prodstruct *aprod;
{


   aprod->nameout = 1;
   printf("___________________________________________________\n\n");
   printf("INPUT:\n%s\n", aprod->inline);

   switch (aprod->dirorfile[0]) {

      case 'd':
                   printf("DIRECTORY NAME:     %s\n", aprod->name);
                   break;

      case 'm':
      case '-':
                   printf("FILE NAME:          %s\n", aprod->name);
                   break;

      case 'c':
                   printf("CHARACTER SPECIAL:  %s\n", aprod->name);
                   break;

      case 'b':
                   printf("BLOCK SPECIAL:      %s\n", aprod->name);
                   break;

      case 'l':
                   printf("LINK NAME:          %s", aprod->name);
                   if (aprod->linkto != NULL)
                      printf(" -> %s\n", aprod->linkto);
                   else
                      printf("\n");
                   break;

      case 's':
                   printf("SOCKET NAME:        %s\n", aprod->name);
                   break;

      case 'p':
                   printf("PIPE NAME:          %s\n", aprod->name);
                   break;

      default:
                   printf("UNKNOWN TYPE:       %s\n", aprod->name);
                   break;
   }

   printf("PATHNAME:           %s\n", aprod->location);
   printf("ACTUAL SEARCH PATH: %s\n", aprod->fullpath);
   printf("\n");
   return(1);
}

int unknownfile(filename, dirname)
char *filename, *dirname;
{
struct stat *buf = NULL;
int there, i;
char *fullpath;
char mybuf[256];
struct passwd *ownerstuff, *getpwuid();
struct tm *getit;

   buf = (struct stat *)malloc(sizeof(struct stat));
   fullpath = (char *)malloc(strlen(dirname) + strlen(filename) + 2);
   strcpy(fullpath, dirname);
   strcat(fullpath, "/");
   strcat(fullpath, filename);

   there = lstat(fullpath, buf);

   printf("___________________________________________________\n\n");
   printf("UNEXPECTED NAME FOUND\n\n");

   switch (buf->st_mode & S_IFMT) {

      case S_IFDIR:
                   printf("DIRECTORY NAME:     %s\n", filename);
                   break;

      case S_IFREG:
                   printf("FILE NAME:          %s\n", filename);
                   break;

      case S_IFCHR:
                   printf("CHARACTER SPECIAL:  %s\n", filename);
                   break;

      case S_IFBLK:
                   printf("BLOCK SPECIAL:      %s\n", filename);
                   break;

      case S_IFLNK:
                   printf("LINK NAME:          %s", filename);
                   for (i = 0; i < 256; i++)
                      mybuf[i] = '\0';
                   i = readlink(fullpath, mybuf, 256);
                   if (i < 0)
                      printf(" -> NOT LINKED TO ANYTHING\n");
                   else
                      printf(" -> %s\n", mybuf);
                   break;

      case S_IFSOCK:
                   printf("SOCKET NAME:        %s\n", filename);
                   break;

      case S_IFIFO:
                   printf("PIPE NAME:          %s\n", filename);
                   break;

      default:
                   printf("UNKNOWN TYPE:       %s\n", filename);
                   break;
   }

   printf("PATHNAME:           %s\n", dirname);
   printf("ACTUAL SEARCH PATH: %s\n", fullpath);

   printf("\n");

   crud.st_mode = buf->st_mode;

   printf("  PERMISSIONS --        :    %s%s%s\n",
              printperm((int)crud.glop.ownerp),
              printperm((int)crud.glop.groupp),
              printperm((int)crud.glop.otherp));

   ownerstuff = getpwuid(buf->st_uid);

   if (ownerstuff != NULL) {
      printf("  OWNER       --        :    %s           %s\n",
                 ownerstuff->pw_name, ownerstuff->pw_gecos);
   }
   else
      printf("  OWNER       --        :    UNKNOWN\n");
   printf("  SIZE        --        :    %d\n", buf->st_size);
   getit = localtime(&buf->st_mtime);
   printf("  CREATED     --        :    %02d/%02d/%02d   ",
           getit->tm_mon + 1, getit->tm_mday, getit->tm_year);
   printf("%02d:%02d:%02d\n", getit->tm_hour, getit->tm_min, getit->tm_sec);

   printf("\n");
   free(fullpath);
   free(buf);
   printf("___________________________________________________\n\n");
}
