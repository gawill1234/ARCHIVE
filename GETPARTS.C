#include <stdio.h>
#include <string.h>

#include "struct.h"
#include "defs.h"

struct prodstruct *getpartsls(oneline, curdir, iostart)
char *oneline, *curdir, *iostart;
{
struct prodstruct *aprod, *getperms(), *makefullpath(), *initaprod();
int spaces, len, i;
char *tryit;
char perms[ITEMLEN], no[ITEMLEN], owner[ITEMLEN], group[ITEMLEN];
char size[ITEMLEN], mon[ITEMLEN];
char dayofmon[ITEMLEN], timeofday[ITEMLEN], filename[ITEMLEN];
char lnkptr[ITEMLEN], lnkto[ITEMLEN];
char majordev[ITEMLEN], minordev[ITEMLEN];

   /************************************************************/
   /*   If the line is not long enough to be from the ls command
        return NULL.
   */
   len = strlen(oneline);
   if (len < LSMINLINELEN) {
      return(NULL);
   }
   /************************************************************/

   /************************************************************/
   /*   If there are no blanks in the input line, it is probably
        not a complete line, or the line is not from the ls
        command.  Return NULL.
   */
   len--;
   spaces = countchars(oneline, ' ');
   if (spaces == 0) {
      return(NULL);
   }
   if (len == spaces) {
      return(NULL);
   }
   /************************************************************/
   for (len = 0; len < ITEMLEN; len++) {
      perms[len] = '\0';
      no[len] = '\0';
      owner[len] = '\0';
      group[len] = '\0';
      size[len] = '\0';
      mon[len] = '\0';
      dayofmon[len] = '\0';
      timeofday[len] = '\0';
      filename[len] = '\0';
      lnkptr[len] = '\0';
      lnkto[len] = '\0';
   }

   sscanf(oneline, "%s%s%s%s%s%s%s%s%s%s%s", perms, no, owner, group,
          size, mon, dayofmon, timeofday, filename, lnkptr, lnkto);

   if ((perms[0] == '\0') || ((no[0] == '\0') && (owner[0] == '\0'))) {
      return(NULL);
   }

   /************************************************************/
   /*   Since there are 8 gaps in the output from ls -l, there are
        at least 8 blanks.  If there are fewer than 8 spaces on
        the input line, probably ought to return NULL.
   */

   if (spaces < 8) {
      if (strcmp(perms, "total") == 0)
         return(NULL);
   }
   /************************************************************/

   if ((perms[0] == 'b') || (perms[0] == 'c')) {
      if (countchars(oneline, ',') > 0) {
         for (i = 0; i < LSMINLINELEN - 1; i++) {
            if ((oneline[i] == ',') && (oneline[i + 1] != ' '))
               oneline[i] = ' ';
         }
      }
      sscanf(oneline, "%s%s%s%s%s%s%s%s%s%s", perms, no, owner, group,
             majordev, minordev, mon, dayofmon, timeofday, filename);
      strcpy(size, "0\0");
   }

   if (filename[0] == '\0') {
      tryit = (char *)checkitems(perms, no, owner, group, size, mon, dayofmon,
                  timeofday, filename, lnkptr, lnkto);
      strcpy(filename, tryit);
   }

   aprod = initaprod(oneline);
   aprod->location = (char *)malloc(strlen(iostart) + 1);
   strcpy(aprod->location, iostart);

   aprod = getperms(aprod, perms);

   if (size[0] != '\0') {
      if ((strspn(size, ALPHABET) == 0) &&
          (strspn(size, PUNCTUATION) == 0) &&
          (strspn(size, NUMERIC) != 0)) {
         aprod->size = (char *)malloc(strlen(size) + 1);
         strcpy(aprod->size, size);
      }
   }

   if (aprod->dirorfile[0] == 'l') {
      if (lnkto[0] == '\0') {
         aprod->name = (char *)malloc(strlen(filename) + 1);
         strcpy(aprod->name, filename);
      }
      else {
         aprod->name = (char *)malloc(strlen(filename) + 1);
         strcpy(aprod->name, filename);
         aprod->linkto = (char *)malloc(strlen(lnkto) + 1);
         strcpy(aprod->linkto, lnkto);
      }
   }
   else {
      if (filename[0] != '\0') {
         aprod->name = (char *)malloc(strlen(filename) + 1);
         strcpy(aprod->name, filename);
      }
   }


   if (filename[0] != '\0')
      aprod = makefullpath(aprod, curdir);

   return(aprod);
}

int countchars(string, c)
char *string;
char c;
{
int i, len, cnt;

   cnt = 0;

   len = strlen(string);

   for (i = 0; i < len; i++)
      if (string[i] == c)
         cnt++;
   return(cnt);
}

struct prodstruct *getperms(aprod, mid)
struct prodstruct *aprod;
char *mid;
{
unsigned retper();


   if ((*mid != '\0') && (*mid != ' ')) {
      aprod->dirorfile[0] = *mid;
      aprod->dirorfile[1] = '\0';
   }

   if (strlen(mid) != 10) {
      return(aprod);
   }

   mid++;

   aprod->permstr = (char *)malloc(strlen(mid) + 1);
   strcpy(aprod->permstr, mid);

   aprod->owner = aprod->owner + retper(mid);
   mid++;
   aprod->owner = aprod->owner + retper(mid);
   mid++;
   if ((*mid == 's') || (*mid == 'S'))
      aprod->setuid = 1;
   if (retper(mid) == 1) {
      aprod->owner = aprod->owner + 1;
      aprod->tryexec = 1;
   }
   
   mid++;
   aprod->group = aprod->group + retper(mid);
   mid++;
   aprod->group = aprod->group + retper(mid);
   mid++;
   if ((*mid == 's') || (*mid == 'S'))
      aprod->setgid = 1;
   if (retper(mid) == 1) {
      aprod->group = aprod->group + 1;
      aprod->tryexec = 1;
   }

   mid++;
   aprod->other = aprod->other + retper(mid);
   mid++;
   aprod->other = aprod->other + retper(mid);
   mid++;
   if ((*mid == 't') || (*mid == 'T'))
      aprod->stickybit = 1;
   if (retper(mid) == 1) {
      aprod->other = aprod->other + 1;
      aprod->tryexec = 1;
   }

   return(aprod);
}

unsigned retper(mid)
char *mid;
{
   if (mid != NULL) {
      switch (*mid) {
         case 'r':
                   return(4);

         case 'w':
                   return(2);

         case 'x':
                   return(1);

         case 's':
                   return(1);

         case 't':
                   return(1);

         default:
                   return(0);
      }
   }
   return(0);
}
