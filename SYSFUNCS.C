#include <stdio.h>
#include <stropts.h>
#include <poll.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <sys/times.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/mman.h>
#include <sys/uio.h>
#include <sys/dirent.h>
#include <sys/statvfs.h>
#include <sys/filio.h>
#include <sys/ioctl.h>
#include <priv.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <utime.h>
#include <limits.h>

/*********************
* Declare system calls
*********************/

#if defined(__STDC__)
extern int open(const char *path, int, ...);
extern int creat(const char *path, mode_t mode);
extern int link(const char *param1, const char *param2);
extern int unlink(const char *param1);
extern int execl(const char *, const char *, ...);
extern int execle(const char *, const char *, ...);
extern int execlp(const char *, const char *, ...);
extern int execv(const char *, char *const *);
extern int execve(const char *, char *const *, char *const *);
extern int execvp(const char *, char *const *);
extern int chmod(const char *path, mode_t mode);
extern int chown(const char *path, uid_t owner, gid_t group);
extern int lchown(const char *path, uid_t owner, gid_t group);
extern int stat(const char *path, struct stat *buf);
extern int utime(const char *path, const struct utimbuf *times);
extern int access(const char *path, int amode);
extern int symlink(const char *name1, const char *name2);
extern int readlink(const char *, void *, int);
extern int mknod(const char *path, mode_t mode, dev_t dev);
extern int mkdir(const char *path, mode_t mode);
extern int rmdir(const char *path);
extern int lstat(const char *path, struct stat *buf);
extern int mkfifo(const char *path, mode_t mode);
extern int truncate(const char *path, off_t length);
extern int close(int fildes), dup(int fildes), pipe(int fildes[2]);
extern int fcntl(int fildes, int cmd, ...), fchmod(int fildes, mode_t mode);
extern int fchown(int fildes, uid_t owner, gid_t group);
extern int fstat(int fildes, struct stat *buf);
extern int getmsg(int fd, struct strbuf *ctlptr, struct strbuf *dataptr, int *flagsp);
extern int getpmsg(int fd, struct strbuf *ctlptr, struct strbuf *dataptr, int *bandp, int *flagsp);
extern int putmsg(int fd, const struct strbuf *ctlptr, const struct strbuf *dataptr, int flags);
extern int putpmsg(int fd, const struct strbuf *ctlptr, const struct strbuf *dataptr, int band, int flags);
extern int poll(struct pollfd *fds, unsigned long nfds, int timeout);
extern int ftruncate(int fildes, off_t length);
extern int rename(const char *old, const char *new);
extern int chdir(const char *path);
extern int fchdir(int fildes);
extern int chroot(const char *path);
extern int statvfs(const char *path, struct statvfs *buf);
extern int fstatvfs(int fildes, struct statvfs *buf);
extern int filepriv(const char *path, int cmd, priv_t *privp, int nentries);
extern pid_t fork(void), fork1(void);
extern pid_t wait(int *stat_loc), getpid(void), getpgrp(void);
extern pid_t setpgrp(void), getsid(pid_t pid), setsid(void), getpgid(pid_t pid);
extern gid_t getgid(void);
extern time_t time(time_t *tloc);
extern void *sbrk(int incr), sync(void), *shmat(int, const void *, int);
#ifdef BSD44
extern offset_t llseek(int fildes, offset_t offset, int whence);
/* extern void profil(unsigned short *, unsigned int, unsigned int, unsigned int); */
#else
extern off_t lseek(int fildes, off_t offset, int whence);
extern void profil(unsigned short *, unsigned int, unsigned int, unsigned int); 
#endif
extern uid_t getuid(void);
extern unsigned alarm(unsigned sec);
extern clock_t times(struct tms *buffer);
extern mode_t umask(mode_t cmask);
extern long ulimit(int cmd, ...), pathconf(const char *path, int name);
extern long fpathconf(int fildes, int name);
extern long sysinfo(int command, char *buf, long count);
extern caddr_t mmap(caddr_t addr, size_t len, int prot, int flags,
                    int fildes, off_t off);
