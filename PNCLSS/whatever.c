#include <stdio.h>
#include <ctype.h>                /* isdigit routine */
#include <fcntl.h>
#include <nlist.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/buf.h>
#include <sys/sysmacros.h>
#include <sys/unistd.h>
#include <sys/types.h>
#include <sys/time.h>             /* ctime routine */
#include <sys/param.h>
#include <sys/map.h>
#include <sys/vfs.h>
#include <sys/vnode.h>
#include <sys/inode.h>
#include <sys/fs/nc1ino.h>
#include <sys/fs/nc1inode.h>
#include <sys/fs/nc1filsys.h>
#include <sys/fs/ncdir.h>
#include <sys/statfs.h>
#define KERNEL 1
#include <sys/mount.h>
#include <dirent.h>
#include <sys/secparm.h>
#include <sys/var.h>

#define DEVNAMESIZE (CDMAXNAMELEN+10)
#define ERR -1

#define NO_DESTROY 0
#define DESTROY 1

#define BAD_DATA 0525252525252525252525

#define DSTRY_MAX 10

#define MAX_WORDS 10

#define WORDSZ 8

#define YES 1
#define NO 0

#define ON_DISK_SUPER 1
#define IN_CORE_INODE 2
#define IN_CORE_MOUNT 3
#define IN_CORE_DYNAMIC 4
#define IN_CORE_SUPER 5

#define MAGIC_NUMBER 1
#define RANDOM_WORD 2
#define GVN_OFFSET 3

#define KMEM "/dev/mem"

extern char *getfile();
extern char *getcwd();
extern char *strrchr();

char errstring[80];
int kmemfd, kmemfd2;
static long nc1magic = FsMAGIC_NC1;
static long nc1dbmagic = DbMAGIC_NC1;
static long nc1inomagic = 0;

struct destroy {
   int dstry_blk;
   int dstry;
   int offset;
   int bd_count;
   int off_count;
   long bad_data;
   long *good_data;
};

struct sprblk {
   char *fs_name;
   char *fs_device;
   int blk_counter;
   struct destroy brk_blk[DSTRY_MAX];
   int mem_offset;
   int dsk_offset;
   int mnt_offset;
   int ino_offset;
   int dyn_offset;
   struct mount *mntptr;
   struct statfs *dsk_buf;
   struct nc1filsys *dsk_seg_super;
   struct nc1filsys *mem_seg_super;
   struct nc1inode *mem_ino_super;
   struct nc1dblock *mem_dyn_super;
   struct sprblk *next_fs;
};

#define OPTIONS "f:d:i:s:S:m:b:"

#define USAGE "badmagic -f file_system [-s magic|random] [-i magic|random] [-S magic|random] [-m random] [-f file_system [-s ...] ...]\n"

