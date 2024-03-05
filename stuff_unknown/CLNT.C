#include <stdio.h>
#include <ctype.h>
#include <time.h>
#include <sys/types.h>

#include "test_clnt_srv.h"
#include "inet.h"
#include "test.h"
#include "test_macros.h"

extern char *hostlist[25];
extern int hostc, Gmax_size, timing, Gsend_bytes;


main(argc, argv)
int argc;
char **argv;
{
extern int doit();
char *dev_interface, *hostname;
int tfd, portnum, local_prot, ttl, mcast, c, bcast, i;
int numbers[4], vrbs, new_size;
word datatype, dataflow;
extern char *sdn, *qdn, *edn, *lpdn;
extern int Gvpi, Gvci, Gqos_sel, Gaal;

extern char *optarg;
extern int optind;

static char *optstring = "a:TVM:S:C:P:A:Q:s:v:b:m:u:t:p:d:D:";

   progname = argv[0];

   numbers[0] = numbers[2] = numbers[3] = 0;
   numbers[1] = 150;

   dataflow = DUPLEX;
   datatype = DG_DATA_UNK;
   local_prot = TCP;

   ttl = 1;
   hostname = dev_interface = NULL;
   new_size = vrbs = tfd = bcast = portnum = mcast = 0;

/***********************************************/
/*   Please excuse the crude nature of the options
     and option checks.  I put them in for me so I
     could stop changing code to try something new.
*/
   while ((c=getopt(argc, argv, optstring)) != EOF) {
      switch (c) {
         case 'a':
                    Gsend_bytes = atoi(optarg);
                    break;
         case 'D':
                    GET_DATA_TYPE(optarg[0], datatype);
                    break;
         case 'd':
                    GET_DATA_FLOW(optarg[0], dataflow);
                    break;
         case 'V':
                    vrbs = 1;
                    break;
         case 'T':
                    timing = 1;
                    break;
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
                    fprintf(stderr, "GET:  %s       %s\n", argv[optind - 1], argv[optind]);
                    local_prot = SPANS;
                    dev_interface = argv[optind - 1];
                    hostname = dev_interface;
                    while (argc > optind) {
                       if (strncmp("-", argv[optind], 1) == 0)
                          break;
                       hostlist[hostc] = argv[optind];
                       optind++;
                       hostc++;
                    }
                    if (hostc > 1)
                       dataflow = MULTICAST;
                    if (hostc < 1) {
                       fprintf(stderr, "No hosts specified\n");
                       exit(1);
                    }
                    break;
         case 'v':
                    local_prot = PVC;
                    hostname = optarg;
                    dev_interface = hostname;
                    i = 0;
                    while (argc > optind) {
                       if (strncmp("-", argv[optind], 1) == 0)
                          break;
                       numbers[i] = atoi(argv[optind]);
                       optind++;
                       i++;
                    }
                    dataflow = MULTICAST;
                    Gvpi = numbers[0];
                    Gvci = numbers[1];
                    break;
         case 'm':
                    dataflow = MULTICAST;
                    local_prot = UDP;
                    hostname = argv[optind - 1];
                    dev_interface = argv[optind];
                    ttl = atoi(argv[++optind]);
                    optind++;
                    mcast = 1;
                    break;

         case 'u':
                    local_prot = UDP;
                    hostname = optarg;
                    break;

         case 't':
                    local_prot = TCP;
                    hostname = optarg;
                    break;

         case 'S':
         case 'p':
                    portnum = atoi(optarg);
                    break;

         case 'b':
                    local_prot = UDP;
                    bcast = 1;
                    hostname = optarg;
                    break;

         default:
                    fprintf(stderr, "Bad args\n");
                    fprintf(stderr,
                            "%s -s device_name host [host [...]] [-p sap]\n",argv[0]);
                    fprintf(stderr,
                            "%s -m multicast_address interface ttl [-p portnum]\n",argv[0]);
                    fprintf(stderr, "%s -u host [-p portnum] /* point to point UDP */\n", argv[0]);
                    fprintf(stderr, "%s -t host [-p portnum] /* point to point TCP */\n", argv[0]);
                    fprintf(stderr, "%s -b broadcast_address [-p portnum]\n", argv[0]);
                    exit(-1);
      }
   }

   set_protocol(local_prot);
   set_client();

   for (c = 0; c < hostc; c++) {
      if (hostlist[c] != NULL)
         fprintf(stderr, "%s       %s      %d\n", hostlist[c], hostname, hostc);
   }

/*
   is_my_srvr_there(hostname, "/tmp_mnt/us/gaw/misc_progs/socket_stuff/server");
*/
   tfd = create_connection_clnt(hostname, portnum);

   if (mcast)
      set_mcast_ttl(tfd, ttl);

   if (bcast)
      set_bcast_on(tfd);

   if (vrbs) 
      print_verbose(tfd);

   if (tfd > 0) {
      if (new_size > 0)
         new_data_size(tfd, new_size);
      if (timing)
         t_sync_time(tfd);
      doit(tfd, datatype, dataflow, 0);
      terminate_connection(tfd);
   }
}
