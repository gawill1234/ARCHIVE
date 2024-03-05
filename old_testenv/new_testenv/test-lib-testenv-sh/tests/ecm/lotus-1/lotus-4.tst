#!/bin/bash

ping -c 1 lotus-domino-vm.vivisimo.com
status=$?
if [ $status -gt 0 ]; then
   echo "Crawl target lotus-domino-vm is not up.  Exiting"
   exit $status
fi

./lotto-base.tst -n lotus-4

status=$?
if [ $status -eq 0 ]; then
   rm lotus-4.xml
fi

exit $status
