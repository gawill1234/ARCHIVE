#ifndef BSD44
#include  <limits.h>
#endif
#include <sys/types.h>
#include <stdio.h>
#include <unistd.h>
#include <stropts.h>
#include <poll.h>
#include <sys/lwp.h>
#ifdef BSD44
#include <sys/synch.h>
#else
#include <synch.h>
#include <priv.h>
#include <acl.h>
#include <audit.h>
#endif
#include <sys/stat.h>
#include <sys/ustat.h>
#include <sys/param.h>
#include <sys/procset.h>
#include <sys/priocntl.h>
#include <sys/rtpriocntl.h>
#include <sys/tspriocntl.h>
#include <sys/statvfs.h>
#include <sys/dirent.h>
#include <sys/times.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <sys/signal.h>
#include <sys/mman.h>
#include <sys/ipc.h>
#include <sys/sem.h>
#include <sys/msg.h>
#include <sys/mount.h>
#include <sys/processor.h>
#include <sys/procset.h>
#include <sys/uio.h>
#include <sys/swap.h>
#include <sys/fstyp.h>
#include <sys/fsid.h>
#include <sys/uadmin.h>
#include <sys/utsname.h>
#include <sys/wait.h>
#ifdef BSD44
#include <bsm/audit.h>
#else
#include <sys/lock.h>
#include <sys/keyctl.h>
#include <sys/secsys.h>
#endif
#include <ucontext.h>
#include <fcntl.h>
#include <utime.h>
/* #include <limits.h> */
/* #include <ulimit.h> */

