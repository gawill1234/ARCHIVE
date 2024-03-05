#ifdef CRAY
#include <a.out.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/unistd.h>
#ifdef CRAY
#include <ctype.h>
#include <sys/target.h>
#endif

#include "struct.h"

int check_magic(aprod, machtarg)
struct prodstruct *aprod;
struct target *machtarg;
{
struct exec *findmagic;
int fno, badmagic;

   badmagic = 0;
   findmagic = NULL;
   findmagic = (struct exec *)malloc(sizeof(struct exec));
   if (findmagic == NULL) {
      printf("Could not get memory\n");
      return(NULL);
   }
   fno = open(aprod->fullpath, O_RDONLY);
   if (fno == (-1)) {
      printf("check_magic:  Could not open %s\n", aprod->fullpath);
      free(findmagic);
      return(-1);
   }
/*
   if (english(fno)) {
      printf("english\n");
   }
   else {

      lseek(fno, 0, 0);
*/
      if (read(fno, findmagic, sizeof(struct exec)) != sizeof(struct exec)) {
         close(fno);
         free(findmagic);
         return(0);
      }
      close(fno);

      switch (findmagic->a_magic) {

         case A_MAGIC1:
                  if (strncmp((char *)&machtarg->mc_pmt,"CRAY-2",6) == 0) {
                     if (machtarg->mc_ibsz != 32)
                        badmagic = 1;
                  }
                  else {
                     if ((machtarg->mc_ibsz != 22) &&
                         (machtarg->mc_ibsz != 24))
                        badmagic = 1;
                  }
                  break;
         case A_MAGIC2:
                  if (strncmp((char *)&machtarg->mc_pmt,"CRAY-2",6) == 0)
                     badmagic = 1;
                  if (strncmp((char *)&machtarg->mc_pmt,"CRAY-1",6) == 0)
                     badmagic = 1;
                  if (strncmp((char *)&machtarg->mc_pmt,"CRAY-XEA",8) == 0)
                     badmagic = 1;
                  if ((strncmp((char *)&machtarg->mc_pmt,"CRAY-X",6) != 0) &&
                      (strncmp((char *)&machtarg->mc_pmt,"CRAY-YMP",8) != 0))
                     badmagic = 1;
                  if ((machtarg->mc_ibsz != 22) &&
                      (machtarg->mc_ibsz != 24))
                     badmagic = 1;
                  break;
         case A_MAGIC3:
         case A_MAGIC4:
                  if (strncmp((char *)&machtarg->mc_pmt,"CRAY-2",6) == 0)
                     badmagic = 1;
                  if (strncmp((char *)&machtarg->mc_pmt,"CRAY-1",6) == 0)
                     badmagic = 1;
                  if ((strncmp((char *)&machtarg->mc_pmt,"CRAY-XEA",8) != 0) &&
                      (strncmp((char *)&machtarg->mc_pmt,"CRAY-YMP",8) != 0))
                     badmagic = 1;
                  if (machtarg->mc_ibsz != 32)
                     badmagic = 1;
                  break;
         default:
                  badmagic = 1;
      
      }
/*
   }
*/

   if (badmagic == 1) {
      if (aprod->nameout == 0)
         nameit(aprod);
    printf("BAD MAGIC -- File is not executable or file is a shell script\n");
   }
   free(findmagic);
   return(0);
}
english (fno)
int fno;
{
#define NASC 128
char *bp;
int n;
register     int     j, vow, freq, rare;
register     int     badpun = 0, punct = 0;
auto    int     ct[NASC];

        bp = (char *)malloc(512);
        for (n = 0; n < 512; n++)
           bp[n] = '\0';

        n = read(fno, bp, 512);

        if (n<50)
                return(0); /* no point in statistics on squibs */

        for(j=0; j<NASC; j++)
                ct[j]=0;

        for(j=0; j<n; j++)
        {
                if (bp[j]<NASC)
                        ct[bp[j]|040]++;
                switch (bp[j])
                {
                case '.':
                case ',':
                case ')':
                case '%':
                case ';':
                case ':':
                case '?':
                        punct++;
                        if(j < n-1 && bp[j+1] != ' ' && bp[j+1] != '\n')
                                badpun++;
                }
        }
        if (badpun*5 > punct)
                return(0);
        vow = ct['a'] + ct['e'] + ct['i'] + ct['o'] + ct['u'];
        freq = ct['e'] + ct['t'] + ct['a'] + ct['i'] + ct['o'] + ct['n'];
        rare = ct['v'] + ct['j'] + ct['k'] + ct['q'] + ct['x'] + ct['z'];
        if(2*ct[';'] > ct['e'])
                return(0);
        if((ct['>']+ct['<']+ct['/'])>ct['e'])
                return(0);      /* shell file test */
        return (vow*5 >= n-ct[' '] && freq >= 10*rare);
}
#endif
