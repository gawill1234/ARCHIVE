



/* The Client */
/*
 * client program to test SIGIO's
 * 
 * usage: client.tcp serverhost port#  (ie. client.tcp hot.cray.com 9876)
 */
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <stdio.h>
#include <netdb.h>


main(int argc, char *argv[])
{
     int s,count;
     char data[4096];
     struct sockaddr_in dest;
     struct hostent *hp; 

     hp = gethostbyname(argv[1]);
     dest.sin_family = hp->h_addrtype;  /* addr type (AF_INET) */
     bcopy(hp->h_addr_list[0], &dest.sin_addr, hp->h_length);
     dest.sin_port = atoi(argv[2]);


     if ((s = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
          perror("client, cannot open socket");
          exit(1);
     }
     if (connect (s, (struct sockaddr *) &dest, sizeof(dest)) < 0) {
          close(s);
          perror("client, connect failed");
          exit(1);
     }
     for (count=0; count < 10; count++) {
          sprintf(data, "TCP test message %5d", count); 
          if (write(s, data, sizeof(data)) < 0) {
               perror("client, write failed");
          }
          sleep(1);
     }
#ifdef CRAY
     fprintf(stdout, "YO\n");
     data[0]='\0';
     write(s, data, 0);
#endif
     close(s);
     exit(0);
}
/* The end of the client */
