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

#define YES 1
#define NO 0

#define KMEM "/dev/mem"

extern char *getfile();
extern char *getcwd();
extern char *strrchr();

char errstring[80];

struct destroy {
   int dstry;
   int offset;
   long bad_data;
   long good_data;
};

struct sprblk {
   char *fs_name;
   char *fs_device;
   struct destroy mem_super;
   struct destroy dsk_super;
   struct destroy mem_mount;
   struct destroy mem_inode;
   struct destroy mem_dynamic;
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

int c, wreck_something = 0, background = 0, len = 0;
char *dstry_fld, *fs_name, *dev_name, *dir_name, *fs_to_dev(), *namesys();
struct sprblk *build_fs_list(), *cr_fs_node();
struct sprblk *head_fs = NULL;
struct sprblk *new_fs_node = NULL;

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
                    new_fs_node->mem_super.dstry = trans(optarg, 0);
                    if (new_fs_node->mem_super.dstry > 0)
                       wreck_something = YES;
#ifdef DEBUG
                    printf(" MEM DESTROY:  %d\n", new_fs_node->mem_super.dstry);
#endif
                    break;

         case 'S':
                    new_fs_node->dsk_super.dstry = trans(optarg, 1);
                    if (new_fs_node->dsk_super.dstry > 0)
                       wreck_something = YES;
#ifdef DEBUG
                    printf(" DSK DESTROY:  %d\n", new_fs_node->dsk_super.dstry);
#endif
                    break;

         case 'm':
                    new_fs_node->mem_mount.dstry = trans(optarg, 2);
                    if (new_fs_node->mem_mount.dstry > 0)
                       wreck_something = YES;
#ifdef DEBUG
                    printf(" MNT DESTROY:  %d\n", new_fs_node->mem_mount.dstry);
#endif
                    break;

         case 'i':
                    new_fs_node->mem_inode.dstry = trans(optarg, 3);
                    if (new_fs_node->mem_inode.dstry > 0)
                       wreck_something = YES;
#ifdef DEBUG
                    printf(" INO DESTROY:  %d\n", new_fs_node->mem_inode.dstry);
#endif
                    break;

         default:
                    fprintf(stderr, USAGE);
                    exit(1);
                    break;
      }
   }
   if (wreck_something == YES) {
      do_destroy(head_fs);
      do_restore(head_fs, background, len);
   }
}

/************************************************/
/*  Set up and destroy the sections of super/mount/inode that
    user requested.
*/
int do_destroy(head_fs)
struct sprblk *head_fs;
{
struct sprblk *fs_node = head_fs;

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
      doit(fs_node, DESTROY);
      fs_node = fs_node->next_fs;
   }
}

long do_devmemwrt(offset, data, device)
int offset;
long data;
char *device;
{
int fd, err;

   if ((fd = open(device, O_RDWR)) == ERR)
      logerr("do_devmemwrt: open");
   if ((err = lseek(fd, offset, SEEK_SET)) == ERR)
      logerr("do_devmemwrt: lseek");
#ifdef REAL
   if ((err = write(fd, (char *)&data, sizeof(long))) == ERR)
      logerr("do_devmemwrt: write");
#endif
   close(fd);

#ifdef DEBUG
   printf("open %s -- O_RDWR\n", device);
   printf("lseek %d\n", offset);
   printf("write %o\n", data);
   printf("close %s\n", device);
   fflush(stdout);
#endif
}

