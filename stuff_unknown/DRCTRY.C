#include <stdio.h>
#include <sys/types.h>
#include <dirent.h>

extern char *progname;
extern char *prog_unknown;

/******************************************/
/*   Library directory entries.  Mostly used
     by test_tmpdir() and test_rmdir()
*/
char *my_start_dir = NULL;
char *my_tmp_dir = NULL;

/********************************************************/
/*
   Destroy local files 
*/
void destroyfiles()
{
DIR *dirp, *opendir();
struct dirent *dp, *readdir();

   dirp = opendir(".");

   while ((dp = readdir(dirp)) != NULL) {
      unlink(dp->d_name);
   }
   closedir(dirp);
   return;
}
/********************************************************/
/*  TEST_TMPDIR

    Create and change to a temporary directory in /tmp.

    PARAMETERS:
       none

    RETURNS
       none
*/
void test_tmpdir()
{
char *getcwd();

   if (progname == NULL)
      progname = prog_unknown;

   my_start_dir = getcwd((char *)NULL, 256);

   my_tmp_dir = tempnam("/tmp", "tst");
   if (mkdir(my_tmp_dir, 0777) != 0) {
      fprintf(stderr, "%s:  tst_tmpdir(), Could not create temp directory\n",
              progname);
      exit(1);
   }

   if (chdir(my_tmp_dir) == (-1)) {
      fprintf(stderr,
             "%s:  tst_tmpdir(), Could not chdir to temp directory - %s\n",
              progname, my_tmp_dir);
      exit(1);
   }
   return;
}
/********************************************************/
/*  TEST_RMDIR
    
    Remove files created by a test that it left around.  Return to the
    directory of origin.  Remove the temporary directory.

    PARAMETERS:
       none

    RETURNs:
       none

*/
void test_rmdir()
{
char *getcwd();

   /***********************************************/
   /*  A double check is performed here.  The reason is
       just in case someone set "my_tmp_dir" from outside
       test_tmpdir(), it could be something different than
       the current directory and it may not be in /tmp.
       The double check makes sure those case are still true
       so the user of this routine does not accidently blow
       away something important in their or someone else's
       home directory structure.
   */
   if (strcmp(my_tmp_dir, getcwd((char *)NULL, 256)) == 0) {
      if (strncmp("/tmp/", my_tmp_dir, 5) == 0) {
         destroyfiles();
      }
      if (chdir(my_start_dir) == (-1)) {
         fprintf(stderr,
                "%s:  tst_tmpdir(), Could not chdir to origin directory - %s\n",
                 progname, my_start_dir);
      }
      else {
         if (rmdir(my_tmp_dir) == (-1)) {
            fprintf(stderr,
                "%s:  tst_tmpdir(), Could not rmdir directory - %s\n",
                 progname, my_tmp_dir);
         }
      }
   }
   return;
}
