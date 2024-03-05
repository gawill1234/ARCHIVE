#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <libgen.h>
#include <dirent.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "test.h"

//
//   Tables:
//      Table Disc
//         artist
//         title
//         year
//         genre
//         disc_id
//
//      Table Track
//         disc_id
//         track
//         title
//

void discfn();
void ttitlefn();
void dyearfn();
void dtitlefn();
void genrefn();
void dlenfn();
char *myreadline();

struct trackst {
   int track_seq;
   int runtime;
   char *artist;
   char *title;
   struct trackst *next;
};

struct discst {
   char *disc_id;
   char *year;
   char *artist;
   char *genre;
   char *title;
   int runtime;
   int varflag;
   struct trackst *tracklist;
};

struct linefunc {
   char *title;
   void (*cdfunction)();
};

#define DISCIDFN 0

struct linefunc linetype[] = {{"DISCID", discfn},
                              {"TTITLE", ttitlefn},
                              {"DYEAR", dyearfn},
                              {"DTITLE", dtitlefn},
                              {"DGENRE", genrefn},
                              {"Disc length:", dlenfn},
                              {NULL, NULL}
};

void freetrack(struct trackst *track)
{
struct trackst *follow;

   follow = track;
   while (follow != NULL) {
      if (follow->title != NULL)
         free(follow->title);
      if (follow->artist != NULL)
         free(follow->artist);
      follow = follow->next;
      free(track);
      track = follow;
   }
   return;
}

void freecd(struct discst *cd)
{
   if (cd->disc_id != NULL)
      free(cd->disc_id);

   if (cd->title != NULL)
      free(cd->title);

   if (cd->year != NULL) {
      free(cd->year);
   }

   if (cd->genre != NULL) {
      free(cd->genre);
   }

   if (cd->artist != NULL)
      free(cd->artist);

   fflush(stdout);
   freetrack(cd->tracklist);
   free(cd);
   return;
}

void dumptrack(struct trackst *track)
{
struct trackst *follow;

   follow = track;
   while (follow != NULL) {
      if (follow->title != NULL) {
         printf("TRACK TITLE:  %s\n", follow->title);
      } else {
         follow->title = (char *)calloc(strlen("UNKNOWN") + 1, 1);
         strcpy(follow->title, "UNKNOWN");
      }
      if (follow->artist != NULL) {
         printf("TRACK ARTIST:  %s\n", follow->artist);
      } else {
         follow->artist = (char *)calloc(strlen("UNKNOWN") + 1, 1);
         strcpy(follow->artist, "UNKNOWN");
      }
      printf("TRACK NUMBER:  %d\n", follow->track_seq);
      fflush(stdout);
      follow = follow->next;
   }
   return;
}

void dumpcd(struct discst *cd, char *backupgenre)
{
   if (cd->disc_id != NULL) {
      if (strlen(cd->disc_id) > 32) {
         return;
      }
#ifdef DEBUG
      printf("DISC ID:  %s\n", cd->disc_id);
#endif
   } else {
      return;
   }

   if (cd->title == NULL) {
      cd->title = (char *)calloc(strlen("UNKNOWN") + 1, 1);
      strcpy(cd->title, "UNKNOWN");
   }
#ifdef DEBUG
   else {
      printf("DISC TITLE:  %s\n", cd->title);
   }
#endif

   if (cd->year != NULL) {
#ifdef DEBUG
      printf("DISC YEAR:  %s\n", cd->year);
#endif
      if (strlen(cd->year) > 32) {
         return;
      }
   } else {
      cd->year = (char *)calloc(5, 1);
      strcpy(cd->year, "1814");
#ifdef DEBUG
      printf("DISC YEAR:  %s\n", cd->year);
#endif
   }

#ifdef DEBUG
   if (cd->runtime != 0)
      printf("DISC RUNTIME:  %d\n", cd->runtime);
#endif

   if (cd->genre != NULL) {
#ifdef DEBUG
      printf("DISC GENRE:  %s\n", cd->genre);
#endif
      if (strlen(cd->genre) > 32) {
         return;
      }
   } else {
      cd->genre = (char *)calloc(strlen(backupgenre) + 1, 1);
      strcpy(cd->genre, backupgenre);
#ifdef DEBUG
      printf("DISC GENRE:  %s\n", cd->genre);
#endif
   }

   if (cd->artist == NULL) {
      cd->artist = (char *)calloc(strlen("UNKNOWN") + 1, 1);
      strcpy(cd->artist, "UNKNOWN");
    } 
#ifdef DEBUG
    else {
      printf("DISC ARTIST:  %s\n", cd->artist);
   }
#endif

   fflush(stdout);
#ifdef DEBUG
   dumptrack(cd->tracklist);
#endif

   printf("Start entry:  %s\n", cd->disc_id);
   fflush(stdout);
   if (check_album_id(cd->disc_id) == 0) {
      if (insert_album_info(cd) == 0) {
         if (insert_track_info(cd) == 0) {
            docommit();
            printf("Commit:  %s\n", cd->disc_id);
            fflush(stdout);
         }
      }
   } else {
      printf("Album exists:  %s\n", cd->disc_id);
      fflush(stdout);
   }

   return;
}

