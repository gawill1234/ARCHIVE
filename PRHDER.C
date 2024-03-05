#include <stdio.h>
#include <time.h>
#include <sys/utsname.h>
#ifdef CRAY
#include <sys/target.h>
#endif

#ifdef CRAY
int prhder(curdir, osinfo, today, machtarg)
char *curdir;
struct utsname *osinfo;
struct tm *today;
struct target *machtarg;
#else
int prhder(curdir, osinfo, today)
char *curdir;
struct utsname *osinfo;
struct tm *today;
#endif
{

   printf("Date and Time:                         %s", asctime(today));
   printf("\n");
#ifdef CRAY
   printf("Machine Type and Serial Number:        %s  %d\n",
           (char *)&machtarg->mc_pmt, machtarg->mc_serial);
   printf(
     "                                       %d CPUs, %d bit addressing\n",
           machtarg->mc_ncpu, machtarg->mc_ibsz);
#endif
   printf("Node Name:                             %s\n", osinfo->nodename);
   printf("\n");
   printf("Operating System:                      %s %s %s\n",
           osinfo->sysname, osinfo->release, osinfo->version);
   printf("\n");
   printf("Origination Directory of System Check: %s\n", curdir);
   printf("\n");
}
