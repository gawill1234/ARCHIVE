#include <sys/ioctl.h>
#include <sys/wait.h>
#include <signal.h>
#include  "inet.h"
#include "test_clnt_srv.h"


extern int routine_tfd, Gquit;

char *foreign_name = NULL;
int foreign_port = 0;

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

void time_to_leave()
{
extern int Gquit;

   fprintf(stderr, "General server:  Error or SIGINT received, exiting\n");
   Gquit = 1;
   return;
}

int get_the_port(strng)
char *strng;
{
register int i;

   i = strlen(strng);
   for (i--; i>= 0; i--)
       if (strng[i] == '.')
          break;
   strng[i] = '\0';
   i++;

   return(atoi(&strng[i]));
}

void check_foreign_restrict(fd, family)
int fd, family;
{
struct sockaddr_in cfr_cli_addr;
int count;

   if (foreign_name != NULL) {

      count = countchars(foreign_name, '.');

      switch (count) {

         case 0:
                   foreign_port = SERV_TCP_PORT;
                   break;

         case 1:
         case 2:
                   foreign_port = get_the_port(foreign_name);
                   break;

         case 3:
                   foreign_port = SERV_TCP_PORT;
                   break;

         case 4:
                   foreign_port = get_the_port(foreign_name);
                   break;

         default:
                   return;
      }

      fprintf(stderr, "%s       %d\n", foreign_name, foreign_port);
         

      if (foreign_port == 0)
         foreign_port = SERV_TCP_PORT;

      init_sockaddr(&cfr_cli_addr, foreign_name, foreign_port, family, NULL);

      if (connect(fd, (struct sockaddr *) &cfr_cli_addr, sizeof(cfr_cli_addr)) < 0)
         fprintf(stderr, "check_foreign_restrict():  connect() failed\n");
   }

   return;

}

/****************************************************/
/*  TCP_INIT_CONNECTION_SRV

    This routine initializes a tcp connect on a port.

     PARAMETERS:
        portnum:  a port number, if 0 it defaults to 6543

     RETURN:
        returns a transport (socket) file descriptor.
        if it fails, it returns -1.
*/

int init_connection_srv(portnum, family, type, hostname)
int  portnum, family, type;
char *hostname;
{
extern int protocol;
int tfd;
struct sockaddr_in ics_serv_addr;

   if (portnum == 0)
      portnum = SERV_TCP_PORT;

   /****************************************/
   /*  open connection
   */
   if ((tfd = socket(family, type, 0)) < 0) {
      fprintf(stderr, "Could not create socket\n");
      return(-1);
   }

   /****************************************/
   /*  Initialize relevant structures (serv_addr and req)
   */
   init_sockaddr(&ics_serv_addr, hostname, portnum, family, NULL);

   /****************************************/
   /*  bind connection
   */
   if (bind(tfd, (struct sockaddr *)&ics_serv_addr, sizeof(ics_serv_addr)) < 0) {
      err_dump("server: can't bind local address");
      return(-1);
   }

   if (protocol == UDP)
      check_foreign_restrict(tfd, family);

   return(tfd);
}


/*********************************************************/
/*   TCP_OPEN_CONNECTION

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

int open_tcp_srv(tfd, function)
int tfd;
func_p function;
{
int newtfd, childpid, cli_len;
struct sockaddr_in ots_cli_addr;


   if (listen(tfd, 5) < 0)
      err_dump("server: listen error");

   routine_tfd = tfd;
   signal(SIGINT, (void *)&time_to_leave);

   for(;;) {

      cli_len = sizeof(ots_cli_addr);
      if ((newtfd = accept(tfd, (struct sockaddr *)&ots_cli_addr, &cli_len)) < 0)
        err_dump("server: accept error");

      if ((childpid = fork()) < 0) {
         err_dump("server: fork error");
      }
      else if (childpid == 0) {
         routine_tfd = newtfd;
         close(tfd);
         (*function)(newtfd);    /*  user provided function */
         fprintf(stderr, "Supplied function complete, exiting\n");
         exit(Gquit);
      }
      close(newtfd);
      if (Gquit != 0)
         break;
   }
   return(0);
}

int open_tcp_srv_noncon(tfd, function)
int tfd;
func_p function;
{
int newtfd, childpid, cli_len;
struct sockaddr_in ots_cli_addr;

   signal(SIGINT, (void *)&time_to_leave);

   if (listen(tfd, 5) < 0)
      err_dump("server: listen error");

   routine_tfd = tfd;

   cli_len = sizeof(ots_cli_addr);

   if ((newtfd = accept(tfd, (struct sockaddr *)&ots_cli_addr, &cli_len)) < 0)
      err_dump("server: accept error");
   routine_tfd = newtfd;

   for(;;) {
      (*function)(newtfd);    /*  user provided function */
      if (Gquit != 0)
         break;
   }
   close(newtfd);
   return(0);
}