#ifdef _cplusplus
extern "C" {
#endif

/*********************
* Declare system calls
*********************/

#if defined(__STDC__)
extern void _exit(int status), _lwp_exit(void), *_lwp_getprivate(void);
#ifdef BSD44
extern void vhangup(void);
#endif
extern void _lwp_setprivate(void *buffer);
extern void _lwp_makecontext(ucontext_t *ucp, void (*start_routine)( void *),
                           void *arg, void *private, caddr_t stack_base,
                           size_t stack_size);
extern int _lwp_cond_broadcast(lwp_cond_t *cvp);
extern int _lwp_cond_signal(lwp_cond_t *cvp);
#ifdef BSD44
extern int _lwp_cond_timedwait(lwp_cond_t *cvp, lwp_mutex_t *p, timestruc_t *abstime);
#else
extern int _lwp_cond_timedwait(lwp_cond_t *cvp, lwp_mutex_t *p, const timestruc_t *abstime);
#endif
extern int _lwp_cond_wait(lwp_cond_t *cvp, lwp_mutex_t *mp);
extern int _lwp_continue(lwpid_t target_lwp);
extern int _lwp_create(ucontext_t *contextp, unsigned long flags, lwpid_t *new_lwp);
extern int _lwp_info(struct lwpinfo *buffer);
extern int _lwp_kill(lwpid_t target_lwp, int sig);
extern int _lwp_mutex_lock(lwp_mutex_t *mp);
extern int _lwp_mutex_trylock(lwp_mutex_t *mp);
extern int _lwp_mutex_unlock(lwp_mutex_t *mp);
extern lwpid_t _lwp_self(void);
#ifdef BSD44
extern int _lwp_sema_init(lwp_sema_t *sema, int count);
extern int _lwp_sema_post(lwp_sema_t *sema);
extern int _lwp_sema_wait(lwp_sema_t *sema);
#else
extern int _lwp_sema_init(_lwp_sema_t *sema, int count);
extern int _lwp_sema_post(_lwp_sema_t *sema);
extern int _lwp_sema_wait(_lwp_sema_t *sema);
#endif
extern int _lwp_suspend(lwpid_t target_lwp);
extern int _lwp_wait(lwpid_t wait_for, lwpid_t *departed_lwp);
extern int adjtime(struct  timeval  *delta,  struct  timeval  *olddelta);
extern int audit(caddr_t record, int length);
extern int auditon( int cmd, caddr_t data, int length);
extern int auditsvc( int fd, int limit), brk(void *endds);
#ifdef BSD44
extern int getaudit( struct auditinfo *info), getauid( au_id_t *auid);
#else
extern int keyctl(int cmd, void *arg, int nskeys);
extern int aclipc(int type, int id, int cmd, int nentries, struct acl *aclbufp);
extern int acl(char *pathp, int cmd, int nentries, struct acl *aclbufp);
extern int auditevt(int cmd, struct aevt *aevtp, int size);
extern int auditctl(int cmd, struct actl *actlp, int size);
extern int auditdmp(struct arec *arecp, int size);
extern int auditlog(int cmd, struct alog *alogp, int size);
extern int auditbuf(int cmd, struct abuf *bufp, int size);
extern int secadvise(struct obj_attr *obj, int cmd, struct sub_attr *sub);
extern int gettimeofday(struct timeval *tp, struct timezone *);
extern int settimeofday(struct timeval *tp, struct timezone *);
#endif
extern int getcontext(ucontext_t *ucp);
extern gid_t getegid(void);
extern uid_t geteuid(void);
extern int getgroups(int gidsetsize, gid_t *grouplist);
extern int getitimer(int which, struct itimerval *value);
extern pid_t getppid(void), getsid(pid_t pid);
extern int getrlimit(int resource, struct rlimit *rlp);
extern int memcntl(caddr_t addr, size_t len, int cmd, caddr_t arg, int attr, int mask);
extern int mincore(caddr_t addr, size_t len, char *vec);
extern int mount(const char *, const char *, int, ...);
extern int mprotect(caddr_t addr, size_t len, int prot);
extern int msgget(key_t key, int msgflg);
#ifdef BSD44
extern int msgctl(int msqid, int cmd, ...);
#else
extern int msgctl(int msqid, int cmd, struct msqid_ds *);
extern int procpriv(int cmd, priv_t *privp, int nentries);
#endif
extern int msgrcv(int msqid, void *msgp, size_t msgsz, long msgtyp, int msgflg);
extern int msgsnd(int msqid, const void *msgp, size_t msgsz, int msgflg);
extern int munmap(caddr_t addr, size_t len);
extern int nice(int incr);
extern int p_online(processorid_t processorid, int flag);
extern int pause(void);
/* extern long priocntl(int, idtype_t, id_t, caddr_t);
* extern long priocntlset(int, procset_t *, caddr_t);
*/
extern int processor_bind(idtype_t  idtype, id_t id,
                          processorid_t processorid, processorid_t *obind);
extern int processor_info(processorid_t processorid, processor_info_t *infop);
extern int ptrace(int request, pid_t pid, int addr, int data);
extern int semctl(int semid, int semnum, int cmd, ...);
extern int semget(key_t key, int nsems, int semflg);
extern int semop(int semid, struct sembuf *sops, size_t nsops);
#ifdef BSD44
extern int setaudit( struct auditinfo *info);
extern int setauid( au_id_t *auid), etcontext(ucontext_t *ucp);
#endif
extern int setegid(gid_t egid), seteuid(uid_t euid), setgid(gid_t gid);
extern int setgroups(int ngroups, const gid_t *grouplist);
extern int setitimer(int, struct itimerval *, struct itimerval *);
extern int setpgid(pid_t pid, pid_t pgid);
extern int setrlimit(int resource, const struct rlimit *rlp);
extern int setuid(uid_t uid), shmctl();
extern int shmdt(const void *);
extern int shmget(key_t key, size_t size, int shmflg);
extern int sigaction(int sig, const struct sigaction *act,
                    struct sigaction *oact);
extern int sigaltstack(const stack_t *ss, stack_t *oss);
extern int sigpending(sigset_t *set);
extern int sigprocmask(int  how,  const  sigset_t  *set,  sigset_t *oset);
extern int sigsend(idtype_t idtype, id_t id, int sig);
#ifdef BSD44
extern int sigsendset(procset_t *psp, int sig);
#else
extern int sigsendset(const procset_t *psp, int sig);
extern int sighold(int sig), sigrelse(int sig), sigignore(int sig);
#endif
extern int sigsuspend(const sigset_t *set);
extern int sigwait(sigset_t *set);
extern int stime(const time_t *tp);
extern int swapctl(int cmd, void *arg);
extern int sysfs(int, ...);
extern int uadmin(int cmd, int fcn, int mdep), umount(const char *file);
extern int uname(struct utsname *name);
extern int ustat(dev_t dev, struct ustat *buf);
extern int utimes(char *file, struct timeval *tvp);
extern pid_t vfork(void);
extern int waitid(idtype_t idtype, id_t id, siginfo_t *infop,
                 int options);
extern pid_t waitpid(pid_t pid, int *stat_loc, int options);
#else
extern int _lwp_cond_broadcast(), _lwp_cond_signal(), _lwp_cond_timedwait();
extern int _lwp_cond_wait(), _lwp_continue(), _lwp_create(), _lwp_info();
extern int _lwp_kill(), lwp_mutex_lock(), _lwp_mutex_trylock(), _lwp_mutex_unlock();
extern int _lwp_sema_init(), _lwp_sema_post(), _lwp_sema_wait(), _lwp_suspend();
extern int _lwp_wait();
extern int acct(), adjtime(), audit(), auditon(), auditsvc(), brk();
extern int getcontext(), getgroups(), getitimer(), getrlimit(), kill();
extern int memcntl(), mincore(), mkdir(), mount(), mprotect();
extern int msgctl(), msgget(), msgrcv(), msgsnd(), munmap(), nice(), p_online();
extern int pause(), processor_bind(), processor_info(), ptrace();
extern int semctl(), semget(), semop();
extern int setcontext(), setegid(), seteuid(), setgid();
extern int setgroups(), setitimer(), setpgid(), setrlimit();
extern int setuid(), shmctl(), shmdt(), shmget(), sigaction(), sigaltstack();
extern int sigpending(), sigprocmask(), sigsend(), sigsendset(), sigsuspend();
extern int sigwait()), stime(), swapctl(), sysfs();
extern int uadmin(), umount(), uname(), ustat(), utimes();
extern int waitid();
extern lwpid_t _lwp_self();
extern gid_t getegid();
extern uid_t geteuid();
extern pid_t getppid(), getsid(), waitpid(), vfork();
extern long priocntl(), priocntlset();
extern void _lwp_makecontext(), _lwp_setprivate();
#ifdef BSD44
extern void vhangup();
extern int getaudit(), getauid(), setaudit(), setauid();
#else
extern int sighold(), sigrelse(), sigignore(), keyctl();
extern int procpriv(), aclipc(), acl(), auditevt();
extern int auditctl(), auditdmp(), auditlog(), auditbuf();
extern int secadvise(), gettimeofday(), settimeofday();
#endif
extern void _exit(), _lwp_exit(), *_lwp_getprivate();
#endif

