#!/bin/bash

#
#   Test the xlhtml converter.  This is a container
#   provided so no one has to remember the options to
#   crt.py.
#
#   This test will currently always fail until the pdftohtml
#   problem it is testing is fixed.
#

converter.py -c pdftohtml -o "-enc UTF-8 -i -noframes -c -stdout" -t converter
z=$?

if [ $z -eq 0 ]; then
   echo "In this case the test correctly compared two bad files."
   echo "The compare file is jibberish, as is the new data file"
   echo "if you are reading this."
   echo "pdftohtml:  Test Failed"
else
   echo "xlhtml:  Test Needs Inspection"
   echo "in the original state, this test failed.  Any change may"
   echo "that it now passes.  INSPECT."
fi

z=1

exit $z
