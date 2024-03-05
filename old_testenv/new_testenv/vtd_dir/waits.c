/***************************************************************************/
/*   This is vtd.  A program to run tests and gather their results.
 *   Yes, it is one big huge file.  If you have this file, you have it all.
 *
 *   Author:  Gary Williams
 *   Made safe for uclibc
 *
 */
#include <stdio.h>
#include <sys/wait.h>
#include <time.h>

#include "locals.h"
#include "externs.h"

/**********************************************************/
/*   A couple of wait routines.  One waits on concurrency.
 *   I.e., if the number of allowable tests drops below the
 *   threshold, waiting stops so a new test can be started.
 *
 *   The other is a hard wait.  It waits for all child 
 *   processes to be done
 */
void hardwait()
{
int pid, status;
struct timespec mine;

   mine.tv_sec = 0;
   mine.tv_nsec = 5;

   pid = 0;

   /**********************************************************/
   /*   Scheduling trickery.  Force the test to run first so
    *   drive does not end up waiting the full 1 second every
    *   time.
    */
   nanosleep(&mine, NULL);

   /**********************************************************/
   /*   A wait loop.  There is no time limit here.  Wait until
    *   all remaining tests are complete before exiting.
    *   Each pass through the loop takes 1 second.
    */
   while (pid >= 0) {
      pid = waitpid(-1, &status, WNOHANG);
      if (pid > 0) {
         dostatus(status, pid);
      } else {
         if (pid == 0) {
            sleep(1);
            flusholdtests();
         }
      }
   }
   /**********************************************************/

}

void waitforit(int waitcount, int newtime)
{
int pid, status, wtime, dothetime;
struct timespec mine;

   mine.tv_sec = 0;
   mine.tv_nsec = 5;

   wtime = 0;
   pid = 0;

   dothetime = MAXTIMEOUT;

   if (newtime > dothetime)
      dothetime = newtime;

   /**********************************************************/
   /*   Scheduling trickery.  Force the test to run first so
    *   drive does not end up waiting the full 1 second every
    *   time.
    */
   nanosleep(&mine, NULL);

   
   /**********************************************************/
   /*   A wait loop.  Wait for dothetime seconds (max).  If the 
    *   test is not complete in that time it gets killed. 
    *   Otherwise, normal cleanup occurs.  Each pass through
    *   the loop takes 1 second.
    */
   while ((wtime < dothetime) && (pid >= 0)) {
      pid = waitpid(-1, &status, WNOHANG);
      if (pid > 0) {
         dostatus(status, pid);
      } else {
         if (pid == 0) {
            if (runcount >= waitcount) {
               sleep(1);
               wtime++;
               flusholdtests();
            } else {
               flusholdtests();
               break;
            }
         }
      }
   }
   /**********************************************************/

}
/*
 *  END OF WAIT ROUTINES
 */
/*********************************************************/
