#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/vfs.h>
#include <pthread.h>

#include "viv_goop.h"

//struct pid_ptr_thing pid_node_arr[MAX_CHILDREN];
extern struct pid_ptr_thing pid_node_arr[];

void print_node_type(int ntype, FILE *fno)
{
   switch (ntype) {
      case DRCTRY:
                   fprintf(fno, "NODE TYPE:  Directory\n");
                   break;
      case RFL:
                   fprintf(fno, "NODE TYPE:  Regular File\n");
                   break;
      case NMDPP:
                   fprintf(fno, "NODE TYPE:  Named Pipe\n");
                   break;
      case SYMLNK:
                   fprintf(fno, "NODE TYPE:  Symbolic Link\n");
                   break;
      case HRDLNK:
                   fprintf(fno, "NODE TYPE:  Hard Link\n");
                   break;
      default:
                   fprintf(fno, "NODE TYPE:  Regular File\n");
                   break;
   }

   return;
}

int random_int_in_range(int min, int max)
{
int range, val;
double myrand;

   range = (max + 1) - min;

   if (range > 0) {
      myrand = 0.0;

      myrand = drand48();

      val = (int)(myrand * (double)range);

      val = val + min;

      if (val > max)
         val = max;
   } else {
      val = min;
   }

   return(val);
}

void dumpurl(struct fs_creations *item, int crawl_type,
             FILE *finfo, FILE *rawpath)
{
char *filename, *build_full_path();

   filename = build_full_path(item);

   if (item->node_status == NODE_EXISTS) {
      exp_exists++;
   } else {
      exp_deleted++;
#ifdef DEBUG
      printf("+++++EXP deleted:%d://%s\n", item->node_status, filename);
      fflush(stdout);
#endif
   }

   if (my_access(item) == 0) {
      switch (item->node_type) {
         case SYMLNK:
         case RFL:
         case HRDLNK:
                       if (my_size(item) > 0) {
                          if (crawl_type == FILE_CRAWL) {
                             fprintf(finfo, "file:/%s\n", filename);
                          }
                          if (crawl_type == SMB_CRAWL) {
                             fprintf(finfo, "smb:/%s\n", filename);
                          }
                          fprintf(rawpath, "%s\n", filename);
                       }
                       act_exists++;
                       break;
         case NMDPP:
                       if (my_size(item) > 0) {
                          if (crawl_type == SMB_CRAWL) {
                             fprintf(finfo, "smb:/%s\n", filename);
                          }
                          fprintf(rawpath, "%s\n", filename);
                       }
                       act_exists++;
                       break;
         case DRCTRY:
         default:
                       act_exists++;
                       break;
      }
   } else {
#ifdef DEBUG
      printf("-----DELETED://%s\n", filename);
      fflush(stdout);
#endif
      act_deleted++;
   }

   free(filename);

   return;
}

void dumpdata(struct fs_creations *item, FILE *fno)
{

   print_node_type(item->node_type, fno);
   switch (item->node_type) {
      case NMDPP:
      case RFL:
                 fprintf(fno, "   NODE NAME(PATH):    %s/%s\n", item->node_dir, item->node_name);
                 fprintf(fno, "   LENGTH:             %d\n", item->file_size);
                 break;
      case DRCTRY:
                 fprintf(fno, "   NODE NAME(DIR):     %s\n", item->node_dir);
                 break;
      case SYMLNK:
      case HRDLNK:
                 fprintf(fno, "   NODE NAME(LINK):    %s/%s\n", item->node_dir, item->node_name);
                 fprintf(fno, "   TARGET:             %s/%s\n", item->linked_to->node_dir, item->linked_to->node_name);
                 break;
      default:
                 break;
   }

   return;
}

static void *creation_loop(struct fs_creations *head)
{
struct fs_creations *new_node, *new_node_node(), *add_new_node(), *tracker;
struct fs_creations *use_this_dir, *get_x_node_name();
char *unique_file();
char *filename = NULL;
time_t this_time;
int i, ntype, which_dir, status;
FILE *fno;
struct statfs *buf;
struct statfs *getfssz();
unsigned long fillmaxbytes;

   fno = fopen("fc_creations", "w+");

   fillmaxbytes = getmaxbytes(head, 0);

   while (fillmaxbytes > 0) {
      do {
         which_dir = random_int_in_range(1, drctry_cnt);
         use_this_dir = get_x_node_name(head, DRCTRY, which_dir);
      } while (use_this_dir->node_status != NODE_EXISTS);
      ntype = get_node_type(1);
      filename = unique_file(use_this_dir->node_dir, ntype);
      new_node = new_node_node(filename, ntype, use_this_dir);
      head = add_new_node(head, new_node);
      create_it(new_node);
      dumpdata(new_node, fno);
      this_time = time((long *)0);
      if (this_time > head->run_time) {
         fprintf(fno, "CREATION LOOP FINISHING -- TIMES UP at %d\n", this_time);
         break;
      }
      fillmaxbytes = getmaxbytes(head, 0);
      fprintf(fno, "CREATION LOOP TIME REMAINING:  %d\n", (head->run_time - this_time));
      fprintf(fno, "CREATION LOOP BLOCKS REMAINING:  %d\n", fillmaxbytes);
   }

   fprintf(fno, "CREATION LOOP COMPLETED\n");
   fclose(fno);

   pthread_exit(NULL);
}

