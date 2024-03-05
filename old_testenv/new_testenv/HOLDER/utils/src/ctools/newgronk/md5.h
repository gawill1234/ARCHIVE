#ifndef __MD5_H__
#define __MD5_H__
#define HEADER_MD5_H

/* MD5.H - header file for MD5C.C
 */

/* Copyright (C) 1991-2, RSA Data Security, Inc. Created 1991. All
rights reserved.

License to copy and use this software is granted provided that it
is identified as the "RSA Data Security, Inc. MD5 Message-Digest
Algorithm" in all material mentioning or referencing this software
or this function.

License is also granted to make and use derivative works provided
that such works are identified as "derived from the RSA Data
Security, Inc. MD5 Message-Digest Algorithm" in all material
mentioning or referencing the derived work.

RSA Data Security, Inc. makes no representations concerning either
the merchantability of this software or the suitability of this
software for any particular purpose. It is provided "as is"
without express or implied warranty of any kind.

These notices must be retained in any copies of any part of this
documentation and/or software.
 */

#include "global.h"

/* MD5 context. */
typedef struct {
  UINT4 state[4];                                   /* state (ABCD) */
  UINT4 count[2];        /* number of bits, modulo 2^64 (lsb first) */
  unsigned char buffer[64];                         /* input buffer */
} MD5_CTX;

#ifdef __cplusplus
extern "C" {
#endif


void MD5Init(MD5_CTX *);
void MD5Update(MD5_CTX *, unsigned char *, unsigned int);
void MD5Final(unsigned char [16], MD5_CTX *);
char *MD5FinalString(MD5_CTX *context);
char *MD5FinalStringBase64(MD5_CTX *context);

/*
	The caller is responsible for freeing the return value 
*/
char * MD5String(unsigned char *);
char * MD5Data (unsigned char *data, unsigned int len);
char * MD5StringBase64(unsigned char *);
char * MD5DataBase64 (unsigned char *data, unsigned int len);

#ifdef __cplusplus
}
#endif

#endif

