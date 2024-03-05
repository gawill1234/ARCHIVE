#include "myincludes.h"

#ifdef __SUNOS__
int GetCmdLine(int globbuf, int i, int j)
{
   return(0);
}
#endif

#ifdef PLATFORM_WINDOWS
int GetCmdLine(int globbuf, int i, int j)
{
   return(0);
}
#endif

#ifdef __LINUX__
int GetCmdLine(glob_t globbuf, int i, int j)
{
char name[48];
int c, h;
FILE *tn;
int k = 0;

   for (h = 0; h < 48; h++) {
      name[h] = '\0';
   }

   snprintf(name, sizeof(name), "%s%s",
            globbuf.gl_pathv[globbuf.gl_pathc - i - 1], "/cmdline");

   tn = fopen(name, "r");
   if (tn == NULL)
      return(0);
   while (k < MAXLINE - 1 && EOF != (c = fgetc(tn))) {
      P[j].cmd[k++] = c == '\0' ? ' ' : c;
   }
   if (k > 0)
      P[j].cmd[k] = '\0';
   fclose(tn);

   return(1);
}
#endif
