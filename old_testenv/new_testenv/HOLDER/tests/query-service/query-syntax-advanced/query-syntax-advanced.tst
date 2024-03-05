#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

#
#   This test exercises different advanced query syntax operators
#   In particular: BEFORE, FOLLOWEDBY, NOTWITHIN, CONTAINING, CONTENT, +, -, 
#   THRU, WITHIN and WORDS
#   the last see also in query-syntax-2 exercises
#     (hazard THRU emolument) WITHIN 7 WORDS

   TNAME="query-syntax-advanced"
   VCOLLECTION="samba-stress"
   VSOURCE="samba-stress"
   DESCRIPTION="This test exercises advanced query syntax operators."
###

export VIVLOWVERSION="7.0"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

run_case() 
{
   echo "########################################"
   echo "Case $1:  $2"
   run_query -S $VCOLLECTION -O querywork/rq$1.res -Q "$2" -n 5000
   url_count -F querywork/rq$1.res > querywork/rq$1.uri
   sort_query_urls -F querywork/rq$1.res >> querywork/rq$1.uri
   diff query_cmp_files/rq$1.cmp querywork/rq$1.uri > querywork/rq$1.diff
   x=$?
   if [ $x -eq 0 ]; then
      echo "Case $1:  Test Passed"
   else
      echo "Case $1:  Test Failed"
   fi
   echo "########################################"
   results=`expr $results + $x`
}

collection_check()
{  

   ccol=$1
   dcr=$2

   echo "query-syntax-advanced:  Checking collection $ccol"
   collection_exists -C $ccol
   exst=$?

   if [ $exst -eq 0 ]; then
      #
      #   Check for the existence of the file system on the target
      #

      restore_collection -C $ccol

      #if [ $dcr -eq 1 ]; then
      #   source $TEST_ROOT/lib/run_std_setup.sh
      #else
      #   start_crawl -C $ccol
      #   wait_for_idle -C $ccol
      #fi

      collection_exists -C $ccol
      exst=$?

      if [ $exst -eq 0 ]; then
         echo "query-syntax-advanced:  Collection missing: $ccol."
         echo "query-syntax-advanced:  Test Failed."
         exit 1
      fi

      #crawl_check $SHOST $ccol
   else
      build_index -C $ccol
      resume_crawl -C $ccol
      wait_for_idle -C $ccol
   fi
   wait_for_idle -C $ccol
}



#####################################################################
test_header $TNAME $DESCRIPTION $VSOURCE

majorversion=`getmajorversion`

if [ "$majorversion" -lt "7" ]; then
   echo "Test not valid for version older than 7.0"
   exit 0
fi

#
#   Check if samba-stress collection exists.  If it does not, run the crawl.
#   If it does, skip this section and move directly to the queries.
#
collection_check $VCOLLECTION 1

stime=`date +%s`
export VIVSTARTTIME=$stime
casecount=`expr $casecount + 19`

#backuprepo="query-syntax-advance.repo.bk"
vdir=`vivisimo_dir -d data`

#delete_file -F $vdir\\$backuprepo

#repository_import -F query-size.xml.raw -S $backuprepo

#   function basic_query_test
#   args are test number, host, collection, query string

# The first time, need to run basic_query_test to get the xml.cmp files
# what since that takes the collection, how is that going to work when the src has been modified?
#   function basic_query_test
#   args are test number, host, collection, query string


# exact content match
#######################
# constitution appears by itself as well as followed by other words in the title

# CONTENT title CONTAINING "constitution"
run_case 1 "CONTENT%20title%20CONTAINING%20%22constitution%22"

# title:constitution
run_case 2 "title%3Aconstitution"

# ranks based on constitution (not the whole title)
# "constitution" WITHIN (CONTENT title NOTCONTAINING (("constitution" THRU 1 WORDS) OR (2 WORDS THRU "constitution")))
run_case 3 "%22constitution%22%20WITHIN%20%28CONTENT%20title%20NOTCONTAINING%20%28%28%22constitution%22%20THRU%201%20WORDS%29%20OR%20%282%20WORDS%20THRU%20%22constitution%22%29%29%29"

# "constitution" WITHIN CONTENT title -("constitution" THRU 1 WORDS WITHIN CONTENT title) -(2 WORDS THRU "constitution" WITHIN CONTENT title)
run_case 4 "%22constitution%22%20WITHIN%20CONTENT%20title%20-%28%22constitution%22%20THRU%201%20WORDS%20WITHIN%20CONTENT%20title%29%20-%282%20WORDS%20THRU%20%22constitution%22%20WITHIN%20CONTENT%20title%29"

#less recommended alternative, ranks by the whole tile
# (CONTENT title CONTAINING "constitution") NOTCONTAINING (("constitution" THRU 1 WORDS) OR (2 WORDS THRU "constitution"))
run_case 5 "%28CONTENT%20title%20CONTAINING%20%22constitution%22%29%20NOTCONTAINING%20%28%28%22constitution%22%20THRU%201%20WORDS%29%20OR%20%282%20WORDS%20THRU%20%22constitution%22%29%29"

# velocity THRU data   
run_case 6 "velocity%20THRU%20data"

# velocity BEFORE data
run_case 7 "velocity%20BEFORE%20data"

# velocity FOLLOWEDBY data
run_case 8 "velocity%20FOLLOWEDBY%20data"

# implementation NOTWITHIN CONTENT title
run_case 9 "implementation%20NOTWITHIN%20CONTENT%20title"

# -title:implementation
run_case 10 "-title%3Aimplementation"

# implementation NOTWITHIN CONTENT snippet
run_case 11 "implementation%20NOTWITHIN%20CONTENT%20snippet"

# (document THRU clustering) CONTAINING vivisimo
#run_case 12 "%28document%20THRU%20clustering%29%20CONTAINING%20vivisimo"

# document THRU vivisimo THRU clustering
#run_case 13 "document%20THRU%20vivisimo%20THRU%20clustering"

# document BEFORE clustering WITHIN 10 WORDS
run_case 14 "document%20BEFORE%20clustering%20WITHIN%2010%20WORDS"

# document BEFORE 10 WORDS BEFORE clustering WITHIN CONTENT snippet  
run_case 15 "document%20BEFORE%2010%20WORDS%20BEFORE%20clustering%20WITHIN%20CONTENT%20snippet"

# WORDS BEFORE clustering NOTCONTAINING document
run_case 16 "WORDS%20BEFORE%20clustering%20NOTCONTAINING%20document"

# clustering -"document clustering"
run_case 17 "clustering%20-%22document%20clustering%22"

# clustering -document
run_case 18 "clustering%20-document"

# clustering NOT document
run_case 19 "clustering%20NOT%20document"

#restore_repository -S $backuprepo
#delete_repository -S $backuprepo

export VIVKILLALL="False"
export VIVDELETE="none"

source $TEST_ROOT/lib/run_std_results.sh
