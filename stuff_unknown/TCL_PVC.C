#include "test.h"
#include "test_macros.h"
#include "inet.h"
#include "test_clnt_srv.h"

#include "tcl.h"

extern int timing;

extern int TCL_vrbs, TCL_dataflow, TCL_datatype, TCL_sendbytes, TCL_trans;

/*****************************************************************************/

int pvcMcastRcv(ClientData clientData, Tcl_Interp *interp,
                int argc, char *argv[])
{
char *dev_interface, *hostname;
int tfd, local_prot, portnum, new_size;
extern int Gvpi, Gvci, Gaal, Gqos_sel;
extern void server_loop();


   if (argc < 2) {
       Tcl_SetResult(interp, "Usage: pvc_mcast_rcv device [vpi[vci[aal[qos]]]]", TCL_STATIC);
       return TCL_ERROR;
   }

   portnum = tfd = new_size = 0;

   local_prot = PVC;
   hostname = argv[1];
   dev_interface = hostname;

   switch (argc) {
      case 6:
               Gqos_sel = atoi(argv[5]);
      case 5:
               Gaal = atoi(argv[4]);
      case 4:
               portnum = Gvci = atoi(argv[3]);
      case 3:
               Gvpi = atoi(argv[2]);
               break;
      default:
               break;
   }

   set_protocol(local_prot);
   set_server();

   tfd = create_connection_srv(hostname, portnum);

   if (new_size > 0)
      new_data_size(tfd, new_size);

   if (tfd < 0)
      exit(-1);

   run_server(tfd, server_loop);
   terminate_connection(tfd);

   return TCL_OK;
}
int pvcMcastSnd(ClientData clientData, Tcl_Interp *interp,
                int argc, char *argv[])
{
char *dev_interface, *hostname;
int tfd, local_prot, portnum, new_size, dataflow, datatype;
extern int verbose, Gvpi, Gvci, Gaal, Gqos_sel, Gsend_bytes;

   if (argc < 2) {
       Tcl_SetResult(interp, "Usage: pvc_mcast_snd device [vpi[vci[aal[qos]]]]", TCL_STATIC);
       return TCL_ERROR;
   }

   if (TCL_sendbytes > 0)
      Gsend_bytes = TCL_sendbytes;

   portnum = tfd = new_size = 0;

   local_prot = PVC;
   hostname = argv[1];
   dev_interface = hostname;

   switch (argc) {
      case 6:
               Gqos_sel = atoi(argv[5]);
      case 5:
               Gaal = atoi(argv[4]);
      case 4:
               portnum = Gvci = atoi(argv[3]);
      case 3:
               Gvpi = atoi(argv[2]);
               break;
      default:
               break;
   }

   dataflow = TCL_dataflow;
   datatype = TCL_datatype;

   set_protocol(local_prot);
   set_client();

   tfd = create_connection_clnt(hostname, portnum);

   if (tfd > 0) {
      if (TCL_vrbs)
         print_verbose(tfd);
      if (new_size > 0)
         new_data_size(tfd, new_size);
      if (timing)
         t_sync_time(tfd);
      doit(tfd, datatype, dataflow, TCL_trans);
      terminate_clnt(tfd);
   }

   return TCL_OK;
}
