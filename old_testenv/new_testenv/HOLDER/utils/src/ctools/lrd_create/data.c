
#include "mystructs.h"

/*
 *   If it is in here, I figure it is going
 *   to get used all over the place.  These
 *   are all declare as extern int in viv_goop.h.
 *   This use of globals seemed, at least here, to
 *   make more sense than passing around big long
 *   parameter lists that just contain some status
 *   variables used for counting various node types.
 */
int rfl_cnt = 0;
int drctry_cnt = 0;
int symlnk_cnt = 0;
int hrdlnk_cnt = 0;
int nmdpp_cnt = 0;
int total_cnt = 0;
int exp_exists = 0;
int act_exists = 0;
int exp_deleted = 0;
int act_deleted = 0;

int verbose = 0;

int children = 0;

struct pid_ptr_thing pid_node_arr[MAX_CHILDREN];
