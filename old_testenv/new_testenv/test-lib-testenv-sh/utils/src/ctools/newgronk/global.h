#ifndef __GLOBAL_H__
#define __GLOBAL_H__

/* GLOBAL.H - RSAREF types and constants. This is part of the MD5 package.
 */

/* PROTOTYPES should be set to one if and only if the compiler supports
  function argument prototyping.
  The following makes PROTOTYPES default to 0 if it has not already
  been defined with C compiler flags.
 */

/* POINTER defines a generic pointer type */
typedef unsigned char *POINTER;

/* UINT2 defines a two byte word */
typedef unsigned short int UINT2;

/* UINT4 defines a four byte word */
/* #if defined(__WORDSIZE) && __WORDSIZE == 64 */
typedef unsigned int UINT4;
/* #else */
/* typedef unsigned long int UINT4; */
/* #endif */


/* PROTO_LIST is defined depending on how PROTOTYPES is defined above.
If using PROTOTYPES, then PROTO_LIST returns the list, otherwise it
  returns an empty list.
 */

#endif

