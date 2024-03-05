#!/bin/bash

test_header()
{
   echo "TEST:  $1"
   shift
   echo "TEST DESCRIPTION:  $*"

   #
   #  Default version to 6.0 or greater
   #
   if [ -z "$VIVVERSION" ]; then
      export VIVVERSION="6.0"
   fi

   if [ -z "$VIVLOWVERSION" ]; then
      export VIVLOWVERSION="4.0"
   fi

   if [ -z "$VIVHIGHVERSION" ]; then
      export VIVHIGHVERSION="$VIVVERSION"
   fi

   if [ -z "$VIVERRORREPORT" ]; then
      export VIVERRORREPORT="True"
   fi

   xx=`versionrunrange`

   if [ $xx -ne 0 ]; then
      echo "Version $VIVVERSION is not in the range of $VIVLOWVERSION to $VIVHIGHVERSION"
      echo "Quitting with a pass since this should not run here"
      exit 0
   fi

   echo
   echo "Version $VIVVERSION is in the range of $VIVLOWVERSION to $VIVHIGHVERSION, Continuing ..."
   echo


   if [ -z "$VIVWORKINGDIR" ]; then
      export VIVWORKINGDIR="querywork"
   fi

   if [ -z "$VIVDEFCONVERT" ]; then
      export VIVDEFCONVERT="false"
   fi

   MajV=`getmajorversion`
   MinV=`getminorversion`

   FullV="$MajV.$MinV"

   #############################################
   #
   #   Check that the test can run with the target environment
   #   The default is to run on all targets
   #
   if [ -z "$VIVRUNTARGET" ]; then
      export VIVRUNTARGET="windows32 windows64 linux32 linux64 solaris32 solaris64 linux windows solaris"
   fi

   rtfound=0
   if [ -z "$VIVTARGETARCH" ]; then
      if [ -z "$VIVTARGETOS" ]; then
         rtfound=1
      fi
   fi

   if [ $rtfound -eq 0 ]; then
      if [ ! -z "$VIVTARGETARCH" ]; then
         for item in $VIVRUNTARGET; do
            if [ "$item" == "$VIVTARGETARCH" ]; then
               rtfound=1
            fi
         done
      fi
   fi

   if [ $rtfound -eq 0 ]; then
      if [ ! -z "$VIVTARGETOS" ]; then
         for item in $VIVRUNTARGET; do
            if [ "$item" == "$VIVTARGETOS" ]; then
               rtfound=1
            fi
         done
      fi
   fi

   if [ $rtfound -eq 0 ]; then
      echo "Target architecture does not match allowed run targets"
      echo "The test will exit as failing since it is not supposed to run"
      exit 1
   fi
   #
   #   End of environment check
   #
   ########################################################

   if [ ! -z "$VIVHOST" ]; then
      if [ "$VIVHOST" != "" ]; then
         ping -c 1 $VIVHOST
         status=$?
         if [ $status -gt 0 ]; then
            echo "$VIVHOST is not up.  Exiting"
            exit $status
         fi
      fi
   else
      echo "VIVHOST is not set.  Exiting"
      exit $status
   fi

   if [ ! -z "$TARGETHOST" ]; then
      if [ "$TARGETHOST" != "" ]; then
         ping -c 3 $TARGETHOST
         status=$?
         if [ $status -gt 0 ]; then
            echo "$TARGETHOST is not up.  Exiting"
            exit $status
         fi
      fi
   fi

   echo "Test begins ..."

   svcnt=`get_service_pid_count -S query-all`
   if [ "$svcnt" -lt 2 ]; then
      echo "Query service is not running correctly, attempting to restart."
      #
      #   Stop whatever query service is running
      #
      stop_query_service

      #
      #   Find any leftover query services (if possible)
      #
      xx=`get_service_pid_list -S query-all`

      #
      #   If there are any leftover query services, kill them
      #
      for item in $xx; do
         #
         #   hard kill of the service
         #
         kill_service_children -S supplied -p $item
      done
      sleep 1

      #
      #   Restart the query service
      #
      start_query_service
   fi
   query_pid_count=`get_service_pid_count -S query-all`
   if [ "$query_pid_count" -ge 2 ]; then
      echo "Query service is OK"
   else
      echo "Query service is not OK"
   fi

   mydir=`pwd`
   getversionfiles -D $mydir

}