/**************************************
* Declare testing system call functions
**************************************/
extern int nosys(), myfork(), myfork1(), mygetpid(), mygetuid(), mysync();
extern int mygetpgrp(), mysetpgrp();
#if defined(__STDC__)
extern int myopen(char *param1, int param2, int param3, int param4, int param5);
extern int mycreat(const char *param1, mode_t parm2);
extern int mylink(const char *param1, const char *param2);
extern int myunlink(const char *param1);
extern int myexecl(const char *param1, const char *param2, ...);
extern int myexecle(const char *param1, const char *param2, ...);
extern int myexeclp(const char *param1, const char *param2, ...);
extern int myexecv(const char *param1, char *const *param2);
extern int myexecve(const char *param1, char *const *param2, char *const *param3);
extern int myexecvp(const char *param1, char *const *param2);
extern int mychmod(const char *param1, mode_t param2);
extern int mychown(const char *param1, uid_t param2, gid_t param3);
extern int mystat(const char *param1, struct stat *param2);
extern int myaccess(const char *param1, int param2);
extern int mylchown(const char *param1, uid_t param2, gid_t param3);
extern int myutime(const char *param1, const struct utimbuf *param2);
extern int mywait(int param1), mytime(time_t param1), mysbrk(int param1);
extern int mylseek(int param1, long param2, int param3), myalarm(unsigned param1);
extern int mymkdir(const char *param1, mode_t param2);
extern int myrmdir(const char *param1);
extern int mylstat(const char *param1, struct stat *param2);
extern int mysymlink(const char *param1, const char *param2);
extern int myreadlink(const char *param1, void *param2, int param3);
extern int mymknod(const char *param1, mode_t param2, dev_t param3);
extern int mymkfifo(const char *param1, mode_t param2);
extern int mytruncate(const char *param1, off_t length);
extern int mygetsid(pid_t param1), mysetsid(void), mygetpgid(pid_t param1);
extern int mytimes(struct tms param1), mygetgid(void), myulimit(int param1, int param2);
extern int myshmat(int param1, void *param2, int param3), myumask(mode_t param1);
extern int mypathconf(const char param1, int param2);
extern int myfpathconf(int param1, int param2);
extern int mymmap(caddr_t param1, size_t param2, int param3, int param4,
                 int param5, off_t param6);
