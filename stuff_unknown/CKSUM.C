#include "test_struct.h"
#include "test_clnt_srv.h"

/****************************************************/
/*   CKSUM

    A bastardized version of IP checksum.  Works 
    because I am only checksumming individual portions
    of data.
*/
unsigned short cksum(buf, len)
void *buf;
int len;
{
word sum = 0;
unsigned short goofy;

   while (len > 1) {
      sum += *((unsigned short *) buf)++;
      if (sum & 0x80000000)
         sum = (sum & 0xffff) + (sum >> 16);
      len -= 2;
   }

   if (len) {
      goofy = (unsigned short)(*(unsigned char *)buf);
#if defined(__alpha)
      goofy = goofy << 8;
#endif
      sum += goofy;
   }

   while (sum >> 16)
      sum = (sum & 0xffff) + (sum >> 16);

   return(~sum);
}
