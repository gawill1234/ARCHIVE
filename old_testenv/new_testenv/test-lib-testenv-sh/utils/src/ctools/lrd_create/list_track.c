#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#include "viv_goop.h"

int set_node_status(struct fs_creations *node, int node_status, char *from)
{
char *filename, *build_full_path();

   filename = build_full_path(node);

   switch (node_status) {
      case NODE_EXISTS:
         if (my_access(node) == 0) {
            node->node_status = node_status;
#ifdef DEBUG
            printf("===SET STATUS: EXISTS from %s, %s\n", from, filename);
#endif
         } else {
            node->node_status = NODE_DELETED;
            if (verbose) {
               fprintf(stderr, "===SET STATUS: DELETED(ERR) from %s, %s\n", from, filename);
            }
         }
         break;
      case NODE_DELETED:
         if (my_access(node) == 0) {
            node->node_status = NODE_EXISTS;
            if (verbose) {
               fprintf(stderr, "===SET STATUS: EXISTS(ERR) from %s, %s\n", from, filename);
            }
         } else {
            node->node_status = node_status;
#ifdef DEBUG
            printf("===SET STATUS: DELETED from %s, %s\n", from, filename);
#endif
         }
         break;
      case NODE_CRTFAIL:
         if (my_access(node) == 0) {
            node->node_status = NODE_EXISTS;
            if (verbose) {
               fprintf(stderr, "===SET STATUS: EXISTS(ERR) from %s, %s\n", from, filename);
            }
         } else {
            node->node_status = node_status;
#ifdef DEBUG
            printf("===SET STATUS: CRTFAIL from %s, %s\n", from, filename);
#endif
         }
         break;
      case NODE_WORKING:
         node->node_status = node_status;
#ifdef DEBUG
         printf("===SET STATUS: WORKING from %s, %s\n", from, filename);
#endif
         break;
   }

   free(filename);

   return(0);
}

struct node_ops *get_most_current_op(struct node_ops *op_node)
{
struct node_ops *tracker;

   tracker = op_node;

   while (tracker->op_next_op != NULL) {
      tracker = tracker->op_next_op;
   }

   return(tracker);
}

/*
 *   Get a target for a link to point at.  The
 *   link can be anything, even the link itself.
 */
struct fs_creations *get_link_target(struct fs_creations *head)
{
struct fs_creations *tracker;
int which, i;

   do {
      which = random_int_in_range(1, total_cnt);
      tracker = head;

      for (i = 0; i < which; i++) {
         if (tracker->next != NULL) {
            tracker=tracker->next;
         }
      }
   } while (tracker != NULL && tracker->node_status != NODE_EXISTS);

   return(tracker);
}

/*
 *   Get a target for an update.
 *   It can be anything as long as it is not currently in use.
 */
struct fs_creations *get_update_target(struct fs_creations *head)
{
struct fs_creations *tracker;
int which, i;

   do {
      which = random_int_in_range(1, total_cnt);
      tracker = head;

      for (i = 0; i < which; i++) {
         if (tracker->next != NULL) {
            tracker=tracker->next;
         }
      }
   } while (tracker != NULL && tracker->node_status == NODE_WORKING);

   return(tracker);
}

/*
 *   File sizes are broken up into 6 possible ranges.
 *   Each range is larger than the previous range.
 *   The minimum possible file size is 0.  At the moment,
 *   the max is around 31M.  This will be easy to change
 *   if need be.
 */
void get_file_len_range(int *min_len, int *max_len)
{
double ranger;

   ranger = drand48();

   if (ranger >= 0.0 && ranger <= .2) {
      *min_len = 0;
      *max_len = 2048;
      return;
   }
   if (ranger > .2 && ranger <= .5) {
      *min_len = 2049;
      *max_len = 16384;
      return;
   }
   if (ranger > .5 && ranger <= .8) {
      *min_len = 16385;
      *max_len = 65536;
      return;
   }
   if (ranger > .8 && ranger <= .9) {
      *min_len = 65537;
      *max_len = 524288;
      return;
   }
   if (ranger > .9 && ranger <= .98) {
      *min_len = 524289;
      *max_len = 3145728;
      return;
   }
   if (ranger > .98) {
      *min_len = 3145729;
      *max_len = 31457280;
      return;
   }

   fprintf(stderr, "get_file_len_range() Error: we should not even get here\n");
   fflush(stderr);

   return;
}

