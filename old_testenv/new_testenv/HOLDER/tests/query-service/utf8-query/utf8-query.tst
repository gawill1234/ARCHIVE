
###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="utf8-query"
   DESCRIPTION="query using utf8 character sets"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

basic_query_test 1 $SHOST $VCOLLECTION "I+can+eat+glass"
basic_query_test 2 $SHOST $VCOLLECTION "Ek+get+etið+gler+án+þess+að+verða+sár"
basic_query_test 3 $SHOST $VCOLLECTION "Я+могу+есть+стекло,+оно+мне+не+вредит"
basic_query_test 4 $SHOST $VCOLLECTION "Можам+да+јадам+стакло,+а+не+ме+штета"
basic_query_test 5 $SHOST $VCOLLECTION "Могу+јести+стакло+а+да+ми+не+шкоди"
basic_query_test 6 $SHOST $VCOLLECTION "Ja+mahu+jeści+škło,+jano+mne+ne+škodzić"
basic_query_test 7 $SHOST $VCOLLECTION "Կրնամ+ապակի+ուտել+և+ինծի+անհանգիստ+չըներ"
basic_query_test 8 $SHOST $VCOLLECTION "我能吞下玻璃而不傷身體。"
basic_query_test 9 $SHOST $VCOLLECTION ""

source $TEST_ROOT/lib/run_std_results.sh
