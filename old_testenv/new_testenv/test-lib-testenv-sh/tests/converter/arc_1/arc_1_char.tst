#!/bin/bash

tname="arc_1_char"

./arc_runner.py -f 1_char.zip -q "a" -r 0 -q "" -r 1 -q "z" -r 1 -q "1_char_file" -r 1 -T $tname

exit $?
