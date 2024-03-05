#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="samba-multi-hit"
   VCOLLECTION1="samba-multi-hit1"
   VCOLLECTION2="samba-multi-hit2"
   VCOLLECTION3="samba-multi-hit3"
   VCOLLECTION4="samba-multi-hit4"
   DESCRIPTION="samba crawl of one tar file"

###
###

export VIVRUNTARGET="linux solaris"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

do_delete_p()
{
   if [ "$VIVDELETE" == "" ]; then
      VIVDELETE="pass"
   fi
   if [ "$VIVDELETE == "all" ] || [ "$VIVDELETE" == "pass" ]; then
      delete_collection -f -C $1 -H $4 -U $5 -P $6
   fi

   return
}

do_delete_f()
{
   if [ "$VIVDELETE" == "" ]; then
      VIVDELETE="pass"
   fi
   if [ "$VIVDELETE == "all" ] || [ "$VIVDELETE" == "fail" ]; then
      delete_collection -f -C $1 -H $4 -U $5 -P $6
   fi

   return
}

stop_it_all()
{
   stop_crawler -C $1 -H $4 -U $5 -P $6
   stop_indexing -C $1 -H $4 -U $5 -P $6

   return
}

#####################################################################
local_footer()
{
#####################################################################

###
#   This defines the standard PASS/FAIL output for all of the
#   crawl/query tests.
###

#echo "$1 $2 $3 $4 $5 $6"


if [ $results -eq 0 ]; then
   echo "TEST RESULT FOR $1:  Test Passed"
   stop_it_all $1 $2 $3 $4 $5 $6
   do_delete_p $1 $2 $3 $4 $5 $6
   return
fi

echo "TEST RESULT FOR $1:  Test Failed"
echo "$1:  $2 of $3 cases failed"
stop_it_all $1 $2 $3 $4 $5 $6
do_delete_f $1 $2 $3 $4 $5 $6

return

#####################################################################
}


test_header $VCOLLECTION $DESCRIPTION

RUNCOUNT=25

if [ -z "$VIVVERSION" ]; then
   export VIVVERSION="7.0"
fi

./samba-multi-hit1.sh $RUNCOUNT > querywork/samba-multi-hit1.output &
one=$!
./samba-multi-hit2.sh $RUNCOUNT > querywork/samba-multi-hit2.output &
two=$!
./samba-multi-hit3.sh $RUNCOUNT > querywork/samba-multi-hit3.output &
three=$!
./samba-multi-hit4.sh $RUNCOUNT > querywork/samba-multi-hit4.output &
four=$!

#
#   Create a kill file so if any given thing fails,
#   we can end this immediately.
#
rm -f killer.sh
echo "#!/bin/bash" > killer.sh
echo "kill -9 $one $two $three $four" >> killer.sh
chmod 755 killer.sh

wait $one
w=$?
wait $two
x=$?
wait $three
y=$?
wait $four
z=$?

#
#   If we are done waiting, we do not need
#   this any more.
#
rm -f killer.sh
casecount=4
results=`expr $w + $x + $y + $z`

if [ $w -gt 100 ] || [ $x -gt 100 ] ||
   [ $y -gt 100 ] || [ $z -gt 100 ]; then
   #
   #   Get rid of created files.
   #
   rm -f samba-multi-hit1.xml samba-multi-hit1.xml.stats
   rm -f samba-multi-hit2.xml samba-multi-hit2.xml.stats
   rm -f samba-multi-hit3.xml samba-multi-hit3.xml.stats
   rm -f samba-multi-hit4.xml samba-multi-hit4.xml.stats
   stop_it_all $VCOLLECTION1 $results $casecount $SHOST $VUSER $VPW
   stop_it_all $VCOLLECTION2 $results $casecount $SHOST $VUSER $VPW
   stop_it_all $VCOLLECTION3 $results $casecount $SHOST $VUSER $VPW
   stop_it_all $VCOLLECTION4 $results $casecount $SHOST $VUSER $VPW
   echo "An error happened during one of the crawls."
   echo "All other processes were killed."
   echo "Look in querywork for a file with a .errors suffix."
   echo "TEST RESULT FOR $VCOLLECTION:  Test Failed"
   exit 1
fi

if [ $w -ne 0 ]; then
   echo "samba-multi-hit1 crawl failed"
fi
if [ $x -ne 0 ]; then
   echo "samba-multi-hit2 crawl failed"
fi
if [ $y -ne 0 ]; then
   echo "samba-multi-hit3 crawl failed"
fi
if [ $z -ne 0 ]; then
   echo "samba-multi-hit4 crawl failed"
fi

for file in query_cmp_files/qry*
do
  echo "Updating file ${file}"
  sed -i s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${file}
  sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${file}
done

#
#   Unconditional removal of leftovers
#
rm -f querywork/qry.*

results=0
basic_query_test 1 $SHOST $VCOLLECTION1 ODBC
basic_query_test 2 $SHOST $VCOLLECTION1 main
a=$results

#
#   If query failed, save the query files,
#   otherwise remove them
#
if [ $a -ne 0 ]; then
   mkdir -p querywork/hit1
   mv querywork/qry* querywork/hit1
else
   rm -f querywork/qry.*
fi

results=0
basic_query_test 1 $SHOST $VCOLLECTION2 ODBC
basic_query_test 2 $SHOST $VCOLLECTION2 main
b=$results

#
#   If query failed, save the query files,
#   otherwise remove them
#
if [ $b -ne 0 ]; then
   mkdir -p querywork/hit2
   mv querywork/qry* querywork/hit2
else
   rm -f querywork/qry.*
fi

results=0
basic_query_test 1 $SHOST $VCOLLECTION3 ODBC
basic_query_test 2 $SHOST $VCOLLECTION3 main
c=$results

#
#   If query failed, save the query files,
#   otherwise remove them
#
if [ $c -ne 0 ]; then
   mkdir -p querywork/hit3
   mv querywork/qry* querywork/hit3
else
   rm -f querywork/qry.*
fi

results=0
basic_query_test 1 $SHOST $VCOLLECTION4 ODBC
basic_query_test 2 $SHOST $VCOLLECTION4 main
d=$results

#
#   If query failed, save the query files,
#
if [ $d -ne 0 ]; then
   mkdir -p querywork/hit4
   mv querywork/qry* querywork/hit4
fi

rm query_cmp_files/qry*

results=`expr $a + $w`
local_footer $VCOLLECTION1 $results $casecount $SHOST $VUSER $VPW

results=`expr $b + $x`
local_footer $VCOLLECTION2 $results $casecount $SHOST $VUSER $VPW

results=`expr $c + $y`
local_footer $VCOLLECTION3 $results $casecount $SHOST $VUSER $VPW

results=`expr $d + $z`
local_footer $VCOLLECTION4 $results $casecount $SHOST $VUSER $VPW

results=`expr $a + $b + $c + $d + $w + $x + $y + $z`
if [ $results -eq 0 ]; then
   echo "TEST RESULT FOR $VCOLLECTION:  Test Passed"
   exit 0
fi
echo "TEST RESULT FOR $VCOLLECTION:  Test Failed"
exit 1
