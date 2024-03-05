#!/bin/bash

collectionfile=0
infile=""
outfile=""

while getopts "I:O:c" flag; do
  case "$flag" in
     I) infile=$OPTARG;;
     O) outfile=$OPTARG;;
     c) collectionfile=1;;
     *) echo "Usage: normalize_dictionary.sh -I <infile> -O <outfile> -c"
        exit 1;;
  esac
done

if [ "$infile" == "" ]; then
   echo "No input specfied, exiting"
fi

if [ "$outfile" == "" ]; then
   echo "No output specfied, exiting"
fi

if [ $collectionfile == 1 ]; then
   cat $infile | sed 's/ 1$/1/' | sed 's/ //g' | sed 's// /' > $infile.tmp
   infile="$infile.tmp"
fi

export LC_ALL=C
cat $infile | tr -d '\r' | tr '\0' '\n' | sed 's/ [0-9]*$//' | sed '/^\.[0-9]*$/s/^\.//' | grep . | sort -u > $outfile

