#ifndef _H_TEST_CLNT_SRV
#define _H_TEST_CLNT_SRV

#include "test.h"

#define CMD_SIZE (BYTESINWORD * 3)

/*********************************************************************/
/* All of this info is sent from the client to the server to get the */
/* server to do something required by the client.                    */
/*********************************************************************/

/*********************************************************************/
/*  In defining groups, I decided to use two bits per group with no  */
/*  pair looking like the bit pattern that is defined as valid data  */
/*  Therefore, valid groups are 11, 14, 22, 41, and 44.              */
/*********************************************************************/

#define GRP_MASK      047700000

/**************************************************************************/
/* Server data type/echo indicators
          Tell the server what kind of data is coming and whether or
          not to return a copy to the client.
*/

#define DATA_GRP      041100000     /* Remainder of word is data related */

#define DG_NO_ECHO    000000001     /* Do not echo data */
#define DG_PACK_ECHO  000000002     /* Echo data as it is read */
#define DG_GROUP_ECHO 000000004     /* Read all data and echo as a single chunk */

#define DG_DT_MASK    000003370     /* Mask for legal data block types */

#define DG_LO_DATA    000000010     /*  Data is long, ordered */
#define DG_LR_DATA    000000020     /*  Data is long, random */
#define DG_CHR_DATA   000000040     /*  Data is character */
#define DG_BP_DATA    000000100     /*  Data is long, bit pattern */

#define DG_DATA_UNK   000000200     /*  Data is unknown type */

#define DG_SAME_CHK   000001000

#define DG_END_DATA   000002000     /*  End of transmitted data */

#define GET_DATA_TYPE(_x, _y) \
   { \
              switch (_x) { \
                 case 'o': \
                            _y = DG_LO_DATA; \
                            break; \
                 case 'r': \
                            _y = DG_LR_DATA; \
                            break; \
                 case 'c': \
                            _y = DG_CHR_DATA; \
                            break; \
                 case 'b': \
                            _y = DG_BP_DATA; \
                            break; \
                 case 'u': \
                 default: \
                            _y = DG_DATA_UNK; \
                            break; \
              }; \
   }

/**************************************************************************/
/* Server commands
          Tell the server to do a one time thing, like exit or
          change transmission block size, or get a piece of info.
*/

#define CMD_GRP       042200000     /* Remainder of word is command related */
#define CMD_MASK      000000777     /* Mask for legal commands */

#define CMD_EXIT      000000001     /* Server must clean up and exit */
#define CMD_BLK_SZ    000000002     /* Server change SND/RCV block size */

#define CMD_RE_TIME   000000004     /* Send read end time to client */
#define CMD_RS_TIME   000000010     /* Send read start time to client */
#define CMD_WE_TIME   000000020     /* Send write end time to client */
#define CMD_WS_TIME   000000040     /* Send write start time to client */
#define CMD_TM_SYNC   000000100

#define CMD_RESET     000000200     /* Clean everything and reset */
#define CMD_HEXIT     000000400

/**************************************************************************/
/* Server configuration changes 
          Tell the server to modify output characteristics or how it
          does things(function characteristics).
*/

#define CNF_GRP       041400000     /* Remainder of word is config related */
#define CNF_MASK      000000077     /* Mask for legal config changes */

#define CNF_PASS      000000001     /* Toggle pass message on/off */
#define CNF_FAIL      000000002     /* Toggle fail message on/off */
#define CNF_VERBOSE   000000004     /* Toggle interim messages on/off */
#define CNF_TIMING    000000010     /* Toggle I/O timing on/off */
#define CNF_VERIFY    000000020     /* Toggle data verification */

/**************************************************************************/

/**************************************************************************/
/*  Messages
          Just send a message to another member of the group or to the 
          client or server.
*/

#define MSG_GRP       044400000     /* Remainder of word is a message code */
#define MSG_MASK      000000333     /* Mask of legal messages */

#define MSG_PASS      000000001     /* Last test item passed */
#define MSG_FAIL      000000002     /* Last test item failed */
#define MSG_DATA      000000010     /* Failure was data content related */
#define MSG_SIZE      000000020     /* Failure was data size related */
#define MSG_WHAT      000000100     /* Sender is completely lost */
                                   /*   Will probably cause a CMD_RESET */
#define MSG_EXIST     000000200     /* I exist in the group message */

#define TIMEOUT 90

#define DUPLEX 0
#define SIMPLEX 1
#define MULTICAST 2

#define GET_DATA_FLOW(_x, _y) \
   { \
              switch (_x) { \
                 case 's': \
                            _y = SIMPLEX; \
                            break; \
                 case 'm': \
                            _y = MULTICAST; \
                            break; \
                 case 'd': \
                            _y = DUPLEX; \
                            break; \
                 default: \
                            _y = SIMPLEX; \
                            break; \
              }; \
   }

#define TCP_HEADER_SZ 20
#define UDP_HEADER_SZ 8
#define IP_HEADER_SZ 20

#define ATM_HEADER 5
#define ATM_CELL_SIZE 53
#define ATM_USER_CELL_SIZE (ATM_CELL_SIZE - ATM_HEADER)

#define MAX_SEND_BYTES 409600   /*  800 Blocks @ 512  bytes per block   */
                                /*  100 Blocks @ 4096 bytes per block   */
                                /*  Specified actual size because block */
                                /*  size does vary across machines      */

struct mcast_strt {
   int md;
   int port;
   int counter;
   int creating_pid;
   uint h_inet_addr;
   char *host;
   char *dev_interface;
};

#endif
