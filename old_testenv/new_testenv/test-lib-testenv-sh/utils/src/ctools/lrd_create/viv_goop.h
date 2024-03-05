#include "mystructs.h"

#define NTNDF -1
#define RFL 0
#define DRCTRY 1
#define SYMLNK 2
#define HRDLNK 3
#define NMDPP  4

//////////////////////////////////////////////
//
//   Operations that can be performed to create
//   or on existing nodes.
//
//   Most is self-explanatory.  However, overwrite 
//   should be explained.  Overwrite a link means
//   to delete the link and create whatever it is 
//   being overwritten with.  Of a file means it has
//   all new data in it but was never deleted.  Of a
//   directory means that the entire directory and its
//   contents are gone and replaced.
//
//  Done to new item
#define OP_CREATE  0

//  Done to existing item
#define OP_APPEND  1
#define OP_TRUNC   2
#define OP_OVRWRT  3
#define OP_DELETE  4
#define OP_RNDMCHG 5

//  Done to deleted item
#define OP_REPLACE 6
//////////////////////////////////////////////
//
//   The outcome of any given operation(above)
//   It either worked, or it did not
//
#define OP_FAIL    0
#define OP_SUCCESS 1
#define OP_UNKNOWN 2

//////////////////////////////////////////////
//
//   Current node status
//
#define NODE_EXISTS  0
#define NODE_DELETED 1
#define NODE_CRTFAIL 2
#define NODE_WORKING 3

#define FILE_CRAWL 0
#define SMB_CRAWL  1

extern int rfl_cnt;
extern int drctry_cnt;
extern int symlnk_cnt;
extern int hrdlnk_cnt;
extern int nmdpp_cnt;
extern int total_cnt;
extern int children;
extern int exp_exists;
extern int act_exists;
extern int exp_deleted;
extern int act_deleted;

extern int verbose;

