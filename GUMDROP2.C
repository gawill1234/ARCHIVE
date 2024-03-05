#include <stdio.h>
#include <unistd.h>
main()
{
   printf("FORK/EXEC:  %d is the PE I am on\n", sysconf(_SC_CRAY_PPE));
}
