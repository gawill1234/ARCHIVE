#!/bin/bash

echo "ifi-noload:  A fast index test with indexed fast index which has"
echo "             no overlap between queries and the merges"

./ifi_enqueue.tst -C bashful -D garbage_dir -D garbage_2

if [ $? -eq 0 ]; then
   rm case.bashful.*
   exit 0
fi

exit 99