main(argc, argv)
int argc;
char **argv;
{

extern char *optarg;
extern int optind;

int c, background = 0, len = 0;
char *dstry_fld, *fs_name, *dev_name, *dir_name, *fs_to_dev(), *namesys();
struct sprblk *build_fs_list(), *cr_fs_node();
struct sprblk *head_fs = NULL;
struct sprblk *new_fs_node = NULL;
struct sprblk *trans();

   kmemfd = do_open(KMEM);
#ifdef DEBUG
   kmemfd2 = do_open(KMEM);
#endif

   while (head_fs == NULL) {

      if ((c = getopt(argc, argv, OPTIONS)) != EOF) {
         switch (c) {
/*
            case 'd':
                       dev_name = optarg;
                       fs_name = dev_to_fs(dev_name);
                       break;

*/
            case 'f':
                       dir_name = optarg;
                       fs_name = namesys(dir_name);
                       dev_name = fs_to_dev(fs_name);
                       new_fs_node = cr_fs_node(fs_name, dev_name);
                       head_fs = build_fs_list(head_fs, new_fs_node);
                       break;

            case 'b':
                       len = atoi(optarg);
                       background = 1;
                       break;

            case 's':
            case 'd':
            case 'S':
            case 'm':
            case 'i':
                       fprintf(stderr,
                        "-%c: invalid option until file system specified\n", c);
                       break;

            default:
                       fprintf(stderr, USAGE);
                       exit(1);
                       break;
         }
      }
      else
         exit(1);
   }


   while ((c = getopt(argc, argv, OPTIONS)) != EOF) {

      switch (c) {
         case 'b':
                    len = atoi(optarg);
                    background = 1;
                    break;
/*
         case 'd':
                    dev_name = optarg;
                    fs_name = dev_to_fs(dev_name);
                    break;

*/
         case 'f':
                    dir_name = optarg;
                    fs_name = namesys(dir_name);
                    dev_name = fs_to_dev(fs_name);
                    new_fs_node = cr_fs_node(fs_name, dev_name);
                    head_fs = build_fs_list(head_fs, new_fs_node);
                    break;

         case 's':
                    new_fs_node->brk_blk[new_fs_node->blk_counter].dstry_blk =
                                IN_CORE_SUPER;
                    new_fs_node = trans(optarg, IN_CORE_SUPER, new_fs_node);
#ifdef DEBUG_OPT
                    printf(" MEM DESTROY:  %d\n",
                         new_fs_node->brk_blk[new_fs_node->blk_counter].dstry);
#endif
                    new_fs_node->blk_counter++;
                    break;

         case 'S':
                    new_fs_node->brk_blk[new_fs_node->blk_counter].dstry_blk =
                                ON_DISK_SUPER;
                    new_fs_node = trans(optarg, ON_DISK_SUPER, new_fs_node);
#ifdef DEBUG_OPT
                    printf(" DSK DESTROY:  %d\n",
                         new_fs_node->brk_blk[new_fs_node->blk_counter].dstry);
#endif
                    new_fs_node->blk_counter++;
                    break;

         case 'm':
                    new_fs_node->brk_blk[new_fs_node->blk_counter].dstry_blk =
                                IN_CORE_MOUNT;
                    new_fs_node = trans(optarg, IN_CORE_MOUNT, new_fs_node);
#ifdef DEBUG_OPT
                    printf(" MNT DESTROY:  %d\n",
                         new_fs_node->brk_blk[new_fs_node->blk_counter].dstry);
#endif
                    new_fs_node->blk_counter++;
                    break;

         case 'i':
                    new_fs_node->brk_blk[new_fs_node->blk_counter].dstry_blk =
                                IN_CORE_INODE;
                    new_fs_node = trans(optarg, IN_CORE_INODE, new_fs_node);
#ifdef DEBUG_OPT
                    printf(" INO DESTROY:  %d\n",
                         new_fs_node->brk_blk[new_fs_node->blk_counter].dstry);
#endif
                    new_fs_node->blk_counter++;
                    break;

         case 'd':
                    new_fs_node->brk_blk[new_fs_node->blk_counter].dstry_blk =
                                IN_CORE_DYNAMIC;
                    new_fs_node = trans(optarg, IN_CORE_DYNAMIC, new_fs_node);
#ifdef DEBUG_OPT
                    printf(" DYN DESTROY:  %d\n",
                         new_fs_node->brk_blk[new_fs_node->blk_counter].dstry);
#endif
                    new_fs_node->blk_counter++;
                    break;

         default:
                    fprintf(stderr, USAGE);
                    exit(1);
                    break;
      }
   }
   do_destroy(head_fs, background, len);
   do_restore(head_fs, background, len);
   close(kmemfd);
#ifdef DEBUG
   close(kmemfd2);
#endif
}

/************************************************/
/*  Set up and destroy the sections of super/mount/inode that
    user requested.
*/
int do_destroy(head_fs, background, len)
struct sprblk *head_fs;
int background, len;
{
struct sprblk *fs_node = head_fs;
int i;

   printf("IN DO_DESTROY\n");

   if (fs_node == NULL)
      return(0);

   while (fs_node != NULL) {
      printf("NODE:  %s\n", fs_node->fs_name);
      set_destroy(fs_node);
      fs_node = fs_node->next_fs;
   }

   fs_node = head_fs;
   while (fs_node != NULL) {
      printf("NODE:  %s\n", fs_node->fs_name);
      if (background == NO) {
         if (yesno("Destroy entries?") == YES) {
            for (i = 0; i < fs_node->blk_counter; i++)
               doit(fs_node, DESTROY, i);
         }
      }
      else {
         sleep(len);
         for (i = 0; i < fs_node->blk_counter; i++)
            doit(fs_node, DESTROY, i);
      }
      fs_node = fs_node->next_fs;
   }
}

int do_open(device)
char *device;
{
int fd;

   if ((fd = open(device, O_RDWR)) == ERR)
      logerr("do_open: open");
   return(fd);
}

long do_devmemwrt(offset, data, device, numwrite, writesize, debugitem)
int offset, numwrite, writesize, debugitem;
long *data;
char *device;
{
int fd, err, i, dfd;

   if (strcmp(device, KMEM) == 0) {
      fd = kmemfd;
   }
   else {
      if ((fd = open(device, O_RDWR)) == ERR)
         logerr("do_devmemwrt: open");
   }
   if ((err = lseek(fd, offset, SEEK_SET)) != offset)
      logerr("do_devmemwrt: lseek");
#ifdef REAL
   for (i = 0; i < numwrite; i++) {
      if ((err = write(fd, (char *)data, writesize)) == ERR)
         logerr("do_devmemwrt: write");
   }
#endif
   if (fd != kmemfd)
      close(fd);

#ifdef DEBUG
   debug_two(offset, data, device, numwrite, writesize, debugitem);
#endif
}

