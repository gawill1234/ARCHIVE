#!/bin/bash
#
#  This test requires 2 things:
#  1) It must use bash (linux or cygwin)
#  2) It must run ON the host where velocity is installed
#     because it is using that version of transform

homedir=`vivisimo_dir`
lddir=$homedir/lib

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$lddir
export VIVISIMO_INSTALL_DIR=$homedir

echo "Running transform ..."

sudo LD_LIBRARY_PATH=$lddir VIVISIMO_INSTALL_DIR=$homedir $homedir/bin/transform -xsl segmentLanguage.xsl $1 > $2

echo Done