error_report()
{
   echo "### ERROR MESSAGE REPORT (BEGIN) ##################"
   casecount=`expr $casecount + 1`
   echo ""
   if [ ! -z "$VIVERRIGN" ]; then
      echo ""
      echo "For PASS/FAIL purposes, errors with the following id(s):"
      echo "$VIVERRIGN"
      echo "have been ignored"
   fi
   if [ ! -z "$VIVSYSERRIGN" ]; then
      echo ""
      echo "For PASS/FAIL purposes, errors from the following service(s):"
      echo "$VIVSYSERRIGN"
      echo "have been ignored"
   fi
   gcse -C $1
   errs=$?
   echo "SYSTEM ERRORS OF errors-high:   $errs"
   echo ""

   if [ $errs -ne 0 ]; then
      results=`expr $results + 1`
   fi

   echo "### ERROR MESSAGE REPORT (END) ####################"
   return
}

getmajorversion()
{
   if [ -z "$1" ]; then
      AA=`echo $VIVVERSION | cut -f 1 -d '.'`
   else
      AA=`echo $1 | cut -f 1 -d '.'`
   fi

   echo $AA

   return
}

getminorversion()
{
   if [ -z "$1" ]; then
      AA=`echo $VIVVERSION | cut -f 2 -d '.'`
   else
      AA=`echo $1 | cut -f 2 -d '.'`
   fi

   BB=`echo $AA | sed 's/0//'`

   if [ "$BB" == "$AA" ]; then
      echo ${AA}0
   else
      echo ${AA}
   fi

   return
}

versionrunrange()
{
   MajV=`getmajorversion`
   MinV=`getminorversion`

   MajL=`getmajorversion $VIVLOWVERSION`
   MinL=`getminorversion $VIVLOWVERSION`

   MajH=`getmajorversion $VIVHIGHVERSION`
   MinH=`getminorversion $VIVHIGHVERSION`

   #echo "$MajV.$MinV   $MajH.$MinH   $MajL.$MinL"

   if [ $MajH -lt $MajL ]; then
      #echo "min($VIVLOWVERSION) higher than max($VIVHIGHVERSION)"
      echo 5
      return
   fi

   if [ $MajV -gt $MajH ]; then
      #echo "$VIVVERSION higher than max($VIVHIGHVERSION)"
      echo 1
      return
   fi

   if [ $MajV -gt $MajL ]; then
      #echo "$VIVVERSION higher than min($VIVHIGHVERSION)"
      echo 0
      return
   fi

   if [ $MajV -lt $MajL ]; then
      #echo "$VIVVERSION lower than min($VIVLOWVERSION)"
      echo 2
      return
   fi

   if [ $MinV -gt $MinH ]; then
      #echo "$VIVVERSION higher than max($VIVHIGHVERSION)"
      echo 3
      return
   fi

   if [ $MinV -lt $MinL ]; then
      #echo "$VIVVERSION lower than min($VIVLOWVERSION)"
      echo 4
      return
   fi

   echo 0
   return
}


version60()
{
   qq=`getmajorversion`

   if [ "$qq" -lt "6" ]; then
      echo "Test not valid for version older than 6.0"
      exit 0
   fi
}

version56()
{
   qq=`getmajorversion`

   if [ "$qq" -gt "5" ]; then
      echo "Test not valid for version newer than 5.6"
      exit 0
   fi
}

test_footer()
{
#####################################################################

###
#   This defines the standard PASS/FAIL output for all of the
#   crawl/query tests.
###

#echo "$1 $2 $3 $4 $5 $6"

if [ "$VIVERRORREPORT" == "True" ]; then
   error_report $1
fi

if [ "$VIVDELETE" == "" ]; then
   VIVDELETE="pass"
fi

final_check $1

if [ $results -eq 0 ]; then
   echo "TEST RESULT FOR $1:  Test Passed"
   stop_crawler -C $1 -H $4 -U $5 -P $6
   stop_indexing -C $1 -H $4 -U $5 -P $6
   if [ "$VIVDELETE" == "pass" ] || [ "$VIVDELETE" == "all" ]; then
      delete_collection -f -C $1 -H $4 -U $5 -P $6
   fi
   exit 0
fi

echo "TEST RESULT FOR $1:  Test Failed"
echo "$1:  $2 of $3 cases failed"
stop_crawler -C $1 -H $4 -U $5 -P $6
stop_indexing -C $1 -H $4 -U $5 -P $6
if [ "$VIVDELETE" == "all" ] || [ "$VIVDELETE" == "fail" ]; then
   delete_collection -f -C $1 -H $4 -U $5 -P $6
fi
kill_all_services
kill_all_services
exit 1

#####################################################################
}


