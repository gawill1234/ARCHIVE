#include "test.h"
#include "test_macros.h"
#include "inet.h"
#include "test_clnt_srv.h"

#include "tcl.h"

int TCL_vrbs = 0;
int TCL_dataflow = MULTICAST;
int TCL_datatype = DG_DATA_UNK;
int TCL_portnum = 0;
int TCL_sendbytes = -1;
int TCL_trans = 0;

/*****************************************************************************/

int GenCrc32(ClientData clientData, Tcl_Interp *interp,
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

int datatype_conv(in_val, interp)
char *in_val;
Tcl_Interp *interp;
{
   if (strcmp(in_val, "unk") == 0) {
      TCL_datatype = DG_DATA_UNK;
      sprintf(interp->result, "unk");
      return TCL_OK;
   }
   if (strcmp(in_val, "none") == 0) {
      TCL_datatype = DG_DATA_UNK;
      sprintf(interp->result, "none");
      return TCL_OK;
   }
   if (strcmp(in_val, "chr") == 0) {
      TCL_datatype = DG_CHR_DATA;
      sprintf(interp->result, "chr");
      return TCL_OK;
   }
   if (strcmp(in_val, "lo") == 0) {
      TCL_datatype = DG_LO_DATA;
      sprintf(interp->result, "lo");
      return TCL_OK;
   }
   if (strcmp(in_val, "lr") == 0) {
      TCL_datatype = DG_LR_DATA;
      sprintf(interp->result, "lr");
      return TCL_OK;
   }
   if (strcmp(in_val, "bp") == 0) {
      TCL_datatype = DG_BP_DATA;
      sprintf(interp->result, "bp");
      return TCL_OK;
   }
   return TCL_OK;
}

int dataflow_conv(in_val, interp)
char *in_val;
Tcl_Interp *interp;
{
   if (strcmp(in_val, "multicast") == 0) {
      TCL_dataflow = MULTICAST;
      sprintf(interp->result, "multicast");
      return TCL_OK;
   }
   if (strcmp(in_val, "simplex") == 0) {
      TCL_dataflow = SIMPLEX;
      sprintf(interp->result, "simplex");
      return TCL_OK;
   }
   if (strcmp(in_val, "duplex") == 0) {
      TCL_dataflow = DUPLEX;
      sprintf(interp->result, "duplex");
      return TCL_OK;
   }
   return TCL_OK;
}

int GWConfig(ClientData clientData, Tcl_Interp *interp,
                int argc, char *argv[])
{
extern int verbose, Gaal, Gvci, Gvpi, Gqos_sel, Gsap, Gsend_type;

   if (argc < 2) {
       Tcl_SetResult(interp, "Usage: gaw_config config_element [element_value]", TCL_STATIC);
       return TCL_ERROR;
   }

   if (strncmp(argv[1], "trans", 5) == 0) {
      if (argc == 3) {
         if (strcmp(argv[2], "one") == 0) {
            sprintf(interp->result, "one");
            TCL_trans = 1;
         }
         else {
            sprintf(interp->result, "many");
            TCL_trans = 0;
         }
         return TCL_OK;
      }
      else {
         fprintf(stderr, "Usage: gaw_config config_element [element_value]\n");
         Tcl_SetResult(interp, "       config_element trans requires a value", TCL_STATIC);
         return TCL_ERROR;
      }
   }

   if (strncmp(argv[1], "port", 4) == 0) {
      if (argc == 3) {
         TCL_portnum = atoi(argv[2]);
         sprintf(interp->result, "%d", TCL_portnum);
         return TCL_OK;
      }
      else {
         fprintf(stderr, "Usage: gaw_config config_element [element_value]\n");
         Tcl_SetResult(interp, "       config_element port requires a value", TCL_STATIC);
         return TCL_ERROR;
      }
   }

   if (strncmp(argv[1], "send", 4) == 0) {
      if (argc == 3) {
         TCL_sendbytes = atoi(argv[2]);
         sprintf(interp->result, "%d", TCL_sendbytes);
         return TCL_OK;
      }
      else {
         fprintf(stderr, "Usage: gaw_config config_element [element_value]\n");
         Tcl_SetResult(interp, "       config_element send requires a value", TCL_STATIC);
         return TCL_ERROR;
      }
   }

   if (strncmp(argv[1], "io", 2) == 0) {
      if (argc == 3) {
         if (strcmp(argv[2], "fixed") == 0) {
            sprintf(interp->result, "fixed");
            Gsend_type = 1;
         }
         else {
            sprintf(interp->result, "random");
            Gsend_type = 0;
         }
         return TCL_OK;
      }
      else {
         fprintf(stderr, "Usage: gaw_config config_element [element_value]\n");
         Tcl_SetResult(interp, "       config_element io requires a value", TCL_STATIC);
         return TCL_ERROR;
      }
   }

   if (strncmp(argv[1], "verbose", 7) == 0) {
      if (argc == 3) {
         if (strcmp(argv[2], "on") == 0) {
            sprintf(interp->result, "on");
            TCL_vrbs = 1;
         }
         else {
            sprintf(interp->result, "off");
            TCL_vrbs = 0;
         }
         return TCL_OK;
      }
      else {
         fprintf(stderr, "Usage: gaw_config config_element [element_value]\n");
         Tcl_SetResult(interp, "       config_element verbose requires a value", TCL_STATIC);
         return TCL_ERROR;
      }
   }

   if (strncmp(argv[1], "sap", 3) == 0) {
      if (argc == 3) {
         Gsap = atoi(argv[2]);
         sprintf(interp->result, "%d", Gsap);
         return TCL_OK;
      }
      else {
         fprintf(stderr, "Usage: gaw_config config_element [element_value]\n");
         Tcl_SetResult(interp, "       config_element sap requires a value", TCL_STATIC);
         return TCL_ERROR;
      }
   }

   if (strncmp(argv[1], "vpi", 3) == 0) {
      if (argc == 3) {
         Gvpi = atoi(argv[2]);
         sprintf(interp->result, "%d", Gvpi);
         return TCL_OK;
      }
      else {
         fprintf(stderr, "Usage: gaw_config config_element [element_value]\n");
         Tcl_SetResult(interp, "       config_element vpi requires a value", TCL_STATIC);
         return TCL_ERROR;
      }
   }

   if (strncmp(argv[1], "vci", 3) == 0) {
      if (argc == 3) {
         Gvci = atoi(argv[2]);
         sprintf(interp->result, "%d", Gvci);
         return TCL_OK;
      }
      else {
         fprintf(stderr, "Usage: gaw_config config_element [element_value]\n");
         Tcl_SetResult(interp, "       config_element vci requires a value", TCL_STATIC);
         return TCL_ERROR;
      }
   }

   if (strncmp(argv[1], "aal", 3) == 0) {
      if (argc == 3) {
         Gaal = atoi(argv[2]);
         sprintf(interp->result, "%d", Gaal);
         return TCL_OK;
      }
      else {
         fprintf(stderr, "Usage: gaw_config config_element [element_value]\n");
         Tcl_SetResult(interp, "       config_element aal requires a value", TCL_STATIC);
         return TCL_ERROR;
      }
   }

   if (strncmp(argv[1], "qos", 3) == 0) {
      if (argc == 3) {
         Gqos_sel = atoi(argv[2]);
         sprintf(interp->result, "%d", Gqos_sel);
         return TCL_OK;
      }
      else {
         fprintf(stderr, "Usage: gaw_config config_element [element_value]\n");
         Tcl_SetResult(interp, "       config_element qos requires a value", TCL_STATIC);
         return TCL_ERROR;
      }
   }

   if (strncmp(argv[1], "datatype", 8) == 0) {
      if (argc == 3) {
         return(datatype_conv(argv[2], interp));
      }
      else {
         fprintf(stderr, "Usage: gaw_config config_element [element_value]\n");
         Tcl_SetResult(interp, "       config_element datatype requires a value", TCL_STATIC);
         return TCL_ERROR;
      }
   }

   if (strncmp(argv[1], "dataflow", 8) == 0) {
      if (argc == 3) {
         return(dataflow_conv(argv[2], interp));
      }
      else {
         fprintf(stderr, "Usage: gaw_config config_element [element_value]\n");
         Tcl_SetResult(interp, "       config_element dataflow requires a value", TCL_STATIC);
         return TCL_ERROR;
      }
   }

   return TCL_OK;
}
