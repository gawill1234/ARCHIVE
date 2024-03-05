
struct ldch_opt {
   int a, b, i;           /* Display options, changes nothing */
   int r, r_rate;         /* refresh display at r_rate seconds */
   int f;                 /* Accept ldcache instruction from a file */
   char *f_file;
   int p;                 /* assign cache on per disk basis */
                          /* will cause n_units to be assigned to each */
                          /* physical device in a logical device */
   int w;                 /* makes cache write-through */
   int l;                 /* attach cache to logical device, or mnt point */
   char *l_dev;           /* device to attach cache to. */
                          /* name or device number.  Must begin with / if */
                          /* device name or file system name */
   int h, h_high, h_low;  /* max number of dirty units in cache. */
                          /* high is max number, low is number which */
                          /* will cause flushing of dirty buffers to */
                          /* begin. high=0 disables.  low not specified */
                          /* makes it the same as high */
   int n, n_units;        /* number of cache units, 0 to release */
   int s, s_size;         /* size of cache unit, in 4096 byte blocks */
                          /* must be multiple of largest IO unit of  */
                          /* underlying devices(sector size).  max 256 */
   int t;                 /* mem type for cache, (SSD, BMR, MEM) */
   char t_type[4];
                          /* 1=SSD, 2=MEM, 4=BMR in avail structure */
   int x, x_max, x_min;   /* aging.  max is max seconds before a dirty */
                          /* unit is flushed.  All older than min are */
                          /* flushed.  max=0 disables.  min not specified */
                          /* makes it same as max. TRICKLE SYNC */
   int run_time;
};


struct nschd_opt {
   int B, C, c, d, f, G, g, H, h, i, K, k, L, M, m, N, n, P, p;
   int B_thrash, C_comp_int, c_cpuhog, f_fit_boost, G_guar_in, g_guar_out;
   int H_hog_max_mem, h_memhot, i_inter_pref, K_const_in, k_const_out;
   int L_big_proc, M_mfactor_in, m_mfactor_out, N_nfactor_in, n_nfactor_out;
   int P_pfactor_in, p_pfactor_out;
   int R, r, T, t, V, v, X, x, Y, y;
   int R_thrash, r_cpu, T_tfactor_in, t_tfactor_out, V_max_runs, X_mpx;
   int x_max_out, Y_inter_int, y_small_proc;
   int run_time;
};
   
