#include <stdio.h>

#include "struct.h"

struct exec_list *searchnadd(aprod, treeroot)
struct prodstruct *aprod;
struct exec_list *treeroot;
{
struct exec_list *old_tree_node, *new_tree_node;
struct exec_list *searchtreecmd(), *cr_exec_node(), *puttotree();
struct exec_list *old_file_node, *new_file_node;

   old_tree_node = searchtreecmd(aprod->location, treeroot);
   if (old_tree_node == NULL) {
      new_tree_node = cr_exec_node(aprod->location, aprod->name);
      treeroot = puttotree(new_tree_node, treeroot);
   }
   else {
      old_file_node = searchtreecmd(aprod->name, old_tree_node->paths);
      if (old_file_node == NULL) {
         new_file_node = cr_exec_node(aprod->name, NULL);
         old_tree_node->paths = puttotree(new_file_node, old_tree_node->paths);
      }
   }
   return(treeroot);
}








/**************************************************************/
/*  Original version commented out for now


struct exec_list *searchnadd(aprod, treeroot)
struct prodstruct *aprod;
struct exec_list *treeroot;
{
struct exec_list *old_tree_node, *new_tree_node;
struct exec_list *searchtreecmd(), *cr_exec_node(), *puttotree();
struct path_list *old_path_node, *new_path_node;
struct path_list *searchlist(), *cr_path_node();

   old_tree_node = searchtreecmd(aprod->name, treeroot);
   if (old_tree_node == NULL) {
      new_tree_node = cr_exec_node(aprod->name, aprod->fullpath);
      treeroot = puttotree(new_tree_node, treeroot);
   }
   else {
      old_path_node = searchlist(aprod->fullpath, old_tree_node->paths);
      if (old_path_node == NULL) {
         new_path_node = cr_path_node(aprod->fullpath);
         new_path_node->next = old_tree_node->paths;
         old_tree_node->paths = new_path_node;
      }
   }
   return(treeroot);
}

*/