int doit(fs_node, restore, bn)
struct sprblk *fs_node;
int restore, bn;
{

#ifdef DEBUG
   debug_one(fs_node, bn);
#endif

   if (restore == DESTROY) {
      if (fs_node->brk_blk[bn].dstry != NO_DESTROY) {
         if (fs_node->brk_blk[bn].dstry_blk != ON_DISK_SUPER) {
            do_devmemwrt(fs_node->brk_blk[bn].offset,
                         &fs_node->brk_blk[bn].bad_data, KMEM,
                         fs_node->brk_blk[bn].bd_count, sizeof(long), 0);
         }
         else {
            do_devmemwrt(fs_node->brk_blk[bn].offset,
                         &fs_node->brk_blk[bn].bad_data, fs_node->fs_device,
                         fs_node->brk_blk[bn].bd_count, sizeof(long), 0);
         }
      }
   }
   else {
      if (fs_node->brk_blk[bn].dstry != NO_DESTROY) {
         if (fs_node->brk_blk[bn].dstry_blk != ON_DISK_SUPER) {
            do_devmemwrt(fs_node->brk_blk[bn].offset,
                         fs_node->brk_blk[bn].good_data, KMEM, 1,
                         (fs_node->brk_blk[bn].bd_count * sizeof(long)),
                          fs_node->brk_blk[bn].bd_count);
         }
         else {
            do_devmemwrt(fs_node->brk_blk[bn].offset,
                         fs_node->brk_blk[bn].good_data, fs_node->fs_device, 1,
                         (fs_node->brk_blk[bn].bd_count * sizeof(long)),
                          fs_node->brk_blk[bn].bd_count);
         }
      }
   }
}


/************************************************/
/*  Set up the destroy data.
*/
int set_destroy(fs_node)
struct sprblk *fs_node;
{
int i;

   for (i = 0; i < fs_node->blk_counter; i++) {
      if (fs_node->brk_blk[i].dstry != NO_DESTROY) {
         fs_node->brk_blk[i].bad_data = BAD_DATA;
         switch (fs_node->brk_blk[i].dstry_blk) {
            case ON_DISK_SUPER:
                 dstry_set_up(fs_node, i, &nc1magic, fs_node->dsk_offset,
                               sizeof(struct nc1filsys), fs_node->fs_device);
                 break;

            case IN_CORE_SUPER:
                 dstry_set_up(fs_node, i, &nc1magic, fs_node->mem_offset,
                               sizeof(struct nc1filsys), KMEM);
                 break;

            case IN_CORE_INODE:
                 dstry_set_up(fs_node, i, &nc1inomagic,
                              (fs_node->ino_offset + (4 * WORDSZ)),
                               sizeof(struct nc1inode), KMEM);
                 break;

            case IN_CORE_MOUNT:
                 dstry_set_up(fs_node, i, NULL, fs_node->mnt_offset,
                               sizeof(struct mount), KMEM);
                 break;

            case IN_CORE_DYNAMIC:
                 dstry_set_up(fs_node, i, &nc1dbmagic, fs_node->dyn_offset,
                               sizeof(struct nc1dblock), KMEM);
                 break;

         }
      }
   }
}



/************************************************/
/*  Set up the destroy data.
    Get good data to restore area if possible.
*/
dstry_set_up(fs_node, bn, kgd_data, lc_offset, lc_max_sz, where)
struct sprblk *fs_node;
int bn, lc_offset, lc_max_sz;
long *kgd_data;
char *where;
{
long *get_good_data();

   switch (fs_node->brk_blk[bn].dstry) {
      case MAGIC_NUMBER:
         fs_node->brk_blk[bn].good_data = (long *)malloc(sizeof(long));
         fs_node->brk_blk[bn].good_data = kgd_data;
         fs_node->brk_blk[bn].offset = lc_offset;
         break;

      case RANDOM_WORD:
         fs_node->brk_blk[bn].offset =
                 random_offset(lc_offset, lc_max_sz);
         fs_node->brk_blk[bn].good_data =
                 get_good_data(fs_node->brk_blk[bn].offset, where,
                               fs_node->brk_blk[bn].bd_count);
         break;
      
      case GVN_OFFSET:
         fs_node->brk_blk[bn].offset =
                 lc_offset + (WORDSZ * fs_node->brk_blk[bn].off_count);
         fs_node->brk_blk[bn].good_data =
                 get_good_data(fs_node->brk_blk[bn].offset, where,
                               fs_node->brk_blk[bn].bd_count);
         break;
   }
}

