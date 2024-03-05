#!/bin/bash

tname="arc_1_word"

./arc_runner.py -f 1_word.zip -q "diet" -r 0 -q "" -r 1 -q "snapple" -r 1 -q "1_word_file" -r 1 -T $tname

exit $?
