#!/bin/bash

#####################################################################
##
#   How to create a test (matching this type):
#
#      1. Determine what the test is for by type:
#           data, database, ecm, file, mail, samba, url, xslt
#      2. In the appropriate tests/<type> directory, create a directory
#      named after the collection.  Do not duplicate what is there.
#      3. Create your collection and test it by hand.  Make sure it is
#      doing what you want.
#      4. Put the resulting collection xml in <collection_name>.xml.stats
#      in the previously created directory.
#      5. Delete all of the data from the collection, but not the collection.
#      6. Put the resulting collection xml in <collection_name>.xml
#      in the previously created directory.
#      7. Copy this file into the previously created directory as
#      <collection_name>.tst
#      8. Modify this to run your tests as noted below.
#
#   If your test does queries:
#      1.  Within directory <collection_name> create a directory called
#          query_cmp_files
#      2.  touch (the command) a file named <query>.cmp in that
#          directory.
#      3.  Run your test.  It will fail.  However, you will find that in
#          a created directory (querywork) there is a file named
#          <query>.rslt.  Copy that file into query_cmp_file/<query>.cmp.
#          (overwrite the 0 lenght file you created earlier).  Do this copy
#          for all of the queries.  You can get all of these files in one
#          run if all of your tests are written.
#      4.  Run you test again.  It should pass.  If it does not you have
#          made a mistake, or the queries are volatile.  The first I
#          will help you fix.  The second is a problem on your part.  For
#          the same data, the query should be identical each time.
#
#   Once you have done this once, you will find that it should take you no
#   more than 10 minutes or so to populate a test directory.
#
#   Save your work to CVS
#
#   If you need or want to create a test completely of your own design:
#
#   TEST CREATION RULES:
#      There is only one hard and fast rule.  All tests MUST do this:
#         On PASSING, they:
#            exit 0   (shell)
#            exit(0); (C/C++)
#         On FAILING, they:
#            exit <not 0>   (shell)
#            exit(<not 0>); (C/C++)
#       You get the picture.
#       It is a simple rule.  Please follow it.
#
#       Language is irrelavant as long as you are willing to write the make
#       files and the like to get the test to build.  If you are going to
#       do stuff like this, you may assume that all test specific data files
#       can reside in the test directory or a directory relative to the test
#       directory, i.e., testdir/datadir/datafile or testdir/datafile ...
#

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh


###################   CHANGEABLE SPACE  #########################

   VCOLLECTION="<put your collection name here>"
   DESCRIPTION="<One line description of test>"

#
#  You may declase additional variables here.  They will be
#  global to the script.
#

###################   END CHANGEABLE SPACE  #########################

###
###

source $TEST_ROOT/lib/lib_func.sh

###################   CHANGEABLE SPACE  #########################
source $TEST_ROOT/lib/basic_query_test.sh

#
#  Put your test functions here, or you may do what was done above and
#  put the functions in a sourced (include) file.  Put that file in
#  $TEST_ROOT/lib.  See the file test_examples.sh.
#

###################   END CHANGEABLE SPACE  #########################

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

source $TEST_ROOT/lib/standard_setup.sh

crawl_check $SHOST $VCOLLECTION


###################   CHANGEABLE SPACE  #########################
#
#  Call you test functions here
#  The number of functions can be greater or less than shown.  It
#  depends on how many you create.
#
#
#   function basic_query_test
#   args are test number, host, collection, query string
#
basic_query_test 1 $SHOST $VCOLLECTION Arizona
basic_query_test 2 $SHOST $VCOLLECTION Arizona+Battleship
basic_query_test 3 $SHOST $VCOLLECTION bismarck
basic_query_test 4 $SHOST $VCOLLECTION arizona
basic_query_test 5 $SHOST $VCOLLECTION Blücher

###################   END CHANGEABLE SPACE  #########################

source $TEST_ROOT/lib/standard_results.sh
