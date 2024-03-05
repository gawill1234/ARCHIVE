/*********************************************************/
/*
  rndmkfs:
             written by Gary Williams
             see routine explain_tool() for usage
  
  Original purpose of this tool was to generate a random but valid
  mkfs command line from the data returned from ddstat about a
  logical device.  The tool will subsequently fsck, mount, and chmod
  the file system if the mkfs succeeds.  

  If desired, the tool will destroy the magic number of the created
  file system.
*/
#include <stdio.h>
#include <ctype.h>
#include <fcntl.h>
#include <sys/unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/param.h>
#include <sys/map.h>
#if RELEASE_LEVEL >= 8000
#include <sys/vnode.h>
#include <sys/vfs.h>
#else
#include <sys/inode.h>
#endif
#include <sys/fs/nc1ino.h>
#include <sys/fs/nc1inode.h>
#include <sys/fs/nc1filsys.h>
#include <sys/secparm.h>
#include <sys/ldesc.h>
#if RELEASE_LEVEL > 7050
#include <sys/fs/sfsblock.h>
#include <sys/pddtypes.h>
#else
#include <sys/pdd.h>
#endif

#include <sys/pddprof.h>
#include <sys/sysmacros.h>
#include <sys/ddstat.h>

#define PRIMARY_MAX 16                /* -P argument max */
                                      /*    Defined by mkfs itself */
#define SECONDARY_MAX 32              /* -S argument max */
#define MAX_I_FACTOR 10               /* -i argument max */
#define MAX_INODE_MULT 2              /* -I argument FS_BLOCK multiplier */
                                      /*    creates maximum number of  */
                                      /*    inodes allowed. */
                                      /*    Number of blocks in file system */
                                      /*    times (*) MAX_INODE_MULT */
#define MIN_INODE_DIV 10              /* -I argument FS_BLOCK divisor */
                                      /*    creates minimum number of  */
                                      /*    inodes allowed.  */
                                      /*    Number of blocks in file system */
                                      /*    divided by (/) MIN_INODE_DIV  */
#define MAX_BIGFILE_ALLOC_UNIT 32     /* -A argument max */
#define MIN_FS_SIZE_BLOCKS 10000      /* -n argument min */

struct partition_desc {
   int part_no;
   int part_size;
   int part_actual_size;
   int part_min_aau;
   struct partition_desc *next;
};

/*********************************************************/
/*  Since all of the parts for the mkfs command line
    (or at least several of them) would get passed around
    and modified so much, it seemed easier to just make them
    global to the program.  Usage of the variables is
    generally very similar from option to option (with
    a couple of exceptions).  dash_(whatever) is a flag
    which indicates whether or not the (whatever) option
    will be used.  The other variables represent the argument
    values for the options.  Those names are fairly self
    explanatory.  If you have some familiarity with the mkfs
    command, getting through this should be pretty straight
    forward.
*/
char strat_table[3][5] = {"rrf\0", "rrd1\0", "rrda\0"};

int part_common_modulo_primary;
int part_common_modulo_secondary;

int nparts, dash_em, use_strategy, quick_mode;
int num_primary, num_secondary;
int dash_i, dash_I, i_factor, num_inodes;
int total_space_avail, max_fs_size;
int big_file_thresh_hold, big_file_alloc_unit;
int dash_d, dash_A, dash_B, dash_n, dash_s;
int dash_P, dash_S, dash_p, dash_a;

/*********************************************************/

double drand48();
void srand48();

