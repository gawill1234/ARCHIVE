#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <dirent.h>

#include "viv_goop.h"

struct node_ops *add_new_op_to_node(struct fs_creations *tracker, int myop)
{
struct node_ops *op_track, *new_ops_node(), *get_most_current_op();

   op_track = get_most_current_op(tracker->op_list);
   op_track->op_next_op = new_ops_node(myop, 0, tracker);
   op_track = op_track->op_next_op;

   return(op_track);
}

struct fs_creations *find_node_by_path(struct fs_creations *head,
                                       char *fullpath)
{
char *mypath;
struct fs_creations *tracker;
char *build_full_path();

   if (fullpath != NULL) {
      tracker = head;
      do {
         mypath = build_full_path(tracker);
         if (strcmp(mypath, fullpath) == 0) {
            free(mypath);
            return(tracker);
         }
         free(mypath);
         tracker = tracker->next;
      } while (tracker != NULL);
   } else {
      tracker = NULL;
   }

   return(tracker);

}

void dumpsize(char *filename)
{
struct stat buf;

   if (access(filename, F_OK) == 0) {
      stat(filename, &buf);
      printf("   FILE SIZE:  %d\n", buf.st_size);
      fflush(stdout);
   } else {
      printf("   APPEND NO EXIST:  %s\n", filename);
      fflush(stdout);
   }

   return;
}

char *restore_dir_path(char *path, int plen)
{
char *mptr;
int i;

   mptr = path;

   for (i = 0; i < plen; i++) {
      if (*mptr == '\0') {
         *mptr = '/';
         return(path);
      } else {
         mptr++;
      }
   }

   return(NULL);
}

void replace_directory(char *directory_name,
                       struct fs_creations *head)
{
char *working_dir, *usethis, *_dirname();
int plen;
struct fs_creations *tracker;

   plen = strlen(directory_name);
   working_dir = (char *)calloc(plen + 1, 1);

   strcpy(working_dir, directory_name);

   while (access(working_dir, F_OK) != 0) {
      working_dir = _dirname(working_dir);
   }

   while (access(directory_name, F_OK) != 0) {
      usethis = restore_dir_path(working_dir, plen);
      if (usethis == NULL) {
         break;
      } else {
         tracker = find_node_by_path(head, working_dir);
         set_node_status(tracker, NODE_WORKING, "replace_directory");
         mkdir(working_dir, 0777);
         set_node_status(tracker, NODE_EXISTS, "replace_directory");
      }
   }

   free(working_dir);

   return;
}

void replace_node(struct node_ops *op_node,
                  struct fs_creations *head)
{
int ntype, plen; 
char *_dirname(), *_basename();
struct fs_creations *get_link_target();
void append_file();

   ntype = get_node_type(0);

   if (ntype != DRCTRY) {
      if (op_node->node_ptr->node_type == DRCTRY) {
         op_node->node_ptr->node_name = _basename(op_node->node_ptr->node_dir);
         op_node->node_ptr->node_dir = _dirname(op_node->node_ptr->node_dir);
      }
   } else { 
      if (op_node->node_ptr->node_type != DRCTRY) {
         //
         //   This takes advantage of the fact that node_dir and
         //   node_name are actually part of the same string with 2
         //   pointers into it seperated by a character null.  This 
         //   is just putting the '/' back into the path where the 
         //   null was.
         //
         plen = strlen(op_node->node_ptr->node_dir) +
                strlen(op_node->node_ptr->node_name) + 1;
         op_node->node_ptr->node_dir = restore_dir_path(op_node->node_ptr->node_dir, plen);
         op_node->node_ptr->node_name = NULL;
      }
   }
   replace_directory(op_node->node_ptr->node_dir, head);
   op_node->node_ptr->node_type = ntype;

   switch (ntype) {
      case RFL:
         append_file(op_node);
         break;
      case DRCTRY:    //  Done already up above.
         if (access(op_node->node_ptr->node_dir, F_OK) == 0) {
            set_node_status(op_node->node_ptr, NODE_EXISTS, "replace_node");
         } else {
            set_node_status(op_node->node_ptr, NODE_DELETED, "replace_node");
         }
         break;
      case SYMLNK:
         op_node->node_ptr->linked_to = get_link_target(head);
         symlink_create(op_node->node_ptr);
         break;
      case HRDLNK:
         op_node->node_ptr->linked_to = get_link_target(head);
         link_create(op_node->node_ptr);
         break;
      case NMDPP:
         npipe_create(op_node->node_ptr);
         //append_file(op_node);
         break;
      default:
         break;
   }
      

