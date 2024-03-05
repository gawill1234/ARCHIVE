#!/usr/bin/python

#
#   This is a test of the error-expire and uncrawled-expire settings
#   for the crawler as they apply to connectors.  This is a base
#   test which is called/used by 4 actual tests which set the values
#   appropriate to each of the settings.
#
#     <crawl-options elt-id="2214">
#        <curl-option name="error-expires" elt-id="2215">60</curl-option>
#        <curl-option name="uncrawled-expires" elt-id="2332">60</curl-option>
#        <curl-option name="filter-exact-duplicates" elt-id="2216">false</curl-option>
#        <curl-option name="connect-timeout" elt-id="2333">1</curl-option>
#     </crawl-options>
#

import sys, time, cgi_interface, vapi_interface 
import build_schema_node, subprocess, os, getopt
from lxml import etree

def update_config_file(infile=None, outfile=None, vivdir=None,
                       tname=None, dbname=None):

   if ( vivdir is None ):
      return None
   #end if replace_root
   if ( infile is None ):
      return None
   #end if infile
   if ( outfile is None ):
      return None
   if ( tname is None ):
      return None
   if ( dbname is None ):
      return None
   #end if outfile

   tmpfile = "gigo"
   tmpfile2 = "gigo2"

   cmdstring = "cat " + infile + " | sed -e \'s;REPLACE__ME;" + vivdir + ";g\' > " + tmpfile

   p = subprocess.Popen(cmdstring, shell=True)
   os.waitpid(p.pid, 0)

   cmdstring = "cat " + tmpfile + " | sed -e \'s;REPLACE__NAME;" + tname + ";g\' > " + tmpfile2

   p = subprocess.Popen(cmdstring, shell=True)
   os.waitpid(p.pid, 0)

   cmdstring = "cat " + tmpfile2 + " | sed -e \'s;REPLACE__LOTUS__DB;" + dbname + ";g\' > " + outfile

   p = subprocess.Popen(cmdstring, shell=True)
   os.waitpid(p.pid, 0)

   os.remove(tmpfile)
   os.remove(tmpfile2)

   return

