#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="query-3-coverage"
   DESCRIPTION="increase coverage of index-search.c"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

# Create a collection that has 2 indices and one deleted
# document.

delete_collection -C $VCOLLECTION
create_collection -C $VCOLLECTION

stime=`date +%s`
export VIVSTARTTIME=$stime

start_crawl -C $VCOLLECTION
wait_for_idle -C $VCOLLECTION
refresh_crawl -C $VCOLLECTION
wait_for_idle -C $VCOLLECTION

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
#basic_query_test 1 $SHOST $VCOLLECTION Arizona
#basic_query_test 2 $SHOST $VCOLLECTION Arizona+Battleship
#basic_query_test 3 $SHOST $VCOLLECTION bismarck
#basic_query_test 4 $SHOST $VCOLLECTION arizona
#basic_query_test 5 $SHOST $VCOLLECTION Blücher

date
simple_search -C $VCOLLECTION -Q test -r bad
date
simple_search -C $VCOLLECTION -Q %22this+is+a+test%22 -r good
date
simple_search -C $VCOLLECTION -Q Test
date
simple_search -C $VCOLLECTION -Q TEST%20DOCUMENT_KEY%3a%22smb%3a%2f%2ftestbed5.test.vivisimo.com%3a80%2ftestfiles%2fsamba_test_data%2fsamba-2%2fdoc%2fedaoob.pdf%2f%22
date
simple_search -C $VCOLLECTION -Q TEST%20DOCUMENT_KEY%3a%22notsmb%3a%2f%2ftestbed5.test.vivisimo.com%3a80%2ftestfiles%2fsamba_test_data%2fsamba-2%2fdoc%2fedaoob.pdf%2f%22
date
simple_search -C $VCOLLECTION -Q thisisareallylongwordtotriggertoomanywordsinthenearexpressionfortheunigramer
date
simple_search -C $VCOLLECTION -Q '' -r good
date
simple_search -C $VCOLLECTION -Q %28x+or+%28@+@+not+^%29%29+a+not+b+c+not+d
date
simple_search -C $VCOLLECTION -Q a+%7e+b
date
simple_search -C $VCOLLECTION -Q @+%7e+@
date
simple_search -C $VCOLLECTION -Q not+x
date
simple_search -C $VCOLLECTION -Q test+[within]+%28%22this+is+a%22+[thru]+5+[words]%29
date
simple_search -C $VCOLLECTION -Q %28a+[thru]+b%29+[containing]+%28c+[thru]+d%29
date
simple_search -C $VCOLLECTION -Q %28a+[thru]+b%29+[within]+%28c+[thru]+d%29
date
simple_search -C $VCOLLECTION -Q %28a+[thru]+b%29+[notcontaining]+%28c+[thru]+d%29
date
simple_search -C $VCOLLECTION -Q %28a+[thru]+b%29+[notwithin]+%28c+[thru]+d%29
date
simple_search -C $VCOLLECTION -Q %22{document}%22
date
simple_search -C $VCOLLECTION -Q {document} -r good
date
simple_search -C $VCOLLECTION -Q {document}+or+{document} -r bad
date
simple_search -C $VCOLLECTION -Q %281+or+2%29[words]
date
simple_search -C $VCOLLECTION -Q aa+[words]
date
simple_search -C $VCOLLECTION -Q %22-1%22+[words]
date
simple_search -C $VCOLLECTION -Q 100000000000+[words]
date
simple_search -C $VCOLLECTION -Q 0+[words]
date
simple_search -C $VCOLLECTION -Q [content:title]
date
simple_search -C $VCOLLECTION -Q {content}
date
simple_search -C $VCOLLECTION -Q title:test
date
simple_search -C $VCOLLECTION -Q title:testing -r good
date
simple_search -C $VCOLLECTION -Q %28a+[thru]+b%29+c
date
simple_search -C $VCOLLECTION -Q 1+[words]
date
simple_search -C $VCOLLECTION -Q 2+[words] -r good
date
simple_search -C $VCOLLECTION -Q %281+[words]%29+or+%282+[words]%29
date
simple_search -C $VCOLLECTION -Q %281+[words]%29+%282+[words]%29
date
simple_search -C $VCOLLECTION -Q %282+[words]%29+%281+[words]%29 -r good
date
simple_search -C $VCOLLECTION -Q + -r good%0abad%0augly+duckling%0a%0a%0a
date
simple_search -C $VCOLLECTION -Q ++ -r %0a
date

#
#   Final checks that the query
#   service is, in fact, working correctly.
#
query_service_status -H $SHOST
if [ $? -ne 1 ]; then
   echo "Query service indicate down.  Crashed?  Restarting."
   results=`expr $results + 1`
   #
   #   Restart for next test
   #
   start_query_service -H $SHOST -U $VUSER -P $VPW
fi


source $TEST_ROOT/lib/run_std_results.sh
