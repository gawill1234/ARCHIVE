/*
*****************************************************************
* tsetuplb.c: Generic C Test Program Enviornment Setup Interface
*
* Author: Gary A. Williams
*
* Date: 12/21/95
*****************************************************************
*
* ******************** PUBLIC FUNCTIONS *************************
*
* T_Brk       - Report Test Case Result Via Message Or Disk File,
*               Break All Remaining Test Cases
* T_Brkm      - Report Test Case Result Messages, Break All
*               Remaining Test Cases
* T_BrkLoop   - Report Test Case Result Via Message Or Disk File,
*               Break All Remaining Loop Test Cases, Call User
*               Supplied Function
* T_BrkLoopM  - Report Test Case Result Messagee, Break All 
*               Remaining Loop Test Cases, Call User Supplied
*               Function
* T_Exit      - Report Test Return Value And Exit
* T_Mkchdir   - Create A Unique Directory, Change Dir To It
* T_Res       - Report Test Case Result Via Message Or Disk File
* T_ResM      - Report Test Case Result Messages
* T_Rmdir     - Remove A Directory And All Contents
* T_Sig       - Setup Test Environment Signal Processing
*
* ************************** SYNOPSIS ***************************
*
* T_Brk(int type, char *fname, void (*cleanup) (), char *tmesg, [,arg]...)     
*
* T_Brkm(int type, void (*cleanup) (), char *tmesg, [,arg]...)
*
* T_BrkLoop(int type, char *fname, void (*cleanup) (), char *tmesg, [,arg]...)
*
* T_BrkLoopM(int type, void (*cleanup) (), char *tmesg, [,arg]...)
*
* T_Exit()
*
* T_Mkchdir()
*
* T_Res(int type, char *fname, char *tmesg [,arg]...)
*
* T_ResM(int type, char *tmesg [,arg]...)
*
* T_Rmdir()
*
* T_Sig(int flags, int (*traphandler) (), void (*cleanup) ())
*
*****************************************************************
*
* ******************** PRIVATE FUNCTIONS ************************
*
* DefTrapHandler - Trap Unexpected Signals
* T_Buf_Handler  - Buffer Test Case I/O Messages
* T_Breaks       - Perform Broken Test Case Processing
* T_Checkenv     - Checks Environment Variable Settings
* T_Condense     - Condense/Limit Test Case Results
* T_Environ      - Manages Library STDOUT Stream Flow
* T_Libdebug     - Enables Library Debugging Mode Levels
* T_Print        - Print Test Case Result Messages
* T_Verbose      - Process All Test Case Results
*
* ************************* SYNOPSIS ****************************
*
* DefTrapHandler(int sig)
*
* T_Buf_Handler(int file_contents)
*
* T_Breaks(int caller, int type, char *fname, void (*fnc) (), char *tmesg)
*
* T_Checkenv()
*
* T_Condense(char *tcid, int tnum, int ttype, char *tmesg)
*
* T_Environ()
*
* T_Libdebug(int value)
*
* T_Print(char *tcid, int tnum, int ttype, char *tmesg)
*
* T_Verbose(char *tcid, int tnum, int ttype, char *tmesg)
*
*****************************************************************
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <varargs.h>
#include <sys/errno.h>
#include <sys/signal.h>
#include <sys/stat.h>
#include "test.h"

/*
***************
* Value defines
***************
*/
#define PREFIX_SIZE     4
#define STRING_SIZE   132
#define MAXMESG       150
#define USERMESG     1024
#define BIGBUF      81920
#define VERBOSE         1
#define CONDENSE        2
#define NOPASS          3
#define T_BRK          01
#define T_BRKLOOP      02
/*
****************
* String Defines
****************
*/
#define CONDENSE_S   "CONDENSE"
#define NOPASS_S     "NOPASS"
#define VERBOSE_S    "VERBOSE"
#define T_BRK_S      "T_Brk"
#define T_BRKLOOP_S  "T_BrkLoop"

/*
***********************
* External Declarations
***********************
*/
extern int errno;
extern char *sys_errlist[];
extern char *Tcid;
extern int Tst_Total;

/*
******************
* Global Variables
******************
*/
char *Tst_Buffer=NULL;               /* Pointer To Buffered I/O memory */
char *TestDir;                       /* Pointer to Unique File System */
char *TempDir;                       /* Pointer to Desired File System */
char T_Temporary[USERMESG];
char T_MesgBuf[BIGBUF];              /* Testing Buffered I/O */
int Lib_Debug=0;
#define DEBUGLIB(a) if (a <= Lib_Debug)
int Tst_Count=0;                     /* Current Test Case Indicator */
int Tst_LpTotal=0;
int Do_Translation=1;                /* Flag for Performing vsprintf */
long Tst_Buf_Size=0;                 /* Size of Buffered I/O Memory */
static FILE *T_out=NULL;             /* T_Res output file pointer */
static int T_exval=0;                /* Exit value used by T_Exit() */
static int T_range=1;                /* t_print() number of print cases */
static int T_mode=VERBOSE;           /* Default Print Mode */
static int First_time=TRUE;          /* Becomes FALSE after first T_Res call */
static int Range_warn=FALSE;         /* Possible Range error indicator */
static int flusher=0;
/*
***********************************************************
* Following static variables used for saving previous test
* case information.  This is utilized for compressing test
* case messages when operating outside of VERBOSE messaging
* mode
***********************************************************
*/ 
static char *Last_tcid;              /* test case id */
static int Last_num;                 /* test case number */
static int Last_type;                /* test result type */
static char *Last_mesg;              /* test result message */