main(argc, argv)
char **argv;
int argc;
{
char msg[256], *logical_device_name, *mkfsline, *mount_point;
struct nc1filsys *fptr, *get_nc1_super_blocks();
struct partition_desc *getparts();
struct partition_desc *headnode = NULL;
int error, genonly, fsckflag, trashit, c, fs_init, q_for_me;
char *gen_mkfs();

extern char *optarg;
extern int optind;

static char *optstring = "im:sftnq";

   srand48(time((long *)0));
   mount_point = NULL;
   fs_init = genonly = fsckflag = trashit = dash_s = q_for_me = 0;

   if (argc < 2) {
      fprintf(stderr, "Not enough arguments\n");
      explain_tool();
      exit(1);
   }
   if (argc > 8) {
      fprintf(stderr, "To many arguments\n");
      explain_tool();
      exit(1);
   }

   while ((c=getopt(argc, argv, optstring)) != EOF) {

      switch (c) {
         case 'i':
                   fs_init = 1;
                   break;
         case 'n':
                   genonly = 1;
                   break;
         case 'f':
                   fsckflag = 1;
                   break;
         case 't':
                   trashit = 1;
                   break;
         case 'm':
                   mount_point = optarg;
                   break;
         case 'q':
                   q_for_me = 1;
                   break;
         case 's':
                   /****************************/
                   /*  mkfs  -s option
                   */
                   dash_s = 1;
                   break;
                   /****************************/
         default:
                   explain_tool();
                   exit(1);
                   break;
      }

   }


   error = 0;
   logical_device_name = argv[argc - 1];
#ifdef DEBUG
   printf("DEVICE:  %s\n", logical_device_name);
   fflush(stdout);
#endif
   
   /************************************************/
   /*  If the logical_device_name does not exist,
       there is no point in continueing.
   */

   if (access(logical_device_name, 00) != 0) {
      fprintf(stderr, "%s does not exist\n", logical_device_name);
      exit(1);
   }
   /************************************************/

   if (dash_s == 1)
      sprintf(msg, "mkfs -q -s %s\0", logical_device_name);
   else
      sprintf(msg, "mkfs -q %s\0", logical_device_name);

   if (fs_init == 1) {
#ifdef DEBUG
      printf("Initialize FS:  %s\n", msg);
#else
      error = system(msg);
#endif

      if (error != 0) {
         printf("Initial mkfs failed.  Exiting.\n");
         exit(1);
      }
   }

   if (q_for_me == 0) {
      fptr = get_nc1_super_blocks(logical_device_name);

      headnode = getparts(fptr, headnode, logical_device_name);
 
      /********************************/
      /*  mkfs  -n and -m options 
      */
      determine_fs_size(headnode);
      /********************************/

      /********************************/
      /*  mkfs  -p, -P, -S options  
      */
      do_partition_stuff(headnode);
      /********************************/

      /********************************/
      /*  mkfs  -q and -Q options  
      */
      select_mode();
      /********************************/

      /********************************/
      /*  mkfs  -a option  
      */
      select_strategy();
      /********************************/

      /********************************/
      /*  mkfs  -i and -I options  
      */
      do_inode_stuff();
      /********************************/

      /********************************/
      /*  mkfs  -d option  
      */
      maybe_lost_found();
      /********************************/

      /********************************/
      /*  mkfs  -A and -B options  
      */
      change_big_file(headnode);
      /********************************/

      mkfsline = gen_mkfs(headnode, logical_device_name);
   }
   else {
      mkfsline = &msg[0];
   }
   printf("%s\n", mkfsline);

   if (genonly == 0)
      error = do_mkfs(mkfsline);

   if (error == 0)
      if ((fsckflag == 0) && (genonly == 0))
         error = do_fsck(logical_device_name);

   if (error == 0) {
      if ((mount_point != NULL) && (fsckflag == 0) && (genonly == 0)) {
         error = do_mount(logical_device_name, mount_point);
         if (error == 0)
            do_chmod(mount_point);
      }
   }
  
   if (error = 0)
      if ((mount_point != NULL) && (fsckflag == 0) && (genonly == 0))
         if (trashit == 1)
            trash_fs_control(mount_point, logical_device_name);

}
int do_mkfs(mkfsline)
char *mkfsline;
{
int error;

#ifdef DEBUG
   printf("DO IT:  %s\n", mkfsline);
   return(0);
#else
   error = system(mkfsline);

   if (error != 0)
      fprintf(stderr, "mkfs failed\n");

   return(error);
#endif
}

int do_fsck(logical_device_name)
char *logical_device_name;
{
char msg[256];
int error;

   sprintf(msg, "/etc/fsck -y -c %s\0", logical_device_name);
#ifdef DEBUG
   printf("%s\n", msg);
   return(0);
#else
   error = system(msg);

   if (error != 0)
      fprintf(stderr, "fsck failed\n");

   return(error);
#endif
}

