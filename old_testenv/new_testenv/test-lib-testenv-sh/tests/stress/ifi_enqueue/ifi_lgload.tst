#!/bin/bash

if [ ! -e /testenv/CHECKFILE ]; then
   echo "/testenv file system is not mounted"
   echo "mount -t nfs testbed5.test.vivisimo.com:/virtual2/data /testenv"
   echo "ifi-noload:  Test Failed"
   exit 99
fi

echo "ifi-noload:  A fast index test with indexed fast index which has"
echo "             overlap between queries and the merges.  The amount of"
echo "             data being enqueue pretty much guarantees that the merge"
echo "             and the queries will be going on at the same time."

./ifi_enqueue.tst -C bashful -C doc -C sneezy -C dopey -C grumpy -C sleepy -C happy -D /testenv/test_data/law/US/348 -D /testenv/test_data/law/US/99 -D garbage_dir -D /testenv/test_data/law/F2/724 -D /testenv/test_data/law/F2/992 -D garbage_2 -D /testenv/test_data/law/F3/9 -D /testenv/test_data/law/F3/99

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