   return;
}

void append_file(struct node_ops *op_node)
{
char *filename, *build_full_path(), *_basename(), *_dirname();
int fno, wrttn, holdsize;

   filename = build_full_path(op_node->node_ptr);

#ifdef DEBUG
   dumpsize(filename);
#endif

   switch (op_node->op_type) {
      case OP_REPLACE:
                op_node->op_size = file_length();
                fno = open(filename, O_RDWR | O_CREAT, 0666);
                break;
      case OP_OVRWRT:
                op_node->op_size = op_node->node_ptr->file_size;
                fno = open(filename, O_RDWR, 0666);
                break;
      case OP_APPEND:
      default:
                op_node->op_size = file_length();
                fno = open(filename, O_RDWR | O_APPEND, 0666);
                break;
   }

   if (fno > 0) {
      holdsize = op_node->node_ptr->file_size;
      op_node->node_ptr->file_size = op_node->op_size;
      wrttn = dofile(fno, op_node->node_ptr);
      close(fno);
      op_node->node_ptr->file_size = holdsize;

      if (access(filename, F_OK) == 0) {
         if (wrttn == op_node->op_size) {
            op_node->op_outcome = OP_SUCCESS;
         } else {
            op_node->op_outcome = OP_FAIL;
         }
         op_node->op_size = wrttn;
         set_node_status(op_node->node_ptr, NODE_EXISTS, "append_file");
      } else {
         op_node->op_outcome = OP_FAIL;
         set_node_status(op_node->node_ptr, NODE_DELETED, "append_file");
      }

      if (op_node->op_type == OP_OVRWRT) {
         op_node->op_size = 0;
      }
   } else {
      if (verbose) {
         fprintf(stderr, "append_file():  Open failed\n");
         fprintf(stderr, "append_file():     %s\n", filename);
      }
      op_node->op_outcome = OP_FAIL;
      if (access(filename, F_OK) == 0) {
         set_node_status(op_node->node_ptr, NODE_EXISTS, "append_file");
      } else {
         set_node_status(op_node->node_ptr, NODE_DELETED, "append_file");
      }
   }

#ifdef DEBUG
   dumpsize(filename);
#endif

   free(filename);

   return;
}

void trunc_file(struct node_ops *op_node)
{
char *filename, *build_full_path();
struct stat buf;
int shrinkfrom;

   filename = build_full_path(op_node->node_ptr);
#ifdef DEBUG
   dumpsize(filename);
#endif
   stat(filename, &buf);
   shrinkfrom = buf.st_size;
   op_node->op_size = random_int_in_range(1, shrinkfrom) * (-1);

   truncate(filename, (shrinkfrom + op_node->op_size));
#ifdef DEBUG
   dumpsize(filename);
#endif
   stat(filename, &buf);

   if (access(filename, F_OK) == 0) {
      if (buf.st_size == (shrinkfrom + op_node->op_size)) {
         op_node->op_outcome = OP_SUCCESS;
      } else {
         op_node->op_outcome = OP_FAIL;
      }
      set_node_status(op_node->node_ptr, NODE_EXISTS, "trunc_file");
   } else {
      op_node->op_outcome = OP_FAIL;
      set_node_status(op_node->node_ptr, NODE_DELETED, "trunc_file");
   }

   free(filename);

   return;
}

void delete_node(struct node_ops *op_node)
{
char *filename, *build_full_path();

   filename = build_full_path(op_node->node_ptr);
   if (access(filename, F_OK) == 0) {
      if (op_node->node_ptr->node_type == DRCTRY) {
         rmdir(filename);
      } else {
         unlink(filename);
      }
      if (access(filename, F_OK) == 0) {
#ifdef DEBUG
         printf("   DELETE FAILED:  %s\n", filename);
         fflush(stdout);
#endif
         op_node->op_outcome = OP_FAIL;
         set_node_status(op_node->node_ptr, NODE_EXISTS, "delete_node");
      } else {
#ifdef DEBUG
         printf("   DELETE SUCCEEDED:  %s\n", filename);
         fflush(stdout);
#endif
         op_node->op_outcome = OP_SUCCESS;
         set_node_status(op_node->node_ptr, NODE_DELETED, "delete_node");
      }
   } else {
      if (verbose) {
         fprintf(stderr, "delete_node():  Attempt to delete what does not exist\n");
         fprintf(stderr, "delete_node():     %s\n", filename);
      }
      op_node->op_outcome = OP_FAIL;
      set_node_status(op_node->node_ptr, NODE_DELETED, "delete_node");
   }

   free(filename);

   return;
}

