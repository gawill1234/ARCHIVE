#include "test.h"
#include "test_macros.h"
#include "inet.h"
#include "test_clnt_srv.h"

#include "tcl.h"

extern int TCL_vrbs, TCL_dataflow, TCL_datatype, timing, TCL_portnum, TCL_sendbytes, TCL_trans;

int udpMcastSnd(ClientData clientData, Tcl_Interp *interp,
                int argc, char *argv[])
{
extern int doit();
char *dev_interface, *hostname;
int tfd, portnum, local_prot, ttl, new_size;
word datatype, dataflow;
extern int verbose, Gsend_bytes;

   if (argc != 5) {
       Tcl_SetResult(interp, "Usage: udp_mcast_snd mcast_addr dev_interface ttl port", TCL_STATIC);
       return TCL_ERROR;
   }

   if (TCL_portnum > 0)
      portnum = TCL_portnum;

   if (TCL_sendbytes > 0)
      Gsend_bytes = TCL_sendbytes;
 
   ttl = 1;
   tfd = portnum = new_size = 0;
   hostname = dev_interface = NULL;

   datatype = TCL_datatype;
   dataflow = TCL_dataflow;

   local_prot = UDP;
   hostname = argv[1];
   dev_interface = argv[2];
   ttl = atoi(argv[3]);
   portnum = atoi(argv[4]);

   set_protocol(local_prot);
   set_client();

   tfd = create_connection_clnt(hostname, portnum);
   
   if (tfd > 0) {
      set_mcast_ttl(tfd, ttl);
      if (TCL_vrbs) {
         print_verbose(tfd);
      }
      if (new_size > 0)
         new_data_size(tfd, new_size);
      if (timing)
         t_sync_time(tfd);
      doit(tfd, datatype, dataflow, TCL_trans);
      terminate_connection(tfd);
   }
   return TCL_OK;
}

int udpMcastRcv(ClientData clientData, Tcl_Interp *interp,
                int argc, char *argv[])
{
char *dev_interface, *host;
int tfd, local_prot, ttl, portnum;
extern int run_server();
extern void server_loop();

   ttl = 1;
   tfd = portnum = 0;
   dev_interface = host = NULL;

   if (TCL_portnum > 0)
      portnum = TCL_portnum;

   if (argc != 5) {
       Tcl_SetResult(interp, "Usage: udp_mcast_rcv mcast_addr dev_interface ttl port", TCL_STATIC);
       return TCL_ERROR;
   }

   local_prot = UDP;
   host = argv[1];      /*  also known as optarg  */
   dev_interface = argv[2];
   ttl = atoi(argv[3]);
   portnum = atoi(argv[4]);

   set_protocol(local_prot);
   set_server();

   tfd = create_connection_srv(NULL, portnum);
   tfd = open_mcast(&tfd, host, dev_interface, ttl, portnum);

   run_server(tfd, server_loop);
   terminate_connection(tfd);

   return TCL_OK;
}

int udpRcv(ClientData clientData, Tcl_Interp *interp,
                int argc, char *argv[])
{
char *dev_interface, *host;
int tfd, local_prot, ttl, portnum;
extern int run_server();
extern void server_loop();

   tfd = portnum = 0;
   host = NULL;

   if (TCL_portnum > 0)
      portnum = TCL_portnum;

   switch (argc) {
      case 3:
               portnum = atoi(argv[2]);
      case 2:
               host = argv[1];
               break;
      case 1:
               break;
      default:
               Tcl_SetResult(interp,
                   "Usage: udp_rcv [host] [port]", TCL_STATIC);
               return TCL_ERROR;
               break;
   }

   local_prot = UDP;

   set_protocol(local_prot);
   set_server();

   tfd = create_connection_srv(host, portnum);

   run_server(tfd, server_loop);
   terminate_connection(tfd);

   return TCL_OK;
}

int udpSnd(ClientData clientData, Tcl_Interp *interp,
                int argc, char *argv[])
{
char *dev_interface, *host;
int tfd, local_prot, ttl, portnum, new_size, datatype, dataflow;
extern int TCL_vrbs, doit(), Gsend_bytes;

   new_size = tfd = portnum = 0;
   host = NULL;

   if (TCL_portnum > 0)
      portnum = TCL_portnum;

   if (TCL_sendbytes > 0)
      Gsend_bytes = TCL_sendbytes;

   datatype = TCL_datatype;
   dataflow = TCL_dataflow;

   switch (argc) {
      case 3:
               portnum = atoi(argv[2]);
      case 2:
               host = argv[1];
               break;
      default:
               Tcl_SetResult(interp,
                   "Usage: udp_snd host [port]", TCL_STATIC);
               return TCL_ERROR;
               break;
   }

   local_prot = UDP;

   set_protocol(local_prot);
   set_client();

   tfd = create_connection_clnt(host, portnum);

   if (tfd > 0) {
      if (TCL_vrbs)
         print_verbose(tfd);
      if (new_size > 0)
         new_data_size(tfd, new_size);
      if (timing)
         t_sync_time(tfd);
      doit(tfd, datatype, dataflow, TCL_trans);
      terminate_connection(tfd);
   }

   return TCL_OK;
}