int file_length()
{
int pfxlen, max_len, min_len;

   get_file_len_range(&min_len, &max_len);
 
   pfxlen = random_int_in_range(min_len, max_len);

   return(pfxlen);
}


/*******************************************************/
//
//   Return the last segment of a complete path.
//   This is the same as linux/unix basename().
//
char *_basename(char *path)
{
        register int i;

        i = strlen(path);
        for (i--; i >= 0; i--)
#ifdef PLATFORM_WINDOWS
           if (path[i] == '\\')
#else
           if (path[i] == '/')
#endif
              if (i == 0)
                 return(NULL);
              else
                 break;
        i++;

        return(&path[i]) ;
}
/*******************************************************/
//
//   Return the directory name from a file path, or the
//   preceding directory name from a directory path.
//   This is the same as linux/unix dirname().
//
char *_dirname(char *path)
{
        register int i;

        i = strlen(path);
        for (i--; i>= 0; i--)
#ifdef PLATFORM_WINDOWS
           if (path[i] == '\\')
#else
           if (path[i] == '/')
#endif
              if (i == 0)
                 return(path);
              else
                 break;
        path[i] = '\0';
        i++;

        return(path) ;
}

struct node_ops *new_ops_node(int op_performed, int insize,
                              struct fs_creations *in_node)
{
struct node_ops *new_node = NULL;

   new_node = (struct node_ops *)malloc(sizeof(struct node_ops));

   new_node->op_type = op_performed;
   new_node->op_outcome = OP_UNKNOWN;
   new_node->op_size = insize;
   new_node->op_next_op = NULL;
   new_node->node_ptr = in_node;

   return(new_node);
}

//
//   Create and initialize (only initialize) the new nodes
//   which contain the data related to each node.
//
struct fs_creations *new_node_node(char *node_path, int ntype,
                                   struct fs_creations *dir_node)
{
struct fs_creations *new_node = NULL;

   if (node_path != NULL) {

      new_node = (struct fs_creations *)malloc(sizeof(struct fs_creations));

      //
      //   This basename/dirname combo only works because
      //   it is done in this order.  basename only return
      //   an address.  dirname however, sets the final
      //   slash in the name to a nul.
      //
      if (ntype != DRCTRY) {
         new_node->node_name = _basename(node_path);
         new_node->node_dir = _dirname(node_path);
      } else {
         new_node->node_dir = node_path;
         new_node->node_name = NULL;
      }

      new_node->dir_ptr = dir_node;
      new_node->next = NULL;
      new_node->linked_to = NULL;

      new_node->file_size = 0;
      new_node->fill_perc = 0;
      new_node->run_time = 0;
      new_node->node_type = ntype;
      set_node_status(new_node, NODE_WORKING, "new_node_node");
      new_node->op_list = new_ops_node(OP_CREATE, 0, new_node);
   }

   return(new_node);
}

//
//   Add the new node to the list and finish any node
//   specific set ups, such as getting the length that
//   a regular file should be or getting the target for
//   a link.
//
struct fs_creations *add_new_node(struct fs_creations *head,
                                  struct fs_creations *new_node)
{
struct fs_creations *tracker;

   if (head == NULL) {
      head = new_node;
   } else {
      tracker = head;
      while (tracker->next != NULL) {
         tracker = tracker->next;
      }
      tracker->next = new_node;
   }

   if (new_node->node_type == HRDLNK || new_node->node_type == SYMLNK) {
      new_node->linked_to = get_link_target(head);
   }

   if (new_node->node_type == RFL || new_node->node_type == NMDPP) {
      new_node->file_size = file_length();
   }

   return(head);
}

struct fs_creations *get_x_node_name(struct fs_creations *head,
                                     int ntype, int which)
{
struct fs_creations *tracker;
int counter;

   counter = 0;
   tracker = head;
   while (tracker != NULL) {
      if (tracker->node_type == ntype) {
         counter++;
         if (counter == which) {
            return(tracker);
         }
      }
      tracker = tracker->next;
   }

   return(head);
}