cleanup()
{

   collection_exists -C $2 -H $1 -U $3 -P $4
   x=$?

   if [ $x -eq 1 ]; then

      if [ "$TARGETOS" != "windows" ] && [ "$VIVTARGETOS" != "windows" ]; then
         echo "delete_collection -C $2 -H $1 -U $3 -P $4"
         delete_collection -f -C $2 -H $1 -U $3 -P $4
         x=$?

         if [ -f $2.delcol ]; then
            mv $2.delcol logs/$2.delcol
         fi
         if [ -f $2.delcollog ]; then
            mv $2.delcollog logs/$2.delcollog
         fi

      fi
      if [ $x -eq 1 ]; then
         echo "Unable to delete an older version of the $2 collection"
         echo "Using alternate means ..."
         delete_collection -f -C $2 -H $1 -U $3 -P $4 -f
         x=$?

         if [ -f $2.delcol ]; then
            mv $2.delcol logs/$2.delcol
         fi
         if [ -f $2.delcollog ]; then
            mv $2.delcollog logs/$2.delcollog
         fi

         if [ $x -eq 1 ]; then
            echo "Collection was not deleted"
            exit 1
         fi
      fi
   fi
}

setup_no_wait()
{
   if [ "$VIVDEFCONVERT" == "true" ]; then
      echo "create_collection -C $2 -H $1 -u"
      create_collection -C $2 -H $1 -u
      x=$?
   else
      echo "create_collection -C $2 -H $1"
      create_collection -C $2 -H $1
      x=$?
   fi

   if [ $x -ne 0 ]; then
      echo "Could not create $2 collection"
      exit 1
   fi

   if [ -z "$VIVSTARTTIME" ]; then
      stime=`date +%s`
      export VIVSTARTTIME=$stime
   fi

   echo "start_crawl -C $2 -H $1 -U $3 -P $4"
   start_crawl -C $2 -H $1 -U $3 -P $4
   if [ -f $2.crwlout ]; then
      mv $2.crwlout logs/$2.crwlout
   fi
   if [ -f $2.crwllog ]; then
      mv $2.crwllog logs/$2.crwllog
   fi

   echo "Crawl started, setup complete"
}

setup()
{

   if [ "$VIVDEFCONVERT" == "true" ]; then
      echo "create_collection -C $2 -H $1 -u"
      create_collection -C $2 -H $1 -u
      x=$?
   else
      echo "create_collection -C $2 -H $1"
      create_collection -C $2 -H $1
      x=$?
   fi

   if [ $x -ne 0 ]; then
      echo "Could not create $2 collection"
      exit 1
   fi

   if [ -z "$VIVSTARTTIME" ]; then
      stime=`date +%s`
      export VIVSTARTTIME=$stime
   fi

   echo "start_crawl -C $2 -H $1 -U $3 -P $4"
   start_crawl -C $2 -H $1 -U $3 -P $4
   if [ -f $2.crwlout ]; then
      mv $2.crwlout logs/$2.crwlout
   fi
   if [ -f $2.crwllog ]; then
      mv $2.crwllog logs/$2.crwllog
   fi

   wait_for_idle -C $2 -H $1 -U $3 -P $4

   echo "Crawl/index complete, setup complete"

}

