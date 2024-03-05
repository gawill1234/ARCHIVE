#!/bin/bash

#
#   Test the xlhtml converter.  This is a container
#   provided so no one has to remember the options to
#   crt.py.
#

filelist="03-AccessB 04-AccessB 164-3c1_915497 164-3c3_933367 5_2292178 An_Introduction_to_Heritrix bill_rights bunsho_3732209 constitution edaoob georgebernardshaw Magic_Quadrant_for_Information_Access_Technology2005_Gartner_ oracle10g-quick-install-linux Preambe_and_Bill_of_Rights us_doi Worldwide_Content_Access MQI"

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
   cat $1 | sed "s/</\n</g" | sed "s/>/>\n/g" | grep -v "<.*>" | awkit | sed "s/ /\n/g" | sort > $2
}

secondchance()
{
   fulldiff=0
   for item in $filelist; do
      echo "WORKING WITH $item" 1>&2
      compfile=compare_files/output.$item.pdf
      compfileout=querywork/output.$item.pdf.stripped
      resfile=querywork/$item.pdf.stdout
      resfileout=querywork/$item.pdf.stdout.stripped
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
/home/peiyu/Vivisimo/Converter/testenv/utils/bin/converter.py -c pdftotext -o "-enc UTF-8" -t converter
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
   echo "pdftotext:  Test Passed"
else
   echo "pdftotext:  Test Failed"
fi

exit $z
