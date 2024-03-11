/***************************************************************************/
/*   This is vtd.  A program to run tests and gather their results.
 *   Yes, it is one big huge file.  If you have this file, you have it all.
 *
 *   Author:  Gary Williams
 *   Made safe for uclibc
 *
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/vfs.h>
#include <fcntl.h>
#include <dirent.h>
#include <time.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include <sys/msg.h>
//#include <sys/sysinfo.h>
#include <sys/utsname.h>
#include <libgen.h>
#include <errno.h>

#include "locals.h"
#include "externs.h"

/*******************************************************/
/*  Set a tests assumed limitations.  These can be 
 *  modified by the test entry in the test data file.
 */
void initLims()
{
   test_limits.type = 1;
   test_limits.mbs = 0;
   test_limits.sup = 1;
   test_limits.exists = 1;
   test_limits.copy = 0;
   test_limits.sess = newsession;
   test_limits.name = NULL;
   test_limits.suite = NULL;
   test_limits.category = NULL;
   test_limits.scon = MAXCONCUR;
   test_limits.mcon = MAXCONCUR;
   test_limits.max_time = TIMEOUT_TIME;
   test_limits.run_cnt = REPEAT_COUNT;
   test_limits.passval = 0;
}


/*******************************************************/
/*   For debugging.  Dump the content of the test_limits
 *   structure.
 */
void dumpLims()
{

   if (test_limits.type == 1) {
      printf("TYPE = POSITIVE\n");
      fflush(stdout);
   } else {
      if (test_limits.type == -1) {
         printf("TYPE = NEGATIVE\n");
         fflush(stdout);
      } else {
         printf("TYPE = BOGUS\n");
         fflush(stdout);
      }
   }
   if (test_limits.sup == 1) {
      printf("SUPPORTED = TRUE\n");
      fflush(stdout);
   } else {
      printf("SUPPORTED = FALSE\n");
      fflush(stdout);
   }

   if (test_limits.mbs == 1) {
      printf("MUST BE STANDALONE = TRUE\n");
      fflush(stdout);
   } else {
      printf("MUST BE STANDALONE = FALSE\n");
      fflush(stdout);
   }
   if (test_limits.sess == 1) {
      printf("NEW SESSION = YES\n");
      fflush(stdout);
   } else {
      printf("NEW SESSION = NO\n");
      fflush(stdout);
   }

   if (test_limits.name != NULL) {
      printf("NAME = %s\n", test_limits.name);
      fflush(stdout);
   } else {
      printf("NAME = DEFAULT\n");
      fflush(stdout);
   }
   printf("MIXED CONCURRENCY = %d\n", test_limits.mcon);
   fflush(stdout);
   printf("SELF CONCURRENCY = %d\n", test_limits.scon);
   fflush(stdout);
   printf("RUN TIME = %d\n", test_limits.max_time);
   fflush(stdout);
   printf("PASS EXIT VALUE = %d\n", test_limits.passval);
   fflush(stdout);
}

/*******************************************************/
/*   Use the test limit name and set the correct
 *   place in the limit structure to the limit value.
 */
