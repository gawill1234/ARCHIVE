#include "myincludes.h"

#ifdef __SUNOS__
//
//   Actually, never called when run on SUNOS
//
int GetProcessData(int globbuf, int i, int j)
{
   return(0);
}
#endif

#ifdef PLATFORM_WINDOWS
int GetProcessData(int globbuf, int i, int j)
{
   return(0);
}
#endif

#ifdef __LINUX__
int GetProcessData(glob_t globbuf, int i, int j)
{
char name[48];
int c, h, err;
FILE *tn;
struct stat sstat;
int k = 0;

   for (h = 0; h < 48; h++) {
      name[h] = '\0';
   }

   snprintf(name, sizeof(name), "%s%s",
            globbuf.gl_pathv[globbuf.gl_pathc - i - 1], "/stat");
   tn = fopen(name, "r");
   if (tn == NULL)
       return(0);
   err = fstat(fileno(tn), &sstat);
   if (err == 0) {
      P[j].uid = sstat.st_uid;
      fscanf(tn, "%ld %s %*c %ld %ld",
             &P[j].pid, P[j].cmd, &P[j].ppid, &P[j].pgid);
   } else {
      fclose(tn);
      return(0);
   }
   fclose(tn);
   P[j].thcount = 1;
   return(1);
}
#endif