/*
************
* Types, etc
************
*/
int vsprintf(), T_Checkenv();
void (*T_cleanup) ();  /* Pointer to a function of type void */
void T_Exit(), T_Resm(), T_Brkm(), T_Print(), T_Verbose(), T_Condense();
void T_Brk(), T_Brkm(), T_BrkLoop(), T_BrkLoopm(), T_Print();
void *malloc(), free();

/*
***************************************************
* Library Interface For Enabling Internal Debugging
***************************************************
*/
void
T_Libdebug(int value)
{
   Lib_Debug=value;
}

/*
**************************************************************
* Function : T_Mkchdir() - Create a Unique Temporary Directory
*                          And chdir(2) to it
**************************************************************
*/

void
T_Mkchdir()
{
    char *funame = "T_mkchdir()";

    char *getenv();
    char prefix[PREFIX_SIZE];    /* First three Tcid characters */
    char message[STRING_SIZE];   /* Message Buffer */

    /*
    ***********************************************
    * If TMPDIR is set in environment, set it here.
    * Otherwise, default to /tmp
    ***********************************************
    */
    if ((TempDir=getenv("TMPDIR")) == NULL) {
       TempDir="/tmp";
    }
    /* 
    ****************************************************
    * Simply return if NODIR enviornment variable is set
    ****************************************************
    */
    if (getenv("NODIR") == NULL) {
       strncpy(prefix, Tcid, PREFIX_SIZE-1);
       prefix[PREFIX_SIZE-1] = '\0';
    
       if ((TestDir=tempnam(TempDir, prefix)) == NULL) {
          sprintf(message, "%s : Unable to form temporary directory name %s with prefix %s\n", funame, TempDir, prefix);
          T_Brkm(TBROK, 0, message);
          sprintf(message, "%s : Advisory : no user cleanup function called before exiting", funame);
          T_Resm(TWARN, message);
          T_Exit();
       }
       DEBUGLIB(4) { fprintf(stdout, "%s : In T_Mkchdir() : TempDir = %s : prefix = %s : TestDir = %s\n",
                Tcid, TempDir, prefix, TestDir); fflush(stdout); }

       /*
       ********************************************************
       * Make directory, establish appropriate permissions, and
       * change directory to it
       ********************************************************
       */
       if (mkdir(TestDir, 0755) == -1) {
          sprintf(message, "%s : mkdir(%s) Failure : %d %s\n", funame, errno, sys_errlist[errno]);
          T_Brkm(TBROK, 0, message);
          sprintf(message, "%s : Advisory : no user cleanup function called before exiting", funame);
          T_Resm(TWARN, message);
          T_Exit();
       } else if (chmod(TestDir, 0755) == -1) {
          sprintf(message, "%s : chmod(%s, 0755) Failure : %d %s\n", funame, TestDir, errno, sys_errlist[errno]);
          T_Brkm(TBROK, 0, message);
          sprintf(message, "%s : Advisory : no user cleanup function called before exiting", funame);
          T_Resm(TWARN, message);
          T_Exit();
       } else if (chdir(TestDir) == -1) {
          sprintf(message, "%s : chdir(%s) Failure : %d %s\n", funame, TestDir, errno, sys_errlist[errno]);
          T_Brkm(TBROK, 0, message);
          sprintf(message, "%s : Advisory : no user cleanup function called before exiting", funame);
          T_Resm(TWARN, message);
          T_Exit();
       }
    }
    
}


/*
***************************************************************
* Function : T_Rmdir() - Recursively Remove Temporary Directory
*                        Created By T_Mkchdir()
***************************************************************
*/

void
T_Rmdir()
{
    int (*signal())();                /* Signal System Call */
    char *funame = "T_mkchdir()";
    char buffer[STRING_SIZE];   /* Buffer */

    /* 
    ****************************************************
    * Simply exit if NODIR enviornment variable is set
    ****************************************************
    */
    if (getenv("NODIR") == NULL) {
       /*
       ************************************************
       * Be Defensive, in case TestDir got changed from
       * what it was orginally assigned to be
       ************************************************
       */
       if (strcmp(TestDir, "/") == 0) {
          T_Resm(TWARN, "%s : attempted to recursive remove / or root directory.  Remove aborted\n", funame);
          T_Exit();
       } else if (strcmp(TestDir, "*") == 0) {
          T_Resm(TWARN, "%s : attempted to recursive remove *. Remmove aborted\n", funame);
          T_Exit();
       } else if (chdir(TempDir) == -1) {
          sprintf(buffer, "%s : chdir(%s) Failure : %d %s\n", funame, TestDir, errno, sys_errlist[errno]);
          T_Brkm(TBROK, 0, buffer);
       }
       sprintf(buffer, "rm -rf %s", TestDir);
       DEBUGLIB(4) { fprintf(stdout, "%s : In T_Rmdir() :  TestDir = %s : buffer = %s\n",
                Tcid, TestDir, buffer); fflush(stdout); }
       /*
       ***************************************************************
       * system(3) will generate a SIGCLD, so turn it off or ignore it
       ***************************************************************
       */
       signal(SIGCLD, SIG_IGN);
       if (system(buffer)) {
          sprintf(buffer, "%s : Unable to recursively remove directory %s", funame, TestDir); 
       }
    }
    T_Exit();
}

void (*T_cleanup) ();  /* Pointer to a function of type void */