void setLimStruct(char *limname, char *limval)
{
int len, i;

   len = strlen(limname);
   for (i = 0; i < len; i++) {
      limname[i] = toupper(limname[i]);
   }

   /*
    *len = strlen(limval);
    *for (i = 0; i < len; i++) {
    *   limval[i] = toupper(limval[i]);
    *}
    */

   if (strcmp(limname, "SESS") == 0) {
      if ((limval[0] == 'Y') || (limval[0] == 'y')) {
         test_limits.sess = 1;
      } else {
         test_limits.sess = 0;
      }
      return;
   }

   if (strcmp(limname, "ONHOST") == 0) {
      if ((limval[0] == 'Y') || (limval[0] == 'y')) {
         test_limits.type = 0;
      }
      return;
   }

   if (strcmp(limname, "COPYDIR") == 0) {
      if ((limval[0] == 'Y') || (limval[0] == 'y')) {
         test_limits.copy = 1;
      }
      return;
   }

   if (strcmp(limname, "NAME") == 0) {
      test_limits.name = (char *)malloc(strlen(limval) + 1);
      strcpy(test_limits.name, limval);
      return;
   }

   if (strcmp(limname, "TYPE") == 0) {
      switch (limval[0]) {
         case '+':
            test_limits.type = 1;
            break;
         case '-':
            test_limits.type = -1;
            break;
         case 'b':
         case 'B':
         case 'm':
         case 'M':
         default:
            test_limits.type = 0;
            break;
      }
      return;
   }

   if ((strcmp(limname, "EXIT") == 0) || (strcmp(limname, "PASS") == 0)) {
      test_limits.passval = atoi(limval);
      return;
   }

   if ((strcmp(limname, "TIME") == 0) || (strcmp(limname, "RUN") == 0)) {
      test_limits.max_time = atoi(limval);
      return;
   }

   if (strcmp(limname, "SCON") == 0) {
      test_limits.scon = atoi(limval);
      return;
   }

   if (strcmp(limname, "LOOP") == 0) {
      test_limits.run_cnt = atoi(limval);
      return;
   }

   if (strcmp(limname, "MCON") == 0) {
      test_limits.mcon = atoi(limval);
      return;
   }

   if (strcmp(limname, "SUPP") == 0) {
      if ((limval[0] == 'Y') || (limval[0] == 'y')) {
         test_limits.sup = 1;
      } else {
         test_limits.sup = 0;
      }
      return;
   }

   if (strcmp(limname, "MBS") == 0) {
      if ((limval[0] == 'Y') || (limval[0] == 'y')) {
         test_limits.mbs = 1;
         test_limits.mcon = 1;
      } else {
         test_limits.mbs = 0;
      }
      return;
   }

   if (strcmp(limname, "SUITE") == 0) {
      i = findThis(limval, 0, ',');
      if (i != (-1)) {
         limval[i] = '\0';
         i++;
         len = strlen(&limval[i]);
         test_limits.category = (char *)calloc(len + 1, 1);
         sprintf(test_limits.category, "%s", &limval[i]);
      }
      len = strlen(&limval[0]);
      test_limits.suite = (char *)calloc(len + 1, 1);
      sprintf(test_limits.suite, "%s", &limval[0]);
      return;
   }

   return;
}

/******************************************************/
/*   Originally had strtok_r in here, but in some cases,
 *   it did not work correctly.
 *   This is a new way of doing getLIms.  It uses more
 *   space, but is a lot cleaner in its means of 
 *   execution.  The original kludge fix to strtok is
 *   now labelled getLims2() and is commented out.
 *   If this fails you, you can rename getLims to
 *   useLess, rename getLims2 to getLims and recompile.
 *   It should work.
 */
void getLims(char *lims)
{
struct limstruct {
   char item[DIRLEN];
   char *limname, *limval;
   int good;
};
struct limstruct thing[10];
int end, left, right, i, j, eqcnt, thingcnt;
char *begin;

   end = strlen(lims);

   thingcnt = eqcnt =  right = left = 0;
   begin = lims;

   for (i = 0; i < 10; i++) {
      thing[i].limname = NULL;
      thing[i].limval = NULL;
      thing[i].good = 0;
      for (j = 0; j < DIRLEN; j++) {
         thing[i].item[j] = '\0';
      }
   }
   
   /************************************************/
   /*   If there are no equal signs, there are no
    *   pairs.  return.
    */
   for (i = 0; i < end; i++) {
      if (lims[i] == '=')
         eqcnt++;
   }

   if (eqcnt == 0)
      return;

   /************************************************/
   /*   Find all of the '=' pairs which should be
    *   seperated by a colon.
    */
   while (left < end) {
      right = findThis(lims, left, ':');
      if (right != (-1)) {
         strncpy(thing[thingcnt].item, begin, right - left);
         begin = &lims[right + 1];
         left = right + 1;
      } else {
         strncpy(thing[thingcnt].item, begin, end - left);
         left = end + 1;
      }
      thingcnt++;
   }

   /************************************************/
   /*   Split each of the '=' pairs into a name and
    *   a value.  If there is no equal sign here, 
    *   ignore the thing.
    */
   for (i = 0; i < thingcnt; i++) {
      right = findThis(thing[i].item, 0, '=');
      if (right != (-1)) {
         thing[i].limname = &thing[i].item[0];
         thing[i].limval = &thing[i].item[right + 1];
         thing[i].item[right] = '\0';
         thing[i].good = 1;
      }
   }

   /************************************************/
   /*   Process the pairs for setting the test
    *   limitations.
    */
   for (i = 0; i < thingcnt; i++) {
      if (thing[i].good == 1) {
         setLimStruct(thing[i].limname, thing[i].limval);
      }
   }

   return;
}

int testLims(char *argstr)
{
int cmstart, left, right;

   initLims();
   cmstart = escapeWS(argstr, 0);

   if (argstr[cmstart] == '(') {
      left = cmstart;
      right = findThis(argstr, left, ')');
      if (right != (-1)) {
         cmstart = right + 1;
         cmstart = escapeWS(argstr, cmstart);
         argstr[left] = '\0';
         argstr[right] = '\0';
         left++;
         getLims(&argstr[left]);
      }
   }

#ifdef LIM_DEBUG
   dumpLims();
#endif

   return(cmstart);
}