setup_max_time()
{
   if [ "$VIVDEFCONVERT" == "true" ]; then
      echo "create_collection -C $2 -H $1 -u"
      create_collection -C $2 -H $1 -u
      x=$?
   else
      echo "create_collection -C $2 -H $1"
      create_collection -C $2 -H $1
      x=$?
   fi

   if [ $x -ne 0 ]; then
      echo "Could not create $2 collection"
      exit 1
   fi

   if [ -z "$VIVSTARTTIME" ]; then
      stime=`date +%s`
      export VIVSTARTTIME=$stime
   fi

   echo "start_crawl -C $2 -H $1 -U $3 -P $4"
   start_crawl -C $2 -H $1 -U $3 -P $4
   if [ -f $2.crwlout ]; then
      mv $2.crwlout logs/$2.crwlout
   fi
   if [ -f $2.crwllog ]; then
      mv $2.crwllog logs/$2.crwllog
   fi

   wait_for_idle -C $2 -H $1 -U $3 -P $4 -t $5
   ender=$?
   eval "$6=$ender"

   if [ $ender -gt 0 ]; then
      echo "Crawl/index complete, setup killed.  Time limit exceeded."
      if [ -f $2.stpclog ]; then
         mv $2.stpclog querywork/$2.stpclog
      fi
      if [ -f $2.stpcout ]; then
         mv $2.stpcout querywork/$2.stpcout
      fi
   else
      echo "Crawl/index complete, setup complete"
   fi
}

getsetopts()
{

   OPTERR=0
   OPTIND=1

   while getopts "T:H:U:P:p:" flag; do
     case "$flag" in
        H) SHOST=$OPTARG;;
        U) VUSER=$OPTARG;;
        P) VPW=$OPTARG;;
        T) TARGETOS=$OPTARG;;
        p) VPORT=$OPTARG;;
        *) echo "Usage: $VCOLLECTION.tst -H <host> -U <user> -P <password> -p <port>"
           exit 1;;
     esac
   done

   if [ "$VUSER" == "" ]; then
      echo "Vivisimo username is needed"
      echo "Either set VIVUSER environment variable or"
      echo "use the -U <vivuser> option"
      exit 1
   fi

   if [ "$VPW" == "" ]; then
      echo "Vivisimo password is needed"
      echo "Either set VIVPW environment variable or"
      echo "use the -P <vivpassword> option"
      exit 1
   fi

   if [ "$SHOST" == "" ]; then
      echo "Target host needed"
      echo "Either set VIVHOST environment variable or"
      echo "use the -H <host> option"
      exit 1
   fi

   if [ "$VPORT" == "" ]; then
      echo "Target port needed"
      echo "Either set VIVPORT environment variable or"
      echo "use the -p <port> option"
      exit 1
   fi

   export VIVHOST=$SHOST
   export VIVUSER=$VUSER
   export VIVPW=$VPW
   export VIVPORT=$VPORT
   export VIVTARGETOS=$TARGETOS

}

xslvalue()
{
   value=$4
   outlines=0
   tfile=`mktemp -p /tmp xslXXXXXXXX`
   #rm -f /tmp/xslvalue.grep.tmp
   xsltproc $2 $3 > $tfile
   if [ $? -eq 0 ]; then
      if [ -f $tfile ]; then
         outlines=`stat -c "%s" $tfile`
         if [ $outlines -gt 0 ]; then
            value=`grep -v xml $tfile`
            rm -f $tfile
         else
            value=$4
         fi
      else
         echo "No XML file"
         value=$4
      fi
   else
      echo "Bad XML file: $3"
      value=$4
   fi

   eval "$1=$value"
}

get_valid_index()
{

   xslvalue indexvalid_new $TEST_ROOT/utils/xsl/valid_index_docs.xsl querywork/$2.xml.run -1

   eval "$1=$indexvalid_new"
}

