#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>

#include "viv_goop.h"

#define LINE_LEN 80

int agreement_check(struct stat *buf, int ntype, char *filename)
{
int agrees;

   agrees = 1;

   switch (ntype) {
      case RFL:
         if (!S_ISREG(buf->st_mode)) {
            if (verbose)
               fprintf(stderr, "*****ERROR, %s: Expected FILE, got %o\n",
                       filename, buf->st_mode);
            agrees = 0;
         }
         break;
      case DRCTRY:
         if (!S_ISDIR(buf->st_mode)) {
            if (verbose)
               fprintf(stderr, "*****ERROR, %s: Expected DIRECTORY, got %o\n",
                       filename, buf->st_mode);
            agrees = 0;
         }
         break;
      case NMDPP:
         if (!S_ISFIFO(buf->st_mode)) {
            if (verbose)
               fprintf(stderr, "*****ERROR, %s: Expected NAMED PIPE, got %o\n",
                       filename, buf->st_mode);
            agrees = 0;
         }
         break;
      case HRDLNK:
         agrees = 1;
         break;
      case SYMLNK:
         if (!S_ISLNK(buf->st_mode)) {
            if (verbose)
               fprintf(stderr, "*****ERROR, %s: Expected SYMLINK, got %o\n",
                       filename, buf->st_mode);
            agrees = 0;
         }
         break;
      default:
         agrees = 0;
         break;
   }


   return(agrees);
}

int my_size(struct fs_creations *item)
{
char *filename, *slinkcheck, *build_full_path();
struct fs_creations *lastlink;
int result, thistype, agr;
struct stat buf;

   filename = build_full_path(item);
   result = 0;

   if (lstat(filename, &buf) == 0) {
      result = buf.st_size;
   }

   free(filename);

   return(result);
}

int my_access(struct fs_creations *item)
{
char *filename, *slinkcheck, *build_full_path();
struct fs_creations *lastlink;
int result, thistype, agr;
struct stat buf;

   filename = build_full_path(item);
   result = (-1);


/*
   switch (item->node_type) {
      case RFL:
      case DRCTRY:
      case NMDPP:
         thistype = item->node_type;
         break;
      case HRDLNK:
      case SYMLNK:
         lastlink = get_last_link(item);
         thistype = lastlink->node_type;
         break;
      default:
         break;
   }
*/
   

   if (lstat(filename, &buf) == 0) {
      agr = agreement_check(&buf, item->node_type, filename);
      //if (item->node_type == SYMLNK) {
      if (S_ISLNK(buf.st_mode)) {
         slinkcheck = (char *)calloc(256, 1);
         if (readlink(filename, slinkcheck, 256) > 0) {
            result = 0;
         }
         free(slinkcheck);
      } else {
         result = access(filename, F_OK);
      }
   } else {
      agr = 1;
   }

   free(filename);

   return(result);
}

char *get_one_word(char *buffer)
{
int i, j, len;
char *one_word;

   i = 30;

   while (buffer[i] != '\n')
      i++;

   i++;
   j = i;

   while (buffer[j] != '\n')
      j++;

   len = j - i;

   one_word = (char *)calloc(len + 1, 1);

   strncpy(one_word, &buffer[i], len);

   return(one_word);
}

char *aword(int fno, int size_of_file)
{
int lskpt, readpt, rdamt;
char buffer[129], *one_word;

   buffer[128] = '\0';
   size_of_file = size_of_file - 15;

   lskpt = random_int_in_range(0, size_of_file);
   readpt = lskpt - 30;
   if (readpt <= 0)
      readpt = 0;

   lseek(fno, readpt, SEEK_SET);

   rdamt = read(fno, &buffer, 128);

   one_word = get_one_word(buffer);

   return(one_word);
}

int filesize(char *filename)
{
struct stat buf;
int size;

   size = (-1);

   if (access(filename, F_OK) == 0) {
      stat(filename, &buf);
      size = buf.st_size;
   }

   return(size);
}

int openwordfile(char *filename)
{
int fno;

   fno = (-1);

   if (access(filename, F_OK) == 0) {
      fno = open(filename, O_RDONLY);
   }

   return(fno);

}

