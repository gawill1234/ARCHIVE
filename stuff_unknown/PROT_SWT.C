#include "inet.h"
#include "test.h"

/*****************************************************************/
/*
EXTERNAL VARIABLES RELATED TO PROTOCOL SWITCH

           protocol:   modified by set_protocol().  Identifies current
                       protocol in use

           cLiEnT:     modified by set_client().
           sErVeR:     modified by set_server().

           Gvpi, Gvci, Gaal, Gqos_sel, Gsap:
                       can be modified by the user to use values other
                       than the defaults.  Gvci and Gsap will take the
                       value of portnum, depending on which protocol is
                       used, unless portnum is 0.  Default values are
                       Gvpi 0, Gvci 150, Gaal 5, Gqos_sel 1000, Gsap 4096.

           Grvpvc:     Set by MKVPVC from the vpi and vci.

*/
int Gvpi = 0;
int Gvci = 150;
int Gaal = 5;
int Gqos_sel = 512;
int Gsap = 4096;

int cLiEnT = 0;
int sErVeR = 0;
int protocol = FIO;

char *atm_device_name;

int iamaserver()
{
   return(sErVeR);
}

int iamaclient()
{
   return(cLiEnT);
}

/*****************************************************************/
/*
THIS IS A CLIENT
   Sets the client identifier.  Needed because IO may differ depending
   on whether it is being performed by the client or server side.

   extern int cLiEnT;

*/
void set_client()
{
   if (sErVeR) {
      fprintf(stderr, "set_client():  WARNING, already set as a server, switching.\n");
      sErVeR = 0;
   }
   cLiEnT = 1;
}

/*****************************************************************/
/*
THIS IS A SERVER
   Sets the server identifier.  Needed because IO may differ depending
   on whether it is being performed by the client or server side.

   extern int sErVeR;


*/
void set_server()
{
   if (cLiEnT) {
      fprintf(stderr, "set_server():  WARNING, already set as a client, switching.\n");
      cLiEnT = 0;
   }
   sErVeR = 1;
}

char *copy_dev(device_name)
char *device_name;
{
   if (device_name[0] == '/') {
      atm_device_name = (char *)malloc(strlen(device_name) + 1);
      sprintf(atm_device_name, "%s\0", device_name);
   }
   else {
      atm_device_name = (char *)malloc(strlen(device_name) + 6);
      sprintf(atm_device_name, "/dev/%s\0", device_name);
   }
   return(atm_device_name);
}

/*****************************************************************/
/*
SET THE PROTOCOL TYPE
   Sets the protocol identifier to the requested protocol which
   the client or server is  to use.

          extern protocol;
          prot:   protocol identifier
                  TCP, UDP, PVC, SPANS, FIO, PIO, SMIO,
                  NNI, PNNI, UNI[30,31,40]

              The first four are currently defined and running.
              FIO is file IO, PIO is pipe IO, SMIO is shared memory IO
              These three will be defined when a need for them arises
              Other names are self explanatory


*/
void set_protocol(prot)
int prot;
{
   protocol = prot;
}

/*****************************************************************/
/*
REMOTE WRITE
   Write data to the descriptor.  Usage is the same as write() system
   call.

          fd:      file, socket or communication descriptor
          buffer:  data buffer
          amount:  amount to write


*/
int rem_write(fd, buffer, amount)
int fd, amount;
char *buffer;
{
int retval;

   switch (protocol) {
      case FIO:
      case TCP:
                 retval = write(fd, buffer, amount);
                 break;
      case UDP:
                 retval = write2(fd, buffer, amount);
                 break;
      case PVC:
                 retval = atm_write(fd, buffer, amount);
                 break;
      case SPANS:
                 retval = atm_write2(fd, buffer, amount);
                 break;
      case UNI:
      case NNI:
      case PNNI:
      default:
                 fprintf(stderr, "rem_write:  Protocol undefined for writing\n");
                 break;
   }

   return(retval);
}

int terminate_connection(fd)
int fd;
{
int retval;

   switch (protocol) {
      case FIO:
      case TCP:
      case UDP:
      case PVC:
                 close(fd);
                 break;
      case SPANS:
#ifdef __SPANS
                 retval = atm_close(fd);
                 break;
#endif
      case UNI:
      case NNI:
      case PNNI:
      default:
                 fprintf(stderr, "rem_write:  Protocol undefined for writing\n");
                 break;
   }

   return(retval);
}