crawl_check_fixed_vals()
{

   #
   #   should possibly move this chunk of code to
   #   another location, perhaps in get_collection
   #
   retry=0
   found=0
   mkdir -p querywork
   if [ $4 -eq 1 ]; then
      while [ $retry -lt 3 ];do
         #
         #   This sleep is to allow the stats on the target
         #   to be updated before we get the collection and
         #   check the data.
         #
         sleep 2
         get_collection -C $2 -H $1
         if [ -f $2.xml.run ]; then
            echo "$2.xml.run was found"
            found=1
            mv $2.xml.run querywork/$2.xml.run
            retry=3
         else
            echo "$2.xml.run was NOT found"
            found=0
            retry=`expr $retry + 1`
         fi
      done
   fi
   casecount=`expr $casecount + 5`

   if [ $found -eq 0 ]; then
      echo "querywork/$2.xml.run could not be created, file not found"
   fi

   if [ -f querywork/$2.xml.run ]; then

      xslvalue crawlerr_new $TEST_ROOT/utils/xsl/crawl_errors.xsl querywork/$2.xml.run -1
      xslvalue crawlerr_old $TEST_ROOT/utils/xsl/crawl_errors.xsl $2.xml.stats -4

      xslvalue crawlout_new $TEST_ROOT/utils/xsl/crawl_output.xsl querywork/$2.xml.run -1
      xslvalue crawlout_old $TEST_ROOT/utils/xsl/crawl_output.xsl $2.xml.stats -4

      xslvalue crawldup_new $TEST_ROOT/utils/xsl/crawl_dups.xsl querywork/$2.xml.run -1
      xslvalue crawldup_old $TEST_ROOT/utils/xsl/crawl_dups.xsl $2.xml.stats -4

      xslvalue indexvalid_new $TEST_ROOT/utils/xsl/valid_index_docs.xsl querywork/$2.xml.run -1
      xslvalue indexvalid_old $TEST_ROOT/utils/xsl/valid_index_docs.xsl $2.xml.stats -4

      if [ $indexvalid_new -ne $indexvalid_old ]; then
         results=`expr $results + 1`
         echo "index check:  valid index documents disagree. Saw: $indexvalid_new, expected: $indexvalid_old"
      else
         echo "index check:  valid index documents OK"
      fi

      if [ $crawlerr_new -ne $crawlerr_old ]; then
         results=`expr $results + 1`
         echo "crawl check:  crawl errors disagree. Saw: $crawlerr_new, expected: $crawlerr_old"
      else
         echo "crawl check:  crawl errors OK"
      fi
      if [ $crawldup_new -ne $crawldup_old ]; then
         results=`expr $results + 1`
         echo "crawl check:  crawl duplicates disagree. Saw: $crawldup_new, expected: $crawldup_old"
      else
         echo "crawl check:  crawl duplicates OK"
      fi
      if [ $crawlout_new -ne $crawlout_old ]; then
         if [ $5 -eq 1 ]; then
            results=`expr $results + 1`
            echo "crawl check:  crawl outputs disagree. Saw: $crawlout_new, expected: $crawlout_old"
         else
            echo "WARNING: crawl check:  crawl outputs disagree. Saw: $crawlout_new, expected: $crawlout_old"
         fi
      else
         echo "crawl check:  crawl outputs OK"
      fi

   else
      results=`expr $results + 3`
   fi

}

