#!/bin/bash

#
#   Test the rtf2html converter.  This is a container
#   provided so no one has to remember the options to
#   crt.py.
#

filelist="030507garpt16120 062298_CSD 4.1-schedule Alarm_System Assistantship BAA2005-4 BizRate_XML_API Bosnia_Herzegovina California Community_Meeting_Agenda constitution Dinose_1 dinoseb docview-1064 docview-1742 download handbook ics201 ics207 Installation Kansas_City_policy lettergloballinxs2 letterhead moonews myers3 SharePointTips"

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
      compfile=compare_files/output.$item.rtf
      compfileout=querywork/output.$item.rtf.stripped
      resfile=querywork/$item.rtf.stdout
      resfileout=querywork/$item.rtf.stdout.stripped
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
converter.py -c rtf2html -t converter
z=$?

#
#   A second chance to pass based only on the actual content, not the
#   spacing and html that has been created.
#
scval=`secondchance`
echo "SCVAL:  $scval"

if [ $z -ne 0 ]; then
   z=$scval
fi


if [ $z -eq 0 ]; then
   echo "rtf2html:  Test Passed"
else
   echo "rtf2html:  Test Failed"
fi

exit $z
