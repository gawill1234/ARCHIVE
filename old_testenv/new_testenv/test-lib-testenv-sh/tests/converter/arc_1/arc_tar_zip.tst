#!/bin/bash

tname="arc_tar_zip"

./arc_runner.py -f tarzip.zip -q review -r 106 -q '"Cary Audio"' -r 5 -q "Cary Audio" -r 6 -q "" -r 152 -T $tname

exit $?
