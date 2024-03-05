#include <stdio.h>
#include <sys/types.h>
#include <ctype.h>
#include <pwd.h>
#include <sys/param.h>
#include <sys/dir.h>
#include <sys/aoutdata.h>
#include <sys/sema.h>
#include <sys/sysmacros.h>
#ifdef STK_DCL
#include <sys/cred.h>
#endif
#include <sys/proc.h>
#include <sys/table.h>
#include <sys/ssd.h>
#include <sys/map.h>
#include <sys/category.h>
#include <errno.h>
#include <sys/unistd.h>
#include <sys/ios.h>

#include "struct_tog.h"

struct map tog_map_data(maptype)
char *maptype;
{
struct map maphdr;
struct tbs tabinfo_table;
int retval, map_size, map_offset;
waddr_t map_base;


   retval = tabinfo(maptype, &tabinfo_table);

   if (retval == -1) {
      maphdr.bmp_avail = 0;
      return(maphdr);
   }

   if (tabinfo_table.len != sizeof(struct map)) {
      fprintf(stderr, "blah: map table size mismatch! \
system/%d, map.h/%d\n", tabinfo_table.len, sizeof(struct map));
      maphdr.bmp_avail = 0;
      return(maphdr);
   }

   map_size = tabinfo_table.ent * tabinfo_table.len;
   map_offset = tabinfo_table.head;
   map_base = (waddr_t)tabinfo_table.addr;

   retval = tabread(maptype, (char *)&maphdr, map_size, map_offset);

   if (retval == -1) {
      maphdr.bmp_avail = 0;
      return(maphdr);
   }

   return(maphdr);
}

struct ldctype_t *sds_data(goofy)
struct ldctype_t *goofy;
{
struct map sdsmap;

   sprintf(goofy->cache_type, "SSD\0");
   sdsmap = tog_map_data(SMAP);
   goofy->max_num = sdsmap.bmp_total * SDS_WGHT;
   goofy->num_avail = sdsmap.bmp_avail * SDS_WGHT;

   return(goofy);
}

struct ldctype_t *mem_data(goofy)
struct ldctype_t *goofy;
{
struct map sdsmap;

   sprintf(goofy->cache_type, "MEM\0");
   sdsmap = tog_map_data("ldch_coremap");
   goofy->max_num = sdsmap.bmp_total * MEMKLIK;
   goofy->num_avail = sdsmap.bmp_avail * MEMKLIK;

   return(goofy);
}
struct ldctype_t *bmr_data(goofy)
struct ldctype_t *goofy;
{
struct map sdsmap;

   sprintf(goofy->cache_type, "BMR\0");
   if (sysconf(_SC_CRAY_IOS) == IOS_MODEL_D) {
      sdsmap = tog_map_data("bmrmap");
      goofy->max_num = sdsmap.bmp_total;
      goofy->num_avail = sdsmap.bmp_avail;
   }
   else {
      goofy->max_num = 0;
      goofy->num_avail = 0;
   }

   return(goofy);
}

/***********************************************************/
/*   main() is only here to be used to test the routines
     above in a standalone fashion.
*/
/*
main()
{
struct ldctype_t goofy[3];

   sds_data(&goofy[0]);
   mem_data(&goofy[1]);
   bmr_data(&goofy[2]);

   printf("type  %s     max  %d   avail   %d\n", goofy[0].cache_type,
           goofy[0].max_num, goofy[0].num_avail);
   printf("type  %s     max  %d   avail   %d\n", goofy[1].cache_type,
           goofy[1].max_num, goofy[1].num_avail);
   printf("type  %s     max  %d   avail   %d\n", goofy[2].cache_type,
           goofy[2].max_num, goofy[2].num_avail);

}
*/
