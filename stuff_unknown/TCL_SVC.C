#include "test.h"
#include "test_macros.h"
#include "inet.h"
#include "test_clnt_srv.h"

#include "tcl.h"

extern int TCL_vrbs, TCL_dataflow, TCL_datatype, timing, TCL_sendbytes, TCL_trans;

/*****************************************************************************/

int svcMcastRcv(ClientData clientData, Tcl_Interp *interp,
                int argc, char *argv[])
{
unsigned long crc_accum;

   if (argc != 2) {
       Tcl_SetResult(interp, "Usage: crc32 string_to_crc", TCL_STATIC);
       return TCL_ERROR;
   }

   crc_accum = gen_crc32(0, argv[1], strlen(argv[1]));
   sprintf(interp->result, "%u", crc_accum);
   return TCL_OK;
}
int svcMcastSnd(ClientData clientData, Tcl_Interp *interp,
                int argc, char *argv[])
{
unsigned long crc_accum;

   if (argc != 2) {
       Tcl_SetResult(interp, "Usage: crc32 string_to_crc", TCL_STATIC);
       return TCL_ERROR;
   }

   crc_accum = gen_crc32(0, argv[1], strlen(argv[1]));
   sprintf(interp->result, "%u", crc_accum);
   return TCL_OK;
}
