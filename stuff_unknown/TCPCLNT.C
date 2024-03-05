#include <ctype.h>
#include <time.h>
#include <netdb.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <net/if.h>
#include <sys/ioctl.h>

#include "test_clnt_srv.h"
#include "inet.h"

extern int errno;
extern char *sys_errlist[];
extern word diag_total_run_time_memory;

int routine_tfd;
extern int Gquit;

void leave_client()
{

   fprintf(stderr, "Your client:  Error or SIGINT received, exiting\n");
   Gquit = 1;
   return;
}

/**********************************************************/
/*   TCP_CONNECTION_CLNT

     Establish a connection between a client and a server.

     PARAMETERS:
        hostname:    host to connect to.
        portnum:     port to open connection on
                     defaults to SERV_TCP_PORT if 0

     RETURN:
        socket descriptor if successful.
        -1 if not successful.
*/
int connection_clnt(hostname, portnum, family, type)
char *hostname;
int portnum;
{
int tfd, mflag = 0;

#ifdef DEBUG
fprintf(stderr, "CONNECTION_CLNT ...");
#endif

   if (portnum == 0)
      portnum = SERV_TCP_PORT;

   if (hostname == NULL) {
      fprintf(stderr, "No host name, using local host\n");
      hostname = (char *)malloc(40);
      mflag = 1;
      if (gethostname(hostname, 40) == (-1)) {
         fprintf(stderr, "Could not get local host\n");
         return(-1);
      }
   }
   tfd = do_connection_clnt(hostname, portnum, family, type, TIMEOUT);

   if (mflag != 0)
      free(hostname);

#ifdef DEBUG
fprintf(stderr, "DONE\n");
#endif

   return(tfd);
}

/*******************************************************/
/*  DO_TCP_CONNECTION_CLNT

    Routine establishes a TCP connection for a client program

    PARAMETERS:
       serverloc:   host name for machine client is to talk to
       portnum:     the port number to talk through
       timeout:     How long to try and connect before giving up
                    timeout is given in seconds

    RETURN:
       return the transport file descriptor of the connection
       if it fails, it returns -1.
*/

int do_connection_clnt(serverloc, portnum, family, type, timeout)
char *serverloc;
int portnum, family, type, timeout;
{
int tfd, error;
extern struct sockaddr_in g_serv_addr, g_cli_addr;
long timeinsec, starttime;

#ifdef DEBUG
fprintf(stderr, "DO_CONNECTION_CLNT ...");
#endif

   tfd = error = 0;

   if (portnum == 0)
      return(-1);

   if (serverloc == NULL)
      return(-1);

   starttime = time((long *)0);
   do {
      if (tfd != 0) {
         close(tfd);
      }

      init_sockaddr(&g_serv_addr, serverloc, portnum, family, NULL);

      if ((tfd = socket(family, type, 0)) < 0) {
         fprintf(stderr, "client: cant't open %s", DEV_TCP);
         return(-1);
      }

      if (type == SOCK_DGRAM) {                           /*   UDP protocol  */
         init_sockaddr(&g_cli_addr, NULL, 0, family, NULL);

         if (bind(tfd, (struct sockaddr *)&g_cli_addr, sizeof(g_cli_addr)) < 0) {
            err_dump("client: can't bind local address");
            return(-1);
         }
      }
      else {

         if (error != 0)
            sleep(2);

         timeinsec = time((word *)0);
         if ((timeinsec - starttime) > timeout)
            break;
   
         error = connect(tfd, (struct sockaddr *)&g_serv_addr, sizeof(g_serv_addr));
         if (error < 0)
            fprintf(stderr, "Client connect failed\n");
      }

   } while (error < 0 );

   if (error < 0) {
       fprintf(stderr, "client: can't connect to server -- %d\n", tfd);
       fprintf(stderr, "%s\n", sys_errlist[errno]);
       return(-1);
   }

   routine_tfd = tfd;
   signal(SIGINT, (void *)&leave_client);

#ifdef DEBUG
fprintf(stderr, "DONE\n");
#endif

   return(tfd);
}

/*****************************************************/
/*  TCP_TERMINATE_CLNT

    Routine closes a client connection

    PARAMETERS:
       tfd:   transport (socket) file descriptor

    RETURN:
       nothing
*/

void terminate_clnt(tfd)
int tfd;
{

   close(tfd);
}