void show_usage()
{

   printf("lrd_create [-c <f|s>] [-f <fs fill %>] [-r <run time>]\n\n");

   printf("   -c f: means output will indicate a file system crawl\n");
   printf("   -c s: means output will indicate a samba crawl\n");
   printf("         Output for f will be like:\n");
   printf("            file:///full/file/path\n");
   printf("         Output for s will be like:\n");
   printf("            smb:///smb/file/path\n");
   printf("         default is samba crawl\n\n");

   printf("   -f fill-%:  how full to make a file system while creating\n");
   printf("            file system nodes (files, directories, etc.)\n");
   printf("         -f 80 means fill to 80 percent full\n");
   printf("         default is 75%\n\n");

   printf("   -r run-time:  how long to run the program (even after\n");
   printf("            achieving fill percent above).  Since any node\n");
   printf("            can be modified after being created, how\n");
   printf("            long should this run\n");
   printf("         run-time is in seconds\n");
   printf("         -r 300 would mean run for 5 minutes (300 secs)\n");
   printf("         default is 86400 (24 hours)\n\n");

   fflush(stdout);

   exit(0);
}

int main(int argc, char **argv)
{
//char *tmparr = "/testenv/lrd";
char *tmparr = "/tmp/testing";
struct fs_creations *head = NULL;
struct fs_creations *new_node, *new_node_node(), *add_new_node(), *tracker;
int i, crawl_type, fill_perc, run_time, c;
time_t this_time;
FILE *myout, *myout2;
pthread_t cr_thread;
extern char *optarg;
static char *optstring = "F:c:f:r:hv";
char *sysname, *usedir;

   //   default crawl we are building for will be samba/cifs
   crawl_type = SMB_CRAWL;
   //   file system fill percentage default to 50%
   fill_perc = 50;
   //   run_time in seconds, default to 24 hours (86400 seconds).
   run_time = 24 * 60 * 60;
   usedir = tmparr;

   while ((c=getopt(argc, argv, optstring)) != EOF) {
      switch ((char)c) {
         case 'c':
                     if (strcmp(optarg, "f") == 0)
                        crawl_type = FILE_CRAWL;
                     break;
         case 'f':
                     fill_perc = atoi(optarg);
                     break;
         case 'F':
                     usedir = optarg;
                     break;
         case 'r':
                     run_time = atoi(optarg);
                     break;
         case 'v':
                     verbose = 1;
                     break;
         case 'h':
         default:
                     show_usage();
                     break;
      }
   }


   this_time = time((long *)0);
#ifdef DEBUG
   printf("SEED:  %d\n", this_time);
   fflush(stdout);
#endif
   srand48(this_time);

   drctry_cnt++;
   new_node = new_node_node(usedir, DRCTRY, NULL);
   head = add_new_node(head, new_node);
   if (access(usedir, F_OK) != 0) {
      replace_directory(usedir, head);
   }
   set_node_status(head, NODE_EXISTS, "main");

   //
   //   Not intuitive, but putting them here makes it easier to
   //   carry around.
   //
   head->run_time = this_time + run_time;
   head->fill_perc = 0;

   getmaxbytes(head, fill_perc);

#ifdef DEBUG
   printf("RUN:  %d, %d, %d\n", this_time, run_time, head->run_time);
   fflush(stdout);
   printf("FP:   %d\n", fill_perc);
   fflush(stdout);
#endif

   for (i = 0; i < MAX_CHILDREN; i++) {
      pid_node_arr[i].pid = 0;
      pid_node_arr[i].base_node = NULL;
      pid_node_arr[i].op_node = NULL;
   }

   //creation_loop(head);
   //   Spin off the object creation loop as a thread.
   //   After this, spin off the object modification thread as
   //   a thread.  Creation spins off child processes which run
   //   together to create multiple items at one time.  Modification
   //   spins off threads to do the same, but threads can more easily
   //   keep track of what has/is happening and react accordingly.  At
   //   this comment, the plan is to allow 10 creation processes and
   //   5 modification threads to run concurrently.  This should do
   //   quite a good job at changing a collection out from under the
   //   crawler.
   //
   if (pthread_create(&cr_thread, NULL, (void *)creation_loop, head) != 0) {
      fprintf(stderr, "Could not start creation thread, exiting\n");
      exit(1);
   }

   sleep(10);
   while (total_cnt < 10);

   do_node_updates(head);

   if (pthread_join(cr_thread, NULL) != 0) {
      fprintf(stderr, "Creation thread rejoin failed\n");
   }

   while (children > 0) {
      dowait();
      if (children > 0) {
         sleep(1);
      }
   }

#ifdef DEBUG
   tracker = head;
   while (tracker != NULL) {
      dumpdata(tracker);
      tracker = tracker->next;
   }
#endif

   myout = fopen("fc_files", "w+");
   myout2 = fopen("fc_raw_files", "w+");
   tracker = head;
   while (tracker != NULL) {
      dumpurl(tracker, crawl_type, myout, myout2);
      tracker = tracker->next;
   }
   fclose(myout);

   myout = fopen("fc_tally", "w+");
   fprintf(myout, "Directories:      %d\n", drctry_cnt);
   fprintf(myout, "Regular Files:    %d\n", rfl_cnt);
   fprintf(myout, "Symbolic Links:   %d\n", symlnk_cnt);
   fprintf(myout, "Hard Links:       %d\n", hrdlnk_cnt);
   fprintf(myout, "Named Pipes:      %d\n", nmdpp_cnt);
   fprintf(myout, "Expected nodes:   %d\n", exp_exists);
   fprintf(myout, "Actual nodes:     %d\n", act_exists);
   fprintf(myout, "Expected deleted: %d\n", exp_deleted);
   fprintf(myout, "Actual deleted:   %d\n", act_deleted);
   fclose(myout);

   exit(0);
}