struct trackst *buildtrack()
{
struct trackst *track = NULL;

   track = (struct trackst *)malloc(sizeof(struct trackst));
   if (track != NULL) {
      track->track_seq = 0;
      track->runtime = 0;
      track->title = NULL;
      track->artist = NULL;
      track->next = NULL;
   } else {
      printf("Memory allocation for buildtrack() failed\n");
      fflush(stdout);
   }

   return(track);
}

struct discst *buildcd()
{
struct discst *cd = NULL;

   cd = (struct discst *)malloc(sizeof(struct discst));
   if (cd != NULL) {
      cd->disc_id = NULL;
      cd->year = NULL;
      cd->artist = NULL;
      cd->genre = NULL;
      cd->title = NULL;
      cd->runtime = 0;
      cd->varflag = 0;
      cd->tracklist = NULL;
   } else {
      printf("Memory allocation for buildcd() failed\n");
      fflush(stdout);
   }

   return(cd);
}

void unnewlineit(char *mystring)
{
int i, mystlen, firstnonspace;

   mystlen = strlen(mystring);

   i = mystlen - 1;
   firstnonspace = -1;
   do {
      if (mystring[i] != '\n') {
         if (mystring[i] != ' ') {
            if (mystring[i] != '\0') {
               firstnonspace = i;
            }
         } else {
            mystring[i] = '\0';
         }
      } else {
         mystring[i] = '\0';
      }
      i--;
   } while ((firstnonspace < 0) && (i >= 0));

   return;
}

char *processmystring(char *mystring, int dofree)
{
char *newstring;
int i, j, mystlen, firstnonspace;

   if (mystring == NULL)
      return(NULL);

   firstnonspace = -1;
   mystlen = strlen(mystring);

   i = 0;
   do {
      if (mystring[i] != ' ') {
         firstnonspace = i;
      }
      i++;
   } while ((firstnonspace < 0) && (i < mystlen));


   newstring = (char *)calloc(mystlen + 1, 1);
   strcpy(newstring, &mystring[firstnonspace]);

   i = mystlen - 1;
   firstnonspace = -1;
   do {
      if (mystring[i] != '\n') {
         if (mystring[i] != ' ') {
            if (mystring[i] != '\0') {
               firstnonspace = i;
            }
         } else {
            mystring[i] = '\0';
         }
      } else {
         mystring[i] = '\0';
      }
      i--;
   } while ((firstnonspace < 0) && (i >= 0));

   if (dofree == 1) {
      free(mystring);
   }
   mystlen = strlen(newstring);

   if (mystlen > 0) {
      for (i = 0; i < mystlen; i++) {
         newstring[i] = tolower(newstring[i]);
      }

      for (i = 0; i < mystlen; i++) {
         if (i == 0) {
            newstring[i] = toupper(newstring[i]);
         } else {
            j = i - 1;
            if (isspace(newstring[j])) {
               newstring[i] = toupper(newstring[i]);
            } else {
               if (ispunct(newstring[j])) {
                  newstring[i] = toupper(newstring[i]);
               }
            }
         }
      }
   } else {
#ifdef DEBUG
      printf("newstring is NULL\n");
      fflush(stdout);
#endif
      free(newstring);
      newstring = NULL;
   }

#ifdef DEBUG
   if (newstring != NULL) {
      printf("NEWSTRING:  %s\n", newstring);
      fflush(stdout);
   } else {
      printf("NEWSTRING:  NULL\n");
      fflush(stdout);
   }
#endif
   return(newstring);
}