int doit(fs_node, restore)
struct sprblk *fs_node;
int restore;
{
   if (restore == DESTROY) {
      if (fs_node->mem_inode.dstry != NO_DESTROY)
         do_devmemwrt(fs_node->mem_inode.offset,
                      fs_node->mem_inode.bad_data, KMEM);
      if (fs_node->mem_super.dstry != NO_DESTROY)
         do_devmemwrt(fs_node->mem_super.offset,
                      fs_node->mem_super.bad_data, KMEM);
      if (fs_node->dsk_super.dstry != NO_DESTROY)
         do_devmemwrt(fs_node->dsk_super.offset,
                      fs_node->dsk_super.bad_data, fs_node->fs_device);
      if (fs_node->mem_mount.dstry != NO_DESTROY)
         do_devmemwrt(fs_node->mem_mount.offset,
                      fs_node->mem_mount.bad_data, KMEM);
   }
   else {
      if (fs_node->mem_inode.dstry != NO_DESTROY)
         do_devmemwrt(fs_node->mem_inode.offset,
                      fs_node->mem_inode.good_data, KMEM);
      if (fs_node->mem_super.dstry != NO_DESTROY)
         do_devmemwrt(fs_node->mem_super.offset,
                      fs_node->mem_super.good_data, KMEM);
      if (fs_node->dsk_super.dstry != NO_DESTROY)
         do_devmemwrt(fs_node->dsk_super.offset,
                      fs_node->dsk_super.good_data, fs_node->fs_device);
      if (fs_node->mem_mount.dstry != NO_DESTROY)
         do_devmemwrt(fs_node->mem_mount.offset,
                      fs_node->mem_mount.good_data, KMEM);
   }
}


/************************************************/
/*  Set up the destroy data.
*/
int set_destroy(fs_node)
struct sprblk *fs_node;
{
   if (fs_node->mem_inode.dstry != NO_DESTROY)
      set_ino_dstry(fs_node);
   if (fs_node->mem_super.dstry != NO_DESTROY)
      set_msr_dstry(fs_node);
   if (fs_node->dsk_super.dstry != NO_DESTROY)
      set_dsr_dstry(fs_node);
   if (fs_node->mem_mount.dstry != NO_DESTROY)
      set_mnt_dstry(fs_node);
}

/************************************************/
/*  Set up the destroy data.
    Get good data to restore area if possible.
    This applies to 
          set_ino_dstry:  for in core inode
          set_msr_dstry:  for in core super block
          set_dsr_dstry:  for on disk super block
          set_mnt_dstry:  for mount table
*/
int set_ino_dstry(fs_node)
struct sprblk *fs_node;
{
long get_good_data();

   fs_node->mem_inode.bad_data = BAD_DATA;
   if (fs_node->mem_inode.dstry == 1) {
      fs_node->mem_inode.good_data = 0;
      fs_node->mem_inode.offset = fs_node->ino_offset + (4 * 8);
   }
   else {
      fs_node->mem_inode.offset =
              random_offset(fs_node->ino_offset, sizeof(struct nc1inode));
      fs_node->mem_inode.good_data =
              get_good_data(fs_node->mem_inode.offset, KMEM);
   }
}

int set_msr_dstry(fs_node)
struct sprblk *fs_node;
{
long get_good_data();

   fs_node->mem_super.bad_data = BAD_DATA;
   if (fs_node->mem_super.dstry == 1) {
      fs_node->mem_super.good_data = FsMAGIC_NC1;
      fs_node->mem_super.offset = fs_node->mem_offset;
   }
   else {
      fs_node->mem_super.offset =
              random_offset(fs_node->mem_offset, sizeof(struct nc1filsys));
      fs_node->mem_super.good_data =
              get_good_data(fs_node->mem_super.offset, KMEM);
   }
}

int set_dsr_dstry(fs_node)
struct sprblk *fs_node;
{
long get_good_data();

   fs_node->dsk_super.bad_data = BAD_DATA;
   if (fs_node->dsk_super.dstry == 1) {
      fs_node->dsk_super.good_data = FsMAGIC_NC1;
      fs_node->dsk_super.offset = fs_node->dsk_offset;
   }
   else {
      fs_node->dsk_super.offset =
              random_offset(fs_node->dsk_offset, sizeof(struct nc1filsys));
      fs_node->dsk_super.good_data = 
              get_good_data(fs_node->dsk_super.offset, fs_node->fs_device);
   }
}