int do_mount(logical_device_name, mount_point)
char *logical_device_name, *mount_point;
{
char msg[256];
int error;

   sprintf(msg, "/etc/mount %s %s\0", logical_device_name, mount_point);
#ifdef DEBUG
   printf("%s\n", msg);
   return(0);
#else
   if (access(mount_point, 00) != 0) {
      if (mkdir(mount_point, 0777) != 0) {
         fprintf(stderr, "%s does not exist\n", mount_point);
         return(1);
      }
   }
   error = system(msg);

   if (error != 0)
      fprintf(stderr, "mount failed\n");

   return(error);
#endif
}

int do_chmod(mount_point)
char *mount_point;
{
char msg[256];
int error;

   sprintf(msg, "chmod 777 %s\0", mount_point);
#ifdef DEBUG
   printf("%s\n", msg);
   return(0);
#else
   error = system(msg);

   if (error != 0)
      fprintf(stderr, "chmod failed\n");

   return(error);
#endif
}

int trash_fs_control(mount_point, logical_device_name)
char *mount_point, *logical_device_name;
{
   printf("Will trash file system\n");
}

/****************************************************/
/*  The usage crap is so long, I made it its own
    function.
*/
int explain_tool()
{
   fprintf(stderr, "Usage:   rndmkfs [-i] [-n] [-f] [-s] [-t]");
   fprintf(stderr, " [-m mount_point] logical_device_name\n");
   fprintf(stderr, "         Example:  rndmkfs /dev/dsk/qtest1\n");
   fprintf(stderr, "\n");
   fprintf(stderr, "   -i    initialize FS before setting up mkfs\n");
   fprintf(stderr, "         so there is a super block to do data checking\n");
   fprintf(stderr, "   -n    do not do anything, just generate a mkfs\n");
   fprintf(stderr, "         implies no fsck or mount of FS\n");
   fprintf(stderr, "   -f    do not fsck\n");
   fprintf(stderr, "         implies no mount of FS\n");
   fprintf(stderr, "   -s    FS will be shared\n");
   fprintf(stderr, "   -t    trash FS after creating it\n");
   fprintf(stderr, "   -m mount_point\n");
   fprintf(stderr, "         a directory to mount the created FS on\n");
   fprintf(stderr, "         if none specified, no mount is performed\n");
   fprintf(stderr, "   logical_device_name\n");
   fprintf(stderr, "         the result of mknod(s).  Self explanatory\n");
   fprintf(stderr, "\n");
   fprintf(stderr, "This tool creates randomly generated valid mkfs\n");
   fprintf(stderr, "commands.  At this time the security options are not\n");
   fprintf(stderr, "addressed.\n");
   fprintf(stderr, "\n");
   fprintf(stderr, "OPTION                   Max value generated\n");
   fprintf(stderr, "------                   -------------------\n");
   fprintf(stderr, " -p                      number of partitions\n");
   fprintf(stderr, " -P                      %d\n", PRIMARY_MAX);
   fprintf(stderr, " -S                      %d\n", SECONDARY_MAX);
   fprintf(stderr, " -i                      %d\n", MAX_I_FACTOR);
   fprintf(stderr, " -I                      Number of blocks * %d\n",
           MAX_INODE_MULT);
   fprintf(stderr, " -a                      rrf, rrd1, rrda\n");
   fprintf(stderr, " -A                      %d\n",MAX_BIGFILE_ALLOC_UNIT);
   fprintf(stderr, " -B                      size of file system\n");
   fprintf(stderr, " -n                      total of all partition sizes\n");
   fprintf(stderr, " -m\n");
   fprintf(stderr, " -q\n");
   fprintf(stderr, " -Q\n");
   fprintf(stderr, "\n");
   fprintf(stderr, "After the mkfs the tool performs the following:\n");
   fprintf(stderr, "    /etc/fsck -y -c logical_device_name\n");

}
/**********************************************/
/*  Choose (or not) to use the -A and -B options to
    mkfs.  If one or both are chosen, get valid arguments
    to each of them.
*/
int change_big_file(headnode)
struct partition_desc *headnode;
{
int random, i;

