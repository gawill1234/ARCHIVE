#!/bin/bash

#####################################################################
#
#   Original output.  This is the output from what was deemed to
#   to be a working repository (FYI):
#
#  TEMPLATES CALLED BUT NEVER DEFINED (ERROR):
#     missing template:  js-flash-charts
#     missing template:  js-query-saving
#     missing template:  js-flash-charts
#     missing template:  js-query-saving
#     missing template:  printer-friendly-header-text
#  TEMPLATES DEFINED BUT NEVER CALLED (INFO ONLY):
#     None found
#

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="template-check"
   DESCRIPTION="Make sure called repository templates exist"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

MajV=`getmajorversion`

if [ $MajV -ge 7 ]; then
   get_repository -I
   valid_repo -f repository-internal.xml
   xx=$?
else
   get_repository
   valid_repo -f repository.xml
   xx=$?
fi

if [ $xx -eq 0 ]; then
   echo "template-check:  Test Passed"
   exit 0
fi

echo "template-check:  $xx problems found"
echo "template-check:  Test Failed"
exit 1


