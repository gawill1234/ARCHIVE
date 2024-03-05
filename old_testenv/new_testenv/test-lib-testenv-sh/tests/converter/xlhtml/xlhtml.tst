#!/bin/bash

#
#   Test the xlhtml converter.  This is a container
#   provided so no one has to remember the options to
#   crt.py.
#

filelist="abdp1corelog1 BDTScreen Click-thru_Revenue_And_Hits Clusty_Tabs_Sources eastern05 empty Fb98_60 info_today_2001_attendees jandj_II jandj jnj-federated-search-list journalists_googlesearchappliance_II KM_World_Pre-List02 KM_World myVivisimo_requirements NorthCent_2006Bud PghBizTimes_info Rounding scz_unweightedranks_and_weights Selling_Skills_part_2_-_Buying_ladder_activity servers-pre-office-network servers-pre-rackspace servers test .trials TZ3D_Edit_12 UKCZ UK_Systems_Integrators_contacted_by_Constantine_Zepos VivissimoMetaSearch_Targets ww"

awkit()
{
   awk 'BEGIN      {skip = 0} \
           {if (NF == 0)
               {skip = 1}  \
            else
               {print};  \
            next}'
}

stripemdenno()
{
   cat $1 | sed "s/</\n</g" | sed "s/>/>\n/g" | grep -v "<.*>" | awkit > $2
}

secondchance()
{
   fulldiff=0
   for item in $filelist; do
      echo "WORKING WITH $item" 1>&2
      compfile=compare_files/output.$item.xls
      compfileout=querywork/output.$item.xls.stripped
      resfile=querywork/$item.xls.stdout
      resfileout=querywork/$item.xls.stdout.stripped
      stripemdenno $compfile $compfileout
      stripemdenno $resfile $resfileout
      diff $compfileout $resfileout > querywork/$item.scdiff
      thisdiff=$?
      if [ $thisdiff -ne 0 ]; then
         echo "diff of $compfileout and $resfileout FAILED" 1>&2
         fulldiff=`expr $fulldiff + 1`
      else
         echo "diff of $compfileout and $resfileout PASSED" 1>&2
      fi
   done

   echo $fulldiff

   return
}

z=0
converter.py -c xlhtml -o "-te" -t converter
z=$?

#
#   A second chance to pass based only on the actual content, not the
#   spacing and html that has been created.
#
scval=`secondchance`

if [ $z -ne 0 ]; then
   z=$scval
fi

if [ $z -eq 0 ]; then
   echo "xlhtml:  Test Passed"
else
   echo "xlhtml:  Test Failed"
fi

exit $z