#ifdef BSD44
extern ssize_t readv(int fildes, struct iovec *iov, int iovcnt);
#else
extern ssize_t readv(int fildes, const struct iovec *iov, int iovcnt);
extern ssize_t write(int fildes, const void *buf, size_t nbyte);
extern ssize_t writev(int fildes, const struct iovec *iov, int iovcnt);
extern ssize_t read(int fildes, void *buf, size_t nbyte);
extern ssize_t readv(int fildes, const struct iovec *iov, int iovcnt);
extern ssize_t pwrite(int fd, const void *buf, size_t nbytes, off_t offset);
extern ssize_t pread(int fd, void *buf, size_t nbytes, off_t offset);
extern void (*signal(int, void(*)(int)))(int);
extern void (*sigset(int, void(*)(int)))(int);
#endif
#else
extern int open(), creat(), link(), unlink(), chmod(), close();
extern int execl(), execle(), execlp(), execv(), execve(), execvp();
extern int chown(), stat(), utime(), access(), lchown(), mkdir(), rmdir();
extern int lstat(), symlink(), readlink(), mknod(), mkfifo(), truncate();
extern int close(), dup(), pipe(), fcntl(), fchmod(), fchown(), fstat();
extern int getdents(), ioctl(), getmsg(), getpmsg(), putmsg(), putpmsg();
extern int poll(), ftruncate(), rename(), chdir(), chroot(), statvfs();
extern int fchdir(), fstatvfs(), filepriv();
extern pid_t wait(), getpid(), getpgrp(), setpgrp(), getsid(), setsid();
extern pid_t getpgid(), fork(), fork1();
extern gid_t getgid();
extern off_t lseek();
extern time_t time();
extern void *sbrk(), sync(), *shmat(), profil(), (*signal())();
extern void (*signal())();
extern offset_t llseek();
extern uid_t getuid();
extern unsigned alarm();
extern clock_t times();
extern mode_t umask();
extern long ulimit(), pathconf(), fpathconf(), sysinfo();
extern caddr_t mmap();
extern ssize_t read(),write(), readv(), pread(), writev(), pwrite();
#endif

#define MAX_FILES        64
#define MAX_FILESIZE    256
#define MAX_PATHLENGTH 1024
#define DEBUG(a) if (a <= DEBUG_LEVEL)

extern int Fork_Counter, Fork_Limit, MaxFiles, Random_Filenames;
extern int DEBUG_LEVEL;
extern struct disk_objects DiskFiles[];

static int InDex=0;
char PathName[1024];

/*
*****************************************
* Declare Disk File Information Structure
*****************************************
*/

struct disk_objects {
   char diskname[MAX_FILESIZE];
   char pathname[MAX_PATHLENGTH];
   int active_fd;
} DiskFiles[MAX_FILES];


/*
***************************************
* Randomly select a filename and return
* numeric index to it
***************************************
*/

int get_a_file()
{
   int rc;

   rc = (InDex*getpid())%MAX_FILES;
   if ( DiskFiles[rc].pathname[0] == '\0') {
      strcpy(DiskFiles[rc].pathname,getcwd((char *)NULL, 80));
   }
   strcpy(PathName, DiskFiles[rc].pathname);
   strcat(PathName, "/");
   strcat(PathName, DiskFiles[rc].diskname);
   DEBUG(2) { fprintf(stdout, "PathName = %s\n", PathName); 
            fflush(stdout); }
   InDex++;
   return(rc);

}

/*
******************************************
* Install current working directory within
* disk file object pathname component
******************************************
*/

int change_pathname(int index)
{
    strcpy(DiskFiles[index].pathname, getcwd((char *)NULL, 80));
}


/*
*************************************************
* init_data - Initialize and read in SYSCALL_DATA
*************************************************
*/
int init_filenames(char *filename)
{
   int a;
   char *r, temp[MAX_FILESIZE];

   /* 
   ***********************
   * Create Disk Filenames
   ***********************
   */
   for (a=0; a < MAX_FILES; a++) {
       if (filename) {
          sprintf(temp, "%s%d", filename, a);
       } else {
          r=strrchr(tmpnam(NULL), '/');
          r++;
          sprintf(temp, "%s%d", r, a);

       }

       strcpy(DiskFiles[a].diskname, temp);
       DiskFiles[a].pathname[0]='\0';
       DiskFiles[a].active_fd=-1;
   }
   
   /*
   *  for (a=0; a < MAX_FILES; a++) {
   *      fprintf(stdout, "DiskFiles[%d].diskname = %s\n", a, DiskFiles[a].diskname);
   * exit(1);
   */
   return 0;
}


/*
********************
* A Nothing Function
********************
*/
int nosys()
{
    return(0);
}