/*
****************************************************************
* Function : DefTrapHandler(int sig) - Report unexpected signal,
*            register to recatch and cleanup if requested
****************************************************************
*/

static int
DefTrapHandler(int sig)
{
    int (*signal())();                /* Signal System Call */
    char mesg[MAXMESG];

    DEBUGLIB(3) { fprintf(stdout, "%s : In DefTrapHandler() :  sig = %d\n",
                Tcid, sig); fflush(stdout); }

    if ((sig != SIGCLD) && (sig != SIGSTOP) && (sig != SIGCONT)) {
       if (signal(sig, DefTrapHandler) == (int (*)()) -1) {
          sprintf(mesg, "%s : signal() failed for signal %d : %d %s",
                 Tcid, sig, errno, sys_errlist[errno]); 
          T_Resm(TWARN, mesg); 
       }
    }
    sprintf(mesg, "%s : Unexpected signal %d received.", sig);
    T_Brkm(TBROK, 0, mesg);

    /*
    ******************
    * Cleanup and Exit
    ******************
    */
    if (T_cleanup) {
       (*T_cleanup)();
    }
    T_Exit();
}

/*
**********************************************************************
* Function : T_Sig(int flags, int (*handler) (), void(*cleanup) ()) 
*            - Setup To Catch Unexpected Signals 
*
*            flags - a mask of directives
*            handler - pointer to callers signal trap handler function
*            cleanup - pointer to callers cleanup function
*
*            NOTE : if either handler or cleanup are void pointers,
*                   then default routines local to this file are
*                   utilized
**********************************************************************
*/

void
T_Sig(int flags, int (*traphandler)(), void(*cleanup)())
{
    char *getenv();
    char mesg[MAXMESG];               /* T_Res message buffer */
    int sig;
    int (*signal())();                /* Signal System Call */
    int def_handler();                /* Default Signal Handler */

    DEBUGLIB(3) { fprintf(stdout, "%s : In T_Sig() :  flags = %d\n",
                  Tcid, flags); fflush(stdout); }
    /*
    ****************************************************
    * Simply return if NOSIG environment variable is set
    ****************************************************
    */
    if (getenv("NOSIG") == NULL) {
       /*
       **********************************************
       * Save T_cleanup and handler function pointers
       **********************************************
       */
       T_cleanup = cleanup;

       if (traphandler == DEF_SIGHANDLER) {
          traphandler=DefTrapHandler;
          DEBUGLIB(2) { fprintf(stdout, "%s : Using DEF_SIGHANDLER\n", Tcid);
                     fflush(stdout); }
       }
   
       /*
       **************************************************
       * Loop Through All Signals And Set Signal Handlers
       **************************************************
       */ 

       for (sig=1; sig < NSIG; sig++) {
           if ((sig != SIGKILL) && (sig != SIGSTOP) && (sig != SIGCONT)) {
              if (! ((sig == SIGCLD) && (flags == FORK))) {
                 if (signal(sig, traphandler) == (int (*)()) -1) {
                    sprintf(mesg, "%s : signal() failed for signal %d : %d %s",
                        Tcid, sig, errno, sys_errlist[errno]); 
                    T_Resm(TWARN, mesg); 
                 }
              }
           }
       }
    }
}

/*
*****************************************************************
* Function : T_Buf_Handler(int file_contents) - Manages test case
*            output buffered I/O facilities
*****************************************************************
*/

void T_Buf_Handler(int file_contents)
{
    DEBUGLIB(3) { fprintf(stdout, "In T_Buf_Handler() : file_contents = %d\n",
              file_contents); fflush(stdout); }
    if (file_contents) {
       if ((Tst_Buf_Size > BIGBUF) || (strlen(T_MesgBuf)+Tst_Buf_Size) > BIGBUF) {
          DEBUGLIB(1) { fprintf(stdout, "File Content Buffer Overflow : T_MesgBuf = %s\n", T_MesgBuf); fflush(stdout); }
          fprintf(T_out, "%s", T_MesgBuf);
          fwrite(Tst_Buffer, 1, Tst_Buf_Size, T_out);
          fflush(T_out);
          T_MesgBuf[0]=NULL;
       } else {
          strncat(T_MesgBuf, Tst_Buffer, Tst_Buf_Size);
          DEBUGLIB(1) { fprintf(stdout, "Adding to T_MesgBuf : T_MesgBuf = %s\n", T_MesgBuf); fflush(stdout); }
       }
       /*
       **********************************************************
       * Discard memory now that it has been processed.
       * It's size matched the file content size which could
       * be large at times, and coupled with several result files
       * processed concurrently, we could drain memory by
       * needlessly allocating it
       **********************************************************
       */
       free(Tst_Buffer);
       Tst_Buf_Size=0;
    } else if ((strlen(T_MesgBuf)+strlen(T_Temporary)) > BIGBUF) {
       DEBUGLIB(1) { fprintf(stdout, "T_MesgBuf+T_Temporary > BIGBUF : BEFORE T_MesgBuf = %s\n", T_MesgBuf); fflush(stdout); }
       fprintf(T_out, "%s", T_MesgBuf);
       fflush(T_out);
       strcpy(T_MesgBuf, T_Temporary);
       DEBUGLIB(1) { fprintf(stdout, "T_MesgBuf+T_Temporary > BIGBUF : AFTER T_MesgBuf = %s\n", T_MesgBuf); fflush(stdout); }
    } else {
       strcat(T_MesgBuf, T_Temporary);
       DEBUGLIB(1) { fprintf(stdout, "Adding to T_MesgBuf : T_MesgBuf = %s\n", T_MesgBuf); fflush(stdout); }
    }
}

