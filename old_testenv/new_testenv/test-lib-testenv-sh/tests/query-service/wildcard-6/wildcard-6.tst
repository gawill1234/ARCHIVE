#!/bin/bash

#####################################################################

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="wildcard-6"
   DESCRIPTION="basic crawl verifying that the new wildcard dictionary is right (using optimized 'same stemmer' mode)"

###
###

export VIVLOWVERSION="7.5"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

filecheck()
{
   echo "#######################"
   echo "Check of file $1"
   #
   #   Did we get the file?
   #
   if [ ! -f $1 ]; then
      echo "Failed to get the file."
      exit 1
   else
      echo "Got file $1."
   fi

   #
   #   Is our file readable?
   #
   if [ ! -r $1 ]; then
      echo "File $1 is not readable, attempting chmod"
      chmod 644 $1
      if [ ! -r $1 ]; then
         echo "File $1 is still not readable"
         echo "$VCOLLECTION:  Test Failed"
         exit 1
      else
         echo "File $1 is now readable."
      fi
   else
      echo "File $1 is readable."
   fi

   #
   #   Does the file contain data?
   #
   localsize=`stat -c "%s" $1`
   if [ $localsize -le 0 ]; then
      echo "File $1 has no data in it"
      echo "$VCOLLECTION:  Test Failed"
      exit 1
   else
      echo "Size of file $1 OK at $localsize"
   fi
   echo "Check of $1 complete"
   echo "#######################"
}

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

#origrepo="wildcard-6.orig.repo"
#backup_repository -S $origrepo

delete_collection -C $VCOLLECTION

repository_delete -t application -n wildcard-6-delete-dictionary
repository_delete -t dictionary -n wildcard-6-dictionary
repository_delete -t application -n wildcard-6-axl-hack


majorversion=`getmajorversion`

sed -i s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_USER/${VIV_SAMBA_LINUX_USER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_PASSWORD/${VIV_SAMBA_LINUX_PASSWORD}/g ${VCOLLECTION}.xml
sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${VCOLLECTION}.xml

repository_import -F wildcard-6-delete-dictionary.xml
run_velocity -A wildcard-6-delete-dictionary

if [ "$majorversion" -lt "8" ]; then
   repository_import -F wildcard-6-dictionary_7.xml
else
   repository_import -F wildcard-6-dictionary.xml
fi
repository_import -F wildcard-6-axl-hack.xml

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

# My hacky way to build the dictionary synchronously

echo "#######################"
echo "Building the dictionary"
run_velocity -A wildcard-6-axl-hack
echo "#######################"

# Dictionary sorting requires byte sorting to be consistent

export LC_ALL=C

# Get the dictionary from the search-collection

path=`get_crawl_dir -C $VCOLLECTION`

md5_name=`xsltproc --stringparam mynode wcdict-name $TEST_ROOT/utils/xsl/parse_admin_60.xsl querywork/$VCOLLECTION.admin.xml`

if [ "$VIVTARGETOS" != "windows" ]; then
   fullpath="$path/$md5_name"
   fileonly=`basename $md5_name`
else
   fullpath="$path\\$md5_name"
   fileonly=`echo $md5_name | cut -f 2 -d '\'`
fi

echo "#######################"
echo "Getting collection dictionary file:"
echo "   FROM:  $fullpath"
echo "   TO:    $fileonly"
sleep 1
get_file -F $fullpath
echo "#######################"

filecheck $fileonly

mv $fileonly querywork/collection-dictionary.raw

# Get the dictionary from the dictionaries
# Make sure the dictionary write is complete
sleep 5

vivdir=`vivisimo_dir`
if [ "$VIVTARGETOS" != "windows" ]; then
   vfullpath="$vivdir/data/dictionaries/wildcard-6-dictionary/wildcard.dict"
else
   vfullpath="$vivdir\\data\\dictionaries\\wildcard-6-dictionary\\wildcard.dict"
fi
vfileonly="wildcard.dict"

echo "#######################"
echo "Getting dictionary file:"
echo "   FROM:  $vfullpath"
echo "   TO:    $vfileonly"
sleep 1
get_file -F $vfullpath
echo "#######################"

filecheck $vfileonly

mv $vfileonly querywork/old-dictionary.raw

for which in collection old
do
    if [ "$which" == "collection" ]; then
       normalize_dictionary.sh -I querywork/$which-dictionary.raw -O querywork/$which-dictionary.sorted -c
    else
       normalize_dictionary.sh -I querywork/$which-dictionary.raw -O querywork/$which-dictionary.sorted
    fi
done

# They need to be identical

if ! diff querywork/old-dictionary.sorted querywork/collection-dictionary.sorted ; then
    echo Test failed: dictionaries are different.
    exit 1
fi

echo "Case passes: dictionaries are identical"

#
#   Since we messed with the repository, we need
#   to delete the collection so we can put the repository
#   back the way it was.
#
#   Also, since we killed the collection, the error report
#   is no invalid as far as we are concerned.
#

VIVERRORREPORT="False"
delete_collection -C $VCOLLECTION
run_velocity -A wildcard-6-delete-dictionary

repository_delete -t application -n wildcard-6-delete-dictionary
repository_delete -t dictionary -n wildcard-6-dictionary
repository_delete -t application -n wildcard-6-axl-hack

#restore_repository -S $origrepo
#delete_repository -S $origrepo

rm ${VCOLLECTION}.xml

source $TEST_ROOT/lib/run_std_results.sh