/*
**********************
* Functions to handle: 
*    type differences
*    special needs
**********************
*/
int myfork()
{
   if (Fork_Limit) {
      if (Fork_Counter = Fork_Limit) {
         if (getppid() > 1) {
            Fork_Counter++;
            if (fork() < 0)
               Fork_Counter--; 
         } else {
            exit(1);
         }
      } else {
         return(0);
      }
   } else {
      return(fork());
   }
}

int myfork1()
{
   if (Fork_Limit) {
      if (Fork_Counter = Fork_Limit) {
         if (getppid() > 1) {
            Fork_Counter++;
            if (fork() < 0)
               Fork_Counter--; 
         } else {
            exit(1);
         }
      } else {
         return(0);
      }
   } else {
      return(fork1());
   }
}

int myopen(char *param1, int param2, int param3, int param4, int param5)
{
   int a, rc;

   if (Random_Filenames) {
      return(open(param1,param2,param3,param4,param5));
    } else {
      a=get_a_file();
      if ((rc=open(PathName, param2,param3,param4,param5)) != -1) {
         DiskFiles[a].active_fd=rc;
      } else {
         change_pathname(a);
      }
      return(rc);
    }
}


int mywait(int param1)
{
   int rc;

   rc=wait(&param1);
   if (rc > 0 )
      Fork_Counter--; 
   return(rc);
}

int mytime(time_t param1)
{
   return(time(&param1));
}

int mysbrk(int param1)
{
   sbrk(param1);
   return(0);
}

int mylseek(int param1, long param2, int param3)
{
   if (Random_Filenames)
      return(lseek(param1,param2,param3));
}

int mygetpid()
{
   return(getpid());
}

int mygetuid()
{
   return(getuid());
}

int myalarm(unsigned param1)
{
   return(alarm(param1));
}

int mysync()
{
   sync();
   return(0);
}

int mygetpgrp()
{
   return(getpgrp());
}

int mysetpgrp()
{
   return(setpgrp());
}

int mygetsid(pid_t param1)
{
   return(getsid(param1));
}

int mysetsid()
{
   return(setsid());
}

int mygetpgid(pid_t param1)
{
   return(getpgid(param1));
}

int mytimes(struct tms param1)
{
   return(times(&param1));
}

int mygetgid()
{
   return(getgid());
}

int myshmat(int param1, void *param2, int param3)
{
   shmat(param1, param2, param3);
   return(0);
}

int myumask(mode_t param1)
{
   return(umask(param1));
}

int myulimit(int param1, int param2)
{
   ulimit(param1, param2);
   return(0);
}

int mypathconf(const char param1, int param2)
{
   pathconf(&param1, param2);
   return(0);
}

int mymmap(caddr_t param1, size_t param2, int param3, int param4,
          int param5, off_t param6)
{
   mmap(param1, param2, param3, param4, param5, param6);
   return(0);
}

int myfpathconf(int param1, int param2)
{
   if (Random_Filenames)
      fpathconf(param1, param2);
   return(0);
}

int myreadv(int param1, struct iovec param2, int param3)
{
   int afd, avail;

   if (Random_Filenames)
      afd=param1;

   if (ioctl(afd, FIONREAD, &avail) != -1) {
         if (avail > 0)
            return(readv(afd, &param2, param3));
         else
            return(0);
      } else {
         return(readv(afd, &param2, param3));
      }
}

int mysysinfo(int param1, char param2, long param3)
{
   sysinfo(param1, &param2, param3);
   return(0);
}

int myprofil(unsigned short *param1, unsigned int param2, unsigned int param3, unsigned int param4)
{
   (void) profil(param1, param2, param3, param4);
   return(0);
}

void mysighdlr(int signo) {}

int mysignal(int param1)
{
   (void) signal(param1, mysighdlr);
   return(0);
}

int mysigset(int param1)
{
   (void) sigset(param1, mysighdlr);
   return(0);
}

int mycreat(const char *param1, mode_t param2)
{
   int a, rc;

   if (Random_Filenames) {
      return(creat(param1,param2));
   } else {
      a=get_a_file();
      if ((rc=creat(PathName, param2)) != -1) {
         DiskFiles[a].active_fd=rc;
      } else {
         change_pathname(a);
      }
      return(rc);
   }
}

int mylink(const char *param1, const char *param2)
{
   if (Random_Filenames) {
      return(link(param1,param2));
   } else {
      get_a_file();
      return(link(PathName, param2));
   }
}

