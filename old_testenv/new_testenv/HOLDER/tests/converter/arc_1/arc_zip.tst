#!/bin/bash

tname="arc_zip"

./arc_runner.py -f samba-1.zip -q review -r 6 -q '"Cary Audio"' -r 0 -q "Cary OR Audio" -r 3 -q "" -r 52 -T $tname

exit $?
