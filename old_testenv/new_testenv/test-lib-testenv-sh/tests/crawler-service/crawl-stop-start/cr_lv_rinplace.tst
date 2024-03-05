#!/bin/bash

#
#   Run the main stop start routine with:
#      start type    = refresh-inplace
#      subcollection = live
#      test name     = cr_lv_rinplace
#

./crawl-stop-start.py -T cr_lv_rinplace -S refresh-inplace -C live

exit $?
