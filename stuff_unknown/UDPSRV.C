#include <sys/ioctl.h>
#include <signal.h>
#include  "inet.h"
#include "test_clnt_srv.h"

extern int routine_tfd, Gquit;

/*
*  main(argc, argv)
*  int argc;
*  char **argv;
*  {
*  extern void str_echo();
*  int tfd;
*  
*     progname = argv[0];
*     tfd = init_connection(SERV_TCP_PORT);
*     open_connection(tfd, str_echo);
*  }
*/

/*********************************************************/
/*   OPEN_UDP_SRV

     Routine opens the server side tcp connection and uses it
     in a user provided function.

     PARAMETERS:
        tfd:       transport (socket) file descriptor
        function:  Pointer to a user provided function;
                   The user only has to declare the function
                   like this:  extern func_type func_name();
                   Then pass func_name to this routine like any
                   other variable.  The limitation is that
                   function can not have any parameters passed 
                   to it.  It can be done, but it requires the
                   user to do much more work.
*/

int open_udp_srv(tfd, function)
int tfd;
func_p function;
{
int newtfd, childpid, cli_len;
void time_to_leave();

   routine_tfd = tfd;
   signal(SIGINT, (void *)&time_to_leave);

   for(;;) {
      (*function)(tfd);    /*  user provided function */
      if (Gquit != 0)
         break;
   }
   return(0);
}

