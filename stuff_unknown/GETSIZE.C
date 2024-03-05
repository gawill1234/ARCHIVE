#include <values.h>
#include <sys/types.h>
#include <sys/times.h>

#define MDHIGH 32768
#define MDLOW  4097
#define SMHIGH 4096
#define SMLOW  513
#define TYHIGH 512
#define TYLOW  65
#define MNHIGH 64
#define MNLOW  1
#define LGHIGH 98304
#define LGLOW  32769
#define ELHIGH 262144
#define ELLOW  98305
#define HGHIGH 384000
#define HGLOW  262145
#define GGLOW  384001
#define GGHIGH 409600

/**********************************************************/
/*   GETSIZE

   Choose a file size range base on a random number 
*/
/*
   parameters:
      fillmaxbytes      max number of bytes to put in a file system

   return value:
      return value from function ENOUGH.
*/

int getsize(fillmaxbytes)
unsigned long fillmaxbytes;
{
static double random;
#if defined(SunOS)
double random2 = 0.0;
double random3 = 0.0;
double random4 = 0.0;
#endif
void srand48();
double drand48();
struct tms t_buf;

   if (fillmaxbytes < (LGLOW * 2))
      return(enough(fillmaxbytes, 0, fillmaxbytes));

#if defined(SunOS)
   srand48(random);
   random = drand48();
   random2 = drand48();
   random3 = drand48();

   random4 = (random + random2 + random3) / 3.0;

   random = (random > random2) ? random : random2;
   random = (random > random3) ? random : random3;

   random = (random < random4) ? random : random4;

#else
   srand48(times(&t_buf));
   random = drand48();
#endif

   random = random * 100.0;

   if ((random > 40) && (random < 76)) {
#ifdef DEBUG
      printf("medium file\n");
#endif
      return(enough(MDHIGH, MDLOW, fillmaxbytes));
   } else {
      if ((random > 10) && (random < 41)) {
#ifdef DEBUG
         printf("small file\n");
#endif
         return(enough(SMHIGH, SMLOW, fillmaxbytes));
      } else {
         if ((random > 75) && (random < 91)) {
#ifdef DEBUG
            printf("large file\n");
#endif
            return(enough(LGHIGH, LGLOW, fillmaxbytes));
         } else {
            if ((random >= 0) && (random < 11)) {
#ifdef DEBUG
               printf("tiny file\n");
#endif
               return(enough(TYHIGH, TYLOW, fillmaxbytes));
            } else {
               if ((random > 90) && (random < 96)) {
#ifdef DEBUG
                  printf("ex. large file\n");
#endif
                  return(enough(ELHIGH, ELLOW, fillmaxbytes));
               } else {
                  if (random >= 96) {
#ifdef DEBUG
                     printf("huge file\n");
#endif
                     return(enough(HGHIGH, HGLOW, fillmaxbytes));
                  } else {
                     random = (int)(drand48() * 100);
                     if (random > 5) {
#ifdef DEBUG
                        printf("minute file\n");
#endif
                        return(enough(MNHIGH, MNLOW, fillmaxbytes));
                     }
                     else {
                        return(enough(GGHIGH, GGLOW, fillmaxbytes));
                     }
                  }
               }
            }
         }
      }
   }
}
