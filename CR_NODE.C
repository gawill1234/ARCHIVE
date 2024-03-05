#include <stdio.h>

#include "struct.h"

struct exec_list *cr_exec_node(cmd, path)
char *cmd, *path;
{
struct exec_list *new_exec_node;
struct path_list *cr_path_node();

   new_exec_node = (struct exec_list *)malloc(sizeof(struct exec_list));
   new_exec_node->cmd_name = (char *)malloc(strlen(cmd) + 1);
   strcpy(new_exec_node->cmd_name, cmd);
   new_exec_node->bal = 0;
   if (path != NULL)
      new_exec_node->paths = cr_exec_node(path, NULL);
   else
      new_exec_node->paths = NULL;
   new_exec_node->tests = NULL;
   new_exec_node->left = NULL;
   new_exec_node->right = NULL;
   return(new_exec_node);
}

struct path_list *cr_path_node(path)
char *path;
{
struct path_list *new_path_node;

   new_path_node = (struct path_list *)malloc(sizeof(struct path_list));
   new_path_node->path_name = (char *)malloc(strlen(path) + 1);
   strcpy(new_path_node->path_name, path);
   new_path_node->next = NULL;
   return(new_path_node);
}

void rm_exec_node(old_exec_node)
struct exec_list *old_exec_node;
{

   free(old_exec_node->cmd_name);
   free(old_exec_node);
}

struct test_list *cr_test_node()
{
struct test_list *new_test_node;

   new_test_node = (struct test_list *)malloc(sizeof(struct test_list));
   new_test_node->test_name = NULL;
   new_test_node->actual_exit = 0;
   new_test_node->expected_exit = 0;
   new_test_node->whodolog = 0;
   new_test_node->localrm = 0;
   new_test_node->icp = 0;
   new_test_node->itp = 0;
   new_test_node->rf = 0;
   new_test_node->testwisdom = NULL;
   new_test_node->step1 = NULL;
   new_test_node->getfiles = NULL;
   new_test_node->rmfiles = NULL;
   new_test_node->nexttest = NULL;
   return(new_test_node);
}

void rm_test_node(old_test_node)
struct test_list *old_test_node;
{
void rm_exit_list(), rm_file_list(), rm_steps_list();

   free(old_test_node->test_name);
   if (old_test_node->rmfiles != NULL)
      rm_file_list(old_test_node->rmfiles);
   if (old_test_node->getfiles != NULL)
      rm_file_list(old_test_node->getfiles);
   if (old_test_node->step1 != NULL)
      rm_steps_list(old_test_node->step1);
   if (old_test_node->testwisdom != NULL)
      rm_exit_list(old_test_node->testwisdom);
   free(old_test_node);
}

void rm_test_list(old_test_node)
struct test_list *old_test_node;
{
struct test_list *temp_node;
void rm_test_node();

   while (old_test_node != NULL) {
      temp_node = old_test_node;
      old_test_node = old_test_node->nexttest;
      rm_test_node(temp_node);
   }
}

struct steps_list *cr_steps_node()
{
struct steps_list *new_steps_node;

   new_steps_node = (struct steps_list *)malloc(sizeof(struct steps_list));
   new_steps_node->path = NULL;
   new_steps_node->cmd = NULL;
   new_steps_node->execline = NULL;
   new_steps_node->options = NULL;
   new_steps_node->num_cases = 0;
   new_steps_node->expected_exit = 0;
   new_steps_node->actual_exit = 0;
   new_steps_node->stepwisdom = NULL;
   new_steps_node->nextstep = NULL;
   return(new_steps_node);
}

void rm_steps_node(old_steps_node)
struct steps_list *old_steps_node;
{
   free(old_steps_node->path);
   free(old_steps_node->cmd);
   free(old_steps_node->execline);
   free(old_steps_node->options);
   if (old_steps_node->stepwisdom != NULL)
      rm_exit_list(old_steps_node->stepwisdom);
   free(old_steps_node);
}

void rm_steps_list(old_steps_node)
struct steps_list *old_steps_node;
{
struct steps_list *temp_node;
void rm_steps_node();

   while (old_steps_node != NULL) {
      temp_node = old_steps_node;
      old_steps_node = old_steps_node->nextstep;
      rm_steps_node(temp_node);
   }
}

struct file_list *cr_file_node(name, location)
char *name, *location;
{
struct file_list *new_file_node;

   new_file_node = (struct file_list *)malloc(sizeof(struct file_list));
   new_file_node->file_name = name;
   new_file_node->file_location = location;
   new_file_node->next = NULL;
   return(new_file_node);
}

struct exit_list *cr_exit_node(code, message)
int code;
char *message;
{
struct exit_list *new_exit_node;

   new_exit_node = (struct exit_list *)malloc(sizeof(struct exit_list));
   new_exit_node->exit_code = code;
   new_exit_node->exit_message = message;
   new_exit_node->next = NULL;
   return(new_exit_node);
}

void rm_file_node(old_file_node)
struct file_list *old_file_node;
{

   free(old_file_node->file_name);
   free(old_file_node->file_location);
   free(old_file_node);
}

void rm_file_list(old_file_node)
struct file_list *old_file_node;
{
struct file_list *temp_node;
void rm_file_node();

   while (old_file_node != NULL) {
      temp_node = old_file_node;
      old_file_node = old_file_node->next;
      rm_file_node(temp_node);
   }
}

void rm_exit_node(old_exit_node)
struct exit_list *old_exit_node;
{

   free(old_exit_node->exit_message);
   free(old_exit_node);
}

void rm_exit_list(old_exit_node)
struct exit_list *old_exit_node;
{
struct exit_list *temp_node;
void rm_exit_node();

   while (old_exit_node != NULL) {
      temp_node = old_exit_node;
      old_exit_node = old_exit_node->next;
      rm_exit_node(temp_node);
   }
}