/*******************************************************/
/*  Generate a random offset which will not exceed
    start_loc + max_add;
*/
int random_offset(start_loc, max_add, multip)
int start_loc, max_add, multip;
{
double drand48();
void srand48();
int random;

   max_add = max_add - (WORDSZ * multip);
   sleep(1);
   srand48(time((long *)0));
   random = (int)(drand48() * (double)max_add);
   if (random > max_add)
      random = max_add;
   return(start_loc + random);
}

/*******************************************************/
/*  read the data from offset bytes into /dev/mem
*/
long *get_good_data(offset, device, multip)
int offset, multip;
char *device;
{
int fd, err;
long *some_data;

#ifdef DEBUG
   printf("get_good_data:  device: %s  offset: %d\n", device, offset);
#endif

   some_data = (long *)malloc(sizeof(long) * multip);

   if (strcmp(device, KMEM) == 0) {
      fd = kmemfd;
   }
   else {
      if ((fd = open(device, O_RDONLY)) == ERR)
         logerr("get_good_data: open");
   }
   if ((err = lseek(fd, offset, SEEK_SET)) != offset)
      logerr("get_good_data: lseek");
   if ((err = read(fd, (char *)some_data, (sizeof(long) * multip))) == ERR)
      logerr("get_good_data: read");
   if (fd != kmemfd)
      close(fd);

   return(some_data);
}


/*************************************************/
/*
   Generic routine to get file names.
*/
char *getfile()
{
char filename[80], *retval;
int i;
 
   i = 0;
   while((filename[i] = getchar()) != '\n')
     i++;
   filename[i] = '\0';
   if ((filename[0] == '\0') || (filename[0] == '\n'))
      return(NULL);
   retval = (char *)malloc(strlen(filename) + 1);
   strcpy(retval, filename);
   return(retval);
}

/*********************************************************/
/*   YESNO

   Get answers to yes/no questions
*/
/*
   parameters:
      string       string containing yes/no question

   return value:
      YES(1) or NO(0)    (see mymisc.h)
*/
int yesno(string)
char *string;
{
char *answer, *getfile();
int i, len;
int doit = 1;

   do {
      printf("%s (y or n):  ", string);
      if ((answer = getfile()) != NULL) {
         len = strlen(answer);
         for (i = 0; i < len; i++)
            if (isupper(answer[i]))
               answer[i] = tolower(answer[i]);
         if ((strcmp(answer, "y") == 0) || (strcmp(answer, "yes") == 0)) {
            free(answer);
            return(YES);
         }
         if ((strcmp(answer, "n") == 0) || (strcmp(answer, "no") == 0)) {
            free(answer);
            return(NO);
         }
         free(answer);
         printf("Not a y or an n\n");
      }
      else {
         return(NO);
      }
   } while (doit == 1);
}

int do_restore(head_fs, background, len)
struct sprblk *head_fs;
int background, len;
{
struct sprblk *fs_node = head_fs;
int i;

   printf("IN DO_RESTORE\n");

   if (fs_node == NULL)
      return(0);

   while (fs_node != NULL) {
      printf("NODE:  %s\n", fs_node->fs_name);
      if (background == NO) {
         if (yesno("Restore damaged entries?") == YES) {
            for (i = 0; i < fs_node->blk_counter; i++)
               doit(fs_node, NO_DESTROY, i);
         }
      }
      else {
         sleep(len);
         for (i = 0; i < fs_node->blk_counter; i++)
            doit(fs_node, NO_DESTROY, i);
      }
      fs_node = fs_node->next_fs;
   }
}

struct sprblk *trans(opt_name, trans_for, new_fs_node)
char *opt_name;
int trans_for;
struct sprblk *new_fs_node;
{
char *strtok(), i;

