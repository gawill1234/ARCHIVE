#include <stdio.h>
#include <sys/types.h>
#include <sys/param.h>
#include <sys/stat.h>
#include <sys/ldesc.h>

#if RELEASE_LEVEL > 7050
#include <sys/pddtypes.h>
#else
#include <sys/pdd.h>
#endif

#include <sys/pddprof.h>
#include <sys/sysmacros.h>
#include <sys/ddstat.h>

#include "struct_tog.h"

/*********************************************/
/*  Create and initialize a node which will hold
    data for individual partitions of a
    logical device.

    This is only the data needed to generate a mkfs.
*/
struct partition_desc *get_new_node()
{
struct partition_desc *newnode;

   newnode = (struct partition_desc *)malloc(sizeof(struct partition_desc));
   newnode->next = NULL;
   newnode->part_no = 0;
   newnode->part_size = 0;
   newnode->part_actual_size = 0;
   newnode->part_min_aau = 0;
   return(newnode);
}

int getparts(logical_device_name, ld_list)
char *logical_device_name;
struct ldclist_t *ld_list;
{
int ctr, ctr2, vol_size_check2, nparts;
struct ddstat dp[64];
struct partition_desc *use_node, *get_new_node();


   ld_list->nslices = nparts = vol_size_check2 = 0;

   ld_list->nslices = ddstat(logical_device_name, dp, 64, 0);
#ifdef DEBUG
   printf("NSLICES:  %d\n", ld_list->nslices);
#endif

   for (ctr = 0; ctr < ld_list->nslices; ctr++) {

#ifdef DEBUG
      printf("%s   %d   %d\n",
             dp[ctr].d_path, dp[ctr].d_nest, dp[ctr].d_nslices);
#endif

      if (dp[ctr].d_nest == 1) {

         if (ld_list->partition == NULL) {
            ld_list->partition = get_new_node();
            use_node = ld_list->partition;
         }
         else {
            use_node->next = get_new_node();
            use_node = use_node->next;
         }

         nparts++;
         use_node->part_no = nparts;
         vol_size_check2 = vol_size_check2 + dp[ctr].d_llen;
         use_node->part_size = dp[ctr].d_llen;
         use_node->part_actual_size = dp[ctr].d_llen;

         ctr2 = ctr;
         do {

            if (dp[ctr2].d_iou > use_node->part_min_aau)
               use_node->part_min_aau = dp[ctr2].d_iou;

         } while (dp[++ctr2].d_nest > 1);

      }
   }

   ld_list->vol_size = vol_size_check2;

   return(0);
}
/**********************************************************/
/*  Main used as driver to test above routines.  
    Commented out.
*/
main()
{
struct ldclist_t ldlist;
struct partition_desc *grok;

   getparts("/dev/dsk/tmp_hippi_trm", &ldlist);

   printf("nslices:    %d       volume size:   %d\n",
           ldlist.nslices, ldlist.vol_size);

   grok = ldlist.partition;
   while (grok != NULL) {
      printf("partion:   #:  %d   size:  %d   aau:  %d\n",
              grok->part_no, grok->part_size, grok->part_min_aau);
      grok = grok->next;
   }
}