extern int myreadv(int param1, struct iovec param2, int param3);
extern int mysysinfo(int param1, char param2, long param3);
extern int mywrite(int param1, const void *param2, size_t param3);
extern int mywritev(int param1, const struct iovec *param2, int param3);
extern int myclose(int param1), dup(int param1);
extern int mydup(int param1);
extern int mylseek(int param1, long param2, int param3);
extern int myread(int param1, void *param2, size_t param3);
extern int myreadv(int param1, struct iovec param2, int param3);
extern int mypipe(int param1, int param2);
extern int myfcntl(int param1, int param2, int param3);
extern int myfchmod(int param1, mode_t param2);
extern int myfchown(int param1, uid_t param2, gid_t param3);
extern int myfstat(int param1, struct stat *param2);
extern int mypwrite(int param1, const void *param2, size_t param3, off_t param4);
extern int mypread(int param1, void *param2, size_t param3, off_t param4);
extern int mygetdents(int param1, struct dirent *param2, size_t param3);
extern int myioctl(int param1, int param2, int param3);
extern int mygetmsg(int param1, struct strbuf *param2, struct strbuf *param3, int *param4);
extern int mygetpmsg(int param1, struct strbuf *param2, struct strbuf *param3, int *param4, int *param5);
extern int myputmsg(int param1, const struct strbuf *param2, const struct strbuf *param3, int param4);
extern int myputpmsg(int param1, struct strbuf *param2, struct strbuf *param3, int param4, int param5);
extern int mypoll(struct pollfd *param1, unsigned long param2, int param3);
extern int myftruncate(int param1, off_t param2);
extern int myrename(const char *param1, const char *param2);
extern int mychdir(const char *param1);
extern int myfchdir(int param1);
extern int mychroot(const char *param1);
extern int mystatvfs(const char *param1, struct statvfs *param2);
extern int myfstatvfs(int param1, struct statvfs *param2);
extern int myfilepriv(const char *param1, int param2, priv_t *param3, int param4);
#ifndef BSD44
extern int myprofil(unsigned short *param1, unsigned int param2, unsigned int param3, unsigned int param4);
extern int mysignal(int param1);
extern int mysigset(int param1);
#endif
#else
extern int myopen(), mywait(), mytime(), mysbrk(), mylseek(), myalarm(), mysetsid();
extern int mygetpgid(), mytimes(), mygetgid(), myshmat(), myumask(), myulimit();
extern int mypathconf(), myfpathconf(), mymmap(), mysysinfo(), mycreat(), mylink();
extern int myunlink(), mychmod(), mychown(), mystat(), myutime(), myaccess();
extern int mylchown(), mymkdir(), myrmdir(), mylstat(), mysymlink(), myreadlink();
extern int mymknod(), mymkfifo(),  mytruncate():
extern int myexecl(), myexecli(),  myexeclp(), myexecv(), myexecve(), myexecvp();
extern int mypoll(),  myputpmsg(), myputmsg(), myioctl(), mygetdents();
extern int mypread(), mypwrite(),  myfstat(), myfchown(), myfchmod();
extern int myfcntl(), mypipe(),    myread(), myreadv(), mydup(), myclose();
extern int mywrite(), mywritev(),  myftruncate(), mylseek(), mygetmsg();
extern int mygetpmsg(), myrename(), mychdir(), myfchdir(), mychroot();
extern int mystatvfs(), myfstatvfs(), myfilepriv();
#ifndef BSD44
extern int myprofil(), mysignal(), mysigset()
#endif
#endif

/*******************
* Standard Constants
*******************/
#define TRUE 1        /* Boolean Usage */
#define FALSE 0

#define YES 1         /* Valid System Call */
#define NO 0          /* Invalid System Call */

#define SUCCEED 0     /* exit() usage */
#define FAIL (-1)     /* exit() & error returns */

#define MAXSCNAME                   16 
#define MAXLONG          017777777777L
#define MAX_FILES        64
#define MAX_FILESIZE    256 
#define MAX_PATHLENGTH 1024

/*************************************
* System Call Execution Control Values
**************************************/ 
#define NONE          00
#define ROOT          01

/*****************************************************
* Define testings perspective of the system call table
*****************************************************/

struct system_calls {
/* 0 */  char     sy_name[MAXSCNAME];      /* System Call Name of 16 characters */
/* 1 */  int      sy_flags;                /* Execution Control Flags */
/* 2 */  int      sy_nargs : 16;           /* Total System Call Arguments */
         int      sy_valid : 16;           /* valid Flag (Yes | No) */
/* 3 */  int      sy_loop;                 /* loop Flag (Yes | No) */
/* 4 */  int      (*sy_call) ();           /* Systme Call Handler */
/* 5 */  int      sy_ncalls;               /* Number of Requests */
/* 6 */  int      sy_passes;               /* Number of Successful Invocations */
/* 7 */  int      sy_failures;             /* Number of Failing Invocations */
/* 8 */  int      sy_tottime;              /* Total Time For This Call */ 
/* 9 */  int      sy_maxtime;              /* Maximum Time To Complete */
/* 10 */ int      sy_mintime;              /* Minimum Time To Complete */
};

#define SYSENT(desc,flags,narg,valid,looper,func) { \
        desc,flags,narg,valid,looper,func,0,0,0,0,0,MAXLONG},


