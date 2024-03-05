/**************************************************/
/*  Get Operating System data (release, version ...)
*/
#include <sys/utsname.h>
#include <stdio.h>

struct utsname *get_os()
{
struct utsname *osinfo;
int error;

   osinfo = NULL;
   osinfo = (struct utsname *)malloc(sizeof(struct utsname));
   if (osinfo == NULL) {
      printf("Could not get memory\n");
      return(NULL);
   }

   error = uname(osinfo);
   if (error == (-1)) {
      printf("Could not get OS information\n");
      free(osinfo);
      return(NULL);
   }

   return(osinfo);
}