   switch (trans_for) {
      case ON_DISK_SUPER:
      case IN_CORE_SUPER:
      case IN_CORE_DYNAMIC:
      case IN_CORE_INODE:
         if (strcmp(opt_name, "magic") == 0) {
            new_fs_node->brk_blk[new_fs_node->blk_counter].dstry = MAGIC_NUMBER;
            new_fs_node->brk_blk[new_fs_node->blk_counter].bd_count = 1;
            break;
         }

      case IN_CORE_MOUNT:
         if (strncmp(opt_name, "random", 6) == 0) {
            new_fs_node->brk_blk[new_fs_node->blk_counter].dstry = RANDOM_WORD;
            if (strlen(opt_name) <= 7) {
              new_fs_node->brk_blk[new_fs_node->blk_counter].bd_count = 1;
            }
            else {
               opt_name = opt_name + (WORDSZ - 1);
               i = atoi(opt_name);
               if (i > MAX_WORDS)
                  i = MAX_WORDS;
               if (i < 1)
                  i = 1;
               new_fs_node->brk_blk[new_fs_node->blk_counter].bd_count=i;
            }
            break;
         }
         if (strncmp(opt_name, "offset", 6) == 0) {
            new_fs_node->brk_blk[new_fs_node->blk_counter].dstry = GVN_OFFSET;
            opt_name = opt_name + 7;
            i = atoi(opt_name);
            new_fs_node->brk_blk[new_fs_node->blk_counter].off_count=i;
            new_fs_node->brk_blk[new_fs_node->blk_counter].bd_count = 1;
         }
         break;

      default:
         new_fs_node->brk_blk[new_fs_node->blk_counter].dstry = 0;
   }

   return(new_fs_node);
}

struct sprblk *build_fs_list(head_fs, new_fs_node)
struct sprblk *head_fs, *new_fs_node;
{
struct sprblk *tmp_node;

   if (head_fs == NULL)
      head_fs = new_fs_node;
   else {
      tmp_node = head_fs;
      while (tmp_node->next_fs != NULL)
         tmp_node = tmp_node->next_fs;
      tmp_node->next_fs = new_fs_node;
   }

   return(head_fs);
}

/*******************************************************/
/*  Set up the file system node for insertion into linked list
*/
struct sprblk *cr_fs_node(fs_name, dev_name)
char *fs_name, *dev_name;
{
struct sprblk *new_fs_node;
struct nc1filsys *get_dsk_super(), *get_mem_super();
struct nc1dblock *get_mem_dynamic();
struct nc1inode *get_mem_inode();
struct mount *get_mem_mount();
int i;

   new_fs_node = (struct sprblk *)malloc(sizeof(struct sprblk));
   
   new_fs_node->fs_name = fs_name;
   new_fs_node->fs_device = dev_name;
   new_fs_node->mem_offset = 0;
   new_fs_node->dsk_offset = BSIZE;
   new_fs_node->mnt_offset = 0;
   new_fs_node->ino_offset = 0;
   new_fs_node->dyn_offset = 0;

   for (i = 0; i < DSTRY_MAX; i++) {
      new_fs_node->brk_blk[i].dstry = 0;
      new_fs_node->brk_blk[i].bd_count = 0;
   }

   new_fs_node->blk_counter = 0;

   new_fs_node->dsk_buf = (struct statfs *)malloc(sizeof(struct statfs));
   statfs(fs_name, new_fs_node->dsk_buf, sizeof(struct statfs), 0);


   new_fs_node->dsk_seg_super = get_dsk_super(new_fs_node);

   new_fs_node->mntptr = get_mem_mount(new_fs_node);

   new_fs_node->mem_seg_super = get_mem_super(new_fs_node);
   new_fs_node->mem_dyn_super = get_mem_dynamic(new_fs_node);

   new_fs_node->mem_ino_super = get_mem_inode(new_fs_node);
   new_fs_node->next_fs = NULL;

#ifdef DEBUG
   printf("%d    %d      %d      %d\n",
            new_fs_node->dsk_offset, new_fs_node->mem_offset,
            new_fs_node->mnt_offset, new_fs_node->ino_offset);
#endif

   return(new_fs_node);
}

int getstruct(structname, fd, thestruct, size, progname)
int fd;
char *thestruct, *structname, *progname;
int size;
{
struct nlist nl[2];
int err;

   nl[0].n_name = structname;
   nl[1].n_name = NULL;

   nlist(progname, nl);

   if ((err = lseek(fd, nl[0].n_value, SEEK_SET)) != nl[0].n_value)
      logerr("getstruct: lseek");

   if ((err = read(fd, thestruct, size)) != size)
      logerr("getstruct: read");

   return(0);
}

/***********************************************/
/*  Get the in core inode for a super block
*/
struct nc1inode *get_mem_inode(fs_node)
struct sprblk *fs_node;
{
struct nc1inode *sys_inode;
int fd, err, i;

struct var v;

   sys_inode = (struct nc1inode *)malloc(sizeof(struct nc1inode));

   fd = kmemfd;
   getstruct("v", fd, (char *)&v, sizeof(struct var), "/unicos");

   if ((err = lseek(fd, wtob(v.vb_nc1inode), SEEK_SET)) != wtob(v.vb_nc1inode))
      logerr("get_mem_inode: lseek/inode table");