int myunlink(const char *param1)
{
   if (Random_Filenames) {
      return(unlink(param1));
   } else {
      get_a_file();
      return(unlink(PathName));
   }
}

int myexecl(const char *param1, const char *param2, ...)
{
   if (Random_Filenames) {
      return(execl(param1, param2));
   } else {
      get_a_file();
      return(execl(PathName, param2));
   }
}

int myexecle(const char *param1, const char *param2, ...)
{
   if (Random_Filenames) {
      return(execle(param1, param2));
   } else {
      get_a_file();
      return(execlp(PathName, param2));
   }
}

int myexeclp(const char *param1, const char *param2, ...)
{
   if (Random_Filenames) {
      return(execlp(param1, param2));
   } else {
      get_a_file();
      return(execlp(PathName, param2));
   }
}

int myexecv(const char *param1, char *const *param2)
{
   if (Random_Filenames) {
      return(execv(param1, param2));
   } else {
      get_a_file();
      return(execv(PathName, param2));
   }
}

int myexecve(const char *param1, char *const *param2, char *const *param3)
{
   if (Random_Filenames) {
      return(execve(param1, param2, param3));
   } else {
      get_a_file();
      return(execve(PathName, param2, param3));
   }
}

int myexecvp(const char *param1, char *const *param2)
{
   if (Random_Filenames) {
      return(execvp(param1, param2));
   } else {
      get_a_file();
      return(execvp(PathName, param2));
   }
}

int mychmod(const char *param1, mode_t param2)
{
   if (Random_Filenames) {
      return(chmod(param1, param2));
   } else {
      get_a_file();
      return(chmod(PathName, param2));
   }
}

int mychown(const char *param1, uid_t param2, gid_t param3)
{
   if (Random_Filenames) {
      return(chown(param1, param2, param3));
   } else {
      get_a_file();
      return(chown(PathName, param2,param3));
   }
}

int mystat(const char *param1, struct stat *param2)
{
   if (Random_Filenames) {
      return(stat(param1, param2));
   } else {
      get_a_file();
      return(stat(PathName, param2));
   }
}

int myutime(const char *param1, const struct utimbuf *param2)
{
   if (Random_Filenames) {
      return(utime(param1, param2));
   } else {
      get_a_file();
      return(utime(PathName, param2));
   }
}

int myaccess(const char *param1, int param2)
{
   if (Random_Filenames) {
      return(access(param1, param2));
   } else {
      get_a_file();
      return(access(PathName, param2));
   }
}

int mylchown(const char *param1, uid_t param2, gid_t param3)
{
   if (Random_Filenames)
      return(lchown(param1, param2, param3));
}

int myrmdir(const char *param1)
{
   int a;

   if (Random_Filenames) {
      return(rmdir(param1));
   } else {
      a=get_a_file();
      if (rmdir(PathName) != -1) {
         change_pathname(a);
      }
   }
}

int mymkdir(const char *param1, mode_t param2)
{
   int a, rc;

   if (Random_Filenames) {
      return(mkdir(param1, param2));
   } else {
      a=get_a_file();
      if ((rc=mkdir(PathName, param2)) == -1) {
         change_pathname(a);
      }
      return(rc); 
   }
}

int mylstat(const char *param1, struct stat *param2)
{
   if (Random_Filenames) {
      return(lstat(param1, param2));
   } else {
      get_a_file();
      return(lstat(PathName, param2));
   }
}

int mysymlink(const char *param1, const char *param2)
{
   if (Random_Filenames) {
      return(symlink(param1, param2));
   } else {
      get_a_file();
      return(symlink(PathName, param2));
   }
   
}

int myreadlink(const char *param1, void *param2, int param3)
{
   if (Random_Filenames) {
      return(readlink(param1, param2, param3));
   } else {
      get_a_file();
      return(readlink(PathName, param2, param3));
   }
}

int mymknod(const char *param1, mode_t param2, dev_t param3)
{
   if (Random_Filenames) {
      return(mknod(param1, param2, param3));
   } else {
      get_a_file();
      return(mknod(PathName, param2, param3));
   }
}

int mymkfifo(const char *param1, mode_t param2)
{
   if (Random_Filenames) {
      return(mkfifo(param1, param2));
   } else {
      get_a_file();
      return(mkfifo(PathName, param2));
   }
}

int mytruncate(const char *param1, off_t param2)
{
   if (Random_Filenames) {
      return(truncate(param1, param2));
   } else {
      get_a_file();
      return(truncate(PathName, param2));
   }
}

