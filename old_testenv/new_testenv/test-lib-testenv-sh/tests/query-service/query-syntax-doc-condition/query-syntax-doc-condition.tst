#!/bin/bash

#####################################################################

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

##  pre-requisite: This test can only run on 7.0+
#
   TNAME="query-syntax-doc-condition"
   VCOLLECTION="samba-stress"
   VSOURCE="samba-stress"
   DESCRIPTION="This test exercises the (advanced) global document condition and the one listed under field mappings (*) in the source vse-form. It can only be run on 7.0+"
###

export VIVLOWVERSION="7.0"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

run_case()
{
   echo "########################################"
   echo "Case $1:  $2 using $VSOURCE"
   run_query -S "$VSOURCE" -O querywork/rq$1.res -Q "$2" -n 10000
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

#####################################################################
test_header $TNAME $DESCRIPTION

majorversion=`getmajorversion`

if [ "$majorversion" -lt "7" ]; then
   echo "Test not valid for version older than 7.0"
   exit 0
fi

sed -i s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_USER/${VIV_SAMBA_LINUX_USER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_PASSWORD/${VIV_SAMBA_LINUX_PASSWORD}/g ${VCOLLECTION}.xml
sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${VCOLLECTION}.xml

#
#   Check if samba-stress collection exists.  If it does not, run the crawl.
#   If it does, skip this section and move directly to the queries.
#
collection_exists -C $VCOLLECTION
exst=$?

if [ $exst -eq 0 ]; then
   source $TEST_ROOT/lib/run_std_setup.sh
   crawl_check $SHOST $VCOLLECTION
else
   build_index -C $VCOLLECTION
   resume_crawl -C $VCOLLECTION
   wait_for_idle -C $VCOLLECTION
fi

#backuprepo="query-syntax-doc-condition.repo.bk"
vdir=`vivisimo_dir -d data`
#delete_file -F $vdir\\$backuprepo

#backup_repository -S $backuprepo

## Adding modified sources to the repository temporarily
repository_update -F query-size.xml.raw -N
repository_import -F samba-stress-doc1.xml.raw -N
repository_import -F samba-stress-doc2.xml.raw -N
repository_import -F samba-stress-doc3.xml.raw -N
repository_import -F samba-stress-doc4.xml.raw -N
repository_import -F samba-stress-doc5.xml.raw -N
repository_import -F samba-stress-doc6.xml.raw -N
repository_import -F samba-stress-6.0.xml.raw -N

for file in query_cmp_files/r*
do
   echo "Updating file ${file}"
   sed -i s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${file}
   sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${file}
done


stime=`date +%s`
export VIVSTARTTIME=$stime
casecount=`expr $casecount + 10`

run_case 1 run

# run filetype:xml (source should have *filetype instead of filetype, verify)
run_case 2 "run%20filetype%3Axml"

# ranking should be different, verify
#######################################
VSOURCE="samba-stress-6.0" # filetype (no *)
# run filetype:xml
run_case 3 "run%20filetype%3Axml"

#abuelita language:spanish
run_case 4 "abuelita%20language%3Aspanish"

run_case 5 velocity

#############################
VSOURCE="samba-stress-doc1" # adds: doc-condition-xml=filetype:xml
# (should be the same as the field mapping)
run_case 6 velocity

run_case 7 run

#############################
VSOURCE="samba-stress-doc2" # adds: doc-condition-xml=language:+spanish
run_case 8 abuelita

#############################
VSOURCE="samba-stress-doc3" # adds: doc-condition-xml=(language:spanish) OR (language:french)
run_case 9 abuelita

#############################
VSOURCE="samba-stress-doc4" # adds: doc-condition-xml=language:-english
run_case 10 abuelita

#############################
VSOURCE="samba-stress-doc5" # adds: (language:-english) AND (language:-french)
run_case 11 abuelita

#############################
VSOURCE="samba-stress-doc6" # adds: * in front of language in field-mappings making it into a doc-condition
# needs to be the same num of res as in case 4 above
# abuelita language:spanish
run_case 12 "abuelita%20language%3Aspanish"

repository_delete -t options -n query-meta
repository_delete -t source -n samba-stress-doc1
repository_delete -t source -n samba-stress-doc2
repository_delete -t source -n samba-stress-doc3
repository_delete -t source -n samba-stress-doc4
repository_delete -t source -n samba-stress-doc5
repository_delete -t source -n samba-stress-doc6
repository_delete -t source -n samba-stress-6.0

# Get rid of all the modified sources
#restore_repository -S $backuprepo
#delete_repository -S $backuprepo

export VIVKILLALL="False"
export VIVDELETE="none"
rm samba-stress.xml
rm query_cmp_files/r*
source $TEST_ROOT/lib/run_std_results.sh
