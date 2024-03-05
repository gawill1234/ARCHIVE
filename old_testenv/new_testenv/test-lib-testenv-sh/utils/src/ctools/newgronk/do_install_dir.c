#include "myincludes.h"

//
//   Determine which directory Vivisimo is
//   installed in.  This makes the assumption
//   that this program is installed in the
//   Vivisimo space.
//   This is the command caller and info
//   delivery piece.
//
void doidop(int env_config_int)
{
   switch (env_config_int) {
      case INSTALL_DIR:
                printf("   <OP>INSTALLDIR</OP>\n");
                break;
      case SEARCH_COLLECTIONS_DIR:
                printf("   <OP>COLLECTIONDIR</OP>\n");
                break;
      case VIVISIMO_CONF:
                printf("   <OP>VIVISIMOCONF</OP>\n");
                break;
      case TMP_DIR:
                printf("   <OP>TMPDIR</OP>\n");
                break;
      case DEBUG_DIR:
                printf("   <OP>DEBUGDIR</OP>\n");
                break;
      case REPOSITORY:
                printf("   <OP>REPOSITORY</OP>\n");
                break;
      case REPOSITORY_DIR:
                printf("   <OP>REPOSITORYDIR</OP>\n");
                break;
      case USERS_FILE:
                printf("   <OP>USERSFILE</OP>\n");
                break;
      case USERS_DIR_FILE:
                printf("   <OP>USERSDIR</OP>\n");
                break;
      case DEFAULT_PROJECT:
                printf("   <OP>PROJECT</OP>\n");
                break;
      case BRAND_FILE:
                printf("   <OP>BRAND</OP>\n");
                break;
      case AUTHENTICATION_MACRO:
                printf("   <OP>AUTH</OP>\n");
                break;
      case ADMIN_AUTHENTICATION_MACRO:
                printf("   <OP>ADMINAUTH</OP>\n");
                break;
      case BASE_URL:
                printf("   <OP>URL</OP>\n");
                break;
      case COOKIE_PATH:
                printf("   <OP>COOKIE</OP>\n");
                break;
      default:  printf("   <OP>INSTALLDIR</OP>\n");
                break;
   }

   return;
}

void doiditem(int env_config_int)
{
   switch (env_config_int) {
      case INSTALL_DIR:
                printf("   <DIRECTORY>%s</DIRECTORY>\n",
                       vivisimo_env_config_values[INSTALL_DIR]);
                break;
      case SEARCH_COLLECTIONS_DIR:
                printf("   <DIRECTORY>%s</DIRECTORY>\n",
                       vivisimo_env_config_values[SEARCH_COLLECTIONS_DIR]);
                break;
      case VIVISIMO_CONF:
                printf("   <FILE>%s</FILE>\n",
                       vivisimo_env_config_values[VIVISIMO_CONF]);
                break;
      case TMP_DIR:
                printf("   <DIRECTORY>%s</DIRECTORY>\n",
                       vivisimo_env_config_values[TMP_DIR]);
                break;
      case DEBUG_DIR:
                printf("   <DIRECTORY>%s</DIRECTORY>\n",
                       vivisimo_env_config_values[DEBUG_DIR]);
                break;
      case REPOSITORY:
                printf("   <FILE>%s</FILE>\n",
                       vivisimo_env_config_values[REPOSITORY]);
                break;
      case REPOSITORY_DIR:
                printf("   <DIRECTORY>%s</DIRECTORY>\n",
                           dirname(vivisimo_env_config_values[REPOSITORY]));
                break;
      case USERS_FILE:
                printf("   <FILE>%s</FILE>\n",
                       vivisimo_env_config_values[USERS_FILE]);
                break;
      case USERS_DIR_FILE:
                printf("   <DIRECTORY>%s</DIRECTORY>\n",
                       vivisimo_env_config_values[USERS_DIR_FILE]);
                break;
      case DEFAULT_PROJECT:
                printf("   <PROJECT>%s</PROJECT>\n",
                       vivisimo_env_config_values[DEFAULT_PROJECT]);
                break;
      case BRAND_FILE:
                printf("   <FILE>%s</FILE>\n",
                       vivisimo_env_config_values[BRAND_FILE]);
                break;
      case AUTHENTICATION_MACRO:
                printf("   <AUTH>%s</AUTH>\n",
                       vivisimo_env_config_values[AUTHENTICATION_MACRO]);
                break;
      case ADMIN_AUTHENTICATION_MACRO:
                printf("   <ADMINAUTH>%s</ADMINAUTH>\n",
                       vivisimo_env_config_values[ADMIN_AUTHENTICATION_MACRO]);
                break;
      case BASE_URL:
                printf("   <URL>%s</URL>\n",
                       vivisimo_env_config_values[BASE_URL]);
                break;
      case COOKIE_PATH:
                printf("   <DIRECTORY>%s</DIRECTORY>\n",
                       vivisimo_env_config_values[COOKIE_PATH]);
                break;
      default:
                printf("   <DIRECTORY>%s</DIRECTORY>\n",
                       vivisimo_env_config_values[INSTALL_DIR]);
                break;
   }

   return;
}
int do_install_dir(int env_config_int)
{
   printf("%s", content);
   fflush(stdout);

   printf("<REMOP>\n");
   doidop(env_config_int);
   fflush(stdout);

   doiditem(env_config_int);
   printf("   <OUTCOME>Success</OUTCOME>\n");
   printf("</REMOP>\n");
   fflush(stdout);

   return(0);
}
