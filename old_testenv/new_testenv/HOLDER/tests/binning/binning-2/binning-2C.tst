#!/bin/bash

tfile=`basename $0`
tname=`echo $tfile | sed "s/\.tst//"`

targetDir="$TEST_ROOT/tests/generics"
MyCollection="binning-2"

$TEST_ROOT/tests/generics/runIt.py -C $MyCollection -Q "ship==Destroyer::77;;ship==Battlecruiser::1" -T $tname -U "ship_type.syntax.xml;;$MyCollection.src.xml"