int space_nl(int pos, char *myblock, int wordlen, int linelen)
{
int nextlen;

   nextlen = linelen + wordlen;

   if (nextlen > 72) {
      myblock[pos] = '\n';
      linelen = 0;
   } else {
      myblock[pos] = ' ';
   }

   return(linelen);
}

int punctuation(int pos, char *myblock, int words_in_sentence)
{
double ranger;

   ranger = drand48();

   if (ranger < .03) {
      myblock[pos] = ',';
      return(1);
   } else if (ranger >= .03 && ranger < .10) {
      myblock[pos] = '.';
      myblock[pos + 1] = ' ';
      return(2);
   } else if (ranger >= .10 && ranger < .11) {
      myblock[pos] = ';';
      return(1);
   } else if (ranger >= .11 && ranger < .13) {
      myblock[pos] = '?';
      myblock[pos + 1] = ' ';
      return(2);
   } else {
      return(0);
   }

   return(0);
}

int setparagraph(int sentences, int spaces, int pos, char *myblock)
{
double ranger;

   if (sentences > 3 && spaces == 2) {
      ranger = drand48();
      if (ranger < .3) {
         myblock[pos] = '\n';
         pos++;
         myblock[pos] = '\t';
         pos++;
         return(9);
      }
   }

   return(0);
}

char *build_a_block(int fno, int size_of_file, int blockcount)
{
char *myblock, *one_word;
int len, pos, i, linelen, nextlen, words_in_sentence, spaces;
int sentences;

   myblock = (char *)calloc(4096, 1);
   pos = 0;
   words_in_sentence = 0;
   sentences = 0;

   while (pos < 4096) {
      one_word = aword(fno, size_of_file);
      len = strlen(one_word);
      nextlen = pos + len + 5;

      if (nextlen >= 4096) {
         free(one_word);
         break;
      }

      if (pos > 0) {
         spaces = punctuation(pos, myblock, words_in_sentence);
         pos = pos + spaces;
         linelen = linelen + spaces;
         if (spaces == 2) {
            sentences++;
         }
         spaces = setparagraph(sentences, spaces, pos, myblock);
         linelen = linelen + spaces;
         if (spaces == 9) {
            pos = pos + 2;
            linelen = 0;
            sentences = 0;
         }
         linelen = space_nl(pos, myblock, len, linelen);
         pos++;
         strncpy(&myblock[pos], one_word, len);
         words_in_sentence++;
         pos = pos + len;
         linelen = linelen + len;
      } else {
         if (blockcount > 0) {
            myblock[pos] = ' ';
            pos++;
         }
         strncpy(&myblock[pos], one_word, len);
         words_in_sentence++;
         pos = pos + len;
         linelen = pos + len;
      }

      free(one_word);
   }

   return(myblock);
}

int dofile(int outfile, struct fs_creations *wrk_node)
{
int fno, size_of_file, blocksize, fsize;
int blockcount, remaining, totalsize, wrttn;
char *troot, *filename, *myblock;

   //srand48(time((long *)0));

   troot = getenv("TEST_ROOT");
   totalsize = strlen(troot) + 5 + 5 + 3;
   filename = (char *)calloc(totalsize, 1);
   sprintf(filename, "%s/files/words\0", troot);

   remaining = fsize = wrk_node->file_size;
   blockcount = totalsize = 0;

   fno = openwordfile(filename);
   size_of_file = filesize(filename);
   free(filename);

   do {
      myblock = build_a_block(fno, size_of_file, blockcount);
      if (myblock != NULL) {
         blocksize = strlen(myblock);
         blockcount++;

         if (remaining < blocksize) {
            wrttn = write(outfile, myblock, remaining);
            if (wrttn < 0) {
               perror("   WRITE FAILED:");
               close(fno);
               return(totalsize);
            } else {
               totalsize = totalsize + wrttn;
            }
         } else {
            wrttn = write(outfile, myblock, blocksize);
            if (wrttn < 0) {
               perror("   WRITE FAILED:");
               close(fno);
               return(totalsize);
            } else {
               remaining = remaining - wrttn;
               totalsize = totalsize + wrttn;
            }
         }
         free(myblock);
      }
   } while (totalsize < fsize);

   close(fno);

   return(totalsize);
}
