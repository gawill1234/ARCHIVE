#include <signal.h>
#include "test.h"

void def_handler()
{
   if (progname == NULL)
      progname = prog_unknown;

   fprintf(stderr, "%s - Unexpected signal received\n", progname);
   return;
}

void test_sig(frk_exp, handler, handler2)
int frk_exp;
func_p handler, handler2;
{
int i;

#ifdef AIX
   for (i = 1; i <= SIGMAX; i++) {
#else
   for (i = 1; i <= (NSIG - 1); i++) {
#endif
      switch (i) {
         case SIGCONT:
                           break;
         case SIGUSR1:
                           break;
         case SIGUSR2:
                           break;
         case SIGCHLD:
                           if (frk_exp == FORK)
                              break;
         default:
                           signal(i, handler);
                           break;
      }
   }
}
