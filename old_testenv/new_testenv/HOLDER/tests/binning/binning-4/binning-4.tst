#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="binning-4"
   DESCRIPTION="simple oracle crawl and search with nested binning sets"

###
#
#  Steps to reproduce
#
#  1. Edit the live source for the collection and in the VSE Source Form
#       rights field enter: <value-of-var name="rights" realm="param"/>
#  2. Search the collection with a null query
#  3. Click on the Destroyer bin then click on the Japan sub bin. There
#       should be 3 results and if you look at the xml you will see that
#	the acl for the NATION contents which this bin is based on is
#	"-gillin everyone"
#   4. Add rights=everyone to the URL to search with those rights, the
#       same 3 results should still be there
#   5. Search the collection again with a null query to remove the rights
#       and binning restrictions
#   6. Click on the Destrory bin then click on the Poland sub bin. There
#      	should be 6 results and if you look at the xml you will see that
#	the acl for the NATION contents is "everyone".
#   7. Add rights=everyone to the URL, after adding this param there are
#       now 0 results even though everyone should have rights
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

source $TEST_ROOT/lib/run_std_results.sh