/* 
********************************************************************
* Function : T_Print(char *tcid, int tnum, int ttype, char *tmesg)
*            - print a line or range of lines to output stream
*            T_Mode == VERBOSE, use T_range to expand range of BROKS
*            T_MODE != VERBOSE, use T_range to print range value
********************************************************************
*/

void
T_Print(char *tcid, int tnum, int ttype, char *tmesg)
{
    int range = T_range;   /* local range variable: handles TWARNS */
    char type[5];          /* storage for result type */
    int i;

    DEBUGLIB(3) { fprintf(stdout, "%s : In T_Print() : tnum = %d : ttype = %d : tmesg = %s\n",
                  tcid, tnum, ttype, tmesg); fflush(stdout); }

    /* Insure only one test case is printed for TWARN or TINFO */
    if ((ttype == TWARN) || (ttype == TINFO)) 
       range=1;

    /* Process type string */
    switch (ttype) {
         case TPASS:
                   strcpy(type, "PASS");
                   break;
         case TFAIL:
                   strcpy(type, "FAIL");
                   break;
         case TBROK:
                   strcpy(type, "BROK");
                   break;
         case TRETR:
                   strcpy(type, "RETR");
                   break;
         case TWARN:
                   strcpy(type, "WARN");
                   break;
         case TINFO:
                   strcpy(type, "INFO");
                   break;
         default: 
                   strcpy(type, "????");
                   break;
    }
    /* Now build line and output */
    if (T_mode == VERBOSE) {
       /* Print Range Of Lines */
       for (i=tnum; i < tnum + range; i++) {
           sprintf(T_Temporary, "%-8s%4d  %s  :   %s\n", tcid, i, type, tmesg);
       }
       T_Buf_Handler(0);
       if (Tst_Buffer) 
          T_Buf_Handler(1);
    } else {
       /*
       ****************************************************
       * Condense or NoPass mode : print one condensed line
       * (except for PASS or RETR cases in NOPASS mode!).
       ****************************************************
       */
       if ((T_mode == NOPASS) && ((ttype == TPASS) || (ttype == TRETR)))
          return;
       if (range > 1) {
          sprintf(T_Temporary, "%-8s%4d-%-4d  %s  :  %s\n", tcid, tnum, tnum+range-1, type, tmesg);
          DEBUGLIB(2) { fprintf(stdout, "%s : T_Print() : range > 1 : T_Buf_Handler(0) : T_Temporary = %s\n", tcid, T_Temporary); fflush(stdout); }
          T_Buf_Handler(0);
       } else {
          /* Only one test case here */   
          sprintf(T_Temporary, "%-8s%4d       %s  :  %s\n", tcid, tnum, type, tmesg);
          DEBUGLIB(2) { fprintf(stdout, "%s : T_Print() : range < 1 : T_Buf_Handler(0) : T_Temporary = %s\n", tcid, T_Temporary); fflush(stdout); }
          T_Buf_Handler(0);
       }
    }
}

/*
*******************************************************************
* Function : T_Verbose(char *tcid, int tnum int ttype, char *tmesg)
*            - handle test case messages in verbose mode or print
*            all messages and expand messages if a BROK range is
*            given
*******************************************************************
*/

void
T_Verbose(char *tcid, int tnum, int ttype, char *tmesg)
{
    DEBUGLIB(3) { fprintf(stdout, "%s : In T_Verbose() : tnum = %d : ttype = %d : tmesg = %s\n",
                  tcid, tnum, ttype, tmesg); fflush(stdout); }
    if (tnum < 0) {
       /*
       **********************************************************
       * Set T_range to the absolute value of tnum and set tnum
       * to the current test case number base on Tst_Count.
       * Note : This is why test cases must be received in order.
       **********************************************************
       */
       T_range = -(tnum);
       tnum = Tst_Count + 1;
    } else {
       /* A regular test case - make sure T_range is set to 1 */
       T_range = 1;
    }
    /* update Tst_Count except for WARNS and INFOs */
    if ((ttype != TWARN) && (ttype != TINFO)) {
       /* increment Tst_Count by number of cases being printed */
       Tst_Count += T_range;
    }
    /* Print the line(s) */
    T_Print(tcid, tnum, ttype, tmesg);
}

/*
*********************************************************************
* Function : T_Condense(char *tcid, int tnum int ttype, char *tmesg)
*            - handle test cases in condense or nopass mode. For 
*            condense, save current message and print last message if
*            different than current.  For nopass, skip printing TPASS
*            test case result messages
*********************************************************************
*/

