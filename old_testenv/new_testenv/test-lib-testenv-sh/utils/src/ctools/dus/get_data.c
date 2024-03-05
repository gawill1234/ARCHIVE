#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//
//   Grab posted data and stick it in the
//   provided filename.
//
int get_data(char *infile, char *outfile)
{
FILE *ofd, *ifd;
char buf[4096], obuf[4096];
int buflen, err, i;

   err = 0;
   ifd = ofd = NULL;

   ifd = fopen(infile, "r");
   if (outfile != NULL) {
      ofd = fopen(outfile, "w+");
   }

   for (i = 0; i < 4096; i++) {
      buf[i] = '\0';
      obuf[i] = '\0';
   }

   while (fgets(&buf[0], 4096, ifd) != NULL) {
      buflen = strlen(buf);
      if (buf[0] != '\n') {
         url_decode(&buf, &obuf, buflen);
         if (ofd != NULL) {
            fprintf(ofd, "%s", obuf);
         } else {
            printf("%s", obuf);
            fflush(stdout);
         }
      }
      for (i = 0; i < 4096; i++) {
         buf[i] = '\0';
         obuf[i] = '\0';
      }
   }

   fclose(ifd);
   if (ofd != NULL) {
      fclose(ofd);
   }

   return(err);
}

void show_usage()
{
   printf("decode url stream (dus)\n");
   printf("dus -I <infile> [-O <outfile>]\n");
   printf("       infile is required\n");
   printf("       If outfile is not specified, stdout is used.\n");
   fflush(stdout);

   exit(0);
}

int main(int argc, char **argv)
{
char *infile, *outfile;
int c;
extern char *optarg;
static char *optstring = "I:O:h";

   infile = outfile = NULL;

   while ((c=getopt(argc, argv, optstring)) != EOF) {
      switch ((char)c) {
         case 'I':
                     infile = optarg;
                     break;
         case 'O':
                     outfile = optarg;
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
   }

   get_data(infile, outfile);

   exit(0);
}