void various_check(struct discst *cd)
{
char *tmpartist;
int i, len;
char *various[] = {"various",
                   "varios",
                   "varied",
                   "vari",
                   NULL};

   if (cd->artist != NULL) {
      len = strlen(cd->artist);
      tmpartist = (char *)calloc(len + 1, 1);
      for (i = 0; i < len; i++) {
         tmpartist[i] = tolower(cd->artist[i]);
      }
      i = 0;
      while (various[i] != NULL) {
         if (strneq(tmpartist, various[i], strlen(various[i]))) {
            cd->varflag = 1;
         }
         i++;
      }

      free(tmpartist);
   }

   return;
}

void discfn(struct discst *cd, char *line, char *bugenre)
{
char *mystring, *newstring;
int len, len2;

   mystring = cutatchar(line, '=');
   if (mystring != NULL) {
      len = strlen(mystring);
   } else {
      return;
   }

   if (bugenre != NULL) {
      len = strlen(mystring);
      len2 = strlen(bugenre);

      cd->disc_id = (char *)calloc(len + len2 + 2, 1);
      strcpy(cd->disc_id, mystring);
      strcat(cd->disc_id, "/");
      strcat(cd->disc_id, bugenre);
   } else {
      cd->disc_id = mystring;
   }

#ifdef DEBUG
   printf("discid:  %s\n", cd->disc_id);
   fflush(stdout);
#endif
   return;
}

void dlenfn(struct discst *cd, char *line)
{
int mylen;
char **args, *dooby, *mystring;

   mylen = strlen("Disc length: ");
   dooby = &line[mylen];

   args = split_string(dooby, ' ');
   if (args[0] != NULL) {
      mystring = args[0];
   } else {
      return;
   }

   cd->runtime = atoi(mystring);
   return;
}

void ttitlefn(struct discst *cd, char *line)
{
struct trackst *track = NULL;
struct trackst *follow;
int len, argcnt, i;
int track_seq = 1;
char **args, *mystring, *artist, *title;

   mystring = artist = NULL;
   args = NULL;
   argcnt = 0;

   mystring = cutatchar(line, '=');

   if (strlen(mystring) <= 0) {
      free(mystring);
      return;
   }
#ifdef DEBUG
   else {
      printf("title len:  %d\n", strlen(mystring));
      fflush(stdout);
      printf("title:  ::%s::\n", mystring);
      fflush(stdout);
   }
#endif

   if (cd->varflag == 1) {
      swap_char(mystring, '=', '/');
      swap_char(mystring, '-', '/');
      args = split_string(mystring, '/');
  }

   if (args != NULL) {
      while (args[argcnt] != NULL) {
         argcnt++;
      }
   }

   switch (argcnt) {
      case 0:
               len = strlen(mystring);
               title = mystring;
               break;
      case 1:
               len = strlen(args[0]);
               title = args[0];
               break;
      default:
               artist = args[0];
               len = strlen(args[1]);
               title = args[1];
               break;
   }

   track = buildtrack();
   if (cd->tracklist == NULL) {
      cd->tracklist = track;
   } else {
      follow = cd->tracklist;
      while (follow->next != NULL) {
         follow = follow->next;
      }
      track_seq = follow->track_seq;
      follow->next = track;
      track_seq++;
   }
   track->title = processmystring(title, 0);
   track->track_seq = track_seq;
   track->artist = processmystring(artist, 0);
   free(mystring);
#ifdef DEBUG
   printf("track id:  %d\n", track->track_seq);
   fflush(stdout);
   printf("track:  %s\n", track->title);
   fflush(stdout);
#endif
   return;
}
void dyearfn(struct discst *cd, char *line)
{
char **args, *mystring;
int len, go, i;

   mystring = cutatchar(line, '=');
   if (mystring != NULL) {
      len = strlen(mystring);
   } else {
      return;
   }

   go = 0;
   for (i = 0; i < strlen(mystring); i++) {
      if (mystring[i] != ' ') {
         go = 1;
      }
   }
   if (go > 0) {
      cd->year = mystring;
   } else {
      free(mystring);
   }
   return;
}
void dtitlefn(struct discst *cd, char *line)
{
char **args, *mystring;
int len;

   mystring = cutatchar(line, '=');
   if (mystring != NULL) {
      len = strlen(mystring);
   } else {
      return;
   }

   swap_char(mystring, '=', '/');
   swap_char(mystring, '-', '/');
   args = split_string(mystring, '/');
   if (args[0] != NULL) {
      cd->artist = processmystring(args[0], 0);
#ifdef DEBUG
      printf("artist:  %s\n", cd->artist);
      fflush(stdout);
#endif
   }
   if (args[1] != NULL) {
      cd->title = processmystring(args[1], 0);
#ifdef DEBUG
      printf("title:  %s\n", cd->title);
      fflush(stdout);
#endif
   }
   various_check(cd);
   free(mystring);
   return;
}

