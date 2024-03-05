#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
//#include <values.h>
#include <limits.h>
#include <stdint.h>
#include <wchar.h>

/************************************************/
/*  Gets the bits from "thing", places an
    (int) of the bits in myarray arranged in
    little endian byte/bit order:
     bytes:     3      2     1     0
     bits:    24-31  16-23  8-15  0-7

     bit 0 represent the most significant bit.
     bit 31 is the least significant.
*/
void le_get_bit(thing, len, myarray)
unsigned long thing;
int len;
int *myarray;
{
int i, j, k, b;
union {
   unsigned long goof;
   char c[8];
} dumb;

   dumb.goof = thing;

#if !defined(__alpha)
   dumb.goof = dumb.goof << ((sizeof(long) * 8) - len);
#endif

   b = 1;
   k = 7;
   j = 0;
   for (i = 0; i < len; i++) {
      if (i > 0) {
         if ((i% 8) == 0) {
            j++;
            b++;
            k = 7;
         }
      }
      myarray[i + k] = (int)(dumb.c[j] & 01);
      k = k - 2;
#if !defined(__alpha)
     dumb.c[j] = dumb.c[j] << 1;
#else
     dumb.c[j] = dumb.c[j] >> 1;
#endif
   }
   return;
}
void le_dump_bit(name, thing, len)
char *name;
unsigned long thing;
int len;
{
int i;
#ifndef SunOS
int *myarray;
#else
int myarray[64];
#endif

   len = len * 8;

   fprintf(stderr, "%s:  %lo = ", name, thing);

#ifndef SunOS
   myarray = (int *)malloc(sizeof(int) * len);
#endif

   le_get_bit(thing, len, myarray);

   for (i = 0; i < len; i++) {
       if (i > 0)
          if ((i % 8) == 0)
             fprintf(stderr, "-");
       fprintf(stderr, "%d", myarray[i]);
   }
   fprintf(stderr, "\n");
#ifndef SunOS
   free(myarray);
#endif
   return;
}


/***************************************************/
/*  Get the bits from "thing" in machine order.
    Little endian machines will simply be dumped
    in reverse big endian.  In other words, the
    bit order within the byte will be out of order
    for little endian machine.
    Stashes an (int) of the bit in myarray.

    Big endian order:
    Bytes:     0    1      2      3
    bits:     0-7  8-15  16-23  24-31
    Little endian order:
    Bytes:     3      2      1    0
    bits:    31-24  23-16  15-8  7-0

    bit 0 is the most significant bit.
    bit 31 is the least significant bit.
*/
void mo_get_bit(thing, len, myarray)
unsigned long thing;
int len;
int *myarray;
{
int i;
union {
   struct {
      unsigned int abit:1;
#if !defined(__alpha)
      unsigned int unused:31;
#else
      unsigned int unused:31;
      unsigned int unu2:32;
#endif
   } bits;
   unsigned long goof;
} dumb;

   dumb.goof = thing;

#if !defined(__alpha)
   dumb.goof = dumb.goof << ((sizeof(long) * 8) - len);
#endif

   for (i = 0; i < len; i++) {
      myarray[i] = (int)dumb.bits.abit;
#if !defined(__alpha)
     dumb.goof = dumb.goof << 1;
#else
     dumb.goof = dumb.goof >> 1;
#endif
   }
   return;
}

void mo_dump_bit(name, thing, len)
char *name;
unsigned long thing;
int len;
{
int i;
#ifndef SunOS
int *myarray;
#else
int myarray[64];
#endif

   len = len * 8;

   fprintf(stderr, "%s:  %lo = ", name, thing);

#ifndef SunOS
   myarray = (int *)malloc(sizeof(int) * len);
#endif

   mo_get_bit(thing, len, myarray);

   for (i = 0; i < len; i++) {
       if (i > 0)
          if ((i % 8) == 0)
             fprintf(stderr, "-");
       fprintf(stderr, "%d", myarray[i]);
   }
   fprintf(stderr, "\n");
#ifndef SunOS
   free(myarray);
#endif
   return;
}

/***************************************************/
/*  Basic shift/mask to get bits from "thing".
    Stashes an (int) of the bit in myarray.  All
    bits appear to be arranged in the same order
    with this, big endian looks like little endian ...
    Makes them all look like big endian, or logical
    order, hence the "lo" prefix to the name.

    Bytes:     0    1      2      3
    bits:     0-7  8-15  16-23  24-31
*/
void lo_get_bit(thing, len, myarray)
unsigned long thing;
int len;
int *myarray;
{
int i;

   for (i = 0; i < len; i++) {
      myarray[i] = (int)(thing & 01);
      thing = thing >> 1;
   }
   return;
}

