#!/bin/bash

tname="arc_deep_dir_zip"

./arc_runner.py -f samba_deep.zip -q review -r 100 -q '"Cary Audio"' -r 5 -q "Cary Audio" -r 6 -q "" -r 100 -T $tname

exit $?
