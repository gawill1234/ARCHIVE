#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>

#include "viv_goop.h"

//extern struct pid_ptr_thing pid_node_arr[MAX_CHILDREN];
extern struct pid_ptr_thing pid_node_arr[];

#define NOTHING -1

void clear_pid_elem(int pid)
{
   pid_node_arr[pid].pid = 0;
   pid_node_arr[pid].base_node = NULL;
   pid_node_arr[pid].op_node = NULL;

   return;
}

void set_pid_elem_result(int pid)
{

   pid_node_arr[pid].op_node->op_outcome = OP_SUCCESS;
   set_node_status(pid_node_arr[pid].base_node, NODE_EXISTS, "set_pid_elem_result");

   if ( pid_node_arr[pid].op_node->op_type == OP_DELETE) {
      set_node_status(pid_node_arr[pid].base_node, NODE_DELETED, "set_pid_elem_result");
   }

   return;
}

struct fs_creations *get_last_link(struct fs_creations *item)
{
struct fs_creations *tracker;

   tracker = item;
   while (tracker->linked_to != NULL) {
      tracker = tracker->linked_to;
   }

   return(tracker);
}

int get_pid_elem(int pid)
{
int i;

   for (i = 0; i < MAX_CHILDREN; i++) {
      if (pid_node_arr[i].pid == pid) {
         return(i);
      }
   }

   return(-1);
}

void proc_flush(int xx)
{
int pidelem;

   children--;
   pidelem = get_pid_elem(xx);
   if (pidelem >= 0) {
      set_pid_elem_result(pidelem);
      clear_pid_elem(pidelem);
   } else {
      fprintf(stderr, "proc_flush():  no pid %d found\n", xx);
   }

   return;
}

void dowait()
{
int xx, status, pidelem;

   if (children > 0) {
      if (children < MAX_CHILDREN) {
         while ((xx = waitpid((-1), &status, WNOHANG)) > 0) {
            proc_flush(xx);
         }
      } else {
         xx = wait(&status);
         if (xx > 0) {
            proc_flush(xx);
         }
         while ((xx = waitpid((-1), &status, WNOHANG)) > 0) {
            proc_flush(xx);
         }
      }
   }

   return;
}


int file_create(struct fs_creations *wrk_node)
{
char *filename, *build_full_path();
int fno, childpid, i;
struct node_ops *get_most_current_op();

   fno = NOTHING;
   filename = build_full_path(wrk_node);

   if (filename != NULL) {
      fno = open(filename, O_RDWR | O_CREAT, 0666);
      if (fno < 0) {
         if (verbose) {
            perror("file_create");
            fprintf(stderr, "   Creation of %s failed\n", filename);
         }
      }
      free(filename);
   }

   if (fno < 0) {
      set_node_status(wrk_node, NODE_CRTFAIL, "file_create");
   } else {
      dowait();
      childpid = fork();
      if (childpid == 0) {
         dofile(fno, wrk_node);
         close(fno);
         exit(0);
      }
      if (childpid > 0) {
         children++;
         i = 0;
         while (i < MAX_CHILDREN && pid_node_arr[i].pid != 0) {
            i++;
         }
         pid_node_arr[i].pid = childpid;
         pid_node_arr[i].base_node = wrk_node;
         pid_node_arr[i].op_node = get_most_current_op(wrk_node->op_list);
      }
   }

   return(fno);
}

int link_create(struct fs_creations *wrk_node)
{
char *filename1, *filename2, *build_full_path();
int err;

   err = NOTHING;
   filename1 = build_full_path(wrk_node);
   if (wrk_node->linked_to != NULL) {
      filename2 = build_full_path(wrk_node->linked_to);
   } else {
      fprintf(stderr, "link_create:  Nothing to link to\n");
      fprintf(stderr, "   Creation of %s failed\n", filename1);
      free(filename1);
      return(err);
   }

   if (filename1 != NULL) {
      if (filename2 != NULL) {
         err = link(filename2, filename1);
         if (err < 0) {
            sleep(1);
            err = link(filename2, filename1);
            if (err < 0) {
               if (verbose) {
                  perror("link_create");
                  fprintf(stderr, "   Creation of %s to %s failed\n", filename1, filename2);
               }
            }
         }
         free(filename2);
      }
      free(filename1);
   }

   if (err < 0) {
      set_node_status(wrk_node, NODE_CRTFAIL, "link_create");
   } else {
      set_node_status(wrk_node, NODE_EXISTS, "link_create");
   }

   return(err);
}

int symlink_create(struct fs_creations *wrk_node)
{
char *filename1, *filename2, *build_full_path();
int err;

   err = NOTHING;
   filename1 = build_full_path(wrk_node);
   if (wrk_node->linked_to != NULL) {
      filename2 = build_full_path(wrk_node->linked_to);
   } else {
      fprintf(stderr, "symlink_create:  Nothing to link to\n");
      fprintf(stderr, "   Creation of %s failed\n", filename1);
      free(filename1);
      return(err);
   }


   if (filename1 != NULL) {
      if (filename2 != NULL) {
         err = symlink(filename2, filename1);
         if (err < 0) {
            sleep(1);
            err = symlink(filename2, filename1);
            if (err < 0) {
               if (verbose) {
                  perror("symlink_create");
                  fprintf(stderr, "   Creation of %s to %s failed\n", filename1, filename2);
               }
            }
         }
         free(filename2);
      }
      free(filename1);
   }

   if (err < 0) {
      set_node_status(wrk_node, NODE_CRTFAIL, "symlink_create");
   } else {
      set_node_status(wrk_node, NODE_EXISTS, "symlink_create");
   }

   return(err);
}

int directory_create(struct fs_creations *wrk_node)
{
int err;

   err = mkdir(wrk_node->node_dir, 0777);

   if (err < 0) {
      if (verbose) {
         perror("directory_create");
         fprintf(stderr, "   Creation of %s failed\n", wrk_node->node_dir);
      }
      set_node_status(wrk_node, NODE_CRTFAIL, "directory_create");
   } else {
      set_node_status(wrk_node, NODE_EXISTS, "directory_create");
   }

   return(err);
}

int npipe_create(struct fs_creations *wrk_node)
{
char *filename, *build_full_path();
int fno, err;

   err = fno = NOTHING;
   filename = build_full_path(wrk_node);

   if (filename != NULL) {
      err = mkfifo(filename, 0666);
      if (err < 0) {
         if (verbose) {
            perror("npipe_create");
            fprintf(stderr, "   Creation of %s failed\n", filename);
         }
      }
      free(filename);
   }

   if (err < 0) {
      set_node_status(wrk_node, NODE_CRTFAIL, "npipe_create");
   } else {
      set_node_status(wrk_node, NODE_EXISTS, "npipe_create");
   }

   return(err);
}

void create_it(struct fs_creations *wrk_node)
{
int fno;

   switch (wrk_node->node_type) {
      case RFL:
                 fno = file_create(wrk_node);
                 close(fno);
                 break;
      case HRDLNK:
                 fno = link_create(wrk_node);
                 break;
      case NMDPP:
                 fno = npipe_create(wrk_node);
                 break;
      case DRCTRY:
                 directory_create(wrk_node);
                 break;
      case SYMLNK:
                 fno = symlink_create(wrk_node);
                 break;
      default:
                 break;
   }

   return;
}
