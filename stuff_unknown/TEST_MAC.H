#ifndef _H_TEST_MACROS
#define _H_TEST_MACROS
#include <sys/types.h>
#include <sys/times.h>

#include "test_clnt_srv.h"

#define GETTIMES(a, b)  a = times(&b);
#define TIMETYPE        clock_t

#define ONE_WAY_ELAPSED(start, end, transit) \
   {  \
      extern uword Gtime_diff;  \
      extern unsigned Gcli_hz; \
      uword  OWE_sticks; \
      double OWE_csecs;  \
      \
      if (Gcli_hz == 0)  \
         Gcli_hz = HZ;  \
                                                       \
      OWE_csecs = (double)(((unsigned)start) / (double)Gcli_hz); \
      OWE_sticks = end + Gtime_diff;  \
      transit = (double)((double)OWE_sticks / (double)HZ) - OWE_csecs;  \
   }

#define CHECK_MTU() \
   { \
      extern int Gmax_size, Gdata_size, Gmtu; \
 \
      if (Gmtu < Gmax_size) { \
         fprintf(stderr, "MTU = %d,  adjusting max write size\n", Gmtu); \
         Gdata_size = Gdata_size - (Gmax_size - Gmtu); \
         Gmax_size = Gmtu; \
      }; \
}


#ifdef LOGIT
#define DO(DO_func, DO_from, DO_filename, DO_reset)               \
   {                                            \
      int DO_len, DO_btime, DO_etime, DO_error, DO_local;           \
      struct tms DO_tbuf;                       \
                                                \
      DO_local = 0;                             \
      DO_btime = times(&DO_tbuf);		\
      DO_error = DO_func;                       \
      DO_etime = times(&DO_tbuf);		\
                                                \
      if (DO_reset == 1)                        \
         DO_local = DO_reset + DO_error;        \
                                                \
      logcalls(DO_filename, DO_from, #DO_func,	\
               DO_btime, DO_etime, DO_error, DO_local); \
   }
#else
#define DO(DO_func, DO_from, DO_filename, DO_reset)       DO_func
#endif

#ifdef LOGIT
#define DOEXIT(DO_func, DO_from, DO_filename, DO_reset)               \
   {                                            \
      int DO_len, DO_btime;           \
      struct tms DO_tbuf;                        \
                                                \
      DO_btime = times(&DO_tbuf);                       \
      logcalls(DO_filename, DO_from, #DO_func,  \
               DO_btime, DO_btime, 0, 0); \
      dodump();		\
      DO_func;                          \
                                                \
   }
#else
#define DOEXIT(DO_func, DO_from, DO_filename, DO_reset)       DO_func
#endif

#define NEWUID(NU_rootflag, NU_iamroot, NU_newid)   \
{                                                           \
   if ((U_rootflag == 1) && (NU_iamroot == 1)) {           \
      setuid(NU_newid);  \
   };                                                       \
};

#define TEST_PAUSE       \
{                          \
extern int pause_opt;      \
                           \
   if (pause_opt == 1)     \
      pause();             \
};
       
#define TEST(something, index)       \
{                              \
extern int start_time[], end_time[], cum_time[]; \
extern int num_here[], min_time[], max_time[]; \
extern float average_time[];       \
extern char *syscall_name[];           \
int TEST_htime;                   \
struct tms TST_tbuf;                  \
                                 \
   if (num_here == 0) {             \
      syscall_name[index] = (char *)malloc(strlen(#something) + 1);   \
      sprintf(syscall_name[index], "%s\0", #something);   \
   }   \
   \
   start_time[index] = times(&TST_tbuf); \
   something;                    \
   end_time[index] = times(&TST_tbuf);   \
   num_here[index]++;                   \
                   \
   TEST_htime = end_time[index] - start_time[index];   \
                                 \
   cum_time[index] = cum_time[index] + TEST_htime; \
   average_time[index] = (float)(cum_time[index] / num_here[index]);   \
                                   \
   if (TEST_htime > max_time[index])   \
      max_time[index] = TEST_htime;   \
                                   \
   if (min_time[index] == 0)   \
      min_time[index] = max_time[index];   \
   else {   \
      if (TEST_htime < min_time[index])   \
         min_time[index] = TEST_htime;   \
   }   \
};

#define TEST_CLEANUP     \
{                              \
extern int start_time[], end_time[], cum_time[]; \
extern int num_here[], min_time[], max_time[], timing_opt; \
extern float average_time[];       \
extern char *syscall_name[];           \
extern char *progname, *prog_unknown;  \
int i;                             \
                                    \
   if (timing_opt == 1) {              \
      if (progname == NULL)              \
         progname = prog_unknown;              \
                                         \
      for (i = 0; i < 10; i++) {              \
         if (num_here[i] > 0) {              \
           fprintf(stdout, "%d) %s:  %s\n", i, progname, syscall_name[i]);  \
           fprintf(stdout,              \
                   "%d) Max Time:  %d; Min Time:  %d; Average Time:  %d\n",  \
                   i, max_time[i], min_time[i], average_time[i]);  \
           free(syscall_name[i]);  \
         }  \
      }  \
   }  \
};


#endif


