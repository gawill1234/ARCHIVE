#include <sys/types.h>

#define ONE_HOUR_IN_SECS 3600

typedef void (*func_p)();

struct prodstruct {
          char *inline;
          char *name;
          char *location;
          char *fullpath;
          char *linkto;
          int couldbepair;
          char *size;
          char *permstr;
          char dirorfile[2];
          int stickybit;
          int setgid;
          int setuid;
          int owner;
          int group;
          int other;
          int tryexec;
          int notfound;
          int nameout;
};

struct advancer {
          char *oldstring;
          char *newstring;
          char *usestring;
};

struct exec_list {
          char *cmd_name;
          int bal;
          struct test_list *tests;
          struct exec_list *paths;
          struct exec_list *left;
          struct exec_list *right;
};

struct path_list {
          char *path_name;
          struct path_list *next;
};

struct test_list {
          char *test_name;
          int expected_exit;
          int actual_exit;
          int whodolog;
          int localrm;
          int icp;
          int itp;
          int rf;
          struct exit_list *testwisdom;
          struct steps_list *step1;
          struct file_list *getfiles;
          struct file_list *rmfiles;
          struct test_list *nexttest;
};

struct steps_list {
          char *path;
          char *cmd;
          char *execline;
          char *options;
          int num_cases;
          int expected_exit;
          int actual_exit;
          struct exit_list *stepwisdom;
          struct steps_list *nextstep;
};

struct file_list {
          char *file_name;
          char *file_location;
          struct file_list *next;
};

struct exit_list {
          int exit_code;
          char *exit_message;
          struct exit_list *next;
};

struct line_values {
          int cmdvalue;
          char *restofline;
};

/**********************************************/
/*  A ushort (int) is 64 bits on a CRAY.
    Bit fields are left justified.
    Hence the dummy unused if this is on a CRAY
*/
union try {
   struct {
#ifdef CRAY
      unsigned unused:48;
#endif
      unsigned file:1, directory:3, setid:3, ownerp:3, groupp:3, otherp:3;
   } glop;
   ushort st_mode;
} crud;
