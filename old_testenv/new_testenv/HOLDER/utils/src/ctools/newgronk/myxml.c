#include <stdio.h>
#include <string.h>
#include <libxml/tree.h>

//
//   No node nesting at all.  Just go to the end node(s) and
//   search for the items in question.
//
char *simpleGetXmlItem(xmlNodePtr nodeLevel, char *itemtosearch,
                 char *finding, char *itemtoget, char *endnode) 
{
char *thingy = NULL;

   if (itemtoget == NULL) {
      printf("Item to get not specified, exiting\n");
      fflush(stdout);
      return(NULL);
   }

   while (nodeLevel != NULL) {
      if (strcmp(nodeLevel->name, endnode) == 0) {
         if (itemtosearch == NULL || finding == NULL) {
            thingy = xmlGetProp(nodeLevel, itemtoget);
            return(thingy);
         } else {
            thingy = xmlGetProp(nodeLevel, itemtosearch);
            if (thingy != NULL) {
               if (strcmp(thingy, finding) == 0) {
                  free(thingy);
                  thingy = xmlGetProp(nodeLevel, itemtoget);
                  return(thingy);
               } else {
                  free(thingy);
                  thingy = NULL;
               }
            }
         }
      }
      if (nodeLevel->children != NULL) {
         thingy = simpleGetXmlItem(nodeLevel->children, itemtosearch,
                             finding, itemtoget, endnode);
         if (thingy != NULL) {
            return(thingy);
         }
      }
      nodeLevel = nodeLevel->next;
   }

   return(thingy);
}

xmlDocPtr loadXmlFile(char *filename) 
{
xmlDocPtr doc;

   doc = xmlParseFile(filename);

   return(doc);
}

char *simpleFindXmlItem(xmlDocPtr doc, char *itemtosearch,
                  char *finding, char *itemtoget, char *endnode) 
{
char *thingy = NULL;

   thingy = simpleGetXmlItem(doc->children, itemtosearch, finding,
                             itemtoget, endnode);

   return(thingy);
}

int main()
{
xmlDocPtr doc;
char *thingy;
int i;
int vivconfvaluecount = 15;
char *vivconfvalues[] = {"install-dir\0",
                         "search-collections-dir\0",
                         "vivisimo-conf\0",
                         "tmp-dir\0",
                         "debug-dir\0",
                         "repository\0",
                         "users-file\0",
                         "users-dir-file\0",
                         "users-dir\0",
                         "default-project\0",
                         "brand-file\0",
                         "authentication-macro\0",
                         "admin-authentication-macro\0",
                         "base-url\0",
                         "cookie-path\0"};


   i = 0;
   doc = loadXmlFile("vivisimo.conf");

   if (doc != NULL) {
      for (i = 0; i < vivconfvaluecount; i++) {
         printf("Looking for:  %s\n", vivconfvalues[i]);
         thingy = simpleFindXmlItem(doc, "name", vivconfvalues[i],
                                    "value", "option");
         if (thingy != NULL) {
            printf("GOT IT:  %s\n", thingy);
            free(thingy);
         }
      }
      xmlFreeDoc(doc);
   }

   return 0;
}