if __name__ == "__main__":


   cs_pass = 0
   casecount = 0

   opts, args = getopt.getopt(sys.argv[1:], "n:", ["test_name="])

   collection_name = "some-lotus-collection"
   base_file = "basexml"

   tname = 'lotto-base'

   for o, a in opts:
      if o in ("-n", "--test_name"):
         tname = a
   # end for options

   if ( tname != 'lotto-base' ):
      collection_name = tname
      if ( tname == 'lotus-1' ):
         qry = 'BMS OR sreports OR stdparts'
         qres = 3
         eres = 124
         dbname = 'catalog'
      elif ( tname == 'lotus-2' ):
         qry = 'Jerome'
         qres = 36
         eres = 1138
         dbname = 'mail/demo'
      elif ( tname == 'lotus-3' ):
         qry = 'Engineering'
         qres = 783
         eres = 1391
         dbname = 'BMS'
      elif ( tname == 'lotus-4' ):
         qry = '(work AND Nikon) OR work'
         qres = 140
         eres = 151
         dbname = 'sreports-200'
      elif ( tname == 'lotus-5' ):
         qry = 'Server AND Cluster'
         qres = 7323
         eres = 8703
         dbname = 'events4'
      else:
         print tname, ":  Named test does not exist."
         print tname, ":  Valid names are lotus-1, lotus-2,"
         print tname, ":  lotus-3, lotus-4 or lotus-5."
         sys.exit(1)
   else:
      print tname, ":  Test to run not set"
      sys.exit(1)

   collection_file = ''.join([collection_name, '.xml'])

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE API OBJECTS"

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   vivdir = xx.vivisimo_dir()
   vivdir = vivdir + "/lib/java/lotus"
   print tname, ":   VIVISIMO DIR,", vivdir

   yy.api_ss_reset()


   update_config_file(infile=base_file, outfile=collection_file,
                      vivdir=vivdir, tname=tname, dbname=dbname)

   print tname, ":  ##################"
   print tname, ":  CHECK COLLECTION EXISTENCE AND DELETE IF NEEDED"

   cex = xx.collection_exists(collection=collection_name)
   if ( cex == 1 ):
      try:
         yy.api_sc_crawler_stop(collection=collection_name,
                                subc='live', killit='true')
         yy.api_sc_indexer_stop(collection=collection_name,
                                subc='live', killit='true')
         yy.api_sc_delete(collection=collection_name)
      except:
         print tname, ":  Could not reset collection to begin test"
         print tname, ":  For details see ", tname + '.stderr'
         print tname, ":  Test Failed"
         sys.exit(1)
   cex = xx.collection_exists(collection=collection_name)
   if ( cex == 1 ):
      xx.delete_collection(collection=collection_name, force=1)
   #end if collection exists (cex == 1)

   print tname, ":  ##################"
   print tname, ":  CREATE COLLECTION"

   yy.api_sc_create(collection=collection_name, based_on='default')
   yy.api_repository_update(xmlfile=collection_file)
   #yy.api_sc_update_config(collection=collection_name)
   #yy.api_sc_set_xml(collection=collection_name, urlfile=collection_file)
   stime = time.time()
   yy.api_sc_crawler_start(collection=collection_name, stype='new', subc='live')

   print tname, ":  ##################"
   print tname, ":  COLLECTION COMPLETE AND RUNNING"

   xx.wait_for_idle(collection=collection_name)
   etime = time.time()
   crltime = etime - stime

   print tname, ":  Crawl time in seconds,", crltime

   ####################################################################

   print tname, ":  ##################"
   print tname, ":  Get base data, blank query"
   stime = time.time()
   resp = yy.api_qsearch(source=collection_name, num=1000000,
                         query='', filename='first_dump')
   etime = time.time()
   bqrytime = etime - stime

   print tname, ":  Query time in seconds,", bqrytime

   doccount1 = yy.getTotalResults(resptree=resp, filename='first_dump')

   casecount += 1
   if ( doccount1 != eres ):
      print tname, ":  Test Failed"
      print tname, ":  This was a basic crawl with nothing fancy."
      print tname, ":  There are", eres, "unique documents in the space"
      print tname, ":  to be crawled."
      print tname, ":  Expected document count:", eres
      print tname, ":  Actual document count  : ", doccount1
   else:
      cs_pass += 1

   print tname, ":  ##################"
   print tname, ":  Get query data, query =", qry
   stime = time.time()
   resp = yy.api_qsearch(source=collection_name, num=1000000,
                         query=qry, filename='next_dump')
   etime = time.time()
   qrytime = etime - stime

   print tname, ":  Query time in seconds,", qrytime

   doccount2 = yy.getTotalResults(resptree=resp, filename='next_dump')

   casecount += 1
   if ( doccount2 != qres ):
      print tname, ":  Test Failed"
      print tname, ":  There are", qres, "unique documents in the space"
      print tname, ":  to be crawled for query", qry
      print tname, ":  Expected document count:", qres
      print tname, ":  Actual document count  : ", doccount2
   else:
      cs_pass += 1

   ##############################################################

   print tname, ":  ##################"
   print tname, ":  SHUT DOWN COLLECTION"

   #print xx.get_collection_system_errors(collection=collection_name, 
   #                                      starttime=mytime)
   yy.api_sc_crawler_stop(collection=collection_name,
                          subc='live', killit='true')
   yy.api_sc_indexer_stop(collection=collection_name,
                          subc='live', killit='true')

   print tname, ":  ##################"
   print tname, ":  PRINT TEST RESULT"

   print tname, ":  Crawl time =", crltime, "seconds"
   print tname, ":  Blank query time for", doccount1, "results =", bqrytime, "seconds"
   print tname, ":  Query time for", doccount2, "results =", qrytime, "seconds"

   if ( cs_pass == casecount ):
      yy.api_sc_delete(collection=collection_name)
      print tname, ":  Test Passed"
      sys.exit(0)
   #end if

   print tname, ":  Test Failed"
   sys.exit(1)
