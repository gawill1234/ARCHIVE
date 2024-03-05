#ifdef CRAY
/********************************************************/
/*   Get host machine characteristics.
*/
#include <sys/target.h>
#include <stdio.h>

struct target *get_target()
{
struct target *machtarg;
int error;

   machtarg = NULL;
   machtarg = (struct target *)malloc(sizeof(struct target));
   if (machtarg == NULL) {
      printf("Could not get memory\n");
      return(NULL);
   }

   error = target(MC_GET_SYSTEM, machtarg);
   if (error == (-1)) {
      printf("Could not get machine characteristics\n");
      free(machtarg);
      return(NULL);
   }


   return(machtarg);
}
#endif
