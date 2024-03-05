static char USMID[] = "@(#)cuts/src/pics/uts/os/sess_susp.c	80.0	05/19/93 14:13:52";

/*
 *	(C) COPYRIGHT CRAY RESEARCH, INC.
 *	UNPUBLISHED PROPRIETARY INFORMATION.
 *	ALL RIGHTS RESERVED.
 */
#include <stdio.h>
#include <sys/category.h>
#include <sys/restart.h>
#include <errno.h>
#include <signal.h>

int dochild()
{
int childpid, fork();

   childpid = fork();
   if (childpid == 0) {
      setsid();
      while(getppid() != 1);
      _exit(0);
   }
   return(childpid);
}

int dochild2()
{
int childpid, fork();

   childpid = fork();
   if (childpid == 0) {
      while(getppid() != 1);
      _exit(0);
   }
   return(childpid);
}

int susp_res(childpid)
int childpid;
{
int i, susp_err, res_err;
int err = 0;

   sleep(2);
   for (i = 0; i < 10; i++) {
      susp_err = suspend(C_PROC, childpid);
      res_err = resume(C_PROC, childpid);
      if (susp_err != res_err)
         err = 1;
   }

   kill(childpid, 9);

   return(err);
}

int goofy()
{
int err, sesschild, childpid;
union {
   struct {
#ifdef CRAY
      unsigned unused :48, sherr:8, sigid:8;
#else
      unsigned unused :16, sherr:8, sigid:8;
#endif
   } err;
   int retval;
} errstruct;

   err = sesschild = 0;

   sesschild = fork();
   if (sesschild == 0) {
      childpid = dochild2();
      setsid();
      err = susp_res(childpid);
      _exit(err);
   }

   if (sesschild < 0)
      return(1);

   waitpid(sesschild, &errstruct.retval, 0);
   return(errstruct.err.sherr);

}

int tell_errors(tot_err)
int tot_err;
{

   switch (tot_err) {
      case 1:
               printf("sess_susp:  CASE 0:  NO SESSION CHANGE -- FAILED\n");
               break;
      case 2:
               printf("sess_susp:  CASE 1:  CHILD CHANGES SESSION OF THE CHILD -- FAILED\n");
               break;
      case 3:
               printf("sess_susp:  CASE 0:  NO SESSION CHANGE -- FAILED\n");
               printf("sess_susp:  CASE 1:  CHILD CHANGES SESSION OF THE CHILD -- FAILED\n");
               break;
      case 4:
               printf("sess_susp:  CASE 2:  PARENT CHANGES SESSION OF THE PARENT -- FAILED\n");
               break;
      case 5:
               printf("sess_susp:  CASE 0:  NO SESSION CHANGE -- FAILED\n");
               printf("sess_susp:  CASE 2:  PARENT CHANGES SESSION OF THE PARENT -- FAILED\n");
               break;
      case 6:
               printf("sess_susp:  CASE 1:  CHILD CHANGES SESSION OF THE CHILD -- FAILED\n");
               printf("sess_susp:  CASE 2:  PARENT CHANGES SESSION OF THE PARENT -- FAILED\n");
               break;
      case 7:
               printf("sess_susp:  CASE 0:  NO SESSION CHANGE -- FAILED\n");
               printf("sess_susp:  CASE 1:  CHILD CHANGES SESSION OF THE CHILD -- FAILED\n");
               printf("sess_susp:  CASE 2:  PARENT CHANGES SESSION OF THE PARENT -- FAILED\n");
               break;
   }
}


main()
{
int childpid, err, tot_err;

   tot_err = err = 0;

   childpid = dochild2();
   err = susp_res(childpid);
   if (err == 1)
      tot_err = tot_err + 1;

   childpid = dochild();
   err = susp_res(childpid);
   if (err == 1)
      tot_err = tot_err + 2;

   err = goofy();
   if (err == 1)
      tot_err = tot_err + 4;

   if (tot_err == 0) {
      printf("sess_susp 1 PASS : Session suspend and resume Actions\n");
   }
   else {
      tell_errors(tot_err);
   }

   fflush(stdout);
   exit(err);
}
