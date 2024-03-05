#!/bin/bash

#
#   Run the main stop start routine with:
#      start type    = refresh-inplace
#      subcollection = staging
#      test name     = cr_stg_rinplace
#

./crawl-stop-start.py -T cr_stg_rinplace -S refresh-inplace -C staging

exit $?