int myftruncate(int param1, off_t param2)
{
   int a, rc;
   if (Random_Filenames) {
      return(ftruncate(param1, param2));
   } else {
      a=get_a_file();
      rc=ftruncate(DiskFiles[a].active_fd, param2);
      return(rc);
   }
}

int mywrite(int param1, const void *param2, size_t param3)
{
   int a, rc;

   if (Random_Filenames) {
      return(write(param1, param2, param3));
   } else {
      a=get_a_file();
      rc=write(DiskFiles[a].active_fd, param2, param3);
      return(rc);
   }
}

int mywritev(int param1, const struct iovec *param2, int param3)
{
   int a, rc;

   if (Random_Filenames) {
      return(writev(param1, param2, param3));
   } else {
      a=get_a_file();
      rc=writev(DiskFiles[a].active_fd, param2, param3);
      return(rc);
   }
}

int myclose(int param1)
{
   int a, rc;

   if (Random_Filenames) {
      return(myclose(param1));
   } else {
      a=get_a_file();
      if ((rc=close(DiskFiles[a].active_fd)) != -1)
         DiskFiles[a].active_fd=-1;
      return(rc);
   }
}

int mydup(int param1)
{
   int a, rc;

   if (Random_Filenames) {
      return(dup(param1));
   } else {
      a=get_a_file();
      if ((rc=dup(DiskFiles[a].active_fd)) != -1) {
         close(DiskFiles[a].active_fd);
         DiskFiles[a].active_fd=rc;
      }
      return(rc);
   }
}

int myread(int param1, void *param2, size_t param3)
{
   int a, afd, avail;

   if (Random_Filenames) {
       afd=param1;
   } else {
      a=get_a_file();
      afd=DiskFiles[a].active_fd;
   }

   if (ioctl(afd, FIONREAD, &avail) != -1) {
      if (avail > 0)
         return(read(afd, &param2, param3));
      else
         return(0);
   } else {
      return(read(afd, &param2, param3));
   }
}

int mypipe(int param1, int param2)
{
   int a, b;
   static int fildes[2];

   if (Random_Filenames) {
      fildes[0]=param1;
      fildes[1]=param2;
      return(pipe(&fildes[2]));
   } else {
      if (pipe(&fildes[2]) != -1) {
          for (a=b=0; a < MAX_FILES; a++) {
              if (DiskFiles[a].active_fd == -1) {
                 DiskFiles[a].active_fd=fildes[b++];
                 if (b > 1)
                    break;
              }
          }
      }
   }
}

int myfcntl(int param1, int param2, int param3)
{
   int a, rc;

   if (Random_Filenames) {
      return(fcntl(param1, param2, param3));
   } else {
      a=get_a_file();
      rc=fcntl(DiskFiles[a].active_fd, param2, param3);
      return(rc);
   }
}

int myfchmod(int param1, mode_t param2)
{
   int a, rc;

   if (Random_Filenames) {
      return(fchmod(param1, param2));
   } else {
      a=get_a_file();
      rc=fcntl(DiskFiles[a].active_fd, param2);
      return(rc);
   }
}

int myfchown(int param1, uid_t param2, gid_t param3)
{
   int a, rc;

   if (Random_Filenames) {
      return(fchown(param1, param2, param3));
   } else {
      a=get_a_file();
      rc=fchown(DiskFiles[a].active_fd, param2, param3);
      return(rc);
   }
}

int myfstat(int param1, struct stat *param2)
{
   int a, rc;

   if (Random_Filenames) {
      return(fstat(param1, param2));
   } else {
      a=get_a_file();
      rc=fstat(DiskFiles[a].active_fd, param2);
      return(rc);
   }
}

int mypwrite(int param1, const void *param2, size_t param3, off_t param4)
{
   int a, rc;

   if (Random_Filenames) {
      return(pwrite(param1, param2, param3, param4));
   } else {
      a=get_a_file();
      rc=pwrite(DiskFiles[a].active_fd, param2, param3, param4);
      return(rc);
   }
}

int mypread(int param1, void *param2, size_t param3, off_t param4)
{
   int a, afd, avail;

   if (Random_Filenames) {
       afd=param1;
   } else {
      a=get_a_file();
      afd=DiskFiles[a].active_fd;
   }

   if (ioctl(afd, FIONREAD, &avail) != -1) {
      if (avail > 0)
         return(pread(afd, &param2, param3, param4));
      else
         return(0);
   } else {
      return(pread(afd, &param2, param3,param4));
   }
}

