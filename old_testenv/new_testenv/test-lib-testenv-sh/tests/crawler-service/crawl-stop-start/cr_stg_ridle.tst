#!/bin/bash

#
#   Run the main stop start routine with:
#      start type    = resume-and-idle
#      subcollection = staging
#      test name     = cr_stg_ridle
#

./crawl-stop-start.py -T cr_stg_ridle -S resume-and-idle -C staging

exit $?
