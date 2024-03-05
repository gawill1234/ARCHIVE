#include "myincludes.h"

//
//   Dump some XML about what is going on.
//   This is the leading XML to the user
//   specified operation.
//
int ops_out(int from, int what, char *filename, char *collection, int binflag)
{
char *remhost;
//char remhost[] = "junk";

   remhost = get_remote_data();

   printf("%s", content);
   fflush(stdout);

   if (binflag == 1) {
      return(0);
   }

   printf("<REMOP>\n");

   switch (what) {
      case SENDING:
                     printf("   <OP>Send</OP>\n");
                     break;
      case GETTING:
                     printf("   <OP>Get</OP>\n");
                     break;
      case ALTER:
                     printf("   <OP>Alter</OP>\n");
                     break;
      case MYDELETE:
                     printf("   <OP>Delete</OP>\n");
                     break;
      case EXISTS:
                     printf("   <OP>Existence</OP>\n");
                     break;
      case SIZE:
                     printf("   <OP>Size</OP>\n");
                     break;
      case EXEC:
                     printf("   <OP>Execute</OP>\n");
                     break;
      case STATUS:
                     printf("   <OP>Status</OP>\n");
                     break;
      case KILL:
                     printf("   <OP>Kill</OP>\n");
                     break;
      case KILLALL:
                     printf("   <OP>KillAll</OP>\n");
                     break;
      case KILLADMIN:
                     printf("   <OP>KillAdmin</OP>\n");
                     break;
      case REPOIMPORT:
                     printf("   <OP>RepositoryImport</OP>\n");
                     break;
      case RESTORECOLLECTION:
                     printf("   <OP>RestoreCollection</OP>\n");
                     break;
      default:
                     break;
   }

   if (what == EXEC) {
         printf("   <TARGET>Command</TARGET>\n");
   } else {
      if (from == FILE_CP) {
         printf("   <TARGET>File</TARGET>\n");
      } else if (from == REPO) {
         printf("   <TARGET>Repository</TARGET>\n");
         if (collection != NULL) {
            printf("   <REPOSITORY>%s</REPOSITORY>\n", collection);
         } else {
            printf("   <REPOSITORY>None specified</REPOSITORY>\n");
         }
      } else {
         printf("   <TARGET>Collection</TARGET>\n");
         if (collection != NULL) {
            printf("   <COLLECTION>%s</COLLECTION>\n", collection);
         } else {
            printf("   <COLLECTION>None specified</COLLECTION>\n");
         }
      }
   }

   printf("   <REQUESTOR>%s</REQUESTOR>\n", remhost);

   if (what == EXEC) {
      printf("   <COMMAND>%s</COMMAND>\n", filename);
   } else {
      if ( what != RESTORECOLLECTION ) {
         printf("   <FILENAME>%s</FILENAME>\n", filename);
      }
   }

   if ((what == GETTING) || (what == EXEC) || (what == STATUS)) {
      //printf("   <DATA>\n");
      //printf("<![CDATA[\n");
      printf("   <DATA><![CDATA[");
   }
   fflush(stdout);

   return(0);
}

