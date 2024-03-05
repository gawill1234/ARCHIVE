#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

#define HOW_MANY 500
#define MAX_PORT 65535
#define MIN_PORT 1024
#define IPPORT_RESERVED MIN_PORT
int ATEST_PORT;
int starting_ports[HOW_MANY];

#define TEST_PORT(PID)  \
   ATEST_PORT=((((PID%IPPORT_RESERVED)+IPPORT_RESERVED)*3)%65535); \

main()
{
   
   int a, b, c, d;
   a=getpid();
   c=a;

   fprintf(stdout, "Starting Program Process Id = %d\n", a);

   for (b=0; b < HOW_MANY; b++,a++) {
       TEST_PORT(a);
       starting_ports[b]=ATEST_PORT;
   } 
   for (d=1,a=c,b=0; b < HOW_MANY; a++, b++) {
       fprintf(stdout, "PID = %d : Starting Port = %d\n", a, starting_ports[b]);
   }
   
   		
}

