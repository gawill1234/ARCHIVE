#!/bin/bash

tname="arc_nested_zip"

./arc_runner.py -f twozip.zip -q review -r 106 -q '"Cary Audio"' -r 5 -q "Cary Audio" -r 6 -q "" -r 152 -T $tname

exit $?