//
//   Recursive routine to remove a directory and all
//   of its contents.  It drills down to get rid of
//   everything.
//
void remove_directory(char *directory, struct fs_creations *head)
{
struct stat buf;
struct fs_creations *tracker;
struct node_ops *op_track;
DIR *dirp;
char fullpath[256];
struct dirent *dp;
int err = 0;

   dirp = opendir(directory);
   if (dirp != NULL) {
      while ((dp = readdir(dirp)) != NULL) {
         if ((strcmp(dp->d_name, ".") != 0) && (strcmp(dp->d_name, "..") != 0)) {
#ifdef PLATFORM_WINDOWS
            sprintf(fullpath, "%s\\%s\0", directory, dp->d_name);
#else
            sprintf(fullpath, "%s/%s\0", directory, dp->d_name);
#endif
            stat(fullpath, &buf);
            if (S_ISDIR(buf.st_mode)) {
               remove_directory(fullpath, head);
            } else {
               tracker = find_node_by_path(head, fullpath);
               if (tracker != NULL) {
                  if (tracker->node_status != NODE_WORKING) {
                     set_node_status(tracker, NODE_WORKING, "remove_directory");
                     op_track = add_new_op_to_node(tracker, OP_DELETE);
                     delete_node(op_track);
                  }
               } else {
                  if (verbose) {
                     printf("   <ERROR>collection dir(UP):  %s could not be found</ERRORp>\n", directory);
                     fflush(stdout);
                  }
                  err = -1;
               }
            }
         }
      }
      closedir(dirp);
      tracker = find_node_by_path(head, directory);
      if (tracker != NULL) {
         if (tracker->node_status != NODE_WORKING) {
            set_node_status(tracker, NODE_WORKING, "remove_directory");
            op_track = add_new_op_to_node(tracker, OP_DELETE);
            delete_node(op_track);
         }
      } else {
         if (verbose) {
            printf("   <ERROR>collection dir(DOWN):  %s could not be found</ERRORp>\n", directory);
            fflush(stdout);
         }
         err = -1;
      }
   } else {
      if (verbose) {
         printf("   <ERROR>collection dir:  %s could not be opened</ERRORp>\n", directory);
         fflush(stdout);
      }
      err = -1;
   }

   return;
}

void do_delete(struct node_ops *op_node, struct fs_creations *head)
{

   //
   //   Can not delete the top level directory, sorry.
   //
   if (op_node->node_ptr == head) {
      return;
   }

   if (op_node->node_ptr->node_type != DRCTRY) {
      if (op_node->node_ptr->node_status != NODE_WORKING) {
         set_node_status(op_node->node_ptr, NODE_WORKING, "do_delete");
         delete_node(op_node);
      }
   } else {
      remove_directory(op_node->node_ptr->node_dir, head);
   }

   return;
}

void do_unknown(struct node_ops *op_node, struct fs_creations *head)
{

   //
   //   Can not delete the top level directory, sorry.
   //
   if (op_node->node_ptr == head) {
      return;
   }

   set_node_status(op_node->node_ptr, NODE_CRTFAIL, "do_unknown");
   op_node->op_outcome = OP_FAIL;

   return;
}

void dumper2(struct fs_creations *tracker, int myop, FILE *fno)
{


   fprintf(fno, "   DIRECTORY:  %s\n", tracker->node_dir);
   if (tracker->node_name != NULL)
      fprintf(fno, "   FILE NAME:  %s\n", tracker->node_name);

   switch (tracker->node_status) {
      case NODE_EXISTS:
         fprintf(fno, "   STATUS:  NODE EXISTS\n");
         break;
      case NODE_DELETED:
         fprintf(fno, "   STATUS:  NODE DELETED\n");
         break;
      case NODE_CRTFAIL:
         fprintf(fno, "   STATUS:  NODE CRTFAIL\n");
         break;
      case NODE_WORKING:
         fprintf(fno, "   STATUS:  NODE WORKING\n");
         break;
   }
   switch (myop) {
      case OP_CREATE:
         fprintf(fno, "   OPERATION:  CREATE\n");
         break;
      case OP_APPEND:
         fprintf(fno, "   OPERATION:  APPEND\n");
         break;
      case OP_TRUNC:
         fprintf(fno, "   OPERATION:  TRUNCATE\n");
         break;
      case OP_OVRWRT:
         fprintf(fno, "   OPERATION:  OVERWRITE\n");
         break;
      case OP_DELETE:
         fprintf(fno, "   OPERATION:  DELETE\n");
         break;
      case OP_RNDMCHG:
         fprintf(fno, "   OPERATION:  RANDOM CHANGE\n");
         break;
      case OP_REPLACE:
         fprintf(fno, "   OPERATION:  REPLACE\n");
         break;
   }

   return;
}