/*****************************************************
* Define testings perspective of the system call table
*****************************************************/

struct system_calls scalls[] = 
{
/*       Description   Flags      Valid       Function      */
/*       (max #16)           #args     Loop                 */
/*                                                          */
SYSENT( "illegal",     NONE,  0,  YES,   NO,  nosys)        /*  0: Indirect */
SYSENT( "_exit",       NONE,  1,  YES,   NO,  nosys)        /*  1: exit */
SYSENT( "fork",        NONE,  0,  YES,   NO,  myfork)       /*  2: fork */
SYSENT( "read",        NONE,  3,  YES,   NO,  myread)       /*  3: read */
SYSENT( "write",       NONE,  3,  YES,  YES,  mywrite)      /*  4: write */
SYSENT( "open",        NONE,  5,  YES,  YES,  myopen)       /*  5: open */
SYSENT( "close",       NONE,  1,  YES,  YES,  close)        /*  6: close */
SYSENT( "wait",        NONE,  1,  YES,   NO,  mywait)       /*  7: wait */
SYSENT( "creat",       NONE,  2,  YES,  YES,  mycreat)      /*  8: creat */
SYSENT( "link",        NONE,  2,  YES,  YES,  mylink)       /*  9: link */
SYSENT( "unlink",      NONE,  1,  NO,   YES,  myunlink)     /* 10: unlink */
SYSENT( "execv",       NONE,  2,  YES,  YES,  myexecv)      /* 11: execv */
SYSENT( "chdir",       NONE,  1,  YES,  YES,  mychdir)      /* 12: chdir */
SYSENT( "time",        NONE,  1,  YES,  YES,  mytime)       /* 13: time */
SYSENT( "mknod",       NONE, 11,  YES,  YES,  mymknod)      /* 14: mknod */
SYSENT( "chmod",       NONE,  2,  YES,  YES,  mychmod)      /* 15: chmod */
SYSENT( "chown",       NONE,  3,  YES,  YES,  mychown)      /* 16: chown */
SYSENT( "sbrk",        NONE,  1,   NO,   NO,  mysbrk)       /* 17: sbrk */
SYSENT( "stat",        NONE,  2,  YES,  YES,  mystat)       /* 18: stat */
SYSENT( "lseek",       NONE,  3,  YES,  YES,  mylseek)      /* 19: lseek */
SYSENT( "getpid",      NONE,  0,  YES,  YES,  mygetpid)     /* 20: getpid */
SYSENT( "mount",       NONE,  8,  YES,  YES,  mount)        /* 21: mount */
SYSENT( "umount",      NONE,  1,  YES,  YES,  umount)       /* 22: umount */
SYSENT( "setuid",      NONE,  1,  YES,  YES,  setuid)       /* 23: setuid */
SYSENT( "getuid",      NONE,  0,  YES,  YES,  mygetuid)     /* 24: getuid */
SYSENT( "stime",       NONE,  1,  YES,  YES,  stime)        /* 25: stime */
SYSENT( "ptrace",      NONE,  4,   NO,   NO,  ptrace)       /* 26: ptrace */
SYSENT( "alarm",       NONE,  1,   NO,   NO,  myalarm)      /* 27: alarm */
SYSENT( "fstat",       NONE,  2,  YES,  YES,  myfstat)      /* 28: fstat */
SYSENT( "pause",       NONE,  0,   NO,   NO,  pause)        /* 29: pause */
SYSENT( "utime",       NONE,  2,  YES,  YES,  myutime)      /* 30: utime */
SYSENT( "stty",        NONE,  0,  YES,  YES,  nosys)        /* 31: stty */
SYSENT( "gtty",        NONE,  0,  YES,  YES,  nosys)        /* 32: gtty */
SYSENT( "access",      NONE,  2,  YES,  YES,  myaccess)     /* 33: access */
SYSENT( "nice",        NONE,  1,  YES,  YES,  nice)         /* 34: nice */
SYSENT( "statfs",      NONE,  0,   NO,  YES,  nosys)        /* 35: nosys */
SYSENT( "sync",        NONE,  0,  YES,  YES,  mysync)       /* 36: sync */
SYSENT( "kill",        NONE,  2,  YES,  YES,  kill)         /* 37: kill */
SYSENT( "fstatfs",     NONE,  0,   NO,  YES,  nosys)        /* 38: fstatfs */
SYSENT( "getpgrp",     NONE,  0,  YES,  YES,  mygetpgrp)    /* 39.0 : getpgrp */
SYSENT( "setpgrp",     NONE,  0,  YES,  YES,  mysetpgrp)    /* 39.1 : setpgrp */
SYSENT( "getsid",      NONE,  1,  YES,  YES,  mygetsid)     /* 39.2 : getsid */
SYSENT( "setsid",      NONE,  0, YES,   YES,  mysetsid)     /* 39.2 : setsid */
SYSENT( "getpgid",     NONE,  1, YES,   YES,  mygetpgid)    /* 39.3 : getpgid */
SYSENT( "setpgid",     NONE,  2, YES,   YES,  setpgid)      /* 39.4 : setpgid */
SYSENT( "xenix",       NONE,  0, YES,   YES,  nosys)        /* 40 : xenix */
SYSENT( "dup",         NONE,  1, YES,   YES,  mydup)        /* 41 : dup */
SYSENT( "pipe",        NONE,  2, YES,   YES,  mypipe)       /* 42 : pipe */
SYSENT( "times",       NONE,  1, YES,   YES,  mytimes)      /* 43 : times */
#ifdef BSD44
SYSENT( "profil",      NONE,  4, YES,   YES,  nosys)        /* 44 : profil */
SYSENT( "plock",       NONE,  1, YES,   YES,  nosys)        /* 45 : plock */
#else
SYSENT( "profil",      NONE,  4, YES,   YES,  myprofil)      /* 44 : profil */
#endif
SYSENT( "plock",       NONE,  1, YES,   YES,  plock)         /* 45 : plock */
SYSENT( "setgid",      NONE,  1, YES,   YES,  setgid)        /* 46 : setgid */
SYSENT( "getgid",      NONE,  1, YES,   YES,  mygetgid)      /* 47 : getgid */
#ifdef BSD44
SYSENT( "sigctl",      NONE,  4, YES,   YES,  nosys)         /* 48 : sigctl */
#else
SYSENT( "signal",      NONE,  2, YES,   YES,  mysignal)      /* 48.1 : signal */
SYSENT( "sigset",      NONE,  2, YES,   YES,  mysigset)      /* 48.2 : sigset */
SYSENT( "sighold",     NONE,  1, YES,   YES,  sighold)       /* 48.3 : sighold */
SYSENT( "sigrelse",    NONE,  1, YES,   YES,  sigrelse)      /* 48.3 : sigrelse */
SYSENT( "sigignore",   NONE,  1, YES,   YES,  sigignore)     /* 48.4 : sigignore */
#endif
SYSENT( "msgget",      NONE,  2, YES,   YES,  msgget)        /* 49.1 : msgget */
SYSENT( "msgctl",      NONE,  3, YES,   YES,  msgctl)        /* 49.2 : msgget */
SYSENT( "msgrcv",      NONE,  5, YES,   YES,  msgrcv)        /* 49.3 : msgrcv */
SYSENT( "msgsnd",      NONE,  4, YES,   YES,  msgsnd)        /* 49.4 : msgsnd */
SYSENT( "syssun",      NONE,  1, YES,   YES,  nosys)         /* 50 : syssun */
SYSENT( "acct",        NONE,  1, YES,   YES,  acct)          /* 51 : acct */
SYSENT( "shmat",       NONE,  3, YES,   YES,  myshmat)       /* 52.1 : myshmat */
SYSENT( "shmctl",      NONE,  3, YES,   YES,  shmctl)        /* 52.2 : shmctl */
SYSENT( "shmdt",       NONE,  1, YES,   YES,  shmdt)         /* 52.3 : shmdt */
SYSENT( "shmget",      NONE,  3, YES,   YES,  shmget)        /* 52.4 : shmget */
SYSENT( "semctl",      NONE,  3, YES,   YES,  semctl)        /* 53.1 : semctl */
SYSENT( "semget",      NONE,  3, YES,   YES,  semget)        /* 53.2 : semget */
SYSENT( "semop",       NONE,  3, YES,   YES,  semop)         /* 53.3 : semop */
SYSENT( "ioctl",       NONE,  3, YES,   YES,  myioctl)       /* 54 : myioctl */
SYSENT( "uadmin",      NONE,  3, YES,   YES,  uadmin)        /* 55 : uadmin */
SYSENT( "upanic",      NONE,  1, YES,   YES,  nosys)         /* 56 : upanic */
SYSENT( "ustat",       NONE,  2, YES,   YES,  ustat)         /* 57.2 : ustat */
#ifdef BSD44
SYSENT( "fdsync",      NONE,  0, YES,   YES,  nosys)         /* 58 : fdsync */
#else
SYSENT( "fsync",       NONE,  1, YES,   YES,  fsync)         /* 58 : fsync */
#endif
SYSENT( "execve",      NONE,  3, YES,   YES,  myexecve)      /* 59.1 : execve */
SYSENT( "execl",       NONE,  2, YES,   YES,  myexecl)       /* 59.2 : execl */
SYSENT( "execvp",      NONE,  2, YES,   YES,  myexecvp)      /* 59.3 : execvp */
SYSENT( "execle",      NONE,  2, YES,   YES,  myexecle)      /* 59.4 : execle */
SYSENT( "execlp",      NONE,  2, YES,   YES,  myexeclp)      /* 59.5 : execlp */
SYSENT( "umask",       NONE,  1, YES,   YES,  myumask)       /* 60 : umask */
SYSENT( "chroot",      NONE,  1, YES,   YES,  mychroot)      /* 61 : chroot */
SYSENT( "fcntl",       NONE,  3, YES,   YES,  myfcntl)       /* 62 : fcntl */
SYSENT( "ulimit",      NONE,  2, YES,   YES,  myulimit)      /* 63 : ulimit */
SYSENT( "lchown",      NONE,  3, YES,   YES,  mylchown)      /* 65 : lchown */
SYSENT( "rmdir",       NONE,  1, YES,   YES,  myrmdir)       /* 79 : rmdir */
SYSENT( "mkdir",       NONE,  2, YES,   YES,  mymkdir)       /* 80 : mkdir */
SYSENT( "getdents",    NONE,  3, YES,   YES,  mygetdents)    /* 81 : getdents */
SYSENT( "sysfs",       NONE,  3, YES,   YES,  sysfs)         /* 84 : sysfs */
SYSENT( "getmsg",      NONE,  4, YES,   YES,  mygetmsg)      /* 85.1 : mygetmsg */
SYSENT( "putmsg",      NONE,  4, YES,   YES,  myputmsg)      /* 86.1 : myputmsg */
SYSENT( "poll",        NONE,  3, YES,   YES,  mypoll)        /* 87 : poll */
SYSENT( "lstat",       NONE,  2, YES,   YES,  mylstat)       /* 88 : lstat */
SYSENT( "symlink",     NONE,  2, YES,   YES,  mysymlink)     /* 89 : symlink */
SYSENT( "readlink",    NONE,  3, YES,   YES,  myreadlink)    /* 90 : readlink */
SYSENT( "setgroups",   NONE,  2, YES,   YES,  setgroups)     /* 91 : setgroups */
SYSENT( "getgroups",   NONE,  2, YES,   YES,  getgroups)     /* 92 : getgroups */
SYSENT( "fchmod",      NONE,  2, YES,   YES,  myfchmod)      /* 93 : fchmod */
SYSENT( "fchown",      NONE,  3, YES,   YES,  myfchown)      /* 94 : fchown */
SYSENT( "sigprocmask", NONE,  3, YES,   YES,  sigprocmask)   /* 95 : sigprocmask */
SYSENT( "sigsuspend",  NONE,  1, YES,   YES,  sigsuspend)    /* 96 : sigsuspend */
SYSENT( "sigaltstack", NONE,  2, YES,   YES,  sigaltstack)   /* 97 : sigaltstack */
SYSENT( "sigaction",   NONE,  3, YES,   YES,  sigaction)     /* 98 : sigaction */
SYSENT( "sigpending",  NONE,  1, YES,   YES,  sigpending)    /* 99 : sigpending */
SYSENT( "getcontext",  NONE,  1, YES,   YES,  getcontext)    /* 100.1 : getcontext */
SYSENT( "setcontext",  NONE,  1, YES,   YES,  setcontext)    /* 100.2 : setcontext */
SYSENT( "statvfs",     NONE,  2, YES,   YES,  mystatvfs)     /* 103 : statvfs */
SYSENT( "fstatvfs",    NONE,  2, YES,   YES,  myfstatvfs)    /* 104 : fstatvfs */
SYSENT( "sigsend",     NONE,  3, YES,   YES,  sigsend)       /* 107.1 : sigsend */
SYSENT( "sigsendset",  NONE,  2, YES,   YES,  sigsendset)    /* 107.2 : sigsendset */
SYSENT( "priocntl",    NONE,  4, YES,   YES,  nosys)         /* 112 : priocntl */
SYSENT( "pathconf",    NONE,  2, YES,   YES,  mypathconf)    /* 113 : pathconf */
SYSENT( "mincore",     NONE,  3, YES,   YES,  mincore)       /* 114 : mincore */
SYSENT( "mmap",        NONE,  6, YES,   YES,  mymmap)        /* 115 : mmap */
SYSENT( "mprotect",    NONE,  3, YES,   YES,  mprotect)      /* 116 : mprotect */
SYSENT( "munmap",      NONE,  2, YES,   YES,  munmap)        /* 117 : munmap */
SYSENT( "fpathconf",   NONE,  2, YES,   YES,  myfpathconf)   /* 118 : fpathconf */
SYSENT( "vfork",       NONE,  2,  NO,    NO,  nosys)         /* 119 : vfork */
SYSENT( "fchdir",      NONE,  1, YES,   YES,  myfchdir)      /* 120 : fchdir */
SYSENT( "readv",       NONE,  3, YES,   YES,  myreadv)       /* 121 : readv */
SYSENT( "writev",      NONE,  3, YES,   YES,  writev)        /* 122 : writev */
SYSENT( "mknod",       NONE,  3, YES,   YES,  mymknod)       /* 126 : mknod */
SYSENT( "setrlimit",   NONE,  2, YES,   YES,  setrlimit)     /* 128 : setrlimit */
SYSENT( "getrlimit",   NONE,  2, YES,   YES,  getrlimit)     /* 129 : getrlimit */
SYSENT( "memcntl",     NONE,  6, YES,   YES,  memcntl)       /* 131 : memcntl */
SYSENT( "getpmsg",     NONE,  4, YES,   YES,  mygetpmsg)     /* 132 : getpmsg */
SYSENT( "putpmsg",     NONE,  4, YES,   YES,  myputpmsg)     /* 133 : myputpmsg */
SYSENT( "rename",      NONE,  2, YES,   YES,  myrename)      /* 134 : rename */
SYSENT( "uname",       NONE,  1, YES,   YES,  uname)         /* 135 : uname */
SYSENT( "setegid",     NONE,  1, YES,   YES,  setegid)       /* 136 : setegid */
SYSENT( "adjtime",     NONE,  2, YES,   YES,  adjtime)       /* 138 : adjtime */
SYSENT( "sysinfo",     NONE,  3, YES,   YES,  mysysinfo)     /* 139 : sysinfo */
SYSENT( "seteuid",     NONE,  1, YES,   YES,  seteuid)       /* 141 : seteuid */
#ifdef BSD44
SYSENT( "fork1",       NONE,  0, YES,    NO,  myfork1)       /* 143 : fork1 */
#else
SYSENT( "keyctl",      NONE,  3, YES,    NO,  keyctl)        /* 143 : keyctl */
#endif
SYSENT( "sigwait",     NONE,  1, YES,   YES,  sigwait)       /* 144 : sigwait */
#ifdef BSD44
SYSENT( "_lwp_info",   NONE,  1, YES,   YES,  _lwp_info)     /* 145 : _lwp_info */
#else
SYSENT( "filepriv",    NONE,  4, YES,   YES,  myfilepriv)    /* 145 : filepriv */
SYSENT( "procpriv",    NONE,  3, YES,   YES,  procpriv)      /* 146 : procpriv */
SYSENT( "aclipc",      NONE,  5, YES,   YES,  aclipc)        /* 148 : aclipc */
SYSENT( "acl",         NONE,  4, YES,   YES,  acl)           /* 157 : acl */
SYSENT( "auditevt",    NONE,  3, YES,   YES,  auditevt)      /* 158 : auditevt */
SYSENT( "auditctl",    NONE,  3, YES,   YES,  auditctl)      /* 159 : auditctl */
SYSENT( "auditdmp",    NONE,  2, YES,   YES,  auditdmp)      /* 160 : auditdmp */
SYSENT( "auditlog",    NONE,  3, YES,   YES,  auditlog)      /* 161 : auditlog */
SYSENT( "auditbuf",    NONE,  3, YES,   YES,  auditbuf)      /* 162 : auditbuf */
SYSENT( "secadvise",   NONE,  3, YES,   YES,  secadvise)     /* 167 : secadvise */
SYSENT( "gettimeofday", NONE,  2, YES,  YES,  gettimeofday)  /* 171 : gettimeofday */
SYSENT( "settimeofday", NONE,  2, YES,  YES,  settimeofday)  /* 172 : settimeofday */
SYSENT( "pread",       NONE,  4, YES,   YES,  mypread)       /* 189 : pread */
SYSENT( "pwrite",      NONE,  4, YES,   YES,  mypwrite)      /* 190 : pwrite */
SYSENT( "mkfifo",      NONE,  2, YES,   YES,  mymkfifo)      /* Lib 1 : mkfifo */
SYSENT( "truncate",    NONE,  2, YES,   YES,  mytruncate)    /* Lib 2 : truncate */
#endif
};

#define MAX_SYS_CALL sizeof(scalls)/sizeof(struct system_calls)
#ifdef _cplusplus
}
#endif



