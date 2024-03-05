#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

//
//   Grab posted data and stick it in the
//   provided filename.
//
int get_data(char *infile, char *string_to_strip, char *string_to_add)
{
FILE *ifd;
char buf[4096];
char *stringend, *newstring, *strip_string(), *build_new_string();
int buflen, err, i;

   err = 0;
   ifd = NULL;

   ifd = fopen(infile, "r");

   for (i = 0; i < 4096; i++) {
      buf[i] = '\0';
   }

   while (fgets(&buf[0], 4096, ifd) != NULL) {
      buflen = strlen(buf);
      if (buf[0] != '\n') {
         stringend = strip_string(&buf[0], string_to_strip);
         if (stringend != NULL) {
            newstring = build_new_string(stringend, string_to_add);
            if (newstring != NULL) {
#ifdef DEBUG
               printf("%s\n", newstring);
               fflush(stdout);
#endif
               err = err + check_string_as_node(newstring);
               free(newstring);
            }
         }
      }
      for (i = 0; i < 4096; i++) {
         buf[i] = '\0';
      }
   }

   fclose(ifd);

   return(err);
}

void show_usage()
{
   printf("Check that files from a query do indeed exist.\n");
   printf("qry_node_check -I <infile> -o <oldstring> -n <newstring>\n");
   printf("    All arguments are required\n");
   printf("    -I <infile>:  <infile> is the file which contains\n");
   printf("                  the file list.  Getting the file may\n");
   printf("                  require the use of run_query, get_query_urls\n");
   printf("                  and dus tools to get and properly format the\n");
   printf("                  input file\n");
   printf("    -o <oldstring>:  oldstring is something like\n");
   printf("                  smb://samba/file/share.  It is specified\n");
   printf("                  as the parts of a url path that need to be\n");
   printf("                  removed to create a file path to look at\n");
   printf("    -n <newstring>:  newstring is usually /testenv\n");

   fflush(stdout);

   exit(0);
}

int main(int argc, char **argv)
{
char *infile, *oldstring, *newstring;
int c, err;
extern char *optarg;
static char *optstring = "I:o:n:h";

   infile = NULL;

   while ((c=getopt(argc, argv, optstring)) != EOF) {
      switch ((char)c) {
         case 'I':
                     infile = optarg;
                     break;
         case 'o':
                     oldstring = optarg;
                     break;
         case 'n':
                     newstring = optarg;
                     break;
         case 'h':
         default:
                     show_usage();
                     break;
      }
   }

   if (infile == NULL) {
      printf("Required input file not specified.\n");
      show_usage();
   } else {
      if (access(infile, F_OK) != 0 ) {
         printf("File %s does not exist\n", infile);
         show_usage();
      }
   }
   if (newstring == NULL) {
      printf("Required string to use as replacement in node name not specified.\n");
      show_usage();
   }
   if (oldstring == NULL) {
      printf("Required string to be replaced in node name not specified.\n");
      show_usage();
   }

   err = get_data(infile, oldstring, newstring);

   if (err != 0) {
      printf("NODE EXISTENCE CHECK FAILED\n");
      printf("EXPECTED ALL NODES TO EXIST, %d DO NOT\n", err);
   } else {
      printf("NODE EXISTENCE CHECK PASSED\n");
      printf("ALL NODES EXIST\n");
   }
   fflush(stdout);

   exit(err);
}
