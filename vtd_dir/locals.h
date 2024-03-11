#define READLEN 512
#define DIRLEN 512

#define MAXLEV 5
#define MAXRISK 5
#define MAXTESTS 32
#define MAXMUTCLEAN 1800
#define MAXTIMEOUT 172800
#define MAXREPEAT 32
#define ID_COL 2
#define MAXARGS 48

#define UNK 0
#define NEEDFS 1
#define UNSUPP 2
#define NRTYPE 3
#define NOEXIST 4
#define SUIDFAIL 5
#define NOTROOT 6
#define NEEDMEM 7

#define SUIDFAIL_EXIT 103

#define NFS_SUPER_MAGIC 0x6969

#define EXT_SUPER_MAGIC 0x137D
#define EXT2_OLD_SUPER_MAGIC 0xEF51
#define EXT2_SUPER_MAGIC 0xEF53
#define EXT3_SUPER_MAGIC 0xEF53
#define REISERFS_SUPER_MAGIC 0x52654973
#define JFFS2_SUPER_MAGIC 0x72b6
#define UFS_MAGIC 0x00011954

#define BLOCK_SIZE 4096

struct tdata {
   int type;
   int passval;
   int resstat;
   int scon;
   int mbs;
   int mcon;
   int sup;
   int pid;
   int exists;
   int start_time;
   int end_time;
   int max_time;
   int run_cnt;
   int run_done;
   int newsess;
   int copy;
   char *suite;
   char *category;
   char *name;
   char *path;
   char *directory;
   char *directory_base;
   char *cmdline;
   char *holdargs;
   char **args;
};

struct limitations {
   int type;
   int sess;
   int mbs;
   int passval;
   int scon;
   int exists;
   int mcon;
   int sup;
   int max_time;
   int run_cnt;
   int copy;
   char *suite;
   char *category;
   char *name;
};

struct thing {
   int line;
   int used;
};