int set_mnt_dstry(fs_node)
struct sprblk *fs_node;
{
long get_good_data();

   fs_node->mem_mount.bad_data = BAD_DATA;
   fs_node->mem_mount.offset =
           random_offset(fs_node->mnt_offset, sizeof(struct mount));
   fs_node->mem_mount.good_data = 
           get_good_data(fs_node->mem_mount.offset, KMEM);
}

/*******************************************************/
/*  Generate a random offset which will not exceed
    start_loc + max_add;
*/
int random_offset(start_loc, max_add)
int start_loc, max_add;
{
double drand48();
void srand48();
int random;

   srand48(time((long *)0));
   random = (int)(drand48() * (double)max_add);
   if (random > max_add)
      random = max_add;
   if (random > 8)
      random = random - 8;
   return(start_loc + random);
}

/*******************************************************/
/*  read the data from offset bytes into /dev/mem
*/
long get_good_data(offset, device)
int offset;
char *device;
{
int fd, err;
long some_data;

#ifdef DEBUG
   printf("get_good_data:  device: %s  offset: %d\n", device, offset);
#endif

   if ((fd = open(device, O_RDONLY)) == ERR)
      logerr("get_good_data: open");
   if ((err = lseek(fd, offset, SEEK_SET)) != offset)
      logerr("get_good_data: lseek");
   if ((err = read(fd, (char *)&some_data, sizeof(long))) == ERR)
      logerr("get_good_data: read");
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

   printf("IN DO_RESTORE\n");

   if (fs_node == NULL)
      return(0);

   while (fs_node != NULL) {
      printf("NODE:  %s\n", fs_node->fs_name);
      if (background == 0) {
         if (yesno("Restore damaged entries?") == YES)
            doit(fs_node, NO_DESTROY);
      }
      else {
         sleep(len);
         doit(fs_node, NO_DESTROY);
      }
      fs_node = fs_node->next_fs;
   }
}

int trans(opt_name, trans_for)
char *opt_name;
int trans_for;
{

   switch (trans_for) {
      case 0:
      case 1:
      case 3:
               if (strcmp(opt_name, "magic") == 0)
                  return(1);
      case 2:
               if (strcmp(opt_name, "random") == 0)
                  return(2);
      default:
               return(0);
   }

   return(0);
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
struct nc1inode *get_mem_inode();
struct mount *get_mem_mount();

   new_fs_node = (struct sprblk *)malloc(sizeof(struct sprblk));
   
   new_fs_node->fs_name = fs_name;
   new_fs_node->fs_device = dev_name;
   new_fs_node->mem_offset = 0;
   new_fs_node->dsk_offset = BSIZE;
   new_fs_node->mnt_offset = 0;
   new_fs_node->ino_offset = 0;

   new_fs_node->mem_super.dstry = 0;
   new_fs_node->dsk_super.dstry = 0;
   new_fs_node->mem_mount.dstry = 0;
   new_fs_node->mem_inode.dstry = 0;

   new_fs_node->dsk_buf = (struct statfs *)malloc(sizeof(struct statfs));
   statfs(fs_name, new_fs_node->dsk_buf, sizeof(struct statfs), 0);


   new_fs_node->dsk_seg_super = get_dsk_super(new_fs_node);

   new_fs_node->mntptr = get_mem_mount(new_fs_node);
   new_fs_node->mem_seg_super = get_mem_super(new_fs_node);

   new_fs_node->mem_ino_super = get_mem_inode(new_fs_node);
   new_fs_node->next_fs = NULL;

#ifdef DEBUG
   printf("%d    %d      %d      %d\n",
            new_fs_node->dsk_offset, new_fs_node->mem_offset,
            new_fs_node->mnt_offset, new_fs_node->ino_offset);
#endif

   return(new_fs_node);
}

