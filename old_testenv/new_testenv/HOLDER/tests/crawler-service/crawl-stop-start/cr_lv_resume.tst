#!/bin/bash

#
#   Run the main stop start routine with:
#      start type    = resume
#      subcollection = live
#      test name     = cr_lv_resume
#

./crawl-stop-start.py -T cr_lv_resume -S resume -C live

exit $?
