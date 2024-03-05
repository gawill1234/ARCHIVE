#include "tcl.h"

#ifndef _WINDOWS
extern int main();
int *tclDummyMainPtr = (int *) main;
#endif /* _WINDOWS */

/*****************************************************************************/

int Tcl_AppInit(Tcl_Interp *interp)
{
extern int GWConfig(), GenCrc32(), udpSnd(), udpRcv(), udpMcastSnd();
extern int udpMcastRcv(), svcMcastSnd(), svcMcastRcv(), pvcMcastSnd();
extern int pvcMcastRcv(), tcpSnd(), tcpRcv();

   if (Tcl_Init(interp) == TCL_ERROR) {
      return(TCL_ERROR);
   }
   Tcl_CreateCommand(interp, "tcp_rcv", tcpRcv,
                   (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp, "tcp_snd", tcpSnd,
                   (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp, "gaw_config", GWConfig,
                   (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp, "crc32", GenCrc32,
                   (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp, "udp_snd", udpSnd,
                   (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp, "udp_rcv", udpRcv,
                   (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp, "udp_mcast_snd", udpMcastSnd,
                   (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp, "udp_mcast_rcv", udpMcastRcv,
                   (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp, "svc_mcast_snd", svcMcastSnd,
                   (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp, "svc_mcast_rcv", svcMcastRcv,
                   (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp, "pvc_mcast_snd", pvcMcastSnd,
                   (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp, "pvc_mcast_rcv", pvcMcastRcv,
                   (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
   tcl_RcFileName = "~/.filea";
   return TCL_OK;
}

/*
main(argc, argv)
int argc;
char **argv;
{
   Tcl_Main(argc, argv, Tcl_AppInit);
   exit(0);
}
*/