   dash_A = dash_B = 0;

   if ((int)(drand48() * (double)100.0) > 60)
      dash_A = 1;

   if ((int)(drand48() * (double)100.0) > 60)
      dash_B = 1;

   if (dash_B == 1) {
      random = (int)(drand48() * (double)100.0);
      if (random < 90)
         big_file_thresh_hold =
                 (int)(drand48() * (double)(max_fs_size * 4096));
      else
         big_file_thresh_hold = BIGFILE;
   }

   if (dash_A == 1) {
      random = (int)(drand48() * (double)100.0);
      if (random < 90) {

         for (i = 0; i < random; i++) {
            if (big_file_alloc_unit >= MAX_BIGFILE_ALLOC_UNIT)
               big_file_alloc_unit = headnode->part_min_aau;
            else
               big_file_alloc_unit++;
         }

         while ((big_file_alloc_unit % part_common_modulo_primary) != 0)
            big_file_alloc_unit++;
      }
      else {
         big_file_alloc_unit = part_common_modulo_primary;
      }
   }
}

/*************************************************/
/*  Use -d or not.  -d specifies no lost+found to be
    created.
*/
int maybe_lost_found()
{
int random;

   dash_d = 1;
   if ((int)(drand48() * (double)100.0) > 75)
      dash_d = 0;
}

/******************************************************/
/*  Randomly choose a size for the file system other than the
    whole available space.  Once a size is chosen, modify
    the number of partitions which will be utilized (nparts)
    for later use in this program.

    If -m is part of the command line nparts (# of partitions)
    automatically becomes 1.
*/
int determine_fs_size(headnode)
struct partition_desc *headnode;
{
int random, tmpsize;
struct partition_desc *tracit;

   dash_n = 0;

   use_dash_em(headnode);

   if ((int)(drand48() * (double)100.0) > 60)
      dash_n = 1;

   if (dash_n == 1) {
      if ((int)(drand48() * (double)100.0) > 80) {

         if (max_fs_size > MIN_FS_SIZE_BLOCKS) {
            max_fs_size =
              (int)(drand48()*(double)(total_space_avail - MIN_FS_SIZE_BLOCKS));
            max_fs_size = max_fs_size + MIN_FS_SIZE_BLOCKS;
         }

         while ((max_fs_size % headnode->part_min_aau) != 0)
            max_fs_size++;

         if (max_fs_size > total_space_avail)
            max_fs_size = total_space_avail;

      }

      if (nparts > 1) {
         tmpsize = nparts = 0;
         tracit = headnode;
         while (tracit != NULL) {
            if (tmpsize <= max_fs_size)
               nparts++;

            tmpsize = tmpsize + tracit->part_size;

            if (tmpsize > max_fs_size) {
               tmpsize = tmpsize - max_fs_size;
               tracit->part_size = tracit->part_size - tmpsize;
               tracit = NULL;
            }
            else {
               tracit = tracit->next;
            }
         }
      }
   }
}

/***************************************************/
/*  Choose (or not) to use -i or (and) -I.  If either or
    both are chosen, get valid arguments to each of them.
    -I will override -i even if both are present on the
    mkfs command line.
*/
int do_inode_stuff()
{
int random, max_allowed_inodes, min_allowed_inodes, i;

   i_factor = num_inodes = dash_i = dash_I = 0;

   random = (int)(drand48() * (double)100.0);
   if (random < 60) {
      if (random > 50) {
         dash_i = 1;
         dash_I = 1;
      }
      else if (random > 25) {
         dash_i = 1;
      }
      else {
         dash_I = 1;
      }
   }

   if (dash_i == 1) {
      i_factor = (int)(drand48() * (double)MAX_I_FACTOR);
      if (i_factor == 0)
         i_factor = 1;
   }

   if (dash_I == 1) {

      max_allowed_inodes = max_fs_size * MAX_INODE_MULT;
      min_allowed_inodes = max_fs_size / MIN_INODE_DIV;

      random = (int)(drand48() * (double)(max_allowed_inodes * 10.0));
      for (i = 0; i < random; i++) {
         if (num_inodes >= max_allowed_inodes)
            num_inodes = min_allowed_inodes;
         else
            num_inodes++;
      }
   }
      
}

