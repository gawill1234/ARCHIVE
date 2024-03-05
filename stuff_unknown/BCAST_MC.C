#include <ctype.h>
#include <time.h>
#include <netdb.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <net/if.h>
#include <sys/ioctl.h>
#if defined(SunOS) || defined(Solaris)
#include <sys/sockio.h>
#endif

#include "test_clnt_srv.h"
#include "inet.h"

extern int protocol;

void reuse_addr(tfd)
int tfd;
{
int i = 1;

   if (setsockopt(tfd, SOL_SOCKET, SO_REUSEADDR, (char *)&i, sizeof(i)) < 0)
      fprintf(stderr, "reuse_addr():  SO_REUSEADDR, reuse a connect address -- Failed\n");
   return;
}

/***********************************************************************/
/*  SET_BCAST_OFF and SET_BCAST_ON

    Self explanatory.   Turn broadcasting on or off.  Only good on
    datagram type stuff.

    PARAMETERS:
       tfd:  the socket to enable or disable broadcast on

    RETURN:
       nothing
*/
void set_bcast_off(tfd)
int tfd;
{
int i = 0;

   if (setsockopt(tfd, SOL_SOCKET, SO_BROADCAST, (char *)&i, sizeof(i)) < 0)
      fprintf(stderr, "set_bcast_off():  SO_BROADCAST, set off -- Failed\n");

   return;
}

void set_bcast_on(tfd)
int tfd;
{
int i = 1;

   if (setsockopt(tfd, SOL_SOCKET, SO_BROADCAST, (char *)&i, sizeof(i)) < 0)
      fprintf(stderr, "set_bcast_on():  SO_BROADCAST, set on -- Failed\n");

   return;
}

/**********************************************************/
/*  The structures associated with the following two routines:
    OPEN_MCAST and CLOSE_MCAST
    will be placed in shared memory so that more than one
    process has access to the stuff.

    Currently it doesn't do too much because I wanted to work
    out the bugs without the added complications of shared memory
    and semaphores first.

    tfd is the controller here.  If tfd is -1, we are doing everything
    manually.  If tfd is 0, we have not opened a socket yet and we
    want it done along with everything else.  If tfd is greater than
    0, we already have the socket, but we need everything else
    to stash our data in.  If tfd is greater or equal to zero,
    the socket descriptor and the reference into this structure
    will be the same.  One less thing to keep track of.
    If you start in manual, you are committed to manual for the
    remainder of your application.

    dev_interface is the multicasting interface for the machine the
    server is running on.  Some examples:

     Ethernet
       AIX(IBM) = en0
       OSF(DEC) = tu0
       SunOS/Solaris = le0
       IRIX(SGI) = ec0
       HPUX(HP) = lan0
       IRIX(SGI - Challenge/DM)  = et0

    ATM (around here anyway)
      SPANS/FORE IP = fa?, probably fa0
      UNI/Q2931/Classical IP = qa??, probably qaa0
*/
int open_mcast(tfd, name, dev_interface, ttl, portnum)
int *tfd, ttl, portnum;
char *name, *dev_interface;
{
char *host, *dif, commonhost[16];
void add_mcast_grp(), set_mcast_ttl();
extern struct mcast_strt dohickey[];
extern int init_mcast;
uint hina;
int i, retval, found, ifirst;

   if (protocol != UDP) {
      fprintf(stderr, "open_mast():  Can not multicast with given protocol\n");
      return(-1);
   }

   host = (char *)malloc(strlen(name) + 1);
   sprintf(host, "%s\0", name);
   if ((hina = host_inetaddress(host)) == 0) {
      fprintf(stderr, "open_mcast():  Could not get internet address for host\n");
      free(host);
      return(-1);
   }

   /**************************************************************/
   /*  Check to see if this is a valid multicast address.  Must
       be between 224.0.0.0 and 239.255.255.255.  If we got this far,
       we know it is a valid internet address, so all we have to do
       is see if it is valid multicast (between 224 and 239).
   */
   strcpy(commonhost, host);
   for (i = 0; i < 16; i++) {
      if (commonhost[i] == '.')
         commonhost[i] = '\0';
   }
   ifirst = atoi(commonhost);
   if ((ifirst < 224) || (ifirst > 239)) {
      fprintf(stderr, "open_mcast():  Host is not a multicast address\n");
      free(host);
      return(-1);
   }
   /****************************************************************/
   
   /****************************************************************/
   /*   Addresses in the range 224.0.0.1 to 224.0.0.255 are limited
        to one hop no matter what the TTL is set to.  If the used
        address falls in that range, just issue a warning and
        continue.
   */
   if (strncmp("224.0.0.xx", host, 8) == 0)
      fprintf(stderr, "open_mcast():  Warning, selected host address is limited to one hop TTL\n");
   /****************************************************************/

   if (dev_interface == NULL) {
      fprintf(stderr, "open_mcast():  No device interface specified\n");
      return(-1);
   }

   dif = (char *)malloc(strlen(dev_interface) + 1);
   sprintf(dif, "%s\0", dev_interface);

   found = 0;
   retval = *tfd;

   if (init_mcast == 0) {
      for (i = 0; i < 243; i++) {
         dohickey[i].md = -1;
         dohickey[i].port = -1;
         dohickey[i].host = NULL;
         dohickey[i].dev_interface = NULL;
         dohickey[i].counter = 0;
         dohickey[i].creating_pid = -1;
      }
      init_mcast = 1;
   }

/*******************************************************/
/*   This works for now, but there is a bug.  Need to be able
     to get in use ports out of the open mcast structure
     so I can determine if it is to be set up to be 
     reused.
*/
   if (*tfd == 0) {
      retval = *tfd = create_connection_srv(NULL, portnum);
      if (retval < 0) {
         fprintf(stderr, "open_mcast():  Requested connection could not be created\n");
         return(-1);
      }
   }
/*******************************************************/

   if (retval < 0) {
      for (i = 0; i < 243; i++) {
         if (dohickey[i].host != NULL) {
            if (strcmp(dohickey[i].host, host) == 0) {
               free(host);
               free(dif);
               if (dohickey[i].creating_pid != getpid())
                  dohickey[i].counter++;
               retval = i;
               found = 1;
            }
         }
         if (retval == (-1))
            if (dohickey[i].md == (-1))
               retval = i;
      }
   }
   else if (retval > 0) {
      if (dohickey[retval].host != NULL) {
         if (strcmp(dohickey[i].host, host) == 0) {
            free(host);
            free(dif);
            if (dohickey[retval].creating_pid != getpid())
               dohickey[retval].counter++;
            found = 1;
         }
         else {
            fprintf(stderr, "open_mcast():  descriptor in use for another host\n");
            free(host);
            free(dif);
            return(-1);
         }
      }
   }
   else {
      fprintf(stderr, "open_mcast():  Can not allocate valid descriptor\n");
      free(host);
      free(dif);
      return(-1);
   }

   if (found == 0) {
      dohickey[retval].md = retval;
      dohickey[retval].port = portnum;
      dohickey[retval].host = host;
      dohickey[retval].counter = 1;
      dohickey[retval].creating_pid = getpid();
      dohickey[retval].h_inet_addr = hina;
      dohickey[retval].dev_interface = dif;
   }

   if (*tfd > 0)
      add_mcast_grp(*tfd, retval);

   if (ttl > 0)
      set_mcast_ttl(*tfd, ttl);

   return(retval);
}

