/*************************************************************************
 *
 *  TCP/IP Testing       Cray Research, Inc.   Eagan, Minnesota
 *
 *  TEST IDENTIFIER      : $Source:$
 *
 *  TEST TITLE           : Socket system calls regression -- get/setportbm()
 *
 *  PARENT DOCUMENT      : Socket System Calls Regression Test Plan
 *
 *  AUTHOR               : Bill Schoofs
 *
 *  CO-PILOT             : Hal Peterson
 *
 *  INITIAL RELEASE      : Unicos 8.0
 *
 *  TEST CASES           : This test is protocol independent.  getportbm and
 *			   setportbm are so closely interrelated that all test
 *			   cases for both are included in this one test.
 *
 *			   1) call getportbm with valid bitmap pointer  positive
 *			   2) call setportbm with valid bitmap pointer  positive
 *			   3) call getportbm with invalid bitmap ptr    negative
 *			   4) call setportbm with invalid bitmap ptr    negative
 *
 *  CPU TYPES            : CRAY-XMP, CRAY-YMP, CRAY-2, CRAY-C90
 *
 *  INPUT SPECIFICATION  : Usage: portbm
 *
 *  OUTPUT SPECIFICATION : Standard output provided by t_res.c
 *
 *  SPECIAL REQUIREMENTS : This test needs to be run as uid=0 (root).
 *
 *  IMPLEMENTATION NOTES : This test assumes that at least one TCP port in the
 *			   range from 0 to 1023 is not a well known port.
 *
 *  DETAILED DESCRIPTION : get current port bitmap from kernel memory into
 *				a 1st bitmap.
 *			   ensure bit for test port not already on.
 *			   copy 1st bitmap to 2nd bitmap .
 *			   turn on bit for test port in 2nd bitmap.
 *			   set 2nd bitmap into kernel memory.
 *			   get updated port bitmap from kernel memory into
 *				a 3rd bitmap.
 *			   ensure 2nd bitmap and 3rd bitmap are the same.
 *			   set 1st bitmap back into kernel memory.
 *
 *  KNOWN BUGS           : None
 *
 */

#include <errno.h>
#include <signal.h>
#include <sys/param.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/sysmacros.h>
#include "test.h"
#include "usctest.h"

int exp_enos[]={0, 0};
int do_restore=0;
extern char *sys_errlist[];
char *MSG_LOG="portbm.log";
extern int Tst_count;
char *TCID="portbm";
char myname[256];
ulong		bitmap_init[PORTBITMAX], /* initial bitmap from kernel memory */
		bitmap_mod[PORTBITMAX], /* modified bitmap for this test */
		bitmap_cmp[PORTBITMAX]; /* bitmap read for comparison */
void setup(), cleanup();

main(int ac, char **av)
{
  char *msg;
  u_short	testport;               /* port number for test */
  long		k;    			/* bit to set */
  int           lc, wordnb;             /* word where to set the bit for port */
  int           pos;                    /* position in word of the bit to set */


  if ((msg=parse_opts(ac, av, (option_t *) NULL)) != (char *) NULL) {
     tst_brkm(TBROK, NULL, "OPTION PARSING ERROR - %s", msg);
     tst_exit();
  }
  bzero(myname, sizeof(myname));
  bzero((char *)bitmap_init, sizeof(bitmap_init));
  bzero((char *)bitmap_mod, sizeof(bitmap_mod));
  bzero((char *)bitmap_cmp, sizeof(bitmap_cmp));
  /* Do test setup */
  setup();
 
  /* set the expected errnos... */
  TEST_EXP_ENOS(exp_enos);

  for (Tst_count=lc=0; TEST_LOOPING(lc); Tst_count=0,lc++) {
      /*
      * Ensure that the first word of the bitmap is nonzero.  If
      * so, then assume that it is a valid bitmap. If getportbm
      * fails, then do not attempt the setportbm test.
      */

      if (!bitmap_init[0]) {
         tst_resm(TFAIL, "getportbm: invalid portmap");
      } else {
         tst_resm(TPASS, "getportbm Successful");

         /*
         * This test assumes that at least one TCP port in the
         * range from 0 to 1023 is not a well known port.
         */

         for (testport=1023; (TCPPORTRESV(bitmap_init, testport))  && testport;
              testport--);
         if (!testport) {
            tst_resm(TBROK, "getportbm: all TCP ports are well known ports"); 
         } else {

	    /*
	    * Copy the bitmap and turn on the bit for port
            * "testport".
	    */

            bcopy(bitmap_init, bitmap_mod, sizeof(bitmap_init));
	    k = 1 ;
	    wordnb = testport / BIPW ;
	    pos = testport % BIPW ;
	    k <<= pos;
	    bitmap_mod[wordnb] |= k;
	
            TEST(setportbm(bitmap_mod));
            if (TEST_RETURN < 0) {
               tst_resm(TFAIL, "setportbm FAILURE: %d %s", errno, sys_errlist[errno]);
	    } else if (getportbm(bitmap_cmp) < 0) {
               tst_resm(TFAIL, "getportbm FAILURE: %d %s", errno, sys_errlist[errno]);
	    } else  if (bcmp(bitmap_mod, bitmap_cmp, sizeof(bitmap_mod))) {
               tst_resm(TFAIL, "bitmaps before and after setportbm are different");
	    } else {
               tst_resm(TPASS, "setportbm: was Successful");

	       /*
	        * Restore the kernel bitmap back to its 
                * original state
	        */

	       if (setportbm(bitmap_init) < 0) {
                  tst_brkm(TBROK, cleanup, "setportbm FAILURE: %d %s", errno, sys_errlist[errno]);
	       }
	    }
	 }
      }
  
      /*
      * Negative test cases
      */

      if (getportbm(0) < 0) {
         tst_resm(TPASS, "getportbm: correctly gave unsuccessful return code");
      } else {
         tst_resm(TFAIL, "getportbm: should have failed with bitmap pointer equal to zero");
      }
   
      if (setportbm(0) < 0) {
         tst_resm(TPASS, "setportbm: correctly gave unsuccessful return code");
      } else {
         tst_resm(TFAIL, "setportbm: should have failed with bitmap pointer eual to zero");
         cleanup();
      }

  }
  cleanup();
}

void
setup()
{
  int fd;

  /* capture signals */
  tst_sig(NOFORK, DEF_HANDLER, cleanup);

  /* make a temp directory and cd to it */
  tst_tmpdir();

  /* Pause if that option was specified */
  TEST_PAUSE;

  sprintf(myname, "/tmp/%s", TCID);
  /*
  * Loop until we get a lockfile.  This allows multiple
  * versions of this test to run concurrently, even
  * though they cannot all be beyond this point at
  * the same time
  */
  while ((fd=open(myname, O_RDWR|O_CREAT|O_EXCL, 0666)) == -1)
         ;;
  
  close(fd);
  /*
  * Get the system Port Map
  */
  if (getportbm(bitmap_init) < 0) {
    tst_brkm(TBROK, cleanup, "getportbm FAILURE: %d %s", errno, sys_errlist[errno]);
  }
  do_restore=1;
}

void
cleanup()
{
     if (do_restore) {
        if (setportbm(bitmap_init) < 0) {
           tst_resm(TWARN, "cleanup(): setportbm FAILURE: %d %s", errno,  sys_errlist[errno]);
        }
     }
     /*
     * Release the lockfile
     */
     unlink(myname);
     /*
     * print timing stats if that option was specified.
     * print errno log if that option was specified.
     */
     TEST_CLEANUP;

     /* remove the temp dir */
     tst_rmdir();

     /* exit with return code appropriate for results */
     tst_exit();
}
