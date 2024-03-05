#!/bin/bash

#
#   Run the main stop start routine with:
#      start type    = resume-and-idle
#      subcollection = live
#      test name     = cr_lv_ridle
#

./crawl-stop-start.py -T cr_lv_ridle -S resume-and-idle -C live

exit $?