int close_mcast(i)
int i;
{
extern struct mcast_strt dohickey[];

   dohickey[i].counter--;
   if (dohickey[i].counter == 0) {
      dohickey[i].md = -1;
      dohickey[i].port = -1;
      free(dohickey[i].host);
      dohickey[i].host = NULL;
      free(dohickey[i].dev_interface);
      dohickey[i].dev_interface = NULL;
      dohickey[i].creating_pid = -1;
   }
   return(0);
}


void set_mcast_ttl(tfd, ttl)
int tfd;
char ttl;
{
   if (setsockopt(tfd, IPPROTO_IP, IP_MULTICAST_TTL, &ttl, sizeof(ttl)) < 0)
      fprintf(stderr, "set_mcast_ttl():  IP_MULTICAST_TTL, set ttl -- Failed\n");

   return;

}

void add_mcast_grp(tfd, md)
int tfd, md;
{
struct ip_mreq mopt;
struct ifreq info;
extern struct mcast_strt dohickey[];

   mopt.imr_multiaddr.s_addr = dohickey[md].h_inet_addr;
   strcpy(info.ifr_name, dohickey[md].dev_interface);

   if (ioctl(tfd, SIOCGIFADDR, (caddr_t)&info) < 0)
      fprintf(stderr, "add_mcast_grp():  ioctl() failed\n");
   memcpy(&(mopt.imr_interface), &(info.ifr_addr.sa_data[2]), sizeof(struct in_addr));
   if (setsockopt(tfd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mopt, sizeof(mopt)) < 0)
       fprintf(stderr, "add_mcast_grp():  IP_ADD_MEMBERSHIP, add to mcast group -- Failed\n");

   return;
}

void do_add_mcast_grp(tfd, host, dev_interface)
int tfd;
char *host, *dev_interface;
{
struct ip_mreq mopt;
struct ifreq info;
extern struct mcast_strt dohickey[];

   mopt.imr_multiaddr.s_addr = host_inetaddress(host);
   strcpy(info.ifr_name, dev_interface);

   if (ioctl(tfd, SIOCGIFADDR, (caddr_t)&info) < 0)
      fprintf(stderr, "add_mcast_grp():  ioctl() failed\n");
   memcpy(&(mopt.imr_interface), &(info.ifr_addr.sa_data[2]), sizeof(struct in_addr));
   if (setsockopt(tfd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mopt, sizeof(mopt)) < 0)
       fprintf(stderr, "add_mcast_grp():  IP_ADD_MEMBERSHIP, add to mcast group -- Failed\n");

   return;
}

