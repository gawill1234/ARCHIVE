#!/bin/bash

#####################################################################

###
###
   export PATH=$PATH:$TEST_ROOT/utils/bin

   SHOST=$VIVHOST
   VUSER=$VIVUSER
   VPW=$VIVPW

   results=0
   casecount=0

###
###

#####################################################################

cleanup()
{

   collection_exists -C smoke_test -H $SHOST -U $VUSER -P $VPW
   x=$?

   if [ $x -eq 1 ]; then
      echo "delete_collection -C smoke_test -H $SHOST -U $VUSER -P $VPW"
      delete_collection -C smoke_test -H $SHOST -U $VUSER -P $VPW
      collection_exists -C smoke_test -H $SHOST -U $VUSER -P $VPW
      x=$?
      if [ $x -eq 1 ]; then
         echo "Unable to delete an older version of the smoke test collection"
         echo "Using alternate means ..."
         rstring="wget 'http://$SHOST/vivisimo/cgi-bin/gronk?collection=smoke_test&action=rm-collection' -o smoke_test.delcollog -O smoke_test.delcol"
         eval $rstring 2>/dev/null
         collection_exists -C smoke_test -H $SHOST -U $VUSER -P $VPW
         x=$?
         if [ $x -eq 1 ]; then
            exit 1
         fi
      fi
   fi
}

setup()
{
   echo "create_collection -C smoke_test -H $SHOST"
   create_collection -C smoke_test -H $SHOST
   x=$?

   if [ $x -ne 0 ]; then
      echo "Could not create smoke test collection"
      exit 1
   fi

   echo "start_crawl -C smoke_test -H $SHOST -U $VUSER -P $VPW"
   start_crawl -C smoke_test -H $SHOST -U $VUSER -P $VPW

   wait_for_idle -C smoke_test -H $SHOST -U $VUSER -P $VPW

   echo "Crawl/index complete, setup complete"

}

getsetopts()
{

   OPTERR=0
   OPTIND=1

   while getopts "H:U:P:" flag; do
     case "$flag" in
        H) SHOST=$OPTARG;;
        U) VUSER=$OPTARG;;
        P) VPW=$OPTARG;;
        *) echo "Usage: smoke_test.tst -H <host> -U <user> -P <password>"
           exit 1;;
     esac
   done
 
   if [ "$VUSER" == "" ]; then
      echo "Vivisimo username is needed"
      echo "Either set VIVUSER environment variable or"
      echo "use the -U <vivuser> options"
      exit 1
   fi

   if [ "$VPW" == "" ]; then
      echo "Vivisimo password is needed"
      echo "Either set VIVPW environment variable or"
      echo "use the -P <vivpassword> options"
      exit 1
   fi

   if [ "$SHOST" == "" ]; then
      echo "Target host needed"
      echo "Either set VIVHOST environment variable or"
      echo "use the -H <host> options"
      exit 1
   fi

}

test1()
{

   casecount=`expr $casecount + 1`
   echo "test1: Begin"
   simple_search.tst -H $SHOST -C smoke_test -Q Arizona -S /home/testing/smoke_test
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test1: Case Failed"
   else
      echo "test1: Case Passed"
   fi

   results=`expr $results + $xx`

}

test2()
{

   casecount=`expr $casecount + 1`
   echo "test2: Begin"
   simple_search.tst -H $SHOST -C smoke_test -Q Arizona+Battleship -S /home/testing/smoke_test
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test2: Case Failed"
   else
      echo "test2: Case Passed"
   fi

   results=`expr $results + $xx`

}

test3()
{

   casecount=`expr $casecount + 1`
   echo "test3: Begin"
   simple_search.tst -H $SHOST -C smoke_test -Q bismarck -S /home/testing/smoke_test
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test3: Case Failed"
   else
      echo "test3: Case Passed"
   fi

   results=`expr $results + $xx`

}

test4()
{

   casecount=`expr $casecount + 1`
   echo "test4: Begin"
   simple_search.tst -H $SHOST -C smoke_test -Q arizona -S /home/testing/smoke_test
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test4: Case Failed"
   else
      echo "test4: Case Passed"
   fi

   results=`expr $results + $xx`

}

test5()
{

   casecount=`expr $casecount + 1`
   echo "test5: Begin"
   simple_search.tst -H $SHOST -C smoke_test -Q Alarm+System -S /home/testing/smoke_test
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test5: Case Failed"
   else
      echo "test5: Case Passed"
   fi

   results=`expr $results + $xx`

}
test6()
{

   casecount=`expr $casecount + 1`
   echo "test6: Begin"
   simple_search.tst -H $SHOST -C smoke_test -Q Blücher -S /home/testing/smoke_test
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test6: Case Failed"
   else
      echo "test6: Case Passed"
   fi

   results=`expr $results + $xx`

}

