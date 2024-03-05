/* The server */
/*
 * server test progran for catching SIGIO's
 *
 * usage: server.tcp port#    (ie. server.tcp 9876)
 */
#include <stdio.h>
#include <signal.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <netinet/in.h>
#include <netdb.h>

void     sigio();
int  ns, signal_mask;

main(int argc, char *argv[]) 
{
     int s, pgrp, on=1;
     struct sockaddr_in src;
     int len=sizeof(src);

     src.sin_family = AF_INET;
     src.sin_port = atoi(argv[1]);
     src.sin_addr.s_addr = 0;
     if ((s = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
          perror("server: unable to open socket");
          exit(1);
     }
     while (bind(s, (struct sockaddr *)&src, sizeof(src)) < 0) {
          printf("server: waiting on bind...\n");
          sleep(1);
     }
     listen(s, 0);
     ns = accept(s, (struct sockaddr *)&src, &len);
     if (ns < 0) {
          perror("server: accept failed");
          exit(1);
     }

     pgrp = getpid();
     if (ioctl(ns,  SIOCSPGRP, (char *)&pgrp) < 0) {
          perror("server: ioctl SIOCSPGRP");
          exit(1);
     }
     if (ioctl(ns, FIOASYNC, (char *)&on) < 0) {
          perror("server: ioctl FIOASYNC");
          exit(1);
     }
    
     signal(SIGIO, sigio);
     for(;;) {
        pause();
     }
}

void sigio(arg)
int arg;
{
     int available, bytes_read, concurrent;
     char buf[4096];

     sigblock(sigmask(SIGIO));
     bzero(buf, sizeof(buf));

     printf("RECIEVED SIGIO\n");
     
     concurrent=available=0;
     while (available < sizeof(buf)) {
           ioctl(ns, FIONREAD, (char *)&available);
           if ( ! available) {
              concurrent++;
              if (concurrent > 500)
                 break;
           }
     }

     if ((bytes_read=read(ns, &buf, sizeof(buf))) < 0) {
          perror("read");
          exit(1);
     } else if (bytes_read == 0) {
          fprintf(stdout, "ZERO BYTES READ\n");
          exit(0);
     }
     fprintf(stdout, "buf = %s : bytes read = %d\n", buf, bytes_read);
     signal(SIGIO, sigio);
     sigsetmask(0);
}
/* The end of the server */
