#!/bin/bash

#####################################################################
#
###
#   This defines the standard PASS/FAIL output for all of the
#   crawl/query tests.
###
#
#if [ $results -eq 0 ]; then
#   echo "$VCOLLECTION:  Test Passed"
#   exit 0
#fi
#
#echo "$VCOLLECTION:  Test Failed"
#echo "$VCOLLECTION:  $results of $casecount cases failed"
#exit 1
#
#####################################################################

test_footer $VCOLLECTION $results $casecount $SHOST $VUSER $VPW