/*****************************************************************/
/*
REMOTE READ
   Read data from the descriptor.  Usage is the same as read() system
   call.

          fd:      file, socket or communication descriptor
          buffer:  data buffer
          amount:  size of data buffer


*/
int rem_read(fd, buffer, amount)
int fd, amount;
char *buffer;
{
int retval;

   switch (protocol) {
      case FIO:
      case TCP:
                 retval = rd_read2(fd, buffer, amount);
                 break;
      case UDP:
                 retval = read2(fd, buffer, amount);
                 break;
      case PVC:
                 retval = atm_read(fd, buffer, amount);
                 break;
      case SPANS:
                 retval = atm_read2(fd, buffer, amount);
                 break;
      case UNI:
      case NNI:
      case PNNI:
      default:
                 fprintf(stderr, "rem_read:  Protocol undefined for reading\n");
                 break;
   }

   return(retval);
}

/*****************************************************************/
/*
CREATE SERVER SIDE
   Set up and initialize everything required for the server side of
   the requested protocol or IO method.

           hostname:  host or device name
           portnum:   port, sap, or vci


*/
int create_connection_srv(hostname, portnum)
char *hostname;
int portnum;
{
int fd;

   switch (protocol) {
      case TCP:
                 fd = init_connection_srv(portnum, AF_INET, SOCK_STREAM, hostname);
                 break;
      case UDP:
                 fd = init_connection_srv(portnum, AF_INET, SOCK_DGRAM, hostname);
                 break;
      case PVC:
                 atm_device_name = copy_dev(hostname);
                 if (portnum > 0)
                    Gvci = portnum;
                 /*
                    hostname is actually the device name
                 */
                 fd = init_spans_srv_pvc(atm_device_name, Gvpi, Gvci, Gaal, Gqos_sel);
                 break;
      case SPANS:
                 atm_device_name = copy_dev(hostname);
                 if (portnum > 0)
                    Gsap = portnum;

                 /*
                     hostname is actually the device name
                     portnum is actually the SAP
                 */
                 fd = init_spans_srv_svc(atm_device_name, Gsap);
                 break;
      case FIO:
      case UNI:
      case NNI:
      case PNNI:
      default:
                 fprintf(stderr, "rem_write:  Protocol undefined for server connections\n");
                 break;
   }

   return(fd);
}

/*****************************************************************/
/*
CREATE CLIENT SIDE
   Set up and initialize everything required for the client side of
   the requested protocol or IO method.

           hostname:  host or device name
           portnum:   port, sap, or vci


*/
int create_connection_clnt(hostname, portnum)
char *hostname;
int portnum;
{
int fd;

   switch (protocol) {
      case TCP:
                 fd = connection_clnt(hostname, portnum, AF_INET, SOCK_STREAM);
                 break;
      case UDP:
                 fd = connection_clnt(hostname, portnum, AF_INET, SOCK_DGRAM);
                 break;
      case PVC:
                 atm_device_name = copy_dev(hostname);
                 if (portnum > 0)
                    Gvci = portnum;

                 fd = spans_conn_clnt_pvc(atm_device_name, Gvpi, Gvci, Gaal, Gqos_sel);
                 break;
      case SPANS:
                 atm_device_name = copy_dev(hostname);
                 if (portnum > 0)
                    Gsap = portnum;
                 fd = spans_conn_clnt_svc(atm_device_name, Gsap, Gaal, Gqos_sel);
                 break;
      case FIO:
      case UNI:
      case NNI:
      case PNNI:
      default:
                 fprintf(stderr, "rem_write:  Protocol undefined for server connections\n");
                 break;
   }

   return(fd);
}

/*****************************************************************/
/*
RUN THE SERVER
   Complete any connections, if necessary, and execute the user
   function.   User function must allow one parameter, fd, the file
   descriptor of the communication channel.  It is acquired from
   create_connection_srv() or create_connection_clnt() and used
   by rem_read() and rem_write().

           fd:         file, socket or communication descriptor
           function:   pointer to user function to execute as server


*/
void run_server(fd, function)
int fd;
func_p function;
{
   switch (protocol) {
      case TCP:
                 fd = open_tcp_srv(fd, function);
                 break;
      case UDP:
                 fd = open_udp_srv(fd, function);
                 break;
      case PVC:
                 fd = open_spns_srv_pvc(fd, function);
                 break;
      case SPANS:
                 fd = open_spans_srv_svc(fd, function, atm_device_name, Gaal, Gqos_sel);
                 break;
      case FIO:
      case UNI:
      case NNI:
      case PNNI:
      default:
                 fprintf(stderr, "rem_write:  Protocol undefined for server connections\n");
                 break;
   }

   return;
}