void
T_Condense(char *tcid, int tnum, int ttype, char *tmesg)
{
    DEBUGLIB(3) { fprintf(stdout, "%s : In T_Condense : tnum = %d : ttype = %d : tmesg = %s\n", tcid, tnum, ttype, tmesg); fflush(stdout); }
    /* Handle WARNS and INFOs first: no counter manipulations */
    if ((ttype == TWARN) || (ttype == TINFO)) {
       if (First_time == FALSE) {
          T_Print(Last_tcid, Last_num, Last_type, Last_mesg);
          free(Last_tcid);
          free(Last_mesg);
       }
       /* Save current line info for next time */
       Last_tcid = malloc((unsigned) strlen(tcid)+1);
       strcpy(Last_tcid, tcid);
       Last_num=tnum;
       Last_type=ttype;
       Last_mesg = tmesg;
       T_range = 1;
    } else {
       /*
       *****************************************************************
       * We have a PASS, FAIL, BROK, or RETR test case. Check if message
       * is same as last message - if so, increment T_range, Tst_Count
       * and return
       *****************************************************************
       */
       if ((strcmp(Last_tcid, tcid) == 0) &&
          (Last_type == ttype) &&
          (strcmp(Last_mesg, tmesg) == 0) &&
          Range_warn == FALSE) {
          DEBUGLIB(2) { fprintf(stdout, "In T_Condense : Match With Previous Test Case Result\n"); fflush(stdout); }
          /*
          *************************************************
          * Same Message : increment T_range and Tst_Count.
          * (tnum is ignored unless less than zero)
          *************************************************
          */
          if (tnum < 0) { /* Check for negative tnum - range of BROKS, RETRs */
             /*
             *************************************
             * Add absolute Value of tnum to range 
             *************************************
             */
             T_range += -(tnum);
             Tst_Count += -(tnum);
          } else {
             /* Regular Test Case : increment T_range and Tst_Count */
             T_range++;
             Tst_Count++;
          }
       } else {
          DEBUGLIB(2) { fprintf(stdout, "In T_Condense : No Match To Previous Test Case Result\n"); fflush(stdout); }
          /*
          ****************************************************
          * New message : print last message (if there is one)
          * and save current message for next time
          ****************************************************
          */
          if (First_time == FALSE) {
             DEBUGLIB(2) { fprintf(stdout, "T_Print(%s, %d, %d, %s)\n", Last_tcid, Last_num, Last_type, Last_mesg); fflush(stdout); }
             T_Print(Last_tcid, Last_num, Last_type, Last_mesg);
             free(Last_tcid);
             free(Last_mesg);
          }
          /* Check for negative tnum - range of BROKS, RETRs */
          if (tnum < 0) {
             /*
             ***************************************************
             * Set T_range to absolute value of tnum
             * Set tnum to current test case number or Tst_Count
             ***************************************************
             */
             T_range = -(tnum);
             tnum = Tst_Count + 1;
          } else {
             T_range = 1;
          }
          /* Increment Tst_Count by number of test cases to print */
          Tst_Count += T_range;
          /* Save Current line info for next time */
          Last_tcid = malloc((unsigned) strlen(tcid)+1);
          strcpy(Last_tcid, tcid);
          Last_num=tnum;
          Last_type=ttype;
          /* 
          *****************************************************
          * If test results from file are present, save as well
          *****************************************************
          */
          if (Tst_Buffer) {
             Last_mesg = malloc((strlen(tmesg)+Tst_Buf_Size)+1);
             strcpy(Last_mesg, tmesg);
             strcat(Last_mesg, Tst_Buffer);
             free(Tst_Buffer);
             Tst_Buf_Size=0;
          } else {
             Last_mesg = malloc(strlen(tmesg)+1);
             strcpy(Last_mesg, tmesg);
          }
       }
    }
}

/*
******************************************************************
* Function : T_Checkenv() - checks value of environment variable
*            TOUTPUT and returns appropriate testing mode value
*            Valid environmental values are:
*
*            VERBOSE  - All test case information
*            CONDENSE - Compacted/condensced test case information
*            NOPASS - No test case information
******************************************************************
*/

int
T_Checkenv()
{
   int mode;
   char *value, *getenv();

   if ((value = getenv("TOUTPUT")) == NULL) {
      /* TOUTPUT not defined: default to VERBOSE */
      mode = VERBOSE;
   } else if (strcmp(value, CONDENSE_S) == 0) {
      mode = CONDENSE;
   } else if (strcmp(value, NOPASS_S) == 0) {
      mode = NOPASS;
   } else {
      mode = VERBOSE;
   }
   return(mode);
}

/*
*************************************************************
* Function : T_Environ() - preserve test case output, despite
*            any changes to STDOUT
*************************************************************
*/

int
T_Environ()
{
    FILE *fdopen();
    
    if ((T_out = fdopen(dup(fileno(stdout)), "w")) == NULL)
       return(-1);
    else
       return(0);
}

/*
**********************************************************
* Function : T_Res(int ttype, char *fname, char *tmesg)
*            - Report Test Case Results Via String Message
*            Or Disk File Content
**********************************************************
*/ 

