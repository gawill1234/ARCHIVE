#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "mxml.h"

int main()
{
FILE *fp;
mxml_node_t *tree, *node, *node2;

   fp = fopen("vivisimo.conf", "r");
   tree = mxmlLoadFile(NULL, fp, MXML_NO_CALLBACK);
   fclose(fp);

   for (node = mxmlFindElement(tree, tree, "option", "name", NULL, MXML_DESCEND);
        node != NULL;
        node = mxmlFindElement(node, tree, "option", "name", NULL, MXML_DESCEND))
   {
      printf("%s, %s\n", mxmlElementGetAttr(node, "name"),
                         mxmlElementGetAttr(node, "value"));
      fflush(stdout);
   }

}
