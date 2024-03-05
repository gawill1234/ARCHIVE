#!/usr/bin/python

#
#   Test of autocomplete suggestion API and dictionaries.
#

import sys, time, cgi_interface, vapi_interface
import velocityAPI
import urlparse
import os, subprocess
from lxml import etree

def dict_create_and_build(tname, yy, xx, dictionary_name, dictionary_file):

   try:
      yy.api_dictionary_delete(dictionary_name=dictionary_name)
      yy.api_repository_get(elemtype="dictionary",
                            elemname=dictionary_name)
   except velocityAPI.VelocityAPIexception:
      print tname, ":  Dictionary gone, whoohoo!!"

   print tname, ":  Create dictionary", dictionary_name
   yy.api_dictionary_create(dictionary_name=dictionary_name)

   print tname, ":  Update dictionary", dictionary_name
   print tname, ":     It should build using example-metadata collection"
   yy.api_repository_update(xmlfile=dictionary_file)

   print tname, ":  Build dictionary", dictionary_name
   yy.api_dictionary_build(dictionary_name=dictionary_name)
   dstat = yy.api_dictionary_status(xx=xx, dictionary_name=dictionary_name)
   while ( dstat != "aborted" ) and ( dstat != "finished" ):
      print tname, ":     Current build status,", dstat
      time.sleep(5)
      print tname, ":     Recheck the dictionary status"
      dstat = yy.api_dictionary_status(xx=xx, dictionary_name=dictionary_name)

   if ( dstat == "aborted" ):
      print tname, ":  Dictionary build failed", dictionary_name
      print tname, ":  Test Failed"
      sys.exit(99)

   return

def do_dict_file(infile, outfile, target_file, xx):

   if ( xx.TENV.targetos == "windows" ):
      flist = target_file.split('\\')

   cmdstring = "cat " + infile + " | sed -e \'s;REPLACE__WITH__TARGET;"

   if ( xx.TENV.targetos == "windows" ):
      fllen = len(flist)
      cnt = 0
      for item in flist:
         cmdstring = cmdstring + item
         cnt += 1
         if ( cnt < fllen ):
            cmdstring = cmdstring + '\\\\'
   else:
      cmdstring = cmdstring + target_file

   cmdstring = cmdstring + ";g\' > " + outfile

   #print cmdstring

   p = subprocess.Popen(cmdstring, shell=True)
   os.waitpid(p.pid, 0)

   return