void
T_Res(va_alist)
va_dcl                           /* Parameter declaration for varargs */
{
    /*
    **************************************
    * Declarations of the fixed parameters
    **************************************
    */
    int tnum;                    /* Test Case Number */
    int ttype;                   /* Test Result Type */
    char *tformat;               /* Format String For vsprintf */
    char *fname;                 /* filename address pointer */

    /*
    *************
    * Local needs
    *************
    */
    static char warn_mesg[MAXMESG];
    static char tmesg[USERMESG];     /* Buffer for test result messages */
    int num, fclose();
    FILE *fp;                        /* File Pointer */
    struct stat statbuf;             /* stat(2) usage */

    /*
    **************************************************
    * Get the fixed parameters from the parameter list
    **************************************************
    */

    va_list parameters;
    va_start (parameters);
    ttype = va_arg (parameters, int);
    fname = va_arg (parameters, char *);
    tformat = va_arg (parameters, char *);

    DEBUGLIB(3) { fprintf(stdout, "%s : In T_Res() : ttype = %d : fname = %s : tformat = %s\n",
                  Tcid, ttype, fname, tformat); fflush(stdout); }

    /* 
    **************************
    * Build the message string
    **************************
    */
    if (Do_Translation) {
       vsprintf (tmesg, tformat, parameters);
    } else {
       strcpy(tmesg, tformat);
    }
    if ((ttype == TWARN) || (ttype == TINFO)) {
       tnum=0;
    } else {
       tnum=Tst_Count + 1;
    }
    if (fname) {
       /*
       **********************************************
       * See if the file exists and obtain inode info
       **********************************************
       */
       if (stat(fname,&statbuf)) {
          sprintf(warn_mesg, "T_Res : Unable to stat file %s : %d %s", fname, errno, sys_errlist[errno]);
          T_Print(Tcid, 0, TWARN, warn_mesg);
          return;
       }
       Tst_Buf_Size=statbuf.st_size;
       /*
       ***********************
       * Open file for reading
       ***********************
       */
       if ((fp = fopen(fname, "r")) == NULL) {
          sprintf(warn_mesg, "T_Res : Unable to open file %s", fname);
          T_Print(Tcid, 0, TWARN, warn_mesg);
          return;
       }
       /*
       *************************************
       * Get enough memory for file contents
       *************************************
       */
       if ((Tst_Buffer = (char *) malloc(Tst_Buf_Size)) == NULL) {
          sprintf(warn_mesg, "T_Res : Unable to malloc space");
          T_Print(Tcid, 0, TWARN, warn_mesg);
          return;
       }
       /*
       ***************************************
       * read file contents into buffer memory
       ***************************************
       */
       /*
       ************************************************************
       * Ok crayola; core dumps UnixWare
       * fread(&Tst_Buffer[strlen(Tst_Buffer)],1,Tst_Buf_Size, fp);
       ************************************************************
       */
       fread(Tst_Buffer,1,Tst_Buf_Size, fp);
       if (fclose(fp) == EOF) {
          sprintf(warn_mesg, "T_Res : Unable to close file %s", fname);
          T_Print(Tcid, 0, TWARN, warn_mesg);
          return;
       }
    }
    /*
    **************************************************
    * Save the test result type by ORing ttype into
    * the current exit value which is used by T_Exit()
    **************************************************
    */ 
    T_exval |= ttype; 

    /*
    ******************************************************
    * Unless T_out has already been set by T_Environ, make
    * T_Res output to STDOUT
    ******************************************************
    */
    if (T_out == NULL) {
       T_out = stdout;
    }

    /*
    **********************************************
    * Check TOUTPUT environment variable (if first
    * time) and set T_mode flag
    **********************************************
    */
    if (First_time) {
       T_mode = T_Checkenv();
    }

    /* Clear warning messages */

    warn_mesg[0]='\0';

    /*
    *************************************************
    * If no test cases reported, must be WARN or INFO
    *************************************************
    */ 
    if (tnum == 0) {
       if ((ttype != TWARN) && (ttype != TINFO)) {
          strcpy(warn_mesg, "T_Res : Unexpected test case type. Should be TWARN or TINFO.");
       }
    }
    /*
    ****************************************************
    * A negative tnum is only valid for a range of BROKS
    ****************************************************
    */
    if (tnum < 0) {
       if ((ttype != TWARN) && (ttype != TRETR)) {
          strcpy(warn_mesg, "T_Res : Invalid test case range specifier.");
       }
    }
    /*
    ****************************************************************
    * Set warning flag if this test case is out of order.  A warning
    * will be printed later if a range error is detected
    ****************************************************************
    */
    if ((tnum > 0) && (tnum != Tst_Count+1)) {
       Range_warn=FALSE;
    }
    /*
    ***********************************************************
    * Print warning if user is requesting a range of TBROKS and
    * a range error is present
    ***********************************************************
    */
    if ((tnum < 0) && (Range_warn == TRUE)) {
       strcpy(warn_mesg, "T_Res : Previous test case out of sequence. Ranges may be incorrect.");
    }
    /*
    *******************************************************************
    * Process each test case result display mode and print any warnings
    *******************************************************************
    */
    switch (T_mode) {
         case VERBOSE:
                     if (warn_mesg[0]) {
                        T_Print(Tcid, 0, TWARN, warn_mesg); 
                     }
                     T_Verbose(Tcid, tnum, ttype, tmesg);
                     break;
         case NOPASS:
                     /* use t_condense() - T_Print strips PASS */
         case CONDENSE:
                     if (warn_mesg[0]) {
                        T_Print(Tcid, 0, TWARN, warn_mesg); 
                     }
                     T_Condense(Tcid, tnum, ttype, tmesg);
                     break;
         default:
                     sprintf(warn_mesg, "T_Res : Invalid T_mode %d.", T_mode);
                     T_Print(Tcid, 0, TWARN, warn_mesg); 
                     break;
    }
    First_time=FALSE;
}

/*
**********************************************************
* Function : T_Resm(int ttype, char *tmesg) 
*            - Report Test Case Results Via String Message
**********************************************************
*/