void genrefn(struct discst *cd, char *line)
{
int i, go, len;
char *mystring;

   mystring = cutatchar(line, '=');
   if (mystring != NULL) {
      len = strlen(mystring);
   } else {
      return;
   }

   go = 0;
   for (i = 0; i < strlen(mystring); i++) {
      if (mystring[i] != ' ') {
         go = 1;
      }
   }

   if (go > 0) {
      cd->genre = processmystring(mystring, 0);
   }

   return;
}

int processline(struct discst *cd, char *line, char *bugenre)
{
int which, len;
char **args, *fnspace;

   which = 0;
   fnspace = line;
   while ((*fnspace == ' ') || (*fnspace == '#')) {
      fnspace++;
   }

   while (linetype[which].title != NULL) {
      if (strneq(linetype[which].title, fnspace, strlen(linetype[which].title))) {
         unnewlineit(fnspace);
         if (which == DISCIDFN) {
            linetype[which].cdfunction(cd, fnspace, bugenre);
         } else {
            linetype[which].cdfunction(cd, fnspace);
         }
      }
      which++;
   }

   return(0);
}

#ifdef USEFGETS
int reader(FILE *fp, char *backupgenre)
#else
int reader(int fp, char *backupgenre)
#endif
{
char *myline;
struct discst *cd = NULL;

   cd = buildcd();
   backupgenre = processmystring(backupgenre, 0);

   myline = (char *)calloc(257, 1);

   if (myline != NULL) {
#ifdef USEFGETS
      while (fgets(myline, 256, fp) != NULL) {
#else
      while (myreadline(fp, myline, 256) != NULL) {
#endif
         if (strlen(myline) > 0) {
#ifdef DEBUG
            printf("LINE:   %s\n", myline);
            fflush(stdout);
#endif
            processline(cd, myline, backupgenre);
         }
      }
      dumpcd(cd, backupgenre);
      freecd(cd);
      free(myline);
   } else {
      printf("Memory allocation for myline failed\n");
      fflush(stdout);
   }
   return(0);
}

char *getgenre(char *filename)
{
char *tmp, *thegenre;

   tmp = workingdir(filename);
   thegenre = getthefile(tmp);

   return(thegenre);
}

int process_directory(char *directory)
{
#ifdef USEFGETS
FILE *fp;
#else
int fp;
#endif
struct stat buf;
DIR *dirp;
char fullpath[256];
char *thedir, *thefile, *genre;
struct dirent *dp;
int counter;

   counter = 0;
   dirp = opendir(directory);
   if (dirp != NULL) {
      while ((dp = readdir(dirp)) != NULL) {
         if ((strcmp(dp->d_name, ".") != 0) && (strcmp(dp->d_name, "..") != 0)) {
#ifdef PLATFORM_WINDOWS
            sprintf(fullpath, "%s\\%s\0", directory, dp->d_name);
#else
            sprintf(fullpath, "%s/%s\0", directory, dp->d_name);
#endif
            stat(fullpath, &buf);
            if (S_ISDIR(buf.st_mode)) {
               counter += process_directory(fullpath);
            } else {
               thedir = workingdir(fullpath);
               thefile = getthefile(fullpath);
               genre = getgenre(fullpath);
#ifdef DEBUG
               printf("BEGIN %s  #################################\n", thefile);
               printf("PATH:   %s\n", fullpath);
               printf("FILE:   %s\n", thefile);
               printf("DIR:    %s\n", thedir);
               printf("GENRE:  %s\n", genre);
               fflush(stdout);
               printf("BASE DUMP completed, %s\n", fullpath);
               fflush(stdout);
#endif
               if (access(fullpath, R_OK) == 0) {
#ifdef USEFGETS
                  fp = fopen(fullpath, "r");
                  if (fp != NULL) {
#else
                  fp = open(fullpath, O_RDONLY);
                  if (fp >= 0) {
#endif
#ifdef DEBUG
                     printf("%s opened\n", fullpath);
                     fflush(stdout);
#endif
                     reader(fp, genre);
#ifdef USEFGETS
                     fclose(fp);
#else
                     close(fp);
#endif
                     counter++;
                  } else {
                     printf("Open failed\n");
                     fflush(stdout);
                     printf("Could not open %s\n", fullpath);
                     fflush(stdout);
                  }
               } else {
                  printf("Could not read %s\n", fullpath);
                  fflush(stdout);
               }
#ifdef DEBUG
               printf("END %s  #################################\n", thefile);
#endif
               free(thedir);
               free(thefile);
               free(genre);
            }
         }
      }
      closedir(dirp);
   } else {
      printf("Directory %s could not be opened\n", directory);
      fflush(stdout);
   } 

   printf("Directory %s had %d entries\n", directory, counter);
   fflush(stdout);
   return(counter);

}

int onedirectory(char *directory)
{
char *dirpath;

   dirpath = getfullpath(directory);
   process_directory(dirpath);
   return(0);
}

int onefile(char *filename)
{
#ifdef USEFGETS
FILE *fp;
#else
int fp;
#endif
char *fullpath, *genre, *thedir, *thefile;

   fullpath = getfullpath(filename);
   thedir = workingdir(fullpath);
   thefile = getthefile(fullpath);
   genre = getgenre(fullpath);

   printf("PATH:   %s\n", fullpath);
   printf("FILE:   %s\n", thefile);
   printf("DIR:    %s\n", thedir);
   printf("GENRE:  %s\n", genre);
   fflush(stdout);

   if (access(fullpath, F_OK) == 0) {
#ifdef USEFGETS
      fp = fopen(filename, "r");
#else
      fp = open(filename, O_RDONLY);
#endif
      reader(fp, genre);
   } else {
      printf("File %s does not exist\n", filename);
      fflush(stdout);
   }

   return(0);
}

int main(int argc, char **argv)
{
char *filename, *directory;
extern char *optarg;
static char *optmystring = "f:d:";
int c;


   filename = directory = NULL;

   if (argc == 3) {
      while ((c=getopt(argc, argv, optmystring)) != EOF) {
         switch ((char)c) {
            case 'f':
                       filename = optarg;
                       break;
            case 'd':
                       directory = optarg;
                       break;
            default:
                       printf("Invalid argument.\n");
                       printf("usage:  %s < -f filename | -d directory>\n",
                               argv[0]);
                       fflush(stdout);
                       break;
         }
      }
   } else {
      printf("usage:  %s < -f filename | -d directory>\n",
              argv[0]);
      fflush(stdout);
   }

   opendb("gaw", "mustang5", "orcl");
   if (filename != NULL) {
      onefile(filename);
   } else {
      onedirectory(directory);
   }

   exit(0);
}