if __name__ == "__main__":

   tname = 'autocomplete-suggest-1'

   collection_name = "example-metadata"
   dictionary_name = "asugtest"

   dictfile = "dictionary.xml"

   wordfileroot = os.getenv('TEST_ROOT', None)
   wordfile = wordfileroot + '/lib' + '/words'

   xres = ['xanthophyll', 'xanthochroism', 'xanthus', 
           'xerosere', 'xerography', 'xylidine', 'xenogenesis',
           'xiaoping', 'xaviera', 'xanthippe', 'ximena', 'xenakis',
           'xylophone', 'xantha', 'xanthe', 'xymenes', 'ximenes',
           'ximenez', 'xenocryst', 'xylem', 'xavier', 'xenophobe',
           'xylia', 'xanthein', 'xavler', 'xebec', 'xenolith',
           'xiphisternum', 'xerophyte', 'xanthene', 'xylol', 'xylon',
           'xmas', 'xenophon', 'xanthate', 'xenophobia', 'xanthine',
           'xerosis', 'xiongnu', 'xuzhou', 'xylotomy', 'xenophanes',
           'xena', 'xeno', 'xochipilli', 'xerxes', 'xeres', 'xenia',
           'xhosa', 'xylene', 'xever', 'xenocrates', 'xylina', 'xyster',
           'xenon', 'xenogamy', 'xiamen', 'xingu', 'xnty', 'xerox',
           'xylograph', 'xeroderma', 'xemacs', 'xizang', 'xerophagy',
           'xanthin', 'xuthus', 'xerophthalmia', 'xylography', 'xantippe']

   hres = ['horse', 'horses', 'have', 'halley', 'hand',
           'however', 'henry', 'hour', 'hidden', 'himself',
           'hitchhiker', 'high', 'held', 'help']

   fail = 0

   ##############################################################
   #
   #  Test and dictionary setup stuff
   #
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  autocomplete suggestions"

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   xx.version_check(8.0)

   thebeginning = time.time()
   xx.start_crawl(collection=collection_name)
   xx.wait_for_idle(collection=collection_name)

   ####################################################################
   #
   #  Build the next dictionary and run the test.
   #

   dict_create_and_build(tname, yy, xx, dictionary_name, dictfile)

   print tname, ":  #######################################"
   print tname, ":  autocomplete-suggest queries"

   print tname, ":  #######################################"
   print tname, ":  CASE 1"
   print tname, ":  Collection based dictionary"
   print tname, ":  example-metadata collection"
   print tname, ":  get phrase list for 'h'"

   zz = yy.api_autocomplete_suggest(dictionary_name=dictionary_name,
                                    basestr="h", num=30, bow=False)
   #print zz

   ret = yy.check_list(zz, hres)
   if ( ret == 0 ):
      print tname, ":  collection based dictionary"
      print tname, ":  'h' query case passed"
   else:
      print tname, ":  word not found in result list"
      fail += 1

   print tname, ":  #######################################"

   print tname, ":  #######################################"
   print tname, ":  CASE 2"
   print tname, ":  Collection based dictionary"
   print tname, ":  example-metadata collection"
   print tname, ":  get phrase list for 'H'(upper case)"

   zz = yy.api_autocomplete_suggest(dictionary_name=dictionary_name,
                                    basestr="H", num=30, bow=False)
   #print zz

   ret = yy.check_list(zz, hres)
   if ( ret == 0 ):
      print tname, ":  collection based dictionary"
      print tname, ":  'H' query case passed"
   else:
      print tname, ":  word not found in result list"
      fail += 1

   print tname, ":  #######################################"

   ####################################################################
   #
   #  Dictionary setup stuff for the next dictionary
   #

   if ( os.access(wordfile, os.R_OK) != 1 ):
      print tname, ":  Can not get words, test will be shortened"
      print tname, ":  Test Failed, BAIL OUT NOOOOWWW!!!   AAAHHHHH ..."
      sys.exit(99)

   #
   #   windows sucks
   #
   mydir = xx.vivisimo_dir(which='tmp')
   if ( xx.TENV.targetos != "windows" ):
      targetwords = mydir + '/words'
   else:
      targetwords = mydir + '\\words'

   #print mydir
   #print targetwords

   infile = 'fromfilebase'
   outfile = 'from_file.xml'
   next_dict = 'from_file'

   #
   #   Create the dictionary xml file
   #
   do_dict_file(infile, outfile, targetwords, xx)

   #
   #
   print tname, ":  dump the 'words' file to vivisimo 'tmp' so"
   print tname, ":  we can use it to build a dictionary."
   xx.put_file(wordfile, mydir)

   ####################################################################
   #
   #  Build the next dictionary and run the test.
   #

   dict_create_and_build(tname, yy, xx, next_dict, outfile)

   print tname, ":  #######################################"
   print tname, ":  CASE 3"
   print tname, ":  File based dictionary"
   print tname, ":  linux 'words' file"
   print tname, ":  get phrase list for 'x'"

   zz = yy.api_autocomplete_suggest(dictionary_name=next_dict,
                                    basestr="x", num=100, bow=True)

   #print zz
   ret = yy.check_list(zz, xres)
   if ( ret == 0 ):
      print tname, ":  file based dictionary"
      print tname, ":  'x' query case passed"
   else:
      print tname, ":  word not found in result list"
      fail += 1

   print tname, ":  #######################################"

   print tname, ":  #######################################"
   print tname, ":  CASE 4"
   print tname, ":  File based dictionary"
   print tname, ":  linux 'words' file"
   print tname, ":  get phrase list for 'X'(upper case)"

   zz = yy.api_autocomplete_suggest(dictionary_name=next_dict,
                                    basestr="X", num=100, bow=True)

   #print zz
   ret = yy.check_list(zz, xres)
   if ( ret == 0 ):
      print tname, ":  file based dictionary"
      print tname, ":  'x' query case passed"
   else:
      print tname, ":  word not found in result list"
      fail += 1

   print tname, ":  #######################################"

   ####################################################################

   xx.stop_crawl(collection=collection_name, force=1)
   xx.stop_indexing(collection=collection_name, force=1)

   if ( fail == 0 ):
      print tname, ":  Test Passed"
      sys.exit(fail)

   print tname, ":  Test Failed"

   sys.exit(fail)
