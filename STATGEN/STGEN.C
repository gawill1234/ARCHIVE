#include <stdio.h>
#include <time.h>

extern struct tm *localtime();

main()
{
FILE *anfp;
char sysarray[80];
char syscall[80];
char pathname[80];
char *answer = NULL;
long clock;
int exist, number;
struct tm *timestruct;

   printf("TIME TO DO THE DAILY STATUS SHIT\n");
   printf("  HIT RETURN TO CONINUE\n");
   waitasec();

   timestruct = (struct tm *)malloc(sizeof(struct tm));
   strcpy(pathname,"/home/fir21/gaw/statrep");
   clock = time((long *)0);
   timestruct = localtime(&clock);
   strcpy(pathname,"/home/fir21/gaw/statrep/st");
   sprintf(sysarray, "%s%d-%d-%d", pathname,
     timestruct->tm_mon + 1, timestruct->tm_mday, timestruct->tm_year);

   exist = fileexist(sysarray);

   if (exist != 0) {
      anfp = fopen(sysarray,"a+");
      fprintf(anfp,"%s\n\n",sysarray);
   }
   else {
      chmod(sysarray, 0644);
      anfp = fopen(sysarray,"a+");
   }

   dispmenu();

   while ((answer = getfile()) != NULL) {
      number = getnumber(answer);
      switch (number) {
          case 1:
                   question(anfp, "Talk to anybody",
                                  "Spoke to the following people",
                                  "person");
                   break;
          case 2:
                   question(anfp, "Work on anything(projects)", 
                                  "Worked on the following projects",
                                  "worked on");
                   break;
          case 3:
                   question(anfp, "Help anybody",
                                  "Helped the following people",
                                  "person");
                   break;
          case 4:
                   question(anfp, "Take any classes",
                                  "Attended the following classes",
                                  "class");
                   break;
          case 5:
                   question(anfp, "Go anywhere", "Trip to the following",
                                  "place");
                   break;
          case 6:
                   question(anfp, "Miss anything up there",
                                  "Miscellaneous", "what");
                   break;
          case 7:
                   question(anfp, "Plans for later", "Plans", "what");
                   break;
          default:
                   printf("Bad choice, try again\n");
      }
      free(answer);
      dispmenu();
   }

   clrwin();
   fclose(anfp);

   sprintf(syscall,"vi %s",sysarray);
   system(syscall);
}
