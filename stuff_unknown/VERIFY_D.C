#include <stdio.h>
#include "test_clnt_srv.h"
#include "test.h"

/*****************************************************/
/*   Flags used by the networking functions
*/
int do_verify = 0;
int pass_msg = 0;
int fail_msg = 1;
int verbose = 0;

/**************************************************************/
/*  VERIFY_DATA_SH

    Compare to memory areas(buffers) of a given size and print
    whether they are alike or not.

    PARAMETER:
       buffer:    one of the buffers to compare
       buffer2:   the other buffer to compare
       buff_size: the amount of the buffers we are interested in
                  or the size of the data.

    RETURN
       Returns the value of memcmp()
*/
int verify_data_sh(buffer, buffer2, buff_size)
char *buffer, *buffer2;
word buff_size;
{
int cmp_value, i;

   if ((cmp_value = memcmp(buffer, buffer2, buff_size)) != 0) {
      if (fail_msg)
         fprintf(stderr, "%d:  Transfered data is NOT correct\n", buff_size);
   }
   else {
      if (pass_msg)
         fprintf(stderr, "%d:  Transfered data is correct\n", buff_size);
   }
   return(cmp_value);
}

/*************************************************************/
/*  VERIFY_CHR_DATA

    This routine is only useful if the initial data was created
    using the create_chr_data() function.  This function will use
    that same routine to create a copy of the data and then compare
    the two pieces of data.  The originating  processes pid is part
    of the data.  That is why it is passed in here.  The pid was made
    part of the data so that if data from one client goes to the wrong
    place, it would be noticed.

    PARAMETER:
       buffer:     buffer to be verified
       buff_size:  size of the data
       pid:        process id of the process which originated buffer

    RETURN:
       Returns 0 if data is correct, otherwise non-zero.
*/
int verify_chr_data(buffer, buff_size, pid)
char *buffer;
word buff_size, pid;
{
char *comp_buffer, *create_chr_data();
int vvalue;

   comp_buffer = create_chr_data(buff_size, pid);
   vvalue = verify_data_sh(buffer, comp_buffer, buff_size);
   clear_data_amt();
   free(comp_buffer);
   return(vvalue);
}

int verify_word_data(buffer, buff_size)
word *buffer;
int buff_size;
{
int count, badbuffer;
word i;

   badbuffer = 0;
 
   count = buff_size / BYTESINWORD;

   for (i = 0; i < count; i++) {
      if (*buffer != i) {
         badbuffer = 1;
         if (fail_msg)
            if (verbose)
               fprintf(stderr, "%d::  bad element  %d\n", i, *buffer);
      }
      buffer++;
   }
   if (badbuffer) {
      if (fail_msg)
         fprintf(stderr, "Bad word buffer\n");
   }
   else {
      if (pass_msg)
         fprintf(stderr, "Good word buffer\n");
   }

   return(badbuffer);
}

int verify_bit_pattern(buffer, buff_size)
word *buffer;
int buff_size;
{
word *buffer2, *bit_pattern();
int vvalue;

   buffer2 = bit_pattern(&buff_size);
   vvalue = verify_data_sh(buffer, buffer2, buff_size);
   free(buffer2);
   return(vvalue);
}

int verify_oo_word_data(buffer, buff_size)
word *buffer;
int buff_size;
{
word *buffer2;
int i, vvalue, numwords;

   numwords = (buff_size + (BYTESINWORD - 1)) / BYTESINWORD;
   buff_size = numwords * BYTESINWORD;
   buffer2 = (word *)malloc(sizeof(word) * numwords);

   for (i = 0; i < numwords; i++) {
      if (buffer[i] < numwords)
         buffer2[buffer[i]] = buffer[i];
   }

   vvalue = verify_word_data(buffer2, buff_size);
#ifdef DEBUG
   if (vvalue) {
      if (buff_size <= 2048) {
         for (i = 0; i < (buff_size / BYTESINWORD); i++)
            fprintf(stderr, "%d:: Orig:  %d --- Copy:  %d --- Buffer2:  %d\n",
              i, buffer[i], buffer2[buffer[i]], buffer2[i]);
      }
   }
#endif
   free(buffer2);
   return(vvalue);
}

int verify_size(buff_size, received)
word buff_size, received;
{
int vvalue = 0;

   if (verbose) {
      fprintf(stderr, "%d bytes received\n", received);
      fprintf(stderr, "%d bytes expected\n", buff_size);
   }
   if (buff_size != received) {
      vvalue = 1;
      if (fail_msg)
         fprintf(stderr, "%d:  Received amount != Transmitted amount\n", buff_size);
   }
   else {
      if (pass_msg)
         fprintf(stderr, "%d:  Received amount = Transmitted amount\n", buff_size);
   }
   return(vvalue);
}

int verify_data(buffer, payload_type, buff_size, pid, received)
char *buffer;
word payload_type, buff_size, pid;
int received;
{
int vvalue = 0;

   switch (payload_type & DG_DT_MASK) {
      case DG_CHR_DATA:
              if (verbose)
                 fprintf(stderr, "Data type = CHARACTER\n");
              vvalue += verify_chr_data(buffer, buff_size, pid);
              break;

      case DG_LO_DATA:
              if (verbose)
                 fprintf(stderr, "Data type = LONG, ORDERED\n");
              vvalue += verify_word_data(buffer, buff_size);
              break;

      case DG_LR_DATA:
              if (verbose)
                 fprintf(stderr, "Data type = LONG, RANDOM\n");
              vvalue += verify_oo_word_data(buffer, buff_size);
              break;

      case DG_BP_DATA:
              if (verbose)
                 fprintf(stderr, "Data type = LONG, BIT PATTERN\n");
              vvalue += verify_bit_pattern(buffer, buff_size);
              break;

      default:
              if (verbose)
                 fprintf(stderr, "Data type = UNKNOWN\n");
              break;
   }

   return(vvalue);
}
