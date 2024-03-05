#ifndef _H_TEST
#define _H_TEST

#include <stdio.h>

#include "test_macros.h"

extern char *progname, *prog_unknown;

typedef void (*func_p)();

/**********************************************************/
/*  This is definitely not done.  Probably will have to 
    define UNI30, UNI31, UNI40 ...  in order to complete this.
    However, this is sufficient to make the library code
    work.
*/
#define FIO 0
#define TCP 1
#define UDP 2
#define UNI 3
#define NNI 4
#define PNNI 5
#define PVC 6
#define SPANS 7
#define PIO 8
#define SMIO 9


#define PIECEOBLOCK 128
#ifdef BIT_64
#define BLOCKSZ 4096
#define FOURBLOCKSZ 16384
#define WORDSONLINE 16
#define WORDSINBLOCK 512
#define LINESINBLOCK 32
#define DD60BLKSZ 4
#else
#define BLOCKSZ 512
#define FOURBLOCKSZ 4096
#define WORDSONLINE 32
#define WORDSINBLOCK 128
#define LINESINBLOCK 4
#endif

#ifdef BIT_64
#define BYTESINWORD 8
#define BYTESINLONG 8
typedef long 	word;
typedef unsigned long 	uword;
#else
#ifdef __alpha
#define BYTESINWORD 4
#define BYTESINLONG 8
typedef int	word;
typedef unsigned int	uword;
#else
#define BYTESINWORD 4
#define BYTESINLONG 4
typedef long 	word;
typedef unsigned long 	uword;
#endif
#endif

#define IO_TIMEOUT 30

/*
********************************
* Define Test Case Result Values
********************************
*/
#define TPASS   00 /* Test Case Behaves As Expected */
#define TFAIL   01 /* Test Case Produces Unexpected Results */
#define TBROK   02 /* Missing Element To Execute Test Case */
#define TWARN   04 /* Report Incidental Concerns */
#define TRETR  010 /* Test Case Invalid, therefore retired */
#define TINFO  020 /* Test Case Informational message */

#define PASS TPASS
#define FAIL TFAIL
#define BROK TBROK
#define WARN TWARN
#define INFO TINFO
/*
************************
* Default Signal Handler
************************
*/
#define DEF_SIGHANDLER 0
/*
*******************************************
* Test Forking and Death of Child Indicator
*******************************************
*/
#define FORK 01
#define NOFORK 02
/*
***********************
* Miscellaneous defines
***********************
*/
#define YES 1
#define NO 0
#ifndef TRUE
#define TRUE 1
#endif
#ifndef FALSE
#define FALSE 0
#endif


/**  The following bit pattersn will look like  **/
/**  0101010101010101 ...  in a word of data    **/

#define BIT_PATTERN_32 012525252525
#define BIT_PATTERN_64 0525252525252525252525

#endif
