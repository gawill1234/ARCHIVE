#!/bin/bash

#
#   Run the main stop start routine with:
#      start type    = resume
#      subcollection = staging
#      test name     = cr_stg_resume
#

./crawl-stop-start.py -T cr_stg_resume -S resume -C staging

exit $?
