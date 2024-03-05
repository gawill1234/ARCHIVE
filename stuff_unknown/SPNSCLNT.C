#include <ctype.h>
#include <time.h>
#include <netdb.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <net/if.h>
#include <sys/ioctl.h>

#if defined(__SPANS)
#include <fore/types.h>
#include <fore_atm/fore_msg.h>
#include <fore_atm/fore_atm_user.h>

#include "test_clnt_srv.h"
#include "inet.h"
#include "test_struct.h"

extern int errno;
extern char *sys_errlist[];
extern word diag_total_run_time_memory;

int routine_tfd;
extern void leave_client();

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
int spns_connection_clnt(hostname, portnum, family, type)
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

int spans_conn_clnt_pvc(device_name, vpi, vci, aal, qos_req)
char *device_name;
int vpi, vci, qos_req;
Aal_type aal;
{
int fd, error;
long timeinsec, starttime;
Atm_conn_resource qos;
Atm_info info;
extern int Gmtu;
extern Vpvc Grvpvc;

   Grvpvc = MKVPVC(vpi, vci);

   qos.peak_bandwidth = qos_req;
   qos.mean_bandwidth = 0;
   qos.mean_burst = 2;

   if (aal < 0)
      aal = aal_type_5;

   if ((fd = atm_open(device_name, O_RDWR, &info)) < 0) {
     atm_error("spans_conn_clnt_pvc():  atm_open()");
     exit(1);
   }

   Gmtu = info.mtu;

   if (atm_connect_pvc(fd, Grvpvc, aal, &qos) < 0) {
      atm_error("spans_conn_clnt_pvc():  atm_connect_pvc()");
      Grvpvc = 0;
      exit(1);
   }

   return(fd);
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

int spans_conn_clnt_svc(device_name, sap, aal, qos_req)
char *device_name;
int sap, qos_req;
Aal_type aal;
{
int tfd, error, i;
int qlen, connected;
long timeinsec, starttime;
Atm_qos qos;
Atm_sap ssap;
Atm_qos_sel qos_selected;
Atm_dataflow dataflow = duplex;
Atm_endpoint endp_addr;
Atm_info info;

struct multicast_endpoint *mep;

extern char *hostlist[25];
extern int hostc, Gmtu;

#ifdef DEBUG
fprintf(stderr, "DO_CONNECTION_CLNT ...");
#endif

   if (hostc > 1)
      dataflow = multicast;

   ssap = connected = tfd = error = qlen = 0;

   if (aal < 0)
      aal = aal_type_5;

   if (sap < 0)
      sap = 0;

   /*
    * Request some quality of service.
    */
   qos.peak_bandwidth.target  = qos_req; /* kilo-bits */
   qos.peak_bandwidth.minimum = 0;       /* kilo-bits */
   qos.mean_bandwidth.target  = 0;       /* kilo-bits */
   qos.mean_bandwidth.minimum = 0;       /* kilo-bits */
   qos.mean_burst.target      = 0;       /* 2k packet length */
   qos.mean_burst.minimum     = 0;       /* 1k packet length */

   mep = (struct multicast_endpoint *)malloc(sizeof(struct multicast_endpoint) * hostc);

   if ((tfd = atm_open(device_name, O_RDWR, &info)) < 0) {
      atm_error("spans_conn_clnt_svc():  atm_open()");
      return(-1);
   }

   Gmtu = info.mtu;

   if (atm_bind(tfd, ssap, &ssap, qlen) < 0) {
      atm_error("spans_conn_clnt_svc():  atm_bind()");
      return(-1);
   }
   
   for (i = 0; i < hostc; i++) {
      /*
       *  Set up endpoint structures, for any number of end points.
       *  and connect, since it seems it has to be done this way for
       *  whatever absurd reason ...
       */
      mep[i].ep_addr.asap = sap + i;
      mep[i].ep_addr.nsap.addr[0] = 0;
      mep[i].ep_name = hostlist[i];
      if (atm_gethostbyname(mep[i].ep_name, &mep[i].ep_addr.nsap) < 0) {
         fprintf(stderr, "spans_conn_clnt_svc():  atm_gethostbyname() failed,  %s\n", hostlist[i]);
         fprintf(stderr, "spans_conn_clnt_svc():      continuing with remaining hosts ... \n");
      }
      else {
         fprintf(stderr, "CONNECT:  %s\n", mep[i].ep_name);
         error = atm_connect(tfd, &(mep[i].ep_addr), &qos, &qos_selected, aal, dataflow);
         if (error < 0)
            atm_error("spans_conn_clnt_svc():  atm_connect()");
         else
            connected++;
      }
   }

   if (connected <= 0) {
      fprintf(stderr, "spans_conn_clnt_svc(): can't connect to any server\n");
      return(-1);
   }

   if (error < 0) {
       fprintf(stderr, "spans_conn_clnt_svc(): can't connect to server -- %d\n", tfd);
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

void spans_terminate_clnt(tfd)
int tfd;
{

   atm_close(tfd);
}
#else
void spans_conn_clnt_pvc()
{
   return;
}
void spans_conn_clnt_svc()
{
   return;
}
#endif