/***********************************************/
/*  Get the in core inode for a super block
*/
struct nc1inode *get_mem_inode(fs_node)
struct sprblk *fs_node;
{
struct nc1inode *sys_inode;
int fd, err, i, fd2;
struct nlist nl[2];
struct vnode *sys_vnode = NULL;

struct var v;

   nl[0].n_name = "v";
   nl[1].n_name = NULL;

   nlist("/unicos", nl);

   fd = open(KMEM, O_RDONLY);

   err = lseek(fd, nl[0].n_value, SEEK_SET);
   sys_inode = (struct nc1inode *)malloc(sizeof(struct nc1inode));

   err = read(fd, (char *)&v, sizeof(struct var));
   err = lseek(fd, wtob(v.vb_nc1inode), SEEK_SET);

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
                  sys_vnode = (struct vnode *)malloc(sizeof(struct vnode));
                  fd2 = open(KMEM, O_RDONLY);
                  err = lseek(fd2, (long)fs_node->mntptr->m_root*8, SEEK_SET);
                  err = read(fd2, (char *)sys_vnode, sizeof(struct vnode));
                  close(fd2);

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
#endif

                  close(fd);
                  return(sys_inode);
               }
            }
         }
      }
   }

   close(fd);
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
struct nlist nl[2];

struct var v;

   nl[0].n_name = "v";
   nl[1].n_name = NULL;

   nlist("/unicos", nl);

   sys_mount = (struct mount *)malloc(sizeof(struct mount));

   if ((fd = open(KMEM, O_RDONLY)) == ERR)
      logerr("get_mem_mount: open/memory/mount");

   if ((err = lseek(fd, nl[0].n_value, SEEK_SET)) == ERR)
      logerr("get_mem_mount: lseek,nl/memory/mount");

   if ((err = read(fd, (char *)&v, sizeof(struct var))) == ERR)
      logerr("get_mem_mount: read/memory/mount");

   if ((err = lseek(fd, wtob(v.vb_mount), SEEK_SET)) == ERR)
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

            close(fd);
            return(sys_mount);
         }
      }
   }
   close(fd);
   free(sys_mount);
   return(NULL);
}

int dumper(sys_super, fs_node)
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
   if ((err = lseek(fd, BSIZE, SEEK_SET)) == ERR)
      logerr("get_dsk_super: lseek/disk/super");
   if ((err = read(fd, (char *)sys_super, BSIZE)) == ERR)
      logerr("get_dsk_super: read/disk/super");
   close(fd);

#ifdef DEBUG
   printf("ON DISK SUPER DUMP\n");
   dumper(sys_super, fs_node);
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

   sys_super = (struct nc1filsys *)malloc(BSIZE);
   if ((fd = open(KMEM, O_RDONLY)) == ERR)
      logerr("get_mem_super: open/memory/super");
   if ((err = lseek(fd, wtob(fs_node->mntptr->m_bufp), SEEK_SET)) == ERR)
      logerr("get_mem_super: lseek/memory/super/mount");
   if ((err = read(fd, (char *)&my_buffer, sizeof(struct buf))) == ERR)
      logerr("get_mem_super: read/memory/super");
   if ((err = lseek(fd, wtob(my_buffer.b_maddr.bb_waddr), SEEK_SET)) == ERR)
      logerr("get_mem_super: lseek/memory/super/buffer");
   if ((fs_node->mem_offset = lseek(fd, 0, SEEK_CUR)) == ERR)
      logerr("get_mem_super: lseek/memory/super/offset");
   if ((err = read(fd, (char *)sys_super, BSIZE)) == ERR)
      logerr("get_mem_super: read/memory/super");
   close(fd);

#ifdef DEBUG
   printf("IN MEMORY SUPER DUMP\n");
   dumper(sys_super, fs_node);
   printf("OFFSET:  %d\n", fs_node->mem_offset);
#endif

   return(sys_super);
  
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

