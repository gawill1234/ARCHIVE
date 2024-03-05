#include <stdio.h>
#include <varargs.h>
#include <unistd.h>
/*
#include <varargs.h>
*/
#include <errno.h>
#include <sys/errno.h>
#include "test.h"

int global_result = PASS;
int num_cases = 0;

extern char *progname;
extern char *prog_unknown;

extern char *sys_errlist[];

void test_exit()
{

   if (progname == NULL)
      progname = prog_unknown;

   if (global_result != PASS) {
      printf("%s:  Test Failed\n", progname);
      exit(global_result);
   }
   else {
      printf("%s:  Test Passed\n", progname);
      exit(0);
   }
}

void test_result(case_id, result, mesg)
int  case_id, result;
char *mesg;
{
char res_buffer[2][256], case_test[15];
char unknown[8];
int call_exit = NO, print_error = NO;

   /*  Done for stupid compilers that don't allow
       aggregate initialization                    */
   sprintf(unknown, "unknown\0");

   num_cases++;
   if (progname == NULL)
      progname = unknown;

   if (case_id > 0) {
      sprintf(case_test, "Case %d\0", case_id);
   }
   else {
      sprintf(case_test, "Test\0");
      call_exit = YES;
   }

   switch (result) {
      case PASS:
                 sprintf(res_buffer[0], "%s:  %s Pass:  %s\n\0",
                    progname, case_test, mesg);
                 break;
      case BROK:
                 global_result = FAIL;
                 sprintf(res_buffer[0], "%s:  %s Broken:  %s\n\0",
                    progname, case_test, mesg);
                 break;
      case WARN:
                 sprintf(res_buffer[0], "%s:  %s Warning:  %s\n\0",
                    progname, case_test, mesg);
                 break;
      case INFO:
                 sprintf(res_buffer[0], "%s:  %s Info:  %s\n\0",
                    progname, case_test, mesg);
                 break;
      case FAIL:
      default:
                 global_result = FAIL;
                 sprintf(res_buffer[0], "%s:  %s Fail:  %s\n\0",
                    progname, case_test, mesg);
                 if (result != FAIL) {
                    sprintf(res_buffer[1], "%s:     %s\n\0",
                            progname,  sys_errlist[result]);
                    print_error = YES;
                 }
                 break;
   }

   if (call_exit == YES) {
      test_exit();
   }
   else {
      printf("%s", res_buffer[0]);
      if (print_error == YES)
         printf("%s", res_buffer[1]);
      fflush(stdout);
   }

   return;
}

void t_result(va_alist)
va_dcl
{
char msgstr[256];
int res;
char *fmt;
va_list args;

   va_start(args);
   res = va_arg(args, int);
   fmt = va_arg(args, char *);
   vsprintf(msgstr, fmt, args);
   va_end(args);
   test_result(num_cases, res, msgstr);
}
/***********************************************/
/*   Driver to test test_result() routine.
*/
/*
main(argc, argv)
int argc;
char **argv;
{
extern int errno;

   progname = argv[0];

   test_result(1, 19, "it failed");
   test_result(2, PASS, "it passed");
   test_result(0, PASS, "what?");
}
*/
