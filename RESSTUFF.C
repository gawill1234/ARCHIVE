#include <stdio.h>

#include "struct.h"

extern char *resultdir;
extern int ignoretestpass, ignorecasepass;
int T_count = NON_VAL;
int Count_cases = NON_VAL;
int All_pass = NON_VAL;
int Num_cases = NON_VAL;

void TLog();

/**************************************************/
/*
   Log a passing result with a message in the result file
*/
void TPass(testname, message)
char *testname, *message;
{

   (void)TLog(testname, "P", message);

}
/**************************************************/
/*
   Log a failing result with a message in the result file
*/
void TFail(testname, message)
char *testname, *message;
{

   (void)TLog(testname, "F", message);

}
/**************************************************/
/*
   Log a failing result or a passing result in the result file.
   The result may or may not have a message associated with it.
   These test results are issued by the tests.
   Logging the result should be the last thing done because this
   routine causes the test to exit.
*/
void TLog(testname, result, message)
char *testname, *result, *message;
{
FILE *fp, *openfile();

   if (resultdir == NULL)
      testloginit();

   if (ignoretestpass == NON_VAL) {
      fp = openfile(resultdir, "a+");
      if (fp != NULL) {
         if (message != NULL)
            fprintf(fp, "TEST:%s:%s:%s\n", testname, result, message);
         else
            fprintf(fp, "TEST:%s:%s\n", testname, result);
         fclose(fp);
      }
   }
   if (result[0] == 'P')
      exit(NON_VAL);
   else
      exit(NEG_VAL);
}

/**************************************************/
/*
   Log a failing result or a passing result in the result file.
   The result may or may not have a message associated with it.
   These test results are issued by the test driver.
*/
void DLog(testname, result, message)
char *testname, *result, *message;
{
FILE *fp, *openfile();

   if (resultdir == NULL)
      testloginit();

   if (ignoretestpass == NON_VAL) {
      fp = openfile(resultdir, "a+");
      if (fp != NULL) {
         if (message != NULL)
            fprintf(fp, "TEST:%s:%s:%s\n", testname, result, message);
         else
            fprintf(fp, "TEST:%s:%s\n", testname, result);
         fclose(fp);
      }
   }
}

/**************************************************/
/*
    Log a passing result for an individual test case
    in the results file.
*/
int CPass(testname, casename, message)
char *testname, *casename, *message;
{

   return(CLog(testname, casename, "P", message));

}
/**************************************************/
/*
    Log a failing result for an individual test case
    in the results file.
*/
int CFail(testname, casename, message)
char *testname, *casename, *message;
{

   return(CLog(testname, casename, "F", message));

}
/*
void
set_usig(fork_flag, handler, cleanup)
int fork_flag; 
int (*handler)();
void (*cleanup)(); 
{
   return;
}
*/

void t_exit()
{
   exit(NON_VAL);
}
int t_result(testname, casename, result, message)
char *testname, *message;
int casename, result;
{
char casestring[MAX_STR_SIZE];
FILE *fp, *openfile();
int retval = NON_VAL;

   if (Count_cases == NON_VAL) {
      if (fileexist2("numcase_pipe") == NON_VAL) {
         fp = openfile("numcase_pipe", "r+");
         if (fp != NULL) {
            fscanf(fp,"%d", &Num_cases);
            fclose(fp);
            unlink("numcase_pipe");
         }
      }
   }

   sprintf(casestring,"%d\0", casename);

   if (result == NON_VAL)
      retval = CLog(testname, casestring, "P", message);
   else
      retval = CLog(testname, casestring, "F", message);

   Count_cases++;

   if (retval != NON_VAL)
      All_pass = retval;

   if ((Num_cases > NON_VAL) && (Count_cases >= Num_cases))
      exit(All_pass);

   return(retval);
}
/**************************************************/
/*
    Log a passing or failing result for an individual test case
    in the results file.  There may or may not be a message.
    Once the message is logged, whoever called this routine
    will continue to process remaining cases.
*/
int CLog(testname, casename, result, message)
char *testname, *casename, *result, *message;
{
FILE *fp, *openfile();


   if (resultdir == NULL)
      testloginit();

   if (ignorecasepass == NON_VAL) {
      fp = openfile(resultdir, "a+");
      if (fp != NULL) {
         if (message != NULL) 
            fprintf(fp, "CASE:%s:%s:%s:%s\n",
                    testname, casename, result, message);
         else
            fprintf(fp, "CASE:%s:%s:%s\n",
                    testname, casename, result);
         fflush(fp);
         fclose(fp);
      }
   }
   if (result[0] == 'P')
      return(NON_VAL);
   else 
      return(NEG_VAL);
}
/**************************************************/
/*
   If the logging routine has been called by the test it will
   have no idea where the results file is.  This routine
   initializes the resultdir string so results can be logged
   by the test rather than the test driver.
*/
int testloginit()
{
int curdirlen;
char *getcwd(), syspath[MAX_STR_SIZE], *_dirname();
struct path_list *cr_path_node();
char *curdir;

   curdir = getcwd((char *)NULL, ONE_SCR_LINE);
   curdir = _dirname(curdir);
   curdir = _dirname(curdir);
   curdirlen = strlen(curdir);

   resultdir = (char *)malloc(curdirlen + 14);
   strcpy(resultdir, curdir);
   strcat(resultdir, "/test_results\0");

   if (fileexist2(resultdir) != NON_VAL) {
      free(curdir);
      free(resultdir);
      curdir = getcwd((char *)NULL, ONE_SCR_LINE);
      curdirlen = strlen(curdir);

      resultdir = (char *)malloc(curdirlen + 14);
      strcpy(resultdir, curdir);
      strcat(resultdir, "/test_results\0");
   }
}

