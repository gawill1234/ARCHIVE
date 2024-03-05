#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="basic_web_crawl-4"
   #
   #   Filter is for http://www.nytimes.com/*
   #
   DESCRIPTION="Crawl a production web site, hops=1, url filter set"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

source $TEST_ROOT/lib/run_std_setup.sh

sleep 2

run_query -C $VCOLLECTION -Q ""
mv query_results querywork

get_collection -C $VCOLLECTION
mv $VCOLLECTION.xml.run querywork

get_valid_index doc_count $VCOLLECTION

xsltproc $TEST_ROOT/utils/xsl/noscore_stripper querywork/query_results > querywork/urlxml

url_count=`grep -i "www.nytimes.com" querywork/urlxml | grep -i http |wc -l`
not_good=`grep -v -i "www.nytimes.com" querywork/urlxml | grep -i http |wc -l`

echo "Expected docs:  $doc_count"
echo "Got docs:       $url_count"
echo "Bad docs:       $not_good"

if [ $doc_count -eq $url_count ]; then
   if [ $not_good -eq 0 ]; then
      echo "basic_web_crawl-4:  Test Passed"
      exit 0
   fi
fi

echo "basic_web_crawl-4:  Test Failed"
exit 1