void
T_Resm(va_alist)
va_dcl
{
    /*
    ***********************************
    * Declarations of  fixed parameters
    ***********************************
    */
    int ttype;
    char *tformat, *fname;
    static char tmesg[USERMESG];

    /*
    **************************************************
    * Get the fixed parameters from the parameter list
    **************************************************
    */

    va_list parameters;
    va_start (parameters);
    ttype = va_arg (parameters, int);
    tformat = va_arg (parameters, char *);

    /*
    **********************
    * Build message string
    **********************
    */
    vsprintf(tmesg, tformat, parameters);
    Do_Translation=0;
   
    DEBUGLIB(3) { fprintf(stdout, "%s : In T_Resm() : ttype = %d : : tmesg = %s\n",
                  Tcid, ttype, tmesg); fflush(stdout); }
    /*
    ******************************************
    * Call T_Res with a null filename argument
    ******************************************
    */
    fname= '\0';
    T_Res(ttype, fname, tmesg);
    Do_Translation=1; 
}

/*
*************************************************************************
* Function : T_Breaks(int caller, int ttype, char *fname, void (*fnc) (),
*                     char *tmesg) - Fail or break current test case with
*                     appropriate message(s), and remaining test cases
*                     as approripriate for given caller
*************************************************************************
*/

int
T_Breaks(int caller, int ttype, char *fname, void (*fnc) (), char *tmesg)
{
    char *whosewho;
    char mesg[80];

    DEBUGLIB(3) { fprintf(stdout, "%s : In T_Breaks() : ttype = %d : fname = %s : tmesg = %s\n",
                  Tcid, ttype, fname, tmesg); fflush(stdout); }

    if (caller == T_BRKLOOP) {
       whosewho=T_BRKLOOP_S;
       if (Tst_LpTotal) {
          if (Tst_LpTotal <= 0) {
             T_Res(TWARN, 0, "Tst_LpTotal must be > 0 to use %s routine", whosewho);
             return;
          }
       } else {
          T_Res(TWARN, 0, "Tst_LpTotal must be externally defined to use %s routine", whosewho);
          return;
       }
    } else if (caller == T_BRK) {
       whosewho=T_BRK_S;
    }

    if ((ttype != TFAIL) && (ttype != TBROK)) {
       sprintf(mesg, "%s : Invalid Type : %d. Using TBROK", whosewho, ttype);
       T_Res(TWARN, 0, mesg);
       ttype=TBROK;
    }

    if (caller == T_BRKLOOP) {
       int Tst_Ctr, Tst_Remaining;
  
       T_Res(ttype, fname, tmesg);
       Tst_Remaining = Tst_Count % Tst_LpTotal;
       if (Tst_Remaining < 1)
          Tst_Remaining=Tst_LpTotal;
       
       while (Tst_Remaining < Tst_LpTotal) {
           T_Res(TBROK, 0, "Remaining Test Cases Broken");
           Tst_Remaining++;
       }
    } else if (caller == T_BRK) {
       T_Res(ttype, fname, tmesg);
       while (Tst_Count < Tst_Total) {
          T_Res(TBROK, 0, "Remaining Test Cases Broken");
       }
    }
    if (Tst_Count > Tst_Total) {
       T_Res(TWARN, 0, "Tst_Count %d > Tst_Total %d", Tst_Count, Tst_Total);
    }
    if (fnc == NULL) {
       return;
    } else {
       (*fnc) ();
       if (caller == T_BRK)
          T_Exit();
    }
}

/*
***************************************************************************
* Function : T_Brk(int ttype, char *fname, void (*cleanup) (), char *tmesg)
*            - Report TBROK or TFAIL For Current Test Case Via Message
*            And/Or Disk File Contents. TBROK All Remaining Test Cases.
*            If Cleanup Function Provided, Call It And Exit; Otherwise,
*            Return To Caller
***************************************************************************
*/

void
T_Brk(va_alist)
va_dcl
{
    /*
    **************************************
    * Declarations of the fixed parameters
    **************************************
    */
    int ttype;
    char *tformat, *fname;
    static char tmesg[USERMESG];
    void (*fnc) ();

    /*
    ***************************************************
    * Get the fixed parameters from the parameter list.
    ***************************************************
    */
    va_list parameters;
    va_start (parameters);
    ttype = va_arg (parameters, int);
    fname = va_arg (parameters, char *);

    /****************************************************************
    * This was the way of crayola
    * fnc = ((void (**) ()) (parameters += sizeof(void (*) ())))[-1];
    **********************************************
    * UnixWare sizes for function pointers is same
    * as int, long, float. So, fudge it
    **********************************************
    */
    fnc = (void (*) ()) va_arg (parameters, int);
    tformat = va_arg (parameters, char *);

    if (Do_Translation) {
       vsprintf(tmesg, tformat, parameters);
    } else {
       strcpy(tmesg, tformat);
    } 
    DEBUGLIB(3) { fprintf(stdout, "%s : In T_Brk() : ttype = %d : fname = %s : tmesg = %s\n",
                  Tcid, ttype, fname, tmesg); fflush(stdout); }
    T_Breaks(T_BRK, ttype, fname, fnc, tmesg);
    Do_Translation=1; 
}

/*
**********************************************************************
* Function : T_Brkm(int ttype, void (*cleanup) (), char *tmesg)
*            - Report TBROK or TFAIL For Current Test Case Via Message
*            TBROK All Remaining Test Cases.  If Cleanup Function 
*            Provided, Call It And Exit; Otherwise, Return to Caller
**********************************************************************
*/

