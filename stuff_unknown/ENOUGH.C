#include <values.h>
#include <sys/types.h>
#include <sys/times.h>

/*********************************************************/
/*   ENOUGH

   Return a value somewhere between highval and lowval, if possible.
   The value will be the size of the next file.
*/
/*
   parameters:
      highval       highest allowable value to return
      lowval        lowest allowable value to return, unless fillmaxbytes
                    is less.
      fillmaxbytes  number of bytes remaining to fill file system to
                    specified levels

   return value:
      size next file is to be
*/
int enough(highval, lowval, fillmaxbytes)
int highval, lowval;
unsigned long fillmaxbytes;
{
static double random;
double random2;
int difference, take, retval;
void srand48();
double drand48();
struct tms t_buf;

#if defined(SunOS)
   srand48(random);
#else
   srand48(times(&t_buf));
#endif

   random = drand48();
   random2 = drand48();

   if (fillmaxbytes > lowval) {
      if (fillmaxbytes > highval)
         difference = highval - lowval;
      else
         difference = fillmaxbytes - lowval;
      if ((random2 * 100) > 40)
         difference = difference / 2;
      if ((random2 * 100) > 75)
         difference = difference / 2;
      take = (int)((double)difference * random);
      retval = lowval + take;
      return(retval);
   } else {
      return(fillmaxbytes);
   }
}