int do_partition_stuff(headnode)
struct partition_desc *headnode;
{
int i;
struct partition_desc *tracit;

   dash_P = dash_S = dash_p = 0;

   select_num_prim_sec();

   part_common_modulo_primary = headnode->part_min_aau;

   tracit = headnode;
   for (i = 0; i < num_primary; i++)
      tracit = tracit->next;
   part_common_modulo_secondary = tracit->part_min_aau;

   if ((int)(drand48() * (double)100.0) < 90) {

      dash_P = 1;

      if ((int)(drand48() * (double)100.0) < 70) {
         part_common_modulo_primary = 
              get_common_mod(headnode, num_primary, PRIMARY_MAX);
      }
   }

   if (num_secondary >= 1) {

      if ((int)(drand48() * (double)100.0) < 90) {

         dash_S = 1;

         if ((int)(drand48() * (double)100.0) < 70) {
            part_common_modulo_secondary = 
                 get_common_mod(tracit, num_secondary, SECONDARY_MAX);
         }
      }
   }
}

int get_common_mod(localnode, number, maxx)
struct partition_desc *localnode;
int number, maxx;
{
struct partition_desc *tracit;
int i, ret_modulo, random, gotmodflag;

   gotmodflag = ret_modulo = i = 0;

   random = (int)(drand48() * (double)100.0);

   for (i = 0; i < random; i++) {
      if (ret_modulo >= maxx)
         ret_modulo = localnode->part_min_aau;
      else
         ret_modulo++;
   }

   if (ret_modulo == 0)
      ret_modulo = localnode->part_min_aau;

   while (gotmodflag != 1) {
      tracit = localnode;
      for (i = 0; i < number; i++) {

         while ((ret_modulo % localnode->part_min_aau) != 0)
            ret_modulo++;

         while ((tracit->part_size % ret_modulo) != 0)
            ret_modulo++;

         if (ret_modulo > maxx)
             ret_modulo = localnode->part_min_aau;

         if ((ret_modulo % localnode->part_min_aau) != 0)
            ret_modulo = localnode->part_min_aau;

         tracit = tracit->next;
      }

      gotmodflag = 1;
      tracit = localnode;
      for (i = 0; i < number; i++) {
         if ((tracit->part_size % ret_modulo) != 0)
            gotmodflag = 0;
         tracit = tracit->next;
      }
   }

   return(ret_modulo);
}

/*************************************************/
/*  Should we use -m option.  If so, adjust
    the total space, max file system size, number
    of partitions to reflect only one partition available.
*/
int use_dash_em(headnode)
struct partition_desc *headnode;
{
  dash_em = 0;

  if (((int)(drand48() * (double)100.0)) > 90) {
     nparts = 1;
     dash_em = 1;
#if RELEASE_LEVEL < 8000
     max_fs_size = total_space_avail = headnode->part_size;
#endif
  }
}

/*************************************************/
/*  Should we use -p option.  If so, num_primary must
    be at least 1, to reflect that there must always be
    at least one primary partition.  After setting
    the number of primaries, set the rest to be secondaries.
*/
int select_num_prim_sec()
{
int random;

   num_primary = nparts;
   num_secondary = 0;

   if (nparts > 1) {

      if ((int)(drand48() * (double)100.0) > 50)
         dash_p = 1;

      if (dash_p == 1) {
         if ((int)(drand48() * (double)100.0) < 90) {
            num_primary = (int)(drand48() * (double)nparts);
            if (num_primary < 1)
               num_primary = 1;
            num_secondary = nparts - num_primary;
         }
      }
   }
}

/*************************************************/
/*  Select an allocation strategy.  They are listed
    in the strat_table.  This routine picks a number
    to access that table.  If the number is greater
    than 2, this program will use mkfs default.
*/
int select_strategy()
{
int random;

   random = (int)(drand48() * (double)100.0);
   if (random > 75) {
      use_strategy = 0;
   }
   else {
      use_strategy = (int)(drand48() * (double)3.3);
   }
}

