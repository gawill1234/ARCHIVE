#!/bin/bash

#
#   Run the main stop start routine with:
#      start type    = new
#      subcollection = staging
#      test name     = cr_stg_rnew
#

./crawl-stop-start.py -T cr_stg_new -S new -C staging

exit $?
