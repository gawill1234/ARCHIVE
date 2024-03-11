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

int main(int argc, char **argv)
{
char mystr[READLEN];
char *usefile, *buf;
int done, i, slotid;
struct timespec mine;

   done = 0;

   SLEEPTIME = 2;

   driversetup(argc, argv);

   mine.tv_sec = SLEEPTIME;
   mine.tv_nsec = 50000;
   usefile = NULL;
   optDir = NULL;

   /*****************************************/
   /**  If we are using the timed option,  **/
   /**  get now, so we can use it for time **/
   /**  comparisons as we go.              **/
   setstarttime();

   //fprintf(runfp, "<vtd>\n");
   fprintf(runfp, "<pid>%d</pid>\n", getpid());
   buf = getdate();
   if (buf != NULL) {
      fprintf(runfp, "<sdate>%s</sdate>\n", buf);
      free(buf);
   }
   fprintf(runfp, "<stime>%ld</stime>\n", GL_start_time);

   fflush(runfp);

   do {

      /*********************************************/
      /**  The randomizer.  If enabled, generate  **/
      /**  a random order test file for use by    **/
      /**  the driver.  Uses a file so that if    **/
      /**  something happens (like a crash), the  **/
      /**  run in question can be recreated.      **/
      if (GL_dorandom) {
         usefile = newTestFileData(infile, usefile);
      } else {
         usefile = infile;
      }

      fp = fopen(usefile, "r");
      if (fp == NULL) {
         printf("VTD:  Could not open input file:  %s\n", infile);
         exit(0);
      }

      do {
         for (i = 0; i < READLEN; i++)
            mystr[i] = '\0';
         if (readline(fp, mystr)) {
            if (strlen(mystr) > 1) {
               if (mystr[0] != '#') {
                  slotid = dohickey(mystr);
                  nanosleep(&mine, NULL);
                  runit(slotid);
               }
#ifdef DEBUG
               else {
                  printf("COMMENT:  %s\n", mystr);
                  fflush(stdout);
               }
#endif
            }
         } else {
            done = 1;
         }

         /***************************************/
         /**  Are we out of time(if enabled)?  **/
         if (RUN_TIME > 0)
            GL_time_over = checktime();

      } while ((!done) && (!GL_time_over));

      /***************************************/
      /**  Close the existing file because  **/
      /**  we may be generating a new one.  **/
      fclose(fp);

      /***************************************/
      /**  Are we out of time(if enabled)?  **/
      /**  Are we just done?  End of file   **/
      /**  for a single pass ...            **/
      if (RUN_TIME == 0) {
         GL_time_over = 1;
      } else {
         done = 0;
         GL_time_over = checktime();
      }

   } while (!GL_time_over);

   /*********************************************/
   /**  Wait of the remaining tests to finish  **/
   hardwait();

   buf = getdate();
   if (buf != NULL) {
      fprintf(runfp, "<edate>%s</edate>\n", buf);
      free(buf);
   }
   fprintf(runfp, "<etime>%d</etime>\n", (int)time((time_t *)NULL));
   //fprintf(runfp, "</vtd>\n");

   fflush(runfp);

   printf("RUN TIME:  %ld seconds\n", ((int)time((time_t *)NULL) - GL_start_time));

   exit(0);
}
