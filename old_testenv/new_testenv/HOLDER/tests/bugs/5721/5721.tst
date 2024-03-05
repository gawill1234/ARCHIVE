#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="5721"
   DESCRIPTION="crawl a smb directory with over 250k documents"

#
#  Crawled directory for the test has 351523 documents.
#
#  Bug title:  How much memory do you need for a big smb directory?
#
#  Comment 1.
#
#Is it really the case that 128 MB is not enough memory to crawl a directory
#with 350K entries?
#
#Try crawling smb://dev.vivisimo.com/techies2/crpalmer/binning
#
#and it runs out of memory on the seed and there are currently just under 350K
#files in there...
#
#  Comment 2.
#
#Looking at the heap dump,
#
#The top offenders are:
#
#String - 682810 - 13656200 bytes 
#URL - 169916 - 14952608 bytes
#SmbFile - 169767 - 24955749 bytes
#Character[] - 513042 - 50242964 bytes
#
#SmbFile has 3 strings (36 bytes each + actual character data), a URL (104 bytes
#+ whatever real data). Obviously if we can reduce the count of SmbFiles, things
#would be better. I'll send a message to the mailing list to see if there is
#some way of getting smaller arrays. It may involve losing some atomicity, if
#there is any currently... 
#

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

source $TEST_ROOT/lib/run_std_setup.sh
crawl_check $SHOST $VCOLLECTION
source $TEST_ROOT/lib/run_std_results.sh
