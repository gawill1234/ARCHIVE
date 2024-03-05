#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

/*******************************************************/
//
//   Return the last segment of a complete path.
//   This is the same as linux/unix basename().
//
char *_basename(char *path)
{
        register int i;

        i = strlen(path);
        for (i--; i >= 0; i--)
#ifdef PLATFORM_WINDOWS
                if (path[i] == '\\')
#else
                if (path[i] == '/')
#endif
                        break;
        i++;

        return(&path[i]) ;
}
/*******************************************************/
//
//   Return the directory name from a file path, or the
//   preceding directory name from a directory path.
//   This is the same as linux/unix dirname().
//
char *_dirname(char *path)
{
        register int i;

        i = strlen(path);
        for (i--; i>= 0; i--)
#ifdef PLATFORM_WINDOWS
                if (path[i] == '\\')
#else
                if (path[i] == '/')
#endif
                        break;
        path[i] = '\0';
        i++;

        return(path) ;
}
/*******************************************************/

