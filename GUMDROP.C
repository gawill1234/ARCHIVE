#include <stdio.h>
#include <unistd.h>
main()
{
   printf("NO FORK:  %d is the PE I am on\n", sysconf(_SC_CRAY_PPE));
   if (fork() == 0) {
      execl("/virga/u9/gaw/a.out2", 0);
      _exit(0);
   }
   if (fork() == 0) {
      printf("FORK ONLY:  %d is the PE I am on\n", sysconf(_SC_CRAY_PPE));
      _exit(0);
   }
}
