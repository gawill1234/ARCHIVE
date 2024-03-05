#include <stdio.h>

#include "struct.h"

struct exec_list *rightrotat(p)
struct exec_list *p;
{
struct exec_list *hold, *q;

   hold = q = NULL;

   q = p->left;
   hold = q->right;
   q->right = p;
   p->left = hold;
}
struct exec_list *leftrotat(p)
struct exec_list *p;
{
struct exec_list *hold, *q;

   hold = q = NULL;

   q = p->right;
   hold = q->left;
   q->left = p;
   p->right = hold;
}
struct exec_list *checknbal(young, v, p, n, parent)
struct exec_list *young, *v, *p, *n, *parent;
{
int imbal;
struct exec_list *q = NULL;

   if (strcmp(p->cmd_name, young->cmd_name) < 0)
      imbal = 1;
   else
      imbal = -1;

   if (young->bal == 0) {
      young->bal = imbal;
   }
   else {
      if (young->bal != imbal) {
         young->bal = 0;
      }
      else {
         if (n->bal == imbal) {
            q = n;
            if (imbal == 1)
               rightrotat(young);
            else
               leftrotat(young);
            young->bal = 0;
            n->bal = 0;
         }
         else {
            if (imbal == 1) {
               q = n->right;
               leftrotat(n);
               young->left = q;
               rightrotat(young);
            }
            else {
               q = n->left;
               young->right = q;
               rightrotat(n);
               leftrotat(young);
            }
            if (q->bal == 0) {
               young->bal = 0;
               n->bal = 0;
            }
            else {
               if (q->bal == imbal) {
                  young->bal = imbal * (-1);
                  n->bal = 0;
               }
               else {
                  young->bal = 0;
                  n->bal = imbal;
               }
            }
            q->bal = 0;
         }
         if (v == NULL) {
            parent = q;
         }
         else {
            if (young == v->right) 
               v->right = q;
            else
               v->left = q;
         }
      }
   }
   return(parent);
}

struct exec_list *changebal(young, v, p, parent)
struct exec_list *young, *v, *p, *parent;
{
struct exec_list *q, *n;

   q = n = NULL;


   if (strcmp(p->cmd_name, young->cmd_name) < 0) 
      q = young->left;
   else
      q = young->right;

   n = q;

   while (strcmp(q->cmd_name, p->cmd_name) != 0) {
      if (strcmp(p->cmd_name, q->cmd_name) < 0) {
         q->bal = 1;
         q = q->left;
      }
      else {
         q->bal = -1;
         q = q->right;
      }
   }
   parent = checknbal(young, v, p, n, parent);
   return(parent);
}

struct exec_list *addnew(p, parent)
struct exec_list *p, *parent;
{
struct exec_list *v, *young, *r, *q;

   r = parent;
   q = parent;
   young = r;
   v = NULL;
   while (r != NULL) {
      if (strcmp(p->cmd_name, q->cmd_name) < 0) {
         r = q->left;
         if (r != NULL) {
            if (r->bal != 0) {
               v = q;
               young = r;
            }
         }
         if (r == NULL)
            q->left = p;
      }
      else {
         r = q->right;
         if (r != NULL) {
            if (r->bal != 0) {
               v = q;
               young = r;
            }
         }
         if (r == NULL)
            q->right = p;
      }
      q = r;
   }
   parent = changebal(young, v, p, parent);
   return(parent);
}

struct exec_list *puttotree(new_node, parent)
struct exec_list *new_node, *parent;
{

   if (parent == NULL)
      parent = new_node;
   else {
      parent = addnew(new_node, parent);
   }
   return(parent);
}

struct exec_list *searchtreecmd(cmd, parent)
char *cmd;
struct exec_list *parent;
{
struct exec_list *r;
int found = 0;

   r = parent;
   while ((r != NULL) && (found != 1)) {
      if (strcmp(cmd, r->cmd_name) == 0)
         found = 1;
      else {
         if (strcmp(cmd, r->cmd_name) < 0)
            r = r->left;
         else
            r = r->right;
      }
   }
   if (found == 1)
      return(r);
   else
      return(NULL);
}

struct exec_list *searchtreepath(pathname, parent)
char *pathname;
struct exec_list *parent;
{
struct exec_list *r;
int found = 0;

   r = parent;
   while ((r != NULL) && (found != 1)) {
      if (strcmp(pathname, r->cmd_name) == 0)
         found = 1;
      else {
         if (strcmp(pathname, r->cmd_name) < 0)
            r = r->left;
         else
            r = r->right;
      }
   }
   if (found == 1)
      return(r);
   else
      return(NULL);
}

struct exec_list *dumper(tree, indent)
struct exec_list *tree;
int indent;
{
struct exec_list *p;
struct path_list *dumplist();

   p = tree;
   if (p != NULL) {
      p = tree->left;
      dumper(p, indent);
      if (indent == 0)
         printf("%s    %d\n",
             tree->cmd_name, tree->bal);
      else
          printf("      %s    %d\n",
             tree->cmd_name, tree->bal);
      if (tree->paths != NULL)
         dumper(tree->paths, 1);
      p = tree->right;
      dumper(p, indent);
   }
}

struct path_list *dumplist(list)
struct path_list *list;
{

   while (list != NULL) {
      printf("     %s\n", list->path_name);
      list = list->next;
   }
}

struct path_list *searchlist(path, list)
char *path;
struct path_list *list;
{

   while (list != NULL) {
      if (strcmp(path, list->path_name) == 0)
         return(list);
      else
         list = list->next;
   }
   return(list);
}
