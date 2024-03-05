/***************************************************/
/*  Get todays date and time and store it in a manner
    which will not be crushed by future calls to localtime.
*/
#include <stdio.h>
#include <time.h>

struct tm *get_today(timeinsec)
long timeinsec;
{
struct tm *today, *getit;

   today = getit = NULL;
   
   today = (struct tm *)malloc(sizeof(struct tm));
   if (today == NULL) {
      printf(" Could not get memory\n");
      return(NULL);
   }

   getit = localtime(&timeinsec);
   if (getit == NULL) {
      printf("Could not get local date and time using localtime()\n");
      free(today);
      return(NULL);
   }


   today->tm_sec = getit->tm_sec;
   today->tm_min = getit->tm_min;
   today->tm_hour = getit->tm_hour;
   today->tm_mday = getit->tm_mday;
   today->tm_mon = getit->tm_mon;
   today->tm_year = getit->tm_year;
   today->tm_wday = getit->tm_wday;
   today->tm_yday = getit->tm_yday;
   today->tm_isdst = getit->tm_isdst;

   return(today);
}