test7()
{

   casecount=`expr $casecount + 1`
   echo "test7: Begin"
   simple_search.tst -H $SHOST -C smoke_test -Q cænogenèse -S /home/testing/smoke_test
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test7: Case Failed"
   else
      echo "test7: Case Passed"
   fi

   results=`expr $results + $xx`

}

test8()
{

   casecount=`expr $casecount + 1`
   echo "test8: Begin"
   simple_search.tst -H $SHOST -C smoke_test -Q Chris+Palmer -S /home/testing/smoke_test
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test8: Case Failed"
   else
      echo "test8: Case Passed"
   fi

   results=`expr $results + $xx`

}
test9()
{

   casecount=`expr $casecount + 1`
   echo "test9: Begin"
   simple_search.tst -H $SHOST -C smoke_test -Q น่าฟังเอย -S /home/testing/smoke_test
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test9: Case Failed"
   else
      echo "test9: Case Passed"
   fi

   results=`expr $results + $xx`

}
test10()
{

   casecount=`expr $casecount + 1`
   echo "test10: Begin"
   simple_search.tst -H $SHOST -C smoke_test -Q いろはにほへとちりぬるを -S /home/testing/smoke_test
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test10: Case Failed"
   else
      echo "test10: Case Passed"
   fi

   results=`expr $results + $xx`

}
test11()
{

   casecount=`expr $casecount + 1`
   echo "test11: Begin"
   simple_search.tst -H $SHOST -C smoke_test -Q Heizölrückstoßabdämpfung -S /home/testing/smoke_test
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test11: Case Failed"
   else
      echo "test11: Case Passed"
   fi

   results=`expr $results + $xx`

}
test12()
{

   casecount=`expr $casecount + 1`
   echo "test12: Begin"
   simple_search.tst -H $SHOST -C smoke_test -Q lay -S /home/testing/smoke_test
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test12: Case Failed"
   else
      echo "test12: Case Passed"
   fi

   results=`expr $results + $xx`

}
test13()
{

   casecount=`expr $casecount + 1`
   echo "test13: Begin"
   simple_search.tst -H $SHOST -C smoke_test -Q lotus -S /home/testing/smoke_test
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test13: Case Failed"
   else
      echo "test13: Case Passed"
   fi

   results=`expr $results + $xx`

}
test14()
{

   casecount=`expr $casecount + 1`
   echo "test14: Begin"
   simple_search.tst -H $SHOST -C smoke_test -Q quick+brown -S /home/testing/smoke_test
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test14: Case Failed"
   else
      echo "test14: Case Passed"
   fi

   results=`expr $results + $xx`

}
test15()
{

   casecount=`expr $casecount + 1`
   echo "test15: Begin"
   simple_search.tst -H $SHOST -C smoke_test -Q sharepoint -S /home/testing/smoke_test
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test15: Case Failed"
   else
      echo "test15: Case Passed"
   fi

   results=`expr $results + $xx`

}
test16()
{

   casecount=`expr $casecount + 1`
   echo "test16: Begin"
   simple_search.tst -H $SHOST -C smoke_test -Q skilling -S /home/testing/smoke_test
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test16: Case Failed"
   else
      echo "test16: Case Passed"
   fi

   results=`expr $results + $xx`

}
test17()
{

   casecount=`expr $casecount + 1`
   echo "test17: Begin"
   simple_search.tst -H $SHOST -C smoke_test -Q skilling+lay -S /home/testing/smoke_test
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test17: Case Failed"
   else
      echo "test17: Case Passed"
   fi

   results=`expr $results + $xx`

}
test18()
{

   casecount=`expr $casecount + 1`
   echo "test18: Begin"
   simple_search.tst -H $SHOST -C smoke_test -Q vivisimo -S /home/testing/smoke_test
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test18: Case Failed"
   else
      echo "test18: Case Passed"
   fi

   results=`expr $results + $xx`

}
test19()
{

   casecount=`expr $casecount + 1`
   echo "test19: Begin"
   simple_search.tst -H $SHOST -C smoke_test -Q фальшивый -S /home/testing/smoke_test
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test19: Case Failed"
   else
      echo "test19: Case Passed"
   fi

   results=`expr $results + $xx`

}
#####################################################################

getsetopts $*

cleanup $SHOST $USER $VPW
setup $SHOST $USER $VPW

test1 $SHOST 
test2 $SHOST 
test3 $SHOST 
test4 $SHOST 
test5 $SHOST 
test6 $SHOST 
test7 $SHOST 
test8 $SHOST 
test9 $SHOST 
test10 $SHOST 
test11 $SHOST 
test12 $SHOST 
test13 $SHOST 
test14 $SHOST 
test15 $SHOST 
test16 $SHOST 
test17 $SHOST 
test18 $SHOST 
test19 $SHOST 

if [ $results -eq 0 ]; then
   echo "smoke_test:  Test Passed"
   exit 0
fi

echo "smoke_test:  Test Failed"
echo "smoke_test:  $results of $casecount cases failed"
exit 1
