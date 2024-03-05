struct optnarg_t {
   char *option_name;
   char *option_argument;
   int onoff;
   struct optnarg_t *next;
};

struct partition_desc {
   int part_no;
   int part_size;
   int part_actual_size;
   int part_min_aau;
   struct partition_desc *next;
};

struct ldclist_t {
   char *path_name;
   char *logical_dev_name;
   int onoff;
   int nslices;
   int vol_size;
   struct partition_desc *partition;
   struct optnarg_t *opt_list;
   struct ldclist_t *next;
};

struct ldctype_t {
   char cache_type[4];
   int max_num;
   int num_avail;
};
