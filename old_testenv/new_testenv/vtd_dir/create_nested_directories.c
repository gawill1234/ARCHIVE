/***************************************************************************/
/*
 *   Author:  Gary Williams
 *   Made safe for uclibc
 *
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/vfs.h>
#include <fcntl.h>
#include <dirent.h>
#include <time.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include <sys/msg.h>
//#include <sys/sysinfo.h>
#include <sys/utsname.h>
#include <libgen.h>
#include <errno.h>

#include "locals.h"
#include "externs.h"

/* 
 * Attempt to create nested directories, return 1 on success, 0 on failure
 * Why does it take so much code to do the right thing?
 *
 * Returns 1 when all of the directories get created, 0 otherwise
 *
 */
int create_nested_directories(const char *szFileName, FILE *pErrFile, int fff)
{
  char szCreateDir[DIRLEN + 1]; /* accumulator for directories we're creating */
  char* szBaseName;             /* we remove the basename and store the result here */
  char* szPath;                 /* scratch copy of sFileName, because dirname touches the input string */
  struct stat nodeInfo;         /* we need a place to store stat info when we test if directory exists */
  int nStatus;                  /* scratch var for success of library calls */
  int nWorked = 1;              /* what we return to the user about this function */
  char* pcEnd;                  /* pointer used to traverse string */


  szCreateDir[0] = '\0';
  /*
   *   Doing destructive work on the string so make a dup.
   */
  szPath = strdup(szFileName);

  /*
   *   If I remember right, fff means "full file flag", as in, the
   *   path being sent in is the path to a file and we want only
   *   the string of directories.
   */
  if (fff == 0)
     szBaseName = dirname(szPath);
  else
     szBaseName = szPath;

  pcEnd = szBaseName;
  while (*(pcEnd + 1) && *(pcEnd + 1) != '/')
    pcEnd++;

  while (nWorked && *pcEnd) {

    strncpy(szCreateDir, szBaseName, pcEnd - szBaseName + 1);
    szCreateDir[pcEnd - szBaseName + 1] = '\0';
 
    nStatus = stat(szCreateDir, &nodeInfo);
    if (nStatus == 0) {
      if (! S_ISDIR(nodeInfo.st_mode)) {
	fprintf(pErrFile, "Could not create directory %s, because %s exists as a non-directory\n",
		szCreateDir, szCreateDir);
	nWorked = 0;
	break;
      }
    }
    else {
      nStatus = mkdir(szCreateDir, S_IRWXO | S_IRWXG | S_IRWXU);
      if (nStatus != 0) {
	fprintf(pErrFile, "Could not create directory %s, error code %d\n", 
		szCreateDir, errno);
	nWorked = 0;
	break;
      }
    }

    pcEnd++;
    if (*pcEnd != '\0') {
       while (*(pcEnd + 1) && *(pcEnd + 1) != '/')
          pcEnd++;
    }

  }

  free(szPath);
  return nWorked;

}
