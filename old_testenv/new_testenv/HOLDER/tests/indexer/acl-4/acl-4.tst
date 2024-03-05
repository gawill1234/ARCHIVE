#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="acl-4"
   DESCRIPTION="Duplicate content line with different acl"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

filecheck()
{
   echo "#######################"
   echo "Check of file $1"
   #
   #   Did we get the file?
   #
   if [ ! -f $1 ]; then
      echo "Failed to get the file."
      exit 1
   else
      echo "Got file $1."
   fi

   #
   #   Is our file readable?
   #
   if [ ! -r $1 ]; then
      echo "File $1 is not readable, attempting chmod"
      chmod 644 $1
      if [ ! -r $1 ]; then
         echo "File $1 is still not readable"
         echo "$VCOLLECTION:  Test Failed"
         exit 1
      else
         echo "File $1 is now readable."
      fi
   else
      echo "File $1 is readable."
   fi

   #
   #   Does the file contain data?
   #
   localsize=`stat -c "%s" $1`
   if [ $localsize -le 0 ]; then
      echo "File $1 has no data in it"
      echo "$VCOLLECTION:  Test Failed"
      exit 1
   else
      echo "Size of file $1 OK at $localsize"
   fi
   echo "Check of $1 complete"
   echo "#######################"
}

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

#
#  Default version to 6.0 or greater
#
if [ -z "$VIVVERSION" ]; then
   export VIVVERSION="6.0"
fi

majorversion=`getmajorversion`

source_file="$VCOLLECTION.index.snippet"

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

dump_index -C $VCOLLECTION

filecheck $VCOLLECTION.index

casecount=`expr $casecount + 1`
if [ -f $VCOLLECTION.index ]; then
   mv $VCOLLECTION.index querywork/$VCOLLECTION.index
   grep -i "content" querywork/$VCOLLECTION.index | grep -i "acl" > querywork/$VCOLLECTION.index.snippet
   diff -w query_cmp_files/$source_file querywork/$VCOLLECTION.index.snippet > querywork/index.snippet.diff
   difx=$?

   if [ $difx -ne 0 ]; then
      echo "   ACL indices differ"
      results=`expr $results + 1`
   fi
else
   results=`expr $results + 1`
fi

source $TEST_ROOT/lib/run_std_results.sh
