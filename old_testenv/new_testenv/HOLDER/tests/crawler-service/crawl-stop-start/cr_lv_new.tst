#!/bin/bash

#
#   Run the main stop start routine with:
#      start type    = new
#      subcollection = live
#      test name     = cr_lv_new
#

./crawl-stop-start.py -T cr_lv_new -S new -C live

exit $?