   for (i = 0; i < v.v_nc1inode; i++) {
      fs_node->ino_offset = lseek(fd, 0, SEEK_CUR);
      if (read(fd, (char *)sys_inode, sizeof(struct nc1inode)) > 0) {
         if ((sys_inode->nc1i_vnode.v_flag & VROOT) == VROOT) {
            if ((krn_major(sys_inode->nc1i_vattr.va_fsid) ==
                 usr_major(fs_node->mem_seg_super->s_dev))  &&
                (krn_minor(sys_inode->nc1i_vattr.va_fsid) ==
                 usr_minor(fs_node->mem_seg_super->s_dev))) {
               if (fs_node->mem_seg_super->s_root ==
                   sys_inode->nc1i_vattr.va_nodeid) {

#ifdef DEBUG
                  debug_four(v, sys_inode, fs_node);
#endif
                  return(sys_inode);
               }
            }
         }
      }
   }

   free(sys_inode);
   return(NULL);
}

/*************************************************/
/*  Get the mount table
*/
struct mount *get_mem_mount(fs_node)
struct sprblk *fs_node;
{
struct mount *sys_mount;
int fd, err, i;

struct var v;

   sys_mount = (struct mount *)malloc(sizeof(struct mount));

   fd = kmemfd;

   getstruct("v", fd, (char *)&v, sizeof(struct var), "/unicos");

   if ((err = lseek(fd, wtob(v.vb_mount), SEEK_SET)) != wtob(v.vb_mount))
      logerr("get_mem_mount: lseek,v/memory/mount");

   for (i = 0; i < v.v_mount; i++) {
      if ((fs_node->mnt_offset = lseek(fd, 0, SEEK_CUR)) == ERR)
         logerr("get_mem_mount: lseek,offset/memory/mount");
      if (read(fd, (char *)sys_mount, sizeof(struct mount)) > 0) {
         if (strcmp(sys_mount->m_fsname, fs_node->fs_device) == 0) {

#ifdef DEBUG
            printf("MOUNT TABLE STUFF\n");
            printf("DEV:  %s   %s\n", sys_mount->m_fsname, fs_node->fs_device);
            printf("major/minor: %d,%d\n", 
                    krn_major(sys_mount->m_vfs.vfs_fsid.val[0]),
                    krn_minor(sys_mount->m_vfs.vfs_fsid.val[0]));
            printf("flag: %o\n", sys_mount->m_flags);
            printf("OFFSET:  %d\n", fs_node->mnt_offset);
#endif

            return(sys_mount);
         }
      }
   }
   free(sys_mount);
   return(NULL);
}

/*********************************************/
/*  Get the on disk super block
*/
struct nc1filsys *get_dsk_super(fs_node)
struct sprblk *fs_node;
{
struct nc1filsys *sys_super;
int fd, err;

   sys_super = (struct nc1filsys *)malloc(BSIZE);
   if ((fd = open(fs_node->fs_device, O_RDONLY)) == ERR)
      logerr("get_dsk_super: open/disk/super");
   if ((err = lseek(fd, BSIZE, SEEK_SET)) != BSIZE)
      logerr("get_dsk_super: lseek/disk/super");
   if ((err = read(fd, (char *)sys_super, BSIZE)) == ERR)
      logerr("get_dsk_super: read/disk/super");
   close(fd);

#ifdef DEBUG
   printf("ON DISK SUPER DUMP\n");
   debug_three(sys_super, fs_node);
   printf("OFFSET:  %d\n", fs_node->dsk_offset);
#endif

   return(sys_super);
   
}

/*************************************************/
/*  Get the in core super block
*/
struct nc1filsys *get_mem_super(fs_node)
struct sprblk *fs_node;
{
struct nc1filsys *sys_super;
int fd, err;

struct buf my_buffer;

   sys_super = (struct nc1filsys *)malloc(sizeof(struct nc1filsys));
   fd = kmemfd;
   if ((err = lseek(fd, wtob(fs_node->mntptr->m_bufp), SEEK_SET)) != wtob(fs_node->mntptr->m_bufp))
      logerr("get_mem_super: lseek/memory/super/mount");
   if ((err = read(fd, (char *)&my_buffer, sizeof(struct buf))) == ERR)
      logerr("get_mem_super: read/memory/super");
   if ((err = lseek(fd, wtob(my_buffer.b_maddr.bb_waddr), SEEK_SET)) != wtob(my_buffer.b_maddr.bb_waddr))
      logerr("get_mem_super: lseek/memory/super/buffer");
   if ((fs_node->mem_offset = lseek(fd, 0, SEEK_CUR)) == ERR)
      logerr("get_mem_super: lseek/memory/super/offset");
   if ((err = read(fd, (char *)sys_super, BSIZE)) == ERR)
      logerr("get_mem_super: read/memory/super");

#ifdef DEBUG
   printf("IN MEMORY SUPER DUMP\n");
   debug_three(sys_super, fs_node);
   printf("OFFSET:  %d\n", fs_node->mem_offset);
#endif

