#include <stdio.h>
#include <sys/types.h>
#include <dirent.h>

#include "struct.h"

int backcheck(dirname, treeroot)
char *dirname;
struct exec_list *treeroot;
{
DIR *dirp, *opendir();
struct dirent *dp, *readdir();
struct exec_list *searchtreecmd(), *tree_node, *file_node;
int problems = 0;

   if ((tree_node = searchtreecmd(dirname, treeroot)) != NULL) {
      if (tree_node->paths != NULL) {

         dirp = opendir(dirname);
         if (dirp != NULL) {

            while ((dp = readdir(dirp)) != NULL) {
               if ((strcmp(dp->d_name, ".") != 0) && (strcmp(dp->d_name, "..") != 0)) {
                  file_node = searchtreecmd(dp->d_name, tree_node->paths);
                  if (file_node == NULL) {
                     unknownfile(dp->d_name, dirname);
                     problems++;
                  }
               }
            }
            closedir(dirp);
         }
         else {
            printf("___________________________________________________\n\n");
            printf("COULD NOT OPEN DIRECTORY %s\n", dirname);
            problems++;
         }
      }
   }
   return(problems);
}
