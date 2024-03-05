#!/bin/bash

tfile=`basename $0`
tname=`echo $tfile | sed "s/\.tst//"`
targetDir="$TEST_ROOT/tests/generics"

MyCollection="samba-16"

$targetDir/runIt.py -C $MyCollection -T $tname -R "-errors 3"

exit $?
