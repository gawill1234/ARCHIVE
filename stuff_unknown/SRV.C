#include <stdio.h>

#include "test.h"
#include "test_macros.h"

extern char *hostlist[25];
extern int hostc;

main(argc, argv)
int argc;
char **argv;
{
extern void server_loop();
extern char *sdn, *qdn, *edn, *lpdn;
char *dev_interface, *host;
int tfd, md, local_prot, ttl, mcast, c, portnum, bcast, i;
int numbers[4], new_size;
extern int Gvci, Gvpi, Gqos_sel, Gaal;

extern char *optarg;
extern int optind;

extern char *foreign_name;

static char *optstring = "M:S:C:P:A:Q:n:s:v:b:m:utp:F:";

   numbers[0] = numbers[2] = numbers[3] = 0;
   numbers[1] = 150;

   local_prot = TCP;
   ttl = 1;
   host = dev_interface = NULL;
   new_size = tfd = bcast = portnum = mcast = 0;

/***********************************************/
/*   Please excuse the crude nature of the options
     and option checks.  I put them in for me so I
     could stop changing code to try something new.
*/
   while ((c=getopt(argc, argv, optstring)) != EOF) {
      switch (c) {
         case 'M':
                    new_size = atoi(optarg);
                    break;
         case 'A':
                    Gaal = atoi(optarg);
                    break;
         case 'Q':
                    Gqos_sel = atoi(optarg);
                    break;
         case 'P':
                    Gvpi = atoi(optarg);
                    break;
         case 'C':
                    Gvci = atoi(optarg);
                    break;
         case 's':
                    local_prot = SPANS;
                    host = optarg;
                    dev_interface = host;
                    while (argc > optind) {
                       if (strncmp("-", argv[optind], 1) == 0)
                          break;
                       hostlist[hostc] = argv[optind];
                       optind++;
                       hostc++;
                    }
                    break;
         case 'n':
                    hostc = atoi(optarg);
                    break;
         case 'v':
                    local_prot = PVC;
                    host = optarg;
                    dev_interface = host;
                    i = 0;
                    while (argc > optind) {
                       if (strncmp("-", argv[optind], 1) == 0)
                          break;
                       numbers[i] = atoi(argv[optind]);
                       optind++;
                       i++;
                    }
                    Gvpi = numbers[0];
                    Gvci = numbers[1];
                    break;
         case 'm':
                    local_prot = UDP;
                    host = argv[optind - 1];      /*  also known as optarg  */
                    dev_interface = argv[optind];
                    ttl = atoi(argv[++optind]);
                    ++optind;
                    mcast = 1;
                    break;

         case 'u':
                    local_prot = UDP;
                    if (argc > optind)
                       if (strncmp("-", argv[optind], 1) == 0)
                          break;
                    host = argv[optind];
                    optind++;
                    break;

         case 't':
                    local_prot = TCP;
                    if (argc > optind)
                       if (strncmp("-", argv[optind], 1) == 0)
                          break;
                    host = argv[optind];
                    optind++;
                    break;

         case 'S':
         case 'p':
                    portnum = atoi(optarg);
                    break;
    
         case 'b':
                    local_prot = UDP;
                    host = optarg;
                    bcast = 1;
                    break;

         case 'F':
                    foreign_name = optarg;
                    break;

         default:
                    fprintf(stderr, "Bad args\n");
                    fprintf(stderr,
                            "%s -s device_name [host [host [...]]] [-p sap]\n",argv[0]);
                    fprintf(stderr,
                            "%s -m multicast_address interface ttl [-p portnum]\n",argv[0]);
                    fprintf(stderr, 
                           "%s -u [host] [-p portnum] /* point to point UDP */\n", argv[0]);
                    fprintf(stderr,
                           "%s -t [host] [-p portnum] /* point to point TCP */\n", argv[0]);
                    fprintf(stderr, "%s -b broadcast_address [-p portnum]\n", argv[0]);
                    exit(-1);
      }
   }

 
/*
   tcp_server_indicator();
*/
   set_server();

   set_protocol(local_prot);

   for (c = 0; c < hostc; c++) {
      if (hostlist[c] != NULL)
         fprintf(stderr, "%s       %s      %d\n", hostlist[c], host, portnum);
   }

#ifdef DEBUG
   if (host != NULL)
      fprintf(stderr, "HOST:             %s\n", host);
   fprintf(stderr, "PORTNUM:          %d\n", portnum);
   if (dev_interface != NULL) {
      fprintf(stderr, "DEV_INTERFACE:    %s\n", dev_interface);
      fprintf(stderr, "TTL:              %d\n", ttl);
   }
#endif

   if (mcast) {
      tfd = create_connection_srv(NULL, portnum);
      tfd = open_mcast(&tfd, host, dev_interface, ttl, portnum);
   }
   else {
      tfd = create_connection_srv(host, portnum);
   }

   if (new_size > 0)
      new_data_size(tfd, new_size);

   if (tfd < 0)
      exit(-1);

   if (bcast)
      set_bcast_on(tfd);
   run_server(tfd, server_loop);
   terminate_connection(tfd);
}
