#!/bin/bash
#
#  This test requires 2 things:
#  1) It must use bash (linux or cygwin)
#  2) It must run ON the host where velocity is installed
#     because it is using that version of transform
#

homedir=`vivisimo_dir`
lddir=$homedir/lib

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$lddir
export VIVISIMO_INSTALL_DIR=$homedir

echo "Running transform ..."

if [ $3 = 'basis' ]; then
        echo "running basis language classify"
        $homedir/bin/transform -xsl classify_lang_basis.xsl $1 > $2 
        exit 1;
else
       echo "running velocity language classify"
       $homedir/bin/transform -xsl classifyLanguage.xsl $1 > $2 
fi

echo Done
