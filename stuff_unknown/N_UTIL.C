#include <string.h>

#include "test.h"
#include "test_clnt_srv.h"
#include "inet.h"


#include <netinet/in.h>
#include <arpa/inet.h>

#ifndef INADDR_NONE
#define INADDR_NONE 0xffffffff
#endif

extern int protocol;
uint inetaddress = 0;

uint myinetaddress()
{
char hostname[40];
struct hostent *gethostbyname();
struct hostent *hostptr = NULL;

#ifdef DEBUG
fprintf(stderr, "MYINETADDRESS ... ");
#endif

   if (inetaddress == 0) {
      if (gethostname(hostname, 40) == (-1))
         return(0);
      hostptr = gethostbyname(hostname);
      inetaddress = inet_addr(inet_ntoa(*(struct in_addr *)*hostptr->h_addr_list));
   }

#ifdef DEBUG
fprintf(stderr, "DONE\n");
#endif

   return(inetaddress);
}

/**************************************************************/
/*  INIT_SOCKADDR

    Initialize all of those sockaddr_in structures that you
    need to open connections using tcp and udp.  Good for both
    client and server sides.

    PARAMETERS:
       serv_addr:  address of a sockaddr_in structure
       serverloc:  a string which is a server name.  If it is NULL,
                   it assumes this is the server that is trying to
                   initialize and uses the INADDR_ANY crap.  Otherwise,
                   it figures it is a client.  Set this to NULL if
                   init_sockaddr() is being called for any bind().
       portnum:    the port to open things on
                   set to 0 if init_sockaddr() called for client bind().
       family:     same as it would be for sockaddr_in(AF_INET ...)
       service:    name of a service in /etc/services.  In most cases
                   this will probably be NULL.

    RETURNS:
       -1 if error, 0 if success.
       However, it does fill in serv_addr.
*/
int init_sockaddr(serv_addr, serverloc, portnum, family, service)
struct sockaddr_in *serv_addr;
char *serverloc, *service;
int portnum, family;
{
struct hostent *gethostbyname();
struct hostent *hostptr = NULL;
struct servent *sp = NULL;
uword inaddr;

#ifdef DEBUG
fprintf(stderr, "INIT_SOCKADDR ... ");
#endif

   memset(serv_addr, 0, sizeof(serv_addr));
   memset(serv_addr->sin_zero, 0, sizeof(serv_addr->sin_zero));

   serv_addr->sin_family = family;

   if (serverloc == NULL) {
      /**************************************************/
      /*  This is either a server side bind() structure,
          or a client side UDP bind() structure.
      */
      serv_addr->sin_addr.s_addr = htonl(INADDR_ANY);
      myinetaddress();
   }
   else {
      if ((inaddr = inet_addr(serverloc)) != INADDR_NONE) {
         /*  Serverloc is in dotted decimal format */
        serv_addr->sin_addr.s_addr = inaddr;
      }
      else {
         /*  Serverloc is specified as an actual host name */
         hostptr = gethostbyname(serverloc);

         if (hostptr != NULL)
            serv_addr->sin_addr.s_addr =
                   inet_addr(inet_ntoa(*(struct in_addr *)*hostptr->h_addr_list));
         else
            return(-1);
      }
   }

   if (service != NULL) {
      /*******************************************************/
      /*  If a service is specified, try and get the port from the
          service, unless a port is specified. 
      */
      switch (protocol) {
         case UDP:
                   sp = getservbyname(service, "udp");
                   break;
         case TCP:
                   sp = getservbyname(service, "tcp");
                   break;
         default:
                   fprintf(stderr, "init_sockaddr:  unknown protocl\n");
                   return(-1);
                   break;
      }

      if (sp == NULL) {
         fprintf(stderr, "init_sockaddr:  unknown service:  %s\n", service);
         return(-1);
      }

      if (portnum > 0)
         serv_addr->sin_port = htons(portnum);
      else
         serv_addr->sin_port = sp->s_port;
   } 
   else {
      /*******************************************************/
      /*  If no service is specified, just take the portnum.
          Even if it is zero.  It may be a client structure we
          are initializing.
      */
     if (portnum < 0) {
        fprintf(stderr,
               "init_sockaddr:  Must specify some port or 0 if this is the bind() structure\n");
        return(-1);
      }
      else {
         serv_addr->sin_port = htons(portnum);
      }
   }

#ifdef DEBUG
fprintf(stderr, "DONE\n");
#endif
   return(0);
}

uint host_inetaddress(host)
char *host;
{
struct hostent *gethostbyname();
struct hostent *hostptr = NULL;
struct servent *sp = NULL;
uword inaddr;

#ifdef DEBUG
fprintf(stderr, "HOST_INETADDRESS ... ");
#endif

   if (host == NULL) {
      fprintf(stderr, "host_inetaddress():  No host specified\n");
   }
   else {
      if ((inaddr = inet_addr(host)) != INADDR_NONE) {
         /*  host is in dotted decimal format */
         return(inaddr);
      }
      else {
         /*  host is specified as an actual host name */
         hostptr = gethostbyname(host);

         if (hostptr != NULL) {
            inaddr = inet_addr(inet_ntoa(*(struct in_addr *)*hostptr->h_addr_list));
            return(inaddr);
         }
      }
   }

#ifdef DEBUG
fprintf(stderr, "DONE\n");
#endif
   return(0);
}

/***********************************************************/
/*   COUNTCHARS

   Count the characters c, in string string.
*/
/*
   parameters:
      string      string to count characters in
      c           character to count

   return value:
      cnt         number of c in string
*/

int countchars(string, c)
char *string;
char c;
{
int i, len, cnt;

   cnt = 0;

   len = strlen(string);

   for (i = 0; i < len; i++)
      if (string[i] == c)
         cnt++;
   return(cnt);
}