void
T_Brkm(va_alist)
va_dcl
{
    /*
    **************************************
    * Declarations of the fixed parameters
    **************************************
    */
    int ttype;
    char *tformat, *fname;
    void (*fnc) ();
    static char tmesg[USERMESG];

    /*
    **************************************************
    * Get the fixed parameters from the parameter list
    **************************************************
    */
    va_list parameters;
    va_start (parameters);
    ttype = va_arg (parameters, int);

    /*******************************************************************
    * This was the way of crayola
    * fnc = ((void (**) ()) (parameters += sizeof(void (*) ())))[-1];
    **********************************************
    * UnixWare sizes for function pointers is same
    * as int, long, float. So, fudge it
    **********************************************
    */
    fnc = (void (*) ()) va_arg (parameters, int);
    tformat = va_arg (parameters, char *);

    /*
    **********************
    * Build message string
    **********************
    */
    vsprintf(tmesg, tformat, parameters);
    Do_Translation=0;
    DEBUGLIB(3) { fprintf(stdout, "%s : In T_Brkm() : ttype = %d : tmesg = %s\n",
                  Tcid, ttype, tmesg); fflush(stdout); }
   
    /*
    ******************************************
    * Call T_Res with a null filename argument
    ******************************************
    */
    fname= '\0';
    T_Brk(ttype, fname, fnc, tmesg);

}

/*
*******************************************************************************
* Function : T_BrkLoop(int ttype, char *fname, void (*cleanup) (), char *tmesg)
*            - Report TBROK or TFAIL For Current Test Case Via Message
*            And/Or Disk File Contents. TBROK All Remaining Test Cases
*            From Tst_Count Value Up To A Tst_LpTotal multiple.  If 
*            Cleanup Function Provided, Call It And Exit; Otherwise,
*            Return To Caller
*******************************************************************************
*/

void
T_BrkLoop(va_alist)
va_dcl
{
    /*
    **************************************
    * Declarations of the fixed parameters
    **************************************
    */
    int ttype;
    char *tformat, *fname;
    static char tmesg[USERMESG];
    void (*fnc) ();

    /*
    **********************************************
    * Get fixed parameters from the parameter list
    **********************************************
    */
    va_list parameters;
    va_start (parameters);

    ttype = va_arg (parameters, int);
    fname = va_arg (parameters, char *);

    /*******************************************************************
    * This was the way of crayola 
    * fnc = ((void (**) ()) (parameters += sizeof(void (*) ())))[-1];
    **********************************************
    * UnixWare sizes for function pointers is same
    * as int, long, float. So, fudge it
    **********************************************
    */
    fnc = (void (*) ()) va_arg (parameters, int);
    tformat = va_arg (parameters, char *);

    /*
    **************************
    * Build the message string
    **************************
    */
    if (Do_Translation) {
       vsprintf(tmesg, tformat, parameters);
    } else {
       strcpy(tmesg, tformat);
    } 
    DEBUGLIB(3) { fprintf(stdout, "%s : In T_BrkLoop() : ttype = %d : fname = %s : tmesg = %s\n",
                Tcid, ttype, fname, tmesg); fflush(stdout); }

    T_Breaks(T_BRKLOOP, ttype, fname, fnc, tmesg);
    Do_Translation=1;
}

/*
************************************************************************
* Function : T_BrkLoopM(int ttype, void (*cleanup) (), char *tmesg)
*            - Report TBROK or TFAIL For Current Test Case Via Message
*            TBROK All Remaining Test Cases From Tst_Count Value Up To
*            A Tst_LpTotal multiple.  If Cleanup Function Provided, Call
*            It And Exit; Otherwise, Return To Caller
************************************************************************
*/

void
T_BrkLoopM(va_alist)
va_dcl
{
    /*
    **************************************
    * Declarations of the fixed parameters
    **************************************
    */
    int ttype;
    char *tformat, *fname;
    static char tmesg[USERMESG];
    void (*fnc) ();

    /*
    **********************************************
    * Get fixed parameters from the parameter list
    **********************************************
    */
    va_list parameters;
    va_start (parameters);

    ttype = va_arg (parameters, int);

    /*******************************************************************
    * This was the way of crayola
    * fnc = ((void (**) ()) (parameters += sizeof(void (*) ())))[-1];
    **********************************************
    * UnixWare sizes for function pointers is same
    * as int, long, float. So, fudge it
    **********************************************
    */
    fnc = (void (*) ()) va_arg (parameters, int);
    tformat = va_arg (parameters, char *);

    /*
    **************************
    * Build the message string
    **************************
    */
    vsprintf(tmesg, tformat, parameters);
    DEBUGLIB(3) { fprintf(stdout, "%s : In T_BrkLoopM() : ttype = %d : tmesg = %s\n",
                Tcid, ttype, tmesg); fflush(stdout); }
    Do_Translation=0;

    fname='\0';
    T_BrkLoop(ttype, fname, fnc, tmesg);

}

/*
****************************************************************
* Function: T_Exit() - Exit With A Meaningful Test Result Value.
*                      TPASS ==  0
*                      TFAIL ==  1
*                      TBROK ==  2
*                      TWARN ==  4
*                      TRETR ==  8
*                      TINFO == 16
****************************************************************
*/

void
T_Exit()
{
    DEBUGLIB(3) { fprintf(stdout, "%s : In T_Exit() :  T_MesgBuf = %s\n",
                  Tcid, T_MesgBuf); fflush(stdout); }

    /* Print out last line if needed */
    if ((T_mode != VERBOSE) && (First_time == FALSE)) 
       T_Print(Last_tcid, Last_num, Last_type, Last_mesg);

    fprintf(T_out, "%s", T_MesgBuf);

    /* Exit (T_exval & ~ (TRETR|TINFO)); */
    exit(T_exval);
}

