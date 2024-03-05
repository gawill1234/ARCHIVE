#include <stdio.h>

#include "struct.h"
/********************************************************/
/*
   Rotate nodes in a tree to the right
*/

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
/********************************************************/
/********************************************************/
/*
   Rotate nodes in a tree to the left
*/
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
/********************************************************/
/********************************************************/
/*
   Check the current balance state of the nodes in a tree
   and rotate left or right as required
*/
struct exec_list *checknbal(young, v, p, n, parent)
struct exec_list *young, *v, *p, *n, *parent;
{
int imbal;
struct exec_list *q = NULL;

   if (strcmp(p->cmd_name, young->cmd_name) < NON_VAL)
      imbal = POS_VAL;
   else
      imbal = NEG_VAL;

   if (young->bal == NON_VAL) {
      young->bal = imbal;
   }
   else {
      if (young->bal != imbal) {
         young->bal = NON_VAL;
      }
      else {
         if (n->bal == imbal) {
            q = n;
            if (imbal == POS_VAL)
               rightrotat(young);
            else
               leftrotat(young);
            young->bal = NON_VAL;
            n->bal = NON_VAL;
         }
         else {
            if (imbal == POS_VAL) {
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
            if (q->bal == NON_VAL) {
               young->bal = NON_VAL;
               n->bal = NON_VAL;
            }
            else {
               if (q->bal == imbal) {
                  young->bal = imbal * (NEG_VAL);
                  n->bal = NON_VAL;
               }
               else {
                  young->bal = NON_VAL;
                  n->bal = imbal;
               }
            }
            q->bal = NON_VAL;
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
/********************************************************/

/********************************************************/
/*
   Change the balance value of nodes which are affected
   by the addition of a new node to the tree
*/
struct exec_list *changebal(young, v, p, parent)
struct exec_list *young, *v, *p, *parent;
{
struct exec_list *q, *n;

   q = n = NULL;


   if (strcmp(p->cmd_name, young->cmd_name) < NON_VAL) 
      q = young->left;
   else
      q = young->right;

   n = q;

   while (strcmp(q->cmd_name, p->cmd_name) != NON_VAL) {
      if (strcmp(p->cmd_name, q->cmd_name) < NON_VAL) {
         q->bal = POS_VAL;
         q = q->left;
      }
      else {
         q->bal = NEG_VAL;
         q = q->right;
      }
   }
   parent = checknbal(young, v, p, n, parent);
   return(parent);
}
/********************************************************/

/********************************************************/
/*
   Add a new node to the tree
*/
struct exec_list *addnew(p, parent)
struct exec_list *p, *parent;
{
struct exec_list *v, *young, *r, *q;

   r = parent;
   q = parent;
   young = r;
   v = NULL;
   while (r != NULL) {
      if (strcmp(p->cmd_name, q->cmd_name) < NON_VAL) {
         r = q->left;
         if (r != NULL) {
            if (r->bal != NON_VAL) {
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
            if (r->bal != NON_VAL) {
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
/********************************************************/

/********************************************************/
/*
   Create the tree or a cause a new node to be added
*/
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
/********************************************************/

/********************************************************/
/*
   Search a tree for the requested command
*/
struct exec_list *searchtreecmd(cmd, parent)
char *cmd;
struct exec_list *parent;
{
struct exec_list *r;
int found = NON_VAL;

   r = parent;
   while ((r != NULL) && (found != POS_VAL)) {
      if (strcmp(cmd, r->cmd_name) == NON_VAL)
         found = POS_VAL;
      else {
         if (strcmp(cmd, r->cmd_name) < NON_VAL)
            r = r->left;
         else
            r = r->right;
      }
   }
   if (found == POS_VAL)
      return(r);
   else
      return(NULL);
}
/********************************************************/

/********************************************************/
/*
   Search a tree for the requested path
*/
struct exec_list *searchtreepath(pathname, parent)
char *pathname;
struct exec_list *parent;
{
struct exec_list *r;
int found = NON_VAL;

   r = parent;
   while ((r != NULL) && (found != POS_VAL)) {
      if (strcmp(pathname, r->cmd_name) == NON_VAL)
         found = POS_VAL;
      else {
         if (strcmp(pathname, r->cmd_name) < NON_VAL)
            r = r->left;
         else
            r = r->right;
      }
   }
   if (found == POS_VAL)
      return(r);
   else
      return(NULL);
}
/********************************************************/

/********************************************************/
/*
   Dump the contents of a tree to standard out
*/
struct exec_list *dumper(tree)
struct exec_list *tree;
{
struct exec_list *p;
struct path_list *dumplist();

   p = tree;
   if (p != NULL) {
      p = tree->left;
      dumper(p);
      printf("%s    %d\n",
          tree->cmd_name, tree->bal);
      dumplist(tree->paths);
      p = tree->right;
      dumper(p);
   }
}
/********************************************************/

/********************************************************/
/*
   Print the contents of a node
*/
struct path_list *dumplist(list)
struct path_list *list;
{

   while (list != NULL) {
      printf("     %s\n", list->path_name);
      list = list->next;
   }
}
/********************************************************/

/********************************************************/
/*
   Search a linked list for path
*/
struct path_list *searchlist(path, list)
char *path;
struct path_list *list;
{

   while (list != NULL) {
      if (strcmp(path, list->path_name) == NON_VAL)
         return(list);
      else
         list = list->next;
   }
   return(list);
}
