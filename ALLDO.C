#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#ifdef CRAY
#include <sys/target.h>
#endif
#include <time.h>

#include "struct.h"

int all_do(aprod, today, machtarg, curdir, fileage,
           timeinsec, magicflag, sizeflag)
struct prodstruct *aprod;
struct tm *today;
struct target *machtarg;
char *curdir;
int fileage, magicflag, sizeflag;
long timeinsec;
{
struct stat *buf, *file_exist();

         if (checkinput(aprod) != 0) {
            printf("   UNABLE TO CHECK ITEM BECAUSE NEEDED INFORMATION");
            printf(" IS MISSING\n");
            return;
         }
         buf = file_exist(aprod);
         if (aprod->notfound == 0) {
            check_type(aprod, buf);
            check_perm(aprod, buf);
#ifdef CRAY
            if ((aprod->tryexec == 1) && (aprod->dirorfile[0] == '-') &&
                (magicflag == 1))
               check_magic(aprod, machtarg);
#endif
            check_size(aprod, buf, sizeflag);
            check_date(today, buf, fileage, aprod, timeinsec);
         }
         free(buf);
}
