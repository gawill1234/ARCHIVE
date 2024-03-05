#!/bin/bash

echo "ifi-noload:  A fast index test with indexed fast index which has"
echo "             some possible overlap between queries and the merges"

./ifi_enqueue.tst -C bashful -C doc -C sneezy -C dopey -C grumpy -C sleepy -C happy -D garbage_dir -D garbage_2

if [ $? -eq 0 ]; then
   rm case.bashful.*
   rm case.doc.*
   rm case.sneezy.*
   rm case.dopey.*
   rm case.grumpy.*
   rm case.sleepy.*
   rm case.happy.*
   exit 0
fi

exit 99