crawl_check2()
{

   #
   #   should possibly move this chunk of code to
   #   another location, perhaps in get_collection
   #
   retry=0
   mkdir -p querywork
   if [ $4 -eq 1 ]; then
      while [ $retry -lt 3 ];do
         #
         #   This sleep is to allow the stats on the target
         #   to be updated before we get the collection and
         #   check the data.
         #
         sleep 2
         get_collection -C $2 -H $1
         if [ -f $2.xml.run ]; then
            mv $2.xml.run querywork/$2.xml.run
            retry=3
         else
            retry=`expr $retry + 1`
         fi
      done
   fi
   casecount=`expr $casecount + 4`

   if [ -f querywork/$2.xml.run ]; then

      xslvalue crawlerr_new $TEST_ROOT/utils/xsl/crawl_errors.xsl querywork/$2.xml.run -1
      xslvalue crawlerr_old $TEST_ROOT/utils/xsl/crawl_errors.xsl $2.xml.stats -4

      xslvalue crawlout_new $TEST_ROOT/utils/xsl/crawl_output.xsl querywork/$2.xml.run -1
      xslvalue crawlout_old $TEST_ROOT/utils/xsl/crawl_output.xsl $2.xml.stats -4

      xslvalue crawldup_new $TEST_ROOT/utils/xsl/crawl_dups.xsl querywork/$2.xml.run -1
      xslvalue crawldup_old $TEST_ROOT/utils/xsl/crawl_dups.xsl $2.xml.stats -4

      xslvalue indexdocs_new $TEST_ROOT/utils/xsl/index_docs.xsl querywork/$2.xml.run -1
      xslvalue indexdocs_old $TEST_ROOT/utils/xsl/index_docs.xsl $2.xml.stats -4

      xslvalue indexcont_new $TEST_ROOT/utils/xsl/index_content.xsl querywork/$2.xml.run -1
      xslvalue indexcont_old $TEST_ROOT/utils/xsl/index_content.xsl $2.xml.stats -4

      xslvalue indexvalid_new $TEST_ROOT/utils/xsl/valid_index_docs.xsl querywork/$2.xml.run -1
      xslvalue indexvalid_old $TEST_ROOT/utils/xsl/valid_index_docs.xsl $2.xml.stats -4

      if [ $indexvalid_new -ne $indexvalid_old ]; then
         results=`expr $results + 1`
         echo "index check:  valid index documents disagree. Saw: $indexvalid_new, expected: $indexvalid_old"
      else
         echo "index check:  valid index documents OK"
      fi

      if [ $indexdocs_new -ne $indexdocs_old ]; then
         #
         #   Refresh flag.  0 is valid for documents indexed.
         #
         if [ $3 -eq 0 ]; then
            results=`expr $results + 1`
            echo "crawl check:  index documents disagree. Saw: $indexdocs_new, expected: $indexdocs_old"
         else
            echo "WARNING: crawl check:  index documents disagree. Saw: $indexdocs_new, expected: $indexdocs_old"
         fi
      else
         echo "crawl check:  index documents OK"
      fi

      if [ $crawlerr_new -ne $crawlerr_old ]; then
         results=`expr $results + 1`
         echo "crawl check:  crawl errors disagree. Saw: $crawlerr_new, expected: $crawlerr_old"
      else
         echo "crawl check:  crawl errors OK"
      fi
      if [ $crawldup_new -ne $crawldup_old ]; then
         results=`expr $results + 1`
         echo "crawl check:  crawl duplicates disagree. Saw: $crawldup_new, expected: $crawldup_old"
      else
         echo "crawl check:  crawl duplicates OK"
      fi
      if [ $crawlout_new -ne $crawlout_old ]; then
         if [ $5 -eq 1 ]; then
            results=`expr $results + 1`
            echo "crawl check:  crawl outputs disagree. Saw: $crawlout_new, expected: $crawlout_old"
         else
            echo "WARNING: crawl check:  crawl outputs disagree. Saw: $crawlout_new, expected: $crawlout_old"
         fi
      else
         echo "crawl check:  crawl outputs OK"
      fi
      if [ $indexcont_new -ne $indexcont_old ]; then
         if [ $5 -eq 1 ]; then
            results=`expr $results + 1`
            echo "crawl check:  index counts disagree. Saw: $indexcont_new, expected: $indexcont_old"
         else
            echo "WARNING: crawl check:  index counts disagree. Saw: $indexcont_new, expected: $indexcont_old"
         fi
      else
         echo "crawl check:  index counts OK"
      fi

   else
      results=`expr $results + 3`
   fi

}

final_check()
{
   if [ "$TARGETOS" != "windows" ] && [ "$VIVTARGETOS" != "windows" ]; then
      echo "CORE check ..."
      casecount=`expr $casecount + 1`
      collname=`find_collection_core -C $1`
      if [ "$collname" != "" ]; then
         nnn=`basename $collname`
         if [ "$nnn" != "core.xml" ]; then
            echo "Core file found for collection $1"
            echo "Core name:  $collname"
            results=`expr $results + 1`
         fi
      fi
   fi
   casecount=`expr $casecount + 1`
   echo "Query service check ..."
   svcnt=`get_service_pid_count -S query-all`
   if [ "$svcnt" -ne 2 ]; then
      if [ "$svcnt" -ne $query_pid_count ]; then
         echo "Query service is not running correctly"
         results=`expr $results + 1`
      fi
   fi

   return
}

crawl_check_nv()
{
   refr=0
   getr=1
   strict=0

   if [ "$3" == "refresh" ]; then
      refr=1
   fi
   if [ "$4" == "noget" ]; then
      getr=0
   fi

   if [ "$5" == "strict" ]; then
      strict=1
   fi

   crawl_check_fixed_vals $1 $2 $refr $getr $strict
   return

}

crawl_check()
{
   refr=0
   getr=1
   strict=0

   if [ "$3" == "refresh" ]; then
      refr=1
   fi
   if [ "$4" == "noget" ]; then
      getr=0
   fi

   if [ "$5" == "strict" ]; then
      strict=1
   fi

   crawl_check2 $1 $2 $refr $getr $strict
   return

}
