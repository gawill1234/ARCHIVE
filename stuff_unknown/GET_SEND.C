#include "test.h"
#include "test_clnt_srv.h"
#include "inet.h"

extern int errno;
extern char *sys_errlist[];

/*************************************************************/
/*  GET_COMMAND and SEND_COMMAND

    All commands/directions sent to the server from the clients
    are three(3) words long.  The type "word" is defined
    int "test.h".

    get_command reads 3 words and places them in a set of pointers
    passed in by the calling function.  For a complete list of the
    available commands, see the include file "test_clnt_srv.h".
    If the "command" says read data, param_1 will be the amount of
    data and param_2 will be the pid of the sending program.

    send_command sends the 3 words.

    PARAMETER:
       tfd:      socket descriptor
       cmd:      the comand the server is to perform
       param_1:  first paramter to command
       param_2:  second parameter to command (zero to show no param_2)

    RETURN:
       nothing from send_command
       the amount read from get_command
*/
int get_command(tfd, cmd, param_1, param_2)
int tfd;
word *cmd, *param_1, *param_2;
{
int retval;
word incoming[3];

   retval = rem_read(tfd, incoming, BYTESINWORD * 3);
   *cmd = ntohl(incoming[0]);
   *param_1 = ntohl(incoming[1]);
   *param_2 = ntohl(incoming[2]);
   return(retval);
}

int getcmd(tfd, dataarr, size)
int tfd;
word *dataarr;
int size;
{
int i, retval;

   retval = rem_read(tfd, dataarr, BYTESINWORD * size);
   for (i = 0; i < size; i++) {
      dataarr[i] = ntohl(dataarr[i]);
   }
   return(retval);
}

int send_command(tfd, cmd, param_1, param_2)
int tfd;
word cmd, param_1, param_2;
{
word outgoing[3];
int nsent, flag;

   outgoing[0] = htonl(cmd);
   outgoing[1] = htonl(param_1);
   outgoing[2] = htonl(param_2);

#ifdef DEBUG
   fprintf(stderr, "SENDING 12 ... ");
#endif
   nsent = rem_write(tfd, outgoing, (BYTESINWORD * 3));
#ifdef DEBUG
   fprintf(stderr, "%d DONE\n", nsent);
   if (nsent == -1)
      fprintf(stderr, "  send_command error:  %s\n",  sys_errlist[errno]);
#endif

   return(nsent);
}

int sndcmd(tfd, dataarr, size)
int tfd;
word *dataarr;
int size;
{
int i, nsent;
word *outgoing;

   outgoing = (word *)malloc(BYTESINWORD * size);
   for (i = 0; i < size; i++) {
      outgoing[i] = htonl(dataarr[i]);
   }
   nsent = rem_write(tfd, outgoing, (BYTESINWORD * size));
   free(outgoing);
   return(nsent);

}

int server_exit(tfd)
int tfd;
{
word outgoing[3];

   outgoing[0] = (word)(CMD_GRP | CMD_EXIT);
   outgoing[1] = 0;
   outgoing[2] = 0;

   sleep(5);
   sndcmd(tfd, outgoing, 3);
   sleep(1);
   sndcmd(tfd, outgoing, 3);
   sleep(1);
   sndcmd(tfd, outgoing, 3);
   sleep(1);
   sndcmd(tfd, outgoing, 3);
   sleep(1);
   sndcmd(tfd, outgoing, 3);
   sleep(1);
   sndcmd(tfd, outgoing, 3);
   sleep(1);
   sndcmd(tfd, outgoing, 3);
   sleep(1);
   sndcmd(tfd, outgoing, 3);
}

/*
   If the remote switching code is working, this should not be
   necessary.  Therefore, commented out.
*/
/*
int wr_send_command(tfd, cmd, param_1, param_2)
int tfd;
word cmd, param_1, param_2;
{
word outgoing[3];
int nsent;

   outgoing[0] = htonl(cmd);
   outgoing[1] = htonl(param_1);
   outgoing[2] = htonl(param_2);

#ifdef DEBUG
   fprintf(stderr, "SENDING 12 ... ");
#endif
   nsent = write(tfd, &outgoing, (BYTESINWORD * 3));
#ifdef DEBUG
   fprintf(stderr, "%d DONE\n", nsent);
   if (nsent == -1)
      fprintf(stderr, "  write error:  %s\n",  sys_errlist[errno]);
#endif
   return(nsent);
}
*/