   return(sys_super);
  
}

/*************************************************/
/*  Get the in core dynamic block
*/
struct nc1dblock *get_mem_dynamic(fs_node)
struct sprblk *fs_node;
{
struct nc1dblock *sys_dynamic;
int fd, err;

struct buf my_buffer;

   sys_dynamic = (struct nc1dblock *)malloc(sizeof(struct nc1dblock));
   fd = kmemfd;
   if ((fs_node->dyn_offset = lseek(fd, wtob(fs_node->mem_seg_super->s_pdb), SEEK_SET)) != wtob(fs_node->mem_seg_super->s_pdb))
      logerr("get_mem_dynamic: lseek/memory/dynamic/mount");
   if ((err = read(fd, (char *)sys_dynamic, sizeof(struct nc1dblock))) == ERR)
      logerr("get_mem_dynamic: read/memory/dynamic");

#ifdef DEBUG
   printf("IN MEMORY DYNAMIC DUMP\n");
   printf("magic:   %d    %d\n", sys_dynamic->db_magic, DbMAGIC_NC1);
   printf("free blocks:  %d\n", sys_dynamic->db_tfree);
   printf("OFFSET:  %d\n", fs_node->dyn_offset);
#endif

   return(sys_dynamic);

}

/*************************************************/
/*  Code stolen from /etc/devnm
*/
char *fs_to_dev(fs_name)
char *fs_name;
{
   struct stat sbuf;
   struct dirent *dbuf;
   DIR   *dp;
   dev_t fno;
   int   errcode = 0;
   char    dev[DEVNAMESIZE];
   char *dev_name;

   if ((dp = opendir("/dev/dsk")) == NULL) {
      fprintf(stderr, "Cannot open /dev/dsk\n");
      exit(1);
   }

   if (stat(fs_name, &sbuf) == -1) {
      sprintf(dev,"fs_to_dev: %s", fs_name);
      logerr(dev);
      return(NULL);
   }

   fno = sbuf.st_dev;
   (void) rewinddir(dp);
   while (dbuf = readdir(dp)) {
      strcpy(dev, "/dev/dsk/");
      strcat(dev, dbuf->d_name);
      if (stat(dev, &sbuf) == -1) {
         logerr("fs_to_dev:  /dev/dsk stat error");
         exit(1);
      }
      if (fno == sbuf.st_rdev
        && (sbuf.st_mode & S_IFMT) == S_IFBLK) {
         dev_name = (char *)malloc(strlen(dbuf->d_name) + 10);
         sprintf(dev_name, "/dev/dsk/%s\0", dbuf->d_name);
      }
   }

   (void)closedir(dp);

   return(dev_name);
}

/************************************************/
/*  Determine which file system a directory is in.
*/
char *namesys(workdir)
char *workdir;
{
char *sysname;
char *oldsysname;
char *endstr;
char *curdir;
struct stat *buf;
int done, err;
dev_t oldid;

   buf = (struct stat *)malloc(sizeof(struct stat));
   sysname = (char *)malloc(strlen(workdir) + 1);
   oldsysname = (char *)malloc(strlen(workdir) + 1);
   strcpy(sysname,workdir);
   curdir = getcwd((char *)NULL, 80);
   if (strcmp(workdir,curdir) != 0) {
      err = stat(workdir, buf);
      if (err != 0) {
         free(buf);
         free(oldsysname);
         free(sysname);
         sprintf(errstring, "namesys: getting system name: %s", workdir);
         logerr(errstring);
         return(NULL);
      }
   }
   free(curdir);
   done = 0;
   oldid = 0;
   while (done == 0) {
      err = stat(sysname,buf);
      if (err == 0) {
         if (oldid != 0) {
            if (oldid != buf->st_dev) {
               free(buf);
               free(sysname);
               return(oldsysname);
            }
         }
         oldid = buf->st_dev;
      }
      strcpy(oldsysname,sysname);
      endstr = strrchr(sysname,'/');
      *endstr = '\0';
      if (*sysname == '\0') {
         *sysname = '/';
         endstr++;
         *endstr = '\0';
         if (oldid == 0) {
           free(buf);
           free(oldsysname);
           return(sysname);
         }
         stat(sysname,buf);
         if (oldid == buf->st_dev) {
           done = 1;
         }
      }
   }
   free(buf);
   free(oldsysname);
   return(sysname);
}

int logerr(errstring)
char *errstring;
{
   perror(errstring);
   exit(-1);
}

