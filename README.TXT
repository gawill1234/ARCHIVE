To users of sysbash.c

1. Compile Instructions

   Port:  sysbash.c
          sysfuncs.c
          sysbash.h

   To your Unix environment and insure sysbash.h is local to the C code.

   cc -c sysfuncs.c
   cc -c sysbash.c
   cc -o sysbash sysfuncs.o sysbash.o

   If this fails, you must get the porting issues out of the way.  Those dealing 
   with system calls which are invalid and those which are missing...  And, any
   compiler type castings, etc.

2.  sysbash -h

usage: sysbash [-hTNoRT] [-a Alarm_Seed] [-b Start_Sc] [-c Copies] [-d Debug]
            [-e End_Sc] [-f FileName] [-F Fork_Limit] [-i Number] [-l Level] [-n Dir_Name]
            [-p Range] [-r Range] [-s Seed] [-S system_call[,system_call,...]]
            [-t Script_FileName] [-w Weight] [-x Medium] [-z Seed]

     where option meanings are:
            -a      (Def=3) Seconds Children Processes Are Active
            -b      (Def=0) Starting System Call Number
            -c      (Def=1) Number Of Parallel Copies To Run
            -d      (Def=0) Debug Level (Use 0 thru 6)
            -e      (Def=152) Ending System Call Number
            -f      FileName To Use For Disk File System Calls
            -F      Maximum Concurrent Fork Limit Value
            -h      The Help Message
            -i      [DEF=1] Maximum Number Of Iterations(Looping Mode)
            -l      [DEF=5] Levels Of Subdirs To Create
            -n      [DEF=RAM] Name Of Subdirs
            -N      Allow Negative Argument Values
            -o      Toggle Number Of System Call Parameters To 11
            -p      (Def=1000) Range For First Parameter To Sys_Call
            -r      (Def=1000) Range For Random Numbers
            -R      Use Random Number Generator For Disk Filenames
            -s      (Def=1) Starting Seed For Random Number Generator
            -S      Use coma delimited system call list only
            -t      Use This To Create Test Script File
            -T      Use Current Time As Seed For Random Number Generator
            -w      [DEF=100] 0-100 Percent Weighting Towards Randoms
            -x      Used To Scew Random Numbers Toward Zero
            -z      (Def=0) Ending Seed, 0 Means Run Forever


3. An Example

sysbash -i 3 -a 90 -c 3 -F 30 -S read,write,open,close,readv,writev -T


Parent will create 3 children (to do system calls) and wait for their deaths.
Systems calls utilized are above.  Current time value is used for the random
number generator seed...

-i 3 means do everything just described a total of 3 times so 90 seconds times
3 is total run duration..

4. Suggestions/Caveats/Warnings

   cd to where you wanna start the subsequent disk I/O to before running sysbash
   or use the option described above. Its possible to have 10 sysbash programs
   via 5 separate invocation running under 5 different mounted file system points.
   Total sysbash(es) = 50, total proc slot allocations = 50... Concurrent I/O to
   desired I/O channels... Thats the idea here..

   -t Script_FileName creates a bourne shell script file of your command line
      invocation for future replays of what had previously executed without
      any problems.  This can create a regression file(s) to replay at a later time
      which can be advantageous for remembering previous runs/executions....

   -F usages is strongly suggested.  Otherwise, a lot of forking can be done.
      sysbash -S fork,exec is suicidal on the system...

   Use -S to tailor a user process to system calls you want...

   -R creates trash filenames via ls -al output.  You will wonder how some of
      those filename characters where typed in... NOT!!!

   -N will allow negative system call parameter values and extreme negative
      (errno and error value) testing...

   Certain resource exhaustions (filling callout, file table, etc) will hang 
   the os and no problem results.  As, just configure your table's larger is
   the recourse if os has statically defined table sizes.  NOT SO, if dynamic
   table allocations...  Should get OUT OF SPACE and not hangs...

   Lastly, not all outcomes are known...  This is a resiliency tool which
   provides the most in the quickest time...  It can create a sequence of 
   events leading to a critical problem determination which would have been
   very difficult to predict, net alone conceptualize...  Consequently, it
   can result in very impractical problems which are judged unrealistic for
   any HUMAN usage to ever transpire...

   At PCray, we were able to establish a set of command line invocations which could
   run over a weekend, along with a set of functional tests.  The latter results were
   expected to be all PASS and the system was expected to stay up to generate those
   results.....  By simply merging test files/tools, we extended the functionalities to
   saturation levels/stress loads which were more than likely needed to expose small
   window problems/timing problems in the basic functional capabilities.

