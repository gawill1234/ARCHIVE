#!/bin/bash

tname="arc_long_names_zip"

./arc_runner.py -f long_names.zip -q review -r 64 -q '"Cary Audio"' -r 4 -q "Cary OR Audio" -r 60 -q "" -r 64 -T $tname

exit $?
