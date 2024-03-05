#include  "inet.h"
#include "test_clnt_srv.h"

extern int errno;
extern char *sys_errlist[];

/*******************************************************/
/*  IS_MY_SRVR_THERE

    Determine if a server exists on another machine

    PARAMETERS:
       hostname:  host which you want to check for a server
       command:   if not NULL, this routine will try and
                  start "command" as a server if it does not
                  find the server running.

    RETURN:
       0 if server found or started.  -1 if not found.

    This routine requires the use of tcp_server_indicator()
    by the server program.

*/
int is_my_srvr_there(hostname, command)
char *hostname, *command;
{
int tfd, mflag, avail_bytes;
int portnum, flags, numread;
void tcp_terminate_clnt();
char buffer[30];
long timeinsec, starttime;

   portnum = TCP_CONTROL_PORT;

   /*****************************************/
   /*  if hostname is NULL, try and use local host
   */

   if (hostname == NULL) {
      fprintf(stderr, "No host name, using local host\n");
      hostname = (char *)malloc(40);
      mflag = 1;
      if (gethostname(hostname, 40) == (-1)) {
         fprintf(stderr, "Could not get local host\n");
         return(-1);
      }
   }

   /*****************************************/

   /*****************************************/
   /*   Establish the connection
   */

   tfd = do_tcp_connection_clnt(hostname, portnum, 15);

   /*****************************************/

   /*****************************************/
   /*   If the connection is made, write a little
        internal message to show that the connections
        are indeed functioning.  ioctl() is used before
        the read() so we don't have to do anything
        weird to wait for the return data.  This way
        we write 28 bytes, wait for the complete 28 bytes
        to come back, and read the 28 bytes with one
        read().
   */

   if (tfd > 0) {
      write(tfd, "SERVER INDICATOR:  called\n", 28);
     wait_for_data(tfd, 28);
      if ((numread = read(tfd, &buffer, 28)) != 28) {
         fprintf(stderr, "    %s\n", sys_errlist[errno]);
         close(tfd);
         tfd = -1;
      }
      tcp_terminate_clnt(tfd);
      tfd = 0;
   }

   /*****************************************/

   /*****************************************/
   /*   Try and start the server if command is not
        NULL and we didn't find it already
   */

   if (tfd == -1) {
      if (command != NULL) {
         start_remote_server(hostname, command);
         tfd = 0;
      }
   }

   /*****************************************/

   if (mflag != 0)
      free(hostname);

   return(tfd);
}

void do_nothing(fd)
int fd;
{
char buffer[30];
int avail_bytes, numwritten;

   wait_for_data(fd, 28, "do_nothing");

   read(fd, &buffer, 28);
   if ((numwritten = write(fd, &buffer, 28)) != 28)
      fprintf(stderr, "WRITE PROBLEM - %d\n", numwritten);
   close(fd);
   return;
}

/**********************************************************/
/*  TCP_SERVER_INDICATOR

    Routine to run in the background and act as a signaler to
    client programs to indicate that a return server is
    running already.
*/
void tcp_server_indicator()
{
int tfd, childpid;
extern void do_nothing();

   if ((childpid = fork()) < 0) {
      fprintf(stderr, "Could not start server indicator process\n");
   }
   else if (childpid == 0) {
      tfd = tcp_init_connection_srv(TCP_CONTROL_PORT);
      tcp_open_connection_srv(tfd, do_nothing);
      exit(0);
   }
   return;
}

/*****************************************************/
/*  START_REMORTE_SERVER

    Just what the name implies.
    Very crude with lots of room for improvement.

    PARAMETERS:
       hostname:      Name of host to start server on.
       command_line:  Command line of server to start.

    RETURN:
       0 if it thinks it succeeded, -1 if it thinks it failed.

*/
int start_remote_server(hostname, command_line)
char *hostname, *command_line;
{
int mflag;
char rshline[256];

   mflag = 0;

   if (command_line == NULL) {
      fprintf(stderr, "No remote server name supplied\n");
      return(-1);
   }

   if (hostname == NULL) {
      fprintf(stderr, "No host name, using local host\n");
      hostname = (char *)malloc(40);
      mflag = 1;
      if (gethostname(hostname, 40) == (-1)) {
         fprintf(stderr, "Could not get local host\n");
         return(-1);
      }
   }

   sprintf(rshline, "rsh %s %s &\0", hostname, command_line);
   system(rshline);

   if (mflag != 0)
      free(hostname);

   return(0);
}