void lo_dump_bit(name, thing, len)
char *name;
unsigned long thing;
int len;
{
int i;
#ifndef SunOS
int *myarray;
#else
int myarray[64];
#endif

   len = len * 8;

   fprintf(stderr, "%s:  %lo = ", name, thing);

#ifndef SunOS
   myarray = (int *)malloc(sizeof(int) * len);
#endif

   lo_get_bit(thing, len, myarray);

   for (i = 0; i < len; i++) {
       if (i > 0)
          if ((i % 8) == 0)
             fprintf(stderr, "-");
       fprintf(stderr, "%d", myarray[i]);
   }

   fprintf(stderr, "\n");
#ifndef SunOS
   free(myarray);
#endif
   return;
}

int endian()
{
#ifndef SunOS
int *endarray1;
#else
int endarray1[32];
#endif
int big = 1, little = 0, retval = -1;
unsigned int one = 1;

#ifndef SunOS
   endarray1 = (int *)malloc(sizeof(int) * 32);
#endif
   mo_get_bit(one, sizeof(int) * 8, endarray1);

   if (endarray1[0] == 1) {
      retval = little;
   }
   else {
      retval = big;
   }

#ifndef SunOS
   free(endarray1);
#endif
   return(retval);
}

eo_dump_bit(name, thing, len)
char *name;
unsigned long thing;
int len;
{
int i;
#ifndef SunOS
int *myarray;
#else
int myarray[64];
#endif

   len = len * 8;

   fprintf(stderr, "%s:  %lo = ", name, thing);

#ifndef SunOS
   myarray = (int *)malloc(sizeof(int) * len);
#endif

   if (endian())
      mo_get_bit(thing, len, myarray);
   else
      le_get_bit(thing, len, myarray);

   for (i = 0; i < len; i++) {
       if (i > 0)
          if ((i % 8) == 0)
             fprintf(stderr, "-");
       fprintf(stderr, "%d", myarray[i]);
   }
   fprintf(stderr, "\n");
#ifndef SunOS
   free(myarray);
#endif
   return(0);
}


main(argc, argv)
int argc;
char **argv;
{
unsigned short one, maxs, mids, rands;
int sum, len, max, midi, randi;
long intval, maxl, midl, randl;
char c;

   one = 1;
   maxs = 65535;
   sum = 1;
   //max = MAXINT;
   max = INT_MAX;
   intval = 1;
   //maxl = MAXLONG;
   maxl = LONG_MAX;
   mids = 8192;
   midi = INT_MAX/2;
   midl = LONG_MAX/2;
   rands = 1234;
   randi = 56789;
   randl = 99900329;
   c = 'a';

   if (endian())
      fprintf(stderr, "BIG\n");
   else
      fprintf(stderr, "LITTLE\n");

   mo_dump_bit("one", one, sizeof(short));
   eo_dump_bit("one", one, sizeof(short));

   mo_dump_bit("mids", mids, sizeof(short));
   eo_dump_bit("mids", mids, sizeof(short));

   mo_dump_bit("rands", rands, sizeof(short));
   eo_dump_bit("rands", rands, sizeof(short));

   mo_dump_bit("maxs", maxs, sizeof(short));
   eo_dump_bit("maxs", maxs, sizeof(short));
   fprintf(stdout, "\n");

   mo_dump_bit("sum", sum, sizeof(int));
   eo_dump_bit("sum", sum, sizeof(int));

   mo_dump_bit("midi", midi, sizeof(int));
   eo_dump_bit("midi", midi, sizeof(int));

   mo_dump_bit("randi", randi, sizeof(int));
   eo_dump_bit("randi", randi, sizeof(int));

   mo_dump_bit("max", max, sizeof(int));
   eo_dump_bit("max", max, sizeof(int));
   fprintf(stdout, "\n");

   mo_dump_bit("intval", intval, sizeof(long));
   eo_dump_bit("intval", intval, sizeof(long));

   mo_dump_bit("midl", midl, sizeof(long));
   eo_dump_bit("midl", midl, sizeof(long));

   mo_dump_bit("randl", randl, sizeof(long));
   eo_dump_bit("randl", randl, sizeof(long));

   mo_dump_bit("maxl", maxl, sizeof(long));
   eo_dump_bit("maxl", maxl, sizeof(long));

   mo_dump_bit("char", c, sizeof(char));
   eo_dump_bit("char", c, sizeof(char));

   exit(0);
}

