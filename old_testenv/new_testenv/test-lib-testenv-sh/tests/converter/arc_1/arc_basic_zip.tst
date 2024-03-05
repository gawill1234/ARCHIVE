#!/bin/bash

tname="arc_basic_zip"

./arc_runner.py -f av_docs.zip -q review -r 100 -q '"Cary Audio"' -r 5 -q "Cary Audio" -r 6 -T $tname

exit $?