void do_op(struct node_ops *op_node, struct fs_creations *head)
{
char *filename, *build_full_path();
struct fs_creations *get_last_link();


   filename = build_full_path(op_node->node_ptr);

#ifdef DEBUG
   printf("   DO_OP\n");
   fflush(stdout);
   printf("   DO_OP FILE:  %s\n", filename);
   fflush(stdout);
#endif

   switch (op_node->op_type) {
      case OP_REPLACE:
                 replace_node(op_node, head);
                 break;
      case OP_OVRWRT:
      case OP_APPEND:
                 //if (op_node->node_ptr->node_type != NMDPP) {
                 if (get_last_link(op_node->node_ptr)->node_type != NMDPP) {
                    append_file(op_node);
                 } else {
                    set_node_status(op_node->node_ptr, NODE_EXISTS, "do_op");
                 }
                 break;
      case OP_TRUNC:
                 //if (op_node->node_ptr->node_type != NMDPP) {
                 if (get_last_link(op_node->node_ptr)->node_type != NMDPP) {
                    trunc_file(op_node);
                 } else {
                    set_node_status(op_node->node_ptr, NODE_EXISTS, "do_op");
                 }
                 break;
      case OP_DELETE:
                 do_delete(op_node, head);
                 break;
      case OP_RNDMCHG:
                 //op_node->op_type = OP_DELETE;
                 //do_delete(op_node, head);
                 if (access(filename, F_OK) == 0) {
                    set_node_status(op_node->node_ptr, NODE_EXISTS, "do_op");
                 } else {
                    set_node_status(op_node->node_ptr, NODE_DELETED, "do_op");
                 }
                 break;
      default:
                 do_unknown(op_node, head);
                 break;
   }

   free(filename);

   return;
}

void do_one_node_update(struct fs_creations *head, FILE *fno)
{
struct fs_creations *tracker, *get_update_target();
struct node_ops *op_track;
int myop;

   tracker = get_update_target(head);

   if (tracker->node_status == NODE_DELETED) {
      myop = OP_REPLACE;
   } else {
      //
      //   If the node is a directory, the only thing that can
      //   be done is to delete it or do random changes.  In the
      //   case of a directory a random change means deleting a
      //   number of files from it (random, of course).
      //
      if (tracker->node_type == DRCTRY) {
         myop = random_int_in_range(OP_DELETE, OP_RNDMCHG);
         fprintf(fno, "NODE_WORKING, D:  %d, %s\n", myop, tracker->node_dir);
         dumper2(tracker, myop, fno);
      } else {
         myop = random_int_in_range(OP_APPEND, OP_RNDMCHG);
         fprintf(fno, "NODE_WORKING, F:  %d, %s\n", myop, tracker->node_name);
         dumper2(tracker, myop, fno);
      }
   }

   fflush(stdout);

   if (myop != OP_DELETE) {
      set_node_status(tracker, NODE_WORKING, "do_one_node_update");
   }
   op_track = add_new_op_to_node(tracker, myop);
   do_op(op_track, head);

   return;
}

void do_node_updates(struct fs_creations *head)
{
int which, i;
time_t this_time;
FILE *fno;

   fno = fopen("fc_updates", "w+");

   do {
      do_one_node_update(head, fno);
      sleep(1);
      this_time = time((long *)0);
      fprintf(fno, "UPDATES LOOP TIME REMAINING:  %d\n", (head->run_time - this_time));
      if (this_time > head->run_time) {
         fprintf(fno, "UPDATES LOOP FINISHING -- TIMES UP at %d\n", this_time);
         break;
      }
   } while (this_time < head->run_time);

   fprintf(fno, "UPDATES LOOP COMPLETE\n");
   fclose(fno);

   return;
}