#ifdef DEBUG
int debug_one(fs_node, bn)
struct sprblk *fs_node;
int bn;
{
   switch (fs_node->brk_blk[bn].dstry_blk) {
      case IN_CORE_SUPER:
              printf(" MEM DESTROY:  %d\n",
                      fs_node->brk_blk[bn].dstry);
              break;

      case ON_DISK_SUPER:
              printf(" DSK DESTROY:  %d\n",
                      fs_node->brk_blk[bn].dstry);
              break;

      case IN_CORE_INODE:
              printf(" INO DESTROY:  %d\n",
                      fs_node->brk_blk[bn].dstry);
              break;

      case IN_CORE_DYNAMIC:
              printf(" DYN DESTROY:  %d\n",
                      fs_node->brk_blk[bn].dstry);
              break;

      case IN_CORE_MOUNT:
              printf(" MNT DESTROY:  %d\n",
                      fs_node->brk_blk[bn].dstry);
              break;

   }
}
int debug_two(offset, data, device, numwrite, writesize, debugitem)
int offset, numwrite, writesize, debugitem;
long *data;
char *device;
{
int fd, err, i, dfd;

   printf("open %s -- O_RDWR\n", device);
   printf("lseek %d\n", offset);
   if (debugitem == 0) {
      dfd = open("junk", O_RDWR | O_CREAT);
      for (i = 0; i < numwrite; i++) {
         printf("write %o\n", data[0]);
      }
   }
   else {
      dfd = open("junk", O_RDWR);
      for (i = 0; i < debugitem; i++) {
         printf("write %o    %d\n", data[i], data[i]);
      }
   }
   for (i = 0; i < numwrite; i++) {
      if ((err = write(dfd, (char *)data, writesize)) == ERR)
         logerr("debug_two: write");
   }
   close(dfd);
   printf("close %s\n", device);
   fflush(stdout);
}

int debug_three(sys_super, fs_node)
struct nc1filsys *sys_super;
struct sprblk *fs_node;
{
   printf("fs magic: %d   %d\n", sys_super->s_magic, FsMAGIC_NC1);
   printf("fs name:  %s   %s\n", sys_super->s_fname, fs_node->dsk_buf->f_fname);
   printf("fs dev:   %s\n", fs_node->fs_device);
   printf("fs pack:  %s   %s\n", sys_super->s_fpack, fs_node->dsk_buf->f_fpack);
   printf("fs npart: %d   %d\n", sys_super->s_npart, fs_node->dsk_buf->f_npart);
   printf("fs priblock:  %d\n", sys_super->s_priblock);
   printf("fs volume sz: %d   %d\n",
           sys_super->s_fsize, fs_node->dsk_buf->f_blocks);
   printf("fs prinblks:  %d   %d\n",
           sys_super->s_prinblks, fs_node->dsk_buf->f_prinblks);
   printf("fs secblock:  %d\n", sys_super->s_secblock);
   printf("fs secnblks:  %d   %d\n",
           sys_super->s_secnblks, fs_node->dsk_buf->f_secnblks);
   fflush(stdout);
}

int debug_four(v, sys_inode, fs_node)
struct var v;
struct nc1inode *sys_inode;
struct sprblk *fs_node;
{
int fd2, err;
struct vnode *sys_vnode = NULL;

   sys_vnode = (struct vnode *)malloc(sizeof(struct vnode));
   fd2 = kmemfd2;
   err = lseek(fd2, (long)fs_node->mntptr->m_root*WORDSZ, SEEK_SET);
   err = read(fd2, (char *)sys_vnode, sizeof(struct vnode));

   printf("INODE JUNK:  %d\n", v.v_nc1inode);
   printf("flag:  %o    %o\n",
           sys_vnode->v_flag, sys_inode->nc1i_vnode.v_flag);
   printf("REF COUNT:  %d    %d\n",
           sys_vnode->v_count,
           sys_inode->nc1i_vnode.v_count);
   printf("MAJOR:  %d   %d\n",
           krn_major(sys_inode->nc1i_vattr.va_fsid),
           usr_major(fs_node->mem_seg_super->s_dev));
   printf("MINOR:  %d   %d\n",
           krn_minor(sys_inode->nc1i_vattr.va_fsid),
           usr_minor(fs_node->mem_seg_super->s_dev));
   printf("mode:  %o\n", sys_inode->nc1i_vattr.va_mode);
   printf("uid:   %d\n", sys_inode->nc1i_vattr.va_uid);
   printf("size:  %d\n", sys_inode->nc1i_vattr.va_size);
   printf("OFFSET:  %d\n", fs_node->ino_offset);
}
#endif
