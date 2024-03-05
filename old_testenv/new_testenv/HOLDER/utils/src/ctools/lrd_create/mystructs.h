#define MAX_CHILDREN 10

struct node_ops {
   int op_type, op_outcome, op_size;
   struct node_ops *op_next_op;
   struct fs_creations *node_ptr;
};

struct fs_creations {
   char *node_dir;
   char *node_name;
   int node_type, node_status, file_size, ops_count;
   int run_time, fill_perc;
   struct fs_creations *linked_to;
   struct fs_creations *dir_ptr;
   struct fs_creations *next;
   struct node_ops *op_list;
};

struct pid_ptr_thing {
   int pid;
   struct fs_creations *base_node;
   struct node_ops *op_node;
};