/*************************************************/
/*  Quick mode?  With zeroing?  Default?
    0 is -q.  1 is -Q.  Anything else is default.
*/
int select_mode()
{
int random;

   random = (int)(drand48() * (double)100.0);
   if (random > 75) {
      quick_mode = 0;
   }
   else {
      quick_mode = (int)(drand48() * (double)2.3);
   }
}

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

struct partition_desc *getparts(fptr, headnode, logical_device_name)
struct nc1filsys *fptr;
struct partition_desc *headnode;
char *logical_device_name;
{
int ctr, ctr2, vol_size_check2, nslices;
struct partition_desc *get_new_node(), *use_node;
struct ddstat dp[64];


   nslices = nparts = vol_size_check2 = 0;

   nslices = ddstat(logical_device_name, dp, 64, 0);
#ifdef DEBUG
   printf("NSLICES:  %d\n", nslices);
#endif

   for (ctr = 0; ctr < nslices; ctr++) {

#ifdef DEBUG
      printf("%s   %d   %d\n",
             dp[ctr].d_path, dp[ctr].d_nest, dp[ctr].d_nslices);
#endif

      if (dp[ctr].d_nest == 1) {

         if (headnode == NULL) {
            headnode = get_new_node();
            use_node = headnode;
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

   max_fs_size = total_space_avail = vol_size_check2;

   if (fptr != NULL)
      check_stuff(fptr, nparts, vol_size_check2);

   return(headnode);
}

/***************************************************/
/*  Compare data from a super-block to the data
    obtained using ddstat and to data from individual
    partitions within a super-block.  Make sure the stuff
    matches.  Issue a WARNING if they do not.  This routine
    will NOT cause the program to terminate.  If no super-block
    is available to read data from, this routine is not called.
*/
int check_stuff(fptr, nparts, vol_size_check2)
struct nc1filsys *fptr;
int nparts, vol_size_check2;
{
int ctr, vol_size_check;

   ctr = vol_size_check = 0;

   for (ctr=0; ctr < fptr->s_npart; ctr++) {
      vol_size_check = vol_size_check + fptr->s_part[ctr].fd_nblk;
   }

   if ((vol_size_check != fptr->s_fsize) &&
       (vol_size_check2 != fptr->s_fsize)) {
      fprintf(stderr,
       "WARNING: Sum of the parts do not add up, expected %d -- actual %d %d\n",
          fptr->s_fsize, vol_size_check, vol_size_check2);
   }

   if (nparts != fptr->s_npart) {
      fprintf(stderr,
         "WARNING: Partition number mismatch, expected %d -- actual %d\n",
          fptr->s_npart, nparts);
   }
}
/*********************************************************/
/*
* This routine will access the super-block(s) within an improved inode file
* system which is available on all non-Cray2 environments.
*/
struct nc1filsys *get_nc1_super_blocks(logical_device_name)
char *logical_device_name;
{
int device_offset, start_block;
int fd;
off_t offset;
static struct nc1filsys nc1sblks[NC1NSUPER];

   /* Seek to offset */

   if ((fd = open(logical_device_name, O_RDONLY)) == -1) {
      perror("Could not open logical device");
      exit(1);
   }

   offset = BSIZE;
   device_offset = offset;

   if (lseek(fd, offset, SEEK_SET) == -1 ) {
      perror("Could not seek on logical device");
      close(fd);
      return (NULL);
   }

   if (read(fd, nc1sblks, sizeof(nc1sblks)) != sizeof(nc1sblks)) {
      perror("Could not read Super-block");
      close(fd);
      return (NULL);
   }

   close(fd);

   if (nc1sblks[0].s_magic == FsMAGIC_NC1) {
      return((struct nc1filsys *)nc1sblks);
   }
#if RELEASE_LEVEL > 7050
   else if (nc1sblks[0].s_magic == SFSMAGIC) {
      return((struct nc1filsys *)nc1sblks);
   }
#endif
   else {
      return (NULL);
   }
}
/***************************************************/
/*  Take the acquired option data and create the mkfs
    command line.
*/
char *gen_mkfs(headnode, logical_device_name)
struct partition_desc *headnode;
char *logical_device_name;
{
char *msg;

   msg = (char *)malloc(256);

#ifdef DEBUG
   while (headnode != NULL) {
      printf("%d is partition number\n", headnode->part_no);
      printf("%d is partition space\n", headnode->part_size);
      printf("%d is minimum partition size\n", headnode->part_min_aau);
      headnode = headnode->next;
   }
#endif

   sprintf(msg, "/etc/mkfs\0");

   if (dash_p == 1) {
#ifdef DEBUG
      printf("CHANGE PRIMARY/SECONDARY\n");
#endif
      sprintf(msg, "%s -p %d\0", msg, num_primary);
   }

   if (dash_P == 1) {
#ifdef DEBUG
      printf("PRIMARY:    %d    HOW MANY:  %d\n",
         part_common_modulo_primary, num_primary);
#endif
      sprintf(msg, "%s -P %d\0", msg, part_common_modulo_primary);
   }

   if (dash_S == 1) {
#ifdef DEBUG
      printf("SECONDARY:  %d    HOW MANY:  %d\n",
         part_common_modulo_secondary, num_secondary);
#endif
      sprintf(msg, "%s -S %d\0", msg, part_common_modulo_secondary);
   }

   if (dash_em == 1) {
#ifdef DEBUG
      printf("-m will be used\n");
#endif
      sprintf(msg, "%s -m\0", msg);
   }

   if (use_strategy < 3) {
#ifdef DEBUG
      printf("STRATEGY:  %s\n", strat_table[use_strategy]);
#endif
      sprintf(msg, "%s -a %s\0", msg, strat_table[use_strategy]);
   }
#ifdef DEBUG
   else {
      printf("STRATEGY:  default\n");
   }
#endif

#ifdef DEBUG
   printf("QUICK MODE:  ");
#endif
   switch (quick_mode) {
      case 0:
#ifdef DEBUG
              printf("-q\n");
#endif
              sprintf(msg, "%s -q\0", msg);
              break;
      case 1:
#ifdef DEBUG
              printf("-Q\n");
#endif
#if RELEASE_LEVEL >= 8000
              sprintf(msg, "%s -Q\0", msg);
#else
              sprintf(msg, "%s -q\0", msg);
#endif
              break;
      case 2:
#ifdef DEBUG
              printf("DEFAULT with surface check\n");
#endif
              break;
      default:
              printf("BAD QUICK MODE\n");
              break;
   }

   if (dash_n == 1) {
#ifdef DEBUG
      printf("CHANGE FS SIZE\n");
#endif
      sprintf(msg, "%s -n %d\0", msg, max_fs_size);
   }

#ifdef DEBUG
   printf("SIZE OF FS:  %d\n", max_fs_size);

   if ((dash_i == 0) && (dash_I == 0)) {
      printf("I_FACTOR:    default\n");
   }
#endif

   if (dash_i == 1) {
#ifdef DEBUG
      printf("I_FACTOR:    %d\n", i_factor);
#endif
      sprintf(msg, "%s -i %d\0", msg, i_factor);
   }

   if (dash_I == 1) {
#ifdef DEBUG
      printf("NUM INODES:  %d\n", num_inodes);
#endif
      sprintf(msg, "%s -I %d\0", msg, num_inodes);
   }

   if (dash_d == 0) {
#ifdef DEBUG
      printf("NO LOST+FOUND\n");
#endif
      sprintf(msg, "%s -d\0", msg);
   }

   if (dash_B == 1) {
#ifdef DEBUG
      printf("BIG FILE THRESHOLD:  %d\n", big_file_thresh_hold);
#endif
      sprintf(msg, "%s -B %d\0", msg, big_file_thresh_hold);
   }

   if (dash_A == 1) {
#ifdef DEBUG
      printf("BIG FILE ALLOCATION UNIT:  %d\n", big_file_alloc_unit);
#endif
      sprintf(msg, "%s -A %d\0", msg, big_file_alloc_unit);
   }

   if (dash_s == 1) {
      sprintf(msg, "%s -s\0", msg);
   }

   sprintf(msg, "%s %s\0", msg, logical_device_name);

   return(msg);

}
