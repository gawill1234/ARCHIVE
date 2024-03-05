#include <sys/ioctl.h>
#include <signal.h>
#include  "inet.h"
#include "test_clnt_srv.h"

#if defined(__SPANS)
#include <fore/types.h>
#include <fore_atm/fore_msg.h>
#include <fore_atm/fore_atm_user.h>

extern int routine_tfd;
extern void time_to_leave();

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
/****************************************************/
/*  TCP_INIT_CONNECTION_SRV

    This routine initializes a tcp connect on a port.

     PARAMETERS:
        portnum:  a port number, if 0 it defaults to 6543

     RETURN:
        returns a transport (socket) file descriptor.
        if it fails, it returns -1.
*/

int init_spans_srv_svc(device_name, sap)
char *device_name;
Atm_sap sap;
{
extern int protocol;
int tfd, qlen;
struct sockaddr_in ics_serv_addr;
Atm_sap ssap;
Atm_info info;
extern int Gmtu;

   qlen = 7;

   if (sap < 0)
      sap = 0;

   /****************************************/
   /*  open ATM connection
   */
   if ((tfd = atm_open(device_name, O_RDWR, &info)) < 0) {
      fprintf(stderr, "init_spans_srv():  Could not open atm channel\n");
      return(-1);
   }

   Gmtu = info.mtu;

   /****************************************/
   /*  bind ATM connection
   */
   ssap = sap;
   if (atm_bind(tfd, ssap, &ssap, qlen) < 0) {
      atm_error("server: can't bind local address");
      return(-1);
   }

   return(tfd);
}

int init_spans_srv_pvc(device_name, vpi, vci, aal, qos_sel)
char *device_name;
int vpi, vci, qos_sel;
Aal_type aal;
{
int tfd;
struct sockaddr_in ics_serv_addr;
Atm_conn_resource qos;
Atm_info info;

extern int Gmtu;

extern Vpvc Grvpvc;


   /****************************************/
   /*  open ATM connection
   */
   if ((tfd = atm_open(device_name, O_RDWR, &info)) < 0) {
      fprintf(stderr, "init_spans_srv():  Could not open atm channel\n");
      return(-1);
   }

   Gmtu = info.mtu;

   Grvpvc = MKVPVC(vpi, vci);

   qos.peak_bandwidth = qos_sel;
   qos.mean_bandwidth = 0;
   qos.mean_burst = 2;

   /****************************************/
   /*  bind ATM connection
   */
   if (atm_bind_pvc(tfd, Grvpvc, aal, &qos) < 0) {
      atm_error("server: can't bind local address");
      return(-1);
   }


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

int open_spans_srv_svc(tfd, function, device_name, aal, qos_req)
func_p function;
char *device_name;
Aal_type aal;
int tfd, qos_req;
{
int newtfd, childpid, cli_len, cid, pdu_len;
struct sockaddr_in ots_cli_addr;
Atm_qos qos;
Atm_endpoint calling;
Atm_dataflow dataflow = duplex;

extern int hostc;

   if (hostc > 1)
      dataflow = multicast;

   routine_tfd = tfd;
   signal(SIGINT, (void *)time_to_leave);

   if (aal < 0)
      aal = aal_type_5;

   if (atm_listen(tfd, &cid, &calling, &qos,  &aal) < 0)
      atm_error("server: listen error");

   qos.peak_bandwidth.target  = qos_req; /* kilo-bits */
   qos.peak_bandwidth.minimum = 0;       /* kilo-bits */
   qos.mean_bandwidth.target  = 0;       /* kilo-bits */
   qos.mean_bandwidth.minimum = 0;       /* kilo-bits */
   qos.mean_burst.target      = 0;       /* 2k packet length */
   qos.mean_burst.minimum     = 0;       /* 1k packet length */

   for(;;) {

      newtfd = init_spans_srv_svc(device_name, 0);

      if (atm_accept(tfd, newtfd, cid, &qos, dataflow) < 0)
        atm_error("server: accept error");


      if ((childpid = fork()) < 0) {
         err_dump("server: fork error");
      }
      else if (childpid == 0) {
         routine_tfd = newtfd;
         atm_close(tfd);
         if (aal == aal_null) {
            if (atm_setbatchsize(newtfd, pdu_len/ATM_USER_CELL_SIZE) == -1) {
               fprintf(stderr, "open_spans_srv_svc():  atm_setbatchsize() failed for aal0\n");
               return(-1);
            }
         }
         (*function)(newtfd);    /*  user provided function */
         fprintf(stderr, "Supplied function complete, exiting\n");
         exit(0);
      }
      atm_close(newtfd);
      if (Gquit != 0)
         break;
   }
   return(0);
}

int open_spns_srv_pvc(tfd, function)
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

#else
void init_spans_srv_svc()
{
   return;
}

void init_spans_srv_pvc()
{
   return;
}

void open_spns_srv_pvc()
{
   return;
}

void open_spans_srv_svc()
{
   return;
}

#endif
