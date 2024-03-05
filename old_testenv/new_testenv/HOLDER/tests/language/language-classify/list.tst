#!/bin/bash
#
#  This test requires 2 things:
#  1) It must use bash (linux or cygwin)
#  2) It must run ON the host where velocity is installed
#     because it is using that version of transform
#

homedir='vivisimo_dir'
lddir=$homedir/lib

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$lddir
export VIVISIMO_INSTALL_DIR=$homedir
echo "files"
for filename in $1/*; do
    fn=$(basename "$filename")
    out=$(echo $fn |sed 's/\.xml/\.html /g')
    echo "$out"
   #./lng_classify.tst text_ct.xml text_ct2.out $2
    ./lng_classify.tst $filename output/$out  $2
  #  echo "Files executed"
       
done
echo "done"
