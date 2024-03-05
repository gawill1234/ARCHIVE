#include "test_clnt_srv.h"
#include "inet.h"

/****************************************************************/
/*  NEW_BUFFER_SIZE

    Change the local buffer size for both send and receive.
    Local can be either the client OR the server.
    If you wish to change only one of the buffer sizes,
    make the other one zero.

    PARAMETER:
       tfd:            socket descriptor
       snd_buff_size:  New send buffer size
       rcv_buff_size:  New receive buffer size

    RETURN:
       nothing
*/
int new_buffer_size(tfd, snd_buff_size, rcv_buff_size)
int tfd;
word snd_buff_size, rcv_buff_size;
{

   if (snd_buff_size > 0) {
      if (setsockopt(tfd, SOL_SOCKET, SO_SNDBUF,
                 (char *)&snd_buff_size, sizeof(snd_buff_size)) < 0) {
         fprintf(stderr, "setsockopt:  SO_SNDBUF, %d -- Failed\n", snd_buff_size);
         return(-1);
      }
   }
   if (rcv_buff_size > 0) {
      if (setsockopt(tfd, SOL_SOCKET, SO_RCVBUF,
                 (char *)&rcv_buff_size, sizeof(rcv_buff_size)) < 0) {
         fprintf(stderr, "setsockopt:  SO_RCVBUF, %d -- Failed\n", rcv_buff_size);
         return(-1);
      }
   }
   return(0);
}

int get_snd_buffer_size(tfd)
int tfd;
{
int sndbuff, optlen;

   optlen = sizeof(sndbuff);
   if (getsockopt(tfd, SOL_SOCKET, SO_SNDBUF, (char *)&sndbuff, &optlen) < 0)
      return(-1);
   return(sndbuff);
}

int get_rcv_buffer_size(tfd)
int tfd;
{
int rcvbuff, optlen;

   optlen = sizeof(rcvbuff);
   if (getsockopt(tfd, SOL_SOCKET, SO_RCVBUF, (char *)&rcvbuff, &optlen) < 0)
      return(-1);
   return(rcvbuff);
}

/****************************************************************/
/*  NEW_SRV_BUFFER

    Change the send and receive buffer sizes on the server only.
    If you wish to change only one of the buffer sizes,
    make the other one zero.

    PARAMETER:
       tfd:            socket descriptor
       snd_buff_size:  New send buffer size
       rcv_buff_size:  New receive buffer size

    RETURN:
       nothing
*/
void new_srv_buffer_size(tfd, snd_buff_size, rcv_buff_size)
int tfd;
word snd_buff_size, rcv_buff_size;
{

   send_command(tfd, CMD_GRP | CMD_BLK_SZ, snd_buff_size, rcv_buff_size);
   return;
}

/****************************************************************/
/*  CHNG_BUFFER_SIZE

    Change the send and receive buffer sizes on both the client and
    server.  If you wish to change only one of the buffer sizes,
    make the other one zero.

    PARAMETER:
       tfd:            socket descriptor
       snd_buff_size:  New send buffer size
       rcv_buff_size:  New receive buffer size

    RETURN:
       nothing
*/
void chng_buffer_size(tfd, snd_buff_size, rcv_buff_size)
int tfd;
word snd_buff_size, rcv_buff_size;
{

   new_buffer_size(tfd, snd_buff_size, rcv_buff_size);
   new_srv_buffer_size(tfd, snd_buff_size, rcv_buff_size);
   return;
}


