#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "viv_goop.h"

/*
 *   file size ranges:
 *      A, 2 - 8    0 - .4
 *      B, 9 - 16   .4+ - .8
 *      C, 17 - 32  .8+ - .9
 *      D, 33 - 64  .9+ - 1.0
 *
 *   In other words, 40% of file names will be
 *   of length 8 or less.  40% will be between
 *   9 and 16 chars, 10% will be between 17
 *   and 32 chars and 10% will be greater than
 *   32 chars up to 64 chars.
 */

#define ARRAY_LEN 67.0

/*
 *   Take what we can from a work node and build
 *   a full path if it is possible.  Return what we
 *   can, or NULL if none of the path parts contained
 *   anything.
 */
char *build_full_path(struct fs_creations *wrk_node)
{
char *fullpath;
int dirlen, fillen, pthlen;

   dirlen = fillen = pthlen = 0;
   fullpath = NULL;

   if (wrk_node->node_dir != NULL)
      dirlen = strlen(wrk_node->node_dir);
   if (wrk_node->node_name != NULL)
      fillen = strlen(wrk_node->node_name);

   //
   //   If both of the above were NULL, just get out
   //   If either or both were not NULL, build a path,
   //   or what we can of one.
   //
   pthlen = dirlen + fillen;
   if (pthlen > 0) {
      //
      //  string lengths + eol + 1 for dir separator (/)
      //
      pthlen = dirlen + fillen + 1 + 1;

      fullpath = (char *)calloc(pthlen, 1);

      if (fullpath != NULL) {
         if (dirlen > 0 && fillen > 0) {
            sprintf(fullpath, "%s/%s\0", wrk_node->node_dir, wrk_node->node_name);
         } else if (dirlen > 0 && fillen == 0) {
            sprintf(fullpath, "%s\0", wrk_node->node_dir);
         } else if (dirlen == 0 && fillen > 0) {
            sprintf(fullpath, "%s\0", wrk_node->node_name);
         } else {
            fprintf(stderr, "build_full_path:  HUH?\n");
            free(fullpath);
            return(NULL);
         }
      }
   }

   return(fullpath);
}

int get_node_type(int addamt)
{
double ranger;

   ranger = drand48();
   total_cnt = total_cnt + addamt;

   if (ranger > .95) {
      //   Directory
      if (ranger > .95 && ranger <= .98) {
         drctry_cnt = drctry_cnt + addamt;
         return(DRCTRY);
      }
      //   Symbolic link
      if (ranger > .98 && ranger <= .985) {
         symlnk_cnt = symlnk_cnt + addamt;
         return(SYMLNK);
      }
      //   Hard link
      if (ranger > .985 && ranger <= .995) {
         hrdlnk_cnt = hrdlnk_cnt + addamt;
         return(HRDLNK);
      }
      //   Named pipe
      if (ranger > .995) {
         nmdpp_cnt = nmdpp_cnt + addamt;
         return(NMDPP);
      }
   }

   //   Regular file

   rfl_cnt = rfl_cnt + addamt;
   return(RFL);
}

void get_name_len_range(int *min_len, int *max_len)
{
double ranger;

   ranger = drand48();

   if (ranger >= 0.0 && ranger <= .4) {
      *min_len = 2;
      *max_len = 8;
      return;
   }
   if (ranger > .4 && ranger <= .8) {
      *min_len = 9;
      *max_len = 16;
      return;
   }
   if (ranger > .8 && ranger <= .9) {
      *min_len = 17;
      *max_len = 32;
      return;
   }
   if (ranger > .9 && ranger <= .99) {
      *min_len = 33;
      *max_len = 64;
      return;
   }
   if (ranger > .99) {
      *min_len = 65;
      *max_len = 128;
      return;
   }

   fprintf(stderr, "get_name_len_range() Error: we should not even get here\n");
   fflush(stderr);

   return;
}

int file_name_length(int ntype)
{
int pfxlen, max_len, min_len;

   if (ntype != RFL) {
      /*
       *   Even though the length is limited to 8 for a
       *   non-regular files, since there are 67 choices for each
       *   place the number of available names is 67^8.
       *   Thats 406,067,677,556,641 available names.  That
       *   is over 406 TRILLION.  I don't think I'll run
       *   out of names.
       */
      pfxlen = 8;
   } else {
      get_name_len_range(&min_len, &max_len);
      pfxlen = random_int_in_range(min_len, max_len);
   }

   return(pfxlen);
}

/*
 *   Generate a random filename of random length up to
 *   128 characters (not including the directory name).
 *   Would have use tempnam, but it does not allow for
 *   the creation of long names.
 */
char *gen_name(char *dirname, int ntype)
{
char *pfx_array;
char choice_array[] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h',
                       'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p',
                       'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
                       'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F',
                       'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N',
                       'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V',
                       'W', 'X', 'Y', 'Z', '0', '1', '2', '3',
                       '4', '5', '6', '7', '8', '9', '-', '_',
                       '+', '=', '.'};

int i, j, pfxlen, startpoint;

   pfxlen = file_name_length(ntype);

   startpoint = strlen(dirname);
   pfxlen = pfxlen + startpoint + 1;
   startpoint = startpoint + 1;

   pfx_array = (char *)calloc(pfxlen + 1, 1);
   sprintf(pfx_array, "%s/", dirname);
   pfx_array[pfxlen] = '\0';

   for (i = startpoint; i < pfxlen; i++) {
      //
      //   This is to counter some samba/cifs bull.
      //   Make sure no file/directory name ends in
      //   anything but a number or letter.
      //
      if (i >= (pfxlen - 1)) {
         j = (int)(drand48() * (ARRAY_LEN - 5));
      } else {
         j = (int)(drand48() * ARRAY_LEN);
      }
      if ( j == (int)ARRAY_LEN ) {
         j = (int)(ARRAY_LEN - 1.0);
      }
      pfx_array[i] = choice_array[j];
   }


   return(pfx_array);
}
