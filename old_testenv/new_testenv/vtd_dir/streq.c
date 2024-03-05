/***************************************************************************/
/*   This is vtd.  A program to run tests and gather their results.
 *   Yes, it is one big huge file.  If you have this file, you have it all.
 *
 *   Author:  Gary Williams
 *   Made safe for uclibc
 *
 */
#include <string.h>

int streq(char *one, char *two)
{

   if (one == NULL)
      return(0);

   if (two == NULL)
      return(0);

   if (strcmp(one, two) == 0) {
      return(1);
   } else {
      return(0);
   }

   return(0);
}