int mygetdents(int param1, struct dirent *param2, size_t param3)
{
   int a, afd, avail;

   if (Random_Filenames) {
       afd=param1;
   } else {
      a=get_a_file();
      afd=DiskFiles[a].active_fd;
   }

   if (ioctl(afd, FIONREAD, &avail) != -1) {
      if (avail > 0)
         return(getdents(afd, param2, param3));
      else
         return(0);
   } else {
      return(getdents(afd, param2, param3));
   }
}

int myioctl(int param1, int param2, int param3)
{
   int a, afd, avail;

   if (Random_Filenames) {
       afd=param1;
   } else {
      a=get_a_file();
      afd=DiskFiles[a].active_fd;
   }
   return(ioctl(afd, param2, param3));
}

int mygetmsg(int param1, struct strbuf *param2, struct strbuf *param3, int *param4)
{
   int a, afd, avail;

   if (Random_Filenames) {
      afd=param1;
   } else {
      a=get_a_file();
      afd=DiskFiles[a].active_fd;
   }

   if (ioctl(afd, FIONREAD, &avail) != -1) {
      if (avail > 0)
         return(getmsg(afd, param2, param3, param4));
      else
         return(0);
   } else {
      return(getmsg(afd, param2, param3, param4));
   }
}

int mygetpmsg(int param1, struct strbuf *param2, struct strbuf *param3, int *param4, int *param5)
{
   int a, afd, avail;

   if (Random_Filenames) {
      afd=param1;
   } else {
      a=get_a_file();
      afd=DiskFiles[a].active_fd;
   }

   if (ioctl(afd, FIONREAD, &avail) != -1) {
      if (avail > 0)
         return(getpmsg(afd, param2, param3, param4, param5));
      else
         return(0);
   } else {
      return(getpmsg(afd, param2, param3, param4, param5));
   }
}

int myputmsg(int param1, const struct strbuf *param2, const struct strbuf *param3, int param4)
{
   int a, rc;

   if (Random_Filenames) {
      return(putmsg(param1, param2, param3, param4));
   } else {
      a=get_a_file();
      rc=putmsg(DiskFiles[a].active_fd, param2, param3, param4);
      return(rc);
   }
}

int myputpmsg(int param1, struct strbuf *param2, struct strbuf *param3, int param4, int param5)
{
   int a, rc;

   if (Random_Filenames) {
      return(putpmsg(param1, param2, param3, param4, param5));
   } else {
      a=get_a_file();
      rc=putpmsg(DiskFiles[a].active_fd, param2, param3, param4, param5);
      return(rc);
   }
}

int mypoll(struct pollfd *param1, unsigned long param2, int param3)
{
   if (Random_Filenames)
      return(poll(param1, param2, param3));
}

int myrename(const char *param1, const char *param2)
{
   if (Random_Filenames) {
      return(rename(param1, param2));
   } else {
     get_a_file();
     return(rename(PathName, param2));
   }
}

int mychdir(const char *param1)
{
   if (Random_Filenames) {
      return(chdir(param1));
   } else {
     get_a_file();
     return(chdir(PathName));
   }
}

int myfchdir(int param1)
{
   int a;

   if (Random_Filenames) {
      return(fchdir(param1));
   } else {
     a=get_a_file();
     return(fchdir(DiskFiles[a].active_fd));
   }
}

int mychroot(const char *param1)
{
   if (Random_Filenames) {
      return(chroot(param1));
   } else {
     get_a_file();
     return(chroot(PathName));
   }
}

int mystatvfs(const char *param1, struct statvfs *param2)
{
   if (Random_Filenames) {
      return(statvfs(param1,param2));
   } else {
     get_a_file();
     return(statvfs(PathName, param2));
   }
}

int myfstatvfs(int param1, struct statvfs *param2)
{
   int a; 

   if (Random_Filenames) {
      return(fstatvfs(param1,param2));
   } else {
     a=get_a_file();
     return(fstatvfs(DiskFiles[a].active_fd, param2));
   }
}

int myfilepriv(const char *param1, int param2, priv_t *param3, int param4)
{

   if (Random_Filenames) {
      return(filepriv(param1,param2,param3,param4));
   } else {
      get_a_file();
      return(filepriv(PathName, param2, param3, param4));
   }
}
