#include "myincludes.h"
#include <stdio.h>
#include <string.h>
#include "mxml.h"

mxml_node_t *loadXmlFile(char *filename)
{
mxml_node_t *doc;
FILE *fp;

   fp = fopen(filename, "r");
   if (fp) {
     doc = mxmlLoadFile(NULL, fp, MXML_NO_CALLBACK);
     fclose(fp);
   } else {
     doc = mxmlLoadString(NULL, "<options/>", MXML_NO_CALLBACK);
   }

   return(doc);
}

void viv_conf_init()
{
mxml_node_t *tree, *node;
char *thingy, *vcdir, *install_dir, *name;
int i;

   vcdir = (char *)calloc(256, 1);

   if (vivisimo_env_config_values[INSTALL_DIR] == NULL) {
      install_dir = get_install_dir(NULL);
   } else {
      install_dir = vivisimo_env_config_values[INSTALL_DIR];
   }
   strcpy(vcdir, install_dir);
   strcat(vcdir, "/vivisimo.conf");

   i = 0;
   tree = loadXmlFile(vcdir);

   if (tree != NULL) {
      for (node = mxmlFindElement(tree,tree,"option","name",NULL,MXML_DESCEND);
           node != NULL;
           node = mxmlFindElement(node,tree,"option","name",NULL,MXML_DESCEND))
      {

         name = (char *)mxmlElementGetAttr(node, "name");
         thingy = (char *)mxmlElementGetAttr(node, "value");

         if (thingy != NULL) {
            i = 0;
            for (i = 0; i < vivconfvaluecount; i++) {
               if (strcmp(vivconfvalues[i], name) == 0) {
                  vivisimo_env_config_values[i] =
                          (char *)calloc(strlen(thingy) + 1, 1);
                  strcpy(vivisimo_env_config_values[i], thingy);
                  break;
               }
            }
         }
      }
   } else {
      printf("Arrrgghhh!!!  tree is NULL\n");
      fflush(stdout);
   }


   if (vivisimo_env_config_values[REPOSITORY] == NULL) {
      vcdir = (char *)calloc(256, 1);
      strcpy(vcdir, vivisimo_env_config_values[INSTALL_DIR]);
#ifdef PLATFORM_WINDOWS
      strcat(vcdir, "\\data\\repository.xml");
#else
      strcat(vcdir, "/data/repository.xml");
#endif
      vivisimo_env_config_values[REPOSITORY] = vcdir;
   }

   if (vivisimo_env_config_values[USERS_FILE] == NULL) {
      vcdir = (char *)calloc(256, 1);
      strcpy(vcdir, vivisimo_env_config_values[INSTALL_DIR]);
#ifdef PLATFORM_WINDOWS
      strcat(vcdir, "\\data\\users.xml");
#else
      strcat(vcdir, "/data/users.xml");
#endif
      vivisimo_env_config_values[USERS_FILE] = vcdir;
   }

   if (vivisimo_env_config_values[SEARCH_COLLECTIONS_DIR] == NULL) {
      vcdir = (char *)calloc(256, 1);
      strcpy(vcdir, vivisimo_env_config_values[INSTALL_DIR]);
#ifdef PLATFORM_WINDOWS
      strcat(vcdir, "\\data\\search-collections");
#else
      strcat(vcdir, "/data/search-collections");
#endif
      vivisimo_env_config_values[SEARCH_COLLECTIONS_DIR] = vcdir;
   }

   if (vivisimo_env_config_values[SYS_REPORTS_DIR] == NULL) {
      vcdir = (char *)calloc(256, 1);
      strcpy(vcdir, vivisimo_env_config_values[INSTALL_DIR]);
#ifdef PLATFORM_WINDOWS
      strcat(vcdir, "\\data\\system-reporting");
#else
      strcat(vcdir, "/data/system-reporting");
#endif
      vivisimo_env_config_values[SYS_REPORTS_DIR] = vcdir;
   }

   if (vivisimo_env_config_values[OLD_COLLECTIONS_DIR] == NULL) {
      vcdir = (char *)calloc(256, 1);
      strcpy(vcdir, vivisimo_env_config_values[INSTALL_DIR]);
#ifdef PLATFORM_WINDOWS
      strcat(vcdir, "\\data\\collections");
#else
      strcat(vcdir, "/data/collections");
#endif
      vivisimo_env_config_values[OLD_COLLECTIONS_DIR] = vcdir;
   }

   if (vivisimo_env_config_values[TMP_DIR] == NULL) {
      vcdir = (char *)calloc(256, 1);
      strcpy(vcdir, vivisimo_env_config_values[INSTALL_DIR]);
#ifdef PLATFORM_WINDOWS
      strcat(vcdir, "\\tmp");
#else
      strcat(vcdir, "/tmp");
#endif
      vivisimo_env_config_values[TMP_DIR] = vcdir;
   }

   if (vivisimo_env_config_values[DEBUG_DIR] == NULL) {
      vcdir = (char *)calloc(256, 1);
      strcpy(vcdir, vivisimo_env_config_values[INSTALL_DIR]);
#ifdef PLATFORM_WINDOWS
      strcat(vcdir, "\\debug");
#else
      strcat(vcdir, "/debug");
#endif
      vivisimo_env_config_values[DEBUG_DIR] = vcdir;
   }

   if (vivisimo_env_config_values[DEFAULT_PROJECT] == NULL) {
      vcdir = (char *)calloc(32, 1);
      strcpy(vcdir, "query-meta");
      vivisimo_env_config_values[DEFAULT_PROJECT] = vcdir;
   }

   if (vivisimo_env_config_values[AUTHENTICATION_MACRO] == NULL) {
      vcdir = (char *)calloc(32, 1);
      strcpy(vcdir, "authentication");
      vivisimo_env_config_values[AUTHENTICATION_MACRO] = vcdir;
   }

   if (vivisimo_env_config_values[BASE_URL] == NULL) {
      vcdir = (char *)calloc(32, 1);
#ifdef PLATFORM_WINDOWS
      strcat(vcdir, "\\vivisimo");
#else
      strcat(vcdir, "/vivisimo");
#endif
      vivisimo_env_config_values[BASE_URL] = vcdir;
   }

   if (vivisimo_env_config_values[DEFAULT_PROJECT] == NULL) {
      vcdir = (char *)calloc(32, 1);
      strcpy(vcdir, "query-meta");
      vivisimo_env_config_values[DEFAULT_PROJECT] = vcdir;
   }

   if (vivisimo_env_config_values[COOKIE_PATH] == NULL) {
      vcdir = (char *)calloc(32, 1);
#ifdef PLATFORM_WINDOWS
      strcat(vcdir, "\\vivisimo");
#else
      strcat(vcdir, "/vivisimo");
#endif
      vivisimo_env_config_values[COOKIE_PATH] = vcdir;
   }

   return;
}

char *get_install_dir(char *appenddir)
{
   char *directory = calloc(256, 1);

   if (vivisimo_env_config_values[INSTALL_DIR] == NULL) {
      first_get_install_dir();
   }

   strcpy(directory, vivisimo_env_config_values[INSTALL_DIR]);

   if (appenddir != NULL) {
      directory = strcat(directory, appenddir);
   }

   return(directory);
}

// Determine which directory Velocity is installed in,
// and save the result into our global environment.
void first_get_install_dir(void)
{
   char *directory = calloc(256, 1);

   getcwd(directory, 256);

   while (strlen(directory) && strcmp(_basename(directory), "www")) {
      _dirname(directory);
   }
   _dirname(directory);		// remove the "www" the we just found

   vivisimo_env_config_values[INSTALL_DIR] = directory;
}
