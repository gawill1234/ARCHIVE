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
import build_schema_node, subprocess, os, getopt, test_helpers
from lxml import etree

def update_config_file(infile=None, outfile=None, whichword=None,
                       replace_root=None, collection_name=None):
   orig_user = ''.join(['<with name="username">', 
                        os.getenv('VIV_SAMBA_LINUX_USER'),
                        '</with>'])
   orig_pword = ''.join(['<with name="password">',
                        os.getenv('VIV_SAMBA_LINUX_PASSWORD'),
                        '</with>'])
   bad_user = '<with name="username">hockey_puck</with>'
   bad_pword = '<with name="password">stinkyfishheads==</with>'

   if ( replace_root is None ):
      return None
   #end if replace_root
   if ( infile is None ):
      return None
   #end if infile
   if ( outfile is None ):
      return None
   #end if outfile

   tmpfile = 'garbage'
   tmpfile2 = 'garbage2'

   optstr = etree.tostring(replace_root)

   cmdstring = "cat " + infile + " | sed -e \'s;__REPLACE__ME;" + optstr + ";g\' > " + tmpfile

   p = subprocess.Popen(cmdstring, shell=True)
   os.waitpid(p.pid, 0)

   cmdstring = "cat " + tmpfile + " | sed -e \'s;__REPLACE_COLLECTION__;" + collection_name + ";g\' > " + tmpfile2

   p = subprocess.Popen(cmdstring, shell=True)
   os.waitpid(p.pid, 0)

   if ( whichword is None ):
      cmdstring = "cat " + tmpfile2 + " | sed -e \'s;__REPLACE_PASSWORD__;" + orig_user + orig_pword + ";g\' > " + outfile
   else:
      cmdstring = "cat " + tmpfile2 + " | sed -e \'s;__REPLACE_PASSWORD__;" + bad_user + bad_pword + ";g\' > " + outfile
   #end if-else (whichword is None)

   p = subprocess.Popen(cmdstring, shell=True)
   os.waitpid(p.pid, 0)

   os.remove(tmpfile)
   os.remove(tmpfile2)

   return

def build_crawl_options():

   global error_expires, uncrawled_expires, request_timeout
   global connector_timeout, filter_exact_duplicates, max_bytes

   print "##########################################################"
   print "##########################################################"
   print tname, ":  Option settings"
   print tname, ":     filter-exact-duplicates -", filter_exact_duplicates
   print tname, ":     error-expires           -", error_expires
   print tname, ":     uncrawled-expires       -", uncrawled_expires
   print tname, ":     connect-timeout         -", connector_timeout
   print tname, ":     timeout                 -", request_timeout
   print tname, ":     max-bytes               -", max_bytes
   print "##########################################################"

   crawl_options = build_schema_node.create_crawl_options()

   curl_opt = build_schema_node.create_curl_option(addnodeto=crawl_options,
                                 name= 'n-concurrent-requests',
                                 text='8')

   if ( filter_exact_duplicates != 'unset' ):
      curl_opt = build_schema_node.create_curl_option(addnodeto=crawl_options,
                                    name= 'filter-exact-duplicates',
                                    text=filter_exact_duplicates)
   #end if filter_exact_duplicates

   if ( error_expires != 'unset' ):
      curl_opt = build_schema_node.create_curl_option(addnodeto=crawl_options,
                                    name= 'error-expires',
                                    text=error_expires)
   #end if error_expires

   if ( uncrawled_expires != 'unset' ):
      curl_opt = build_schema_node.create_curl_option(addnodeto=crawl_options,
                                    name= 'uncrawled-expires',
                                    text=uncrawled_expires)
   #end if uncrawled_expires

   if ( connector_timeout != 'unset' ):
      curl_opt = build_schema_node.create_curl_option(addnodeto=crawl_options,
                                    name= 'connect-timeout',
                                    text=connector_timeout)
   #end if connector_timeout

   if ( request_timeout != 'unset' ):
      curl_opt = build_schema_node.create_curl_option(addnodeto=crawl_options,
                                    name= 'timeout',
                                    text=request_timeout)
   #end if max_bytes

   if ( max_bytes != 'unset' ):
      curl_opt = build_schema_node.create_curl_option(addnodeto=crawl_options,
                                    name= 'max-bytes',
                                    text=max_bytes)
   #end if max_bytes

   return crawl_options

def update_config_and_restart(base_file, collection_file,
                              collection_name, whichword):

   new_crawl_opts = build_crawl_options()
   update_config_file(infile=base_file, outfile=collection_file,
                      replace_root=new_crawl_opts, whichword=whichword,
                      collection_name=collection_name)

   yy.api_repository_update(xmlfile=collection_file)
   yy.api_sc_set_xml(collection=collection_name, urlfile=collection_file)
   #yy.api_sc_update_config(collection=collection_name)

   try:
      yy.api_sc_crawler_stop(collection=collection_name,
                             subc='live', killit='true')
      yy.api_sc_indexer_stop(collection=collection_name,
                             subc='live', killit='true')
   except:
      try:
         yy.api_sc_crawler_stop(collection=collection_name,
                                subc='live', killit='true')
         yy.api_sc_indexer_stop(collection=collection_name,
                                subc='live', killit='true')
      except:
         print tname, ":  Stop of services failed with an error (2 attempts)"
         print tname, ":  Error detail in ", tname + '.stderr'
         print tname, ":  Test Failed"
         sys.exit(1)

   yy.api_sc_crawler_start(collection=collection_name,
                           stype='refresh-inplace')

   return

if __name__ == "__main__":

   global error_expires, uncrawled_expires, request_timeout
   global connector_timeout, filter_exact_duplicates, max_bytes

   cs_pass = 0
   casecount = 0

   ue = False
   ee = False
   uevalue = None
   eevalue = None

   opts, args = getopt.getopt(sys.argv[1:], "e:u:n:", ["error_expires=", "uncrawled_expires=", "test_name="])

   error_expires = 'unset'
   uncrawled_expires = 'unset'
   connector_timeout = 'unset'
   request_timeout = 'unset'
   max_bytes = 'unset'
   filter_exact_duplicates = 'false'

   collection_name = "erexp-1"
   base_file = ''.join([collection_name, 'base'])
   
   param_base_file = ''.join([base_file, '.base'])
   

   tname = 'error-base'

   for o, a in opts:
      if o in ("-e", "--error_expires"):
         eevalue = a
         ee = True
      if o in ("-u", "--uncrawled_expires"):
         uevalue = a
         ue = True
      if o in ("-n", "--test_name"):
         tname = a
   # end for options

   if ( tname != 'error-base' ):
      collection_name = tname

   collection_file = ''.join([collection_name, '.xml'])

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE API OBJECTS"

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   yy.api_ss_reset()

   print tname, ": De-parameterize base file"
   thelper = test_helpers.TEST_HELPERS(yy, xx, None, tname)
   thelper.set_linux_samba_collection_access_data(param_base_file, base_file)
  
   mytime = time.time()
   print tname, ":  START TIME IN SECONDS:", mytime

   first_crawl_opts = build_crawl_options()
   update_config_file(infile=base_file, outfile=collection_file,
                      replace_root=first_crawl_opts, collection_name=collection_name)

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
   yy.api_sc_set_xml(collection=collection_name, urlfile=collection_file)
   yy.api_sc_crawler_start(collection=collection_name, stype='new', subc='live')

   #print "CHECK NOW"
   #time.sleep(120)

   print tname, ":  ##################"
   print tname, ":  COLLECTION COMPLETE AND RUNNING"

   xx.wait_for_idle(collection=collection_name)

   ####################################################################

   print tname, ":  ##################"
   print tname, ":  Get base data"
   resp = yy.api_qsearch(source=collection_name, num=1000000,
                         query='', filename='first_dump')

   doccount1 = yy.getTotalResults(resptree=resp, filename='first_dump')

   casecount += 1
   if ( doccount1 != 20441 ):
      print tname, ":  Test Failed"
      print tname, ":  This was a basic crawl with nothing fancy."
      print tname, ":  There are 20441 unique documents in the space"
      print tname, ":  to be crawled."
      print tname, ":  Expected document count:  20441"
      print tname, ":  Actual document count  : ", doccount1
      sys.exit(1)
   else:
      cs_pass += 1

   print tname, ":  ##################"
   print tname, ":  set xxxx-expires value to the requested value."
   print tname, ":  This setting will remain for the entire test."

   if ( ee ):
      if ( eevalue is not None ):
         print tname, ":  Set error-expires to", eevalue
         error_expires = eevalue
         #
         #   The way this test is set up, have the eevalue > 190 is 
         #   essentially the same as not setting it in terms of results.
         #   So, set the value, but then make it so results will be based
         #   on the idea that it is not set.
         #
         if ( int(eevalue) > 190 ):
            ee = False
      else:
         print tname, ":  error-expires not set as it was expected to be."
         print tname, ":  Test Failed"
         sys.exit(1)
      #end if-else eevalue is not None
   #end if ee

   if ( ue ):
      if ( uevalue is not None ):
         print tname, ":  Set uncrawled-expires to", uevalue
         uncrawled_expires = uevalue
      else:
         print tname, ":  uncrawled-expires not set as it was expected to be."
         print tname, ":  Test Failed"
         sys.exit(1)
      #end if-else uevalue is not None
   #end if eu

   ####################################################################

   print tname, ":  ##################"
   print tname, ":  Set user/password to make collection data inaccessible"
   print tname, ":  This is a fully errored crawl.  No data is accessed"
   print tname, ":  because the username/password for the samba target is"
   print tname, ":  wrong.  The expectation is that the indexed data will"
   print tname, ":  be altered based on error-expired or uncrawled-expired."

   update_config_and_restart(base_file, collection_file,
                             collection_name, 1)
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  ##################"
   print tname, ":  Get case data"
   counter = 0
   doccount2 = 0
   while ( counter < 10 ):
      if ( doccount2 <= doccount1 ):
         print tname, ":  Query to check data, pass =", counter + 1
         #
         #   Allow time for error-expires or uncrawled-expires to kick in.
         #
         time.sleep(10)
         resp = yy.api_qsearch(source=collection_name, num=1000000,
                               query='', filename='second_dump')

         doccount2 = yy.getTotalResults(resptree=resp, filename='second_dump')
         if ( ee ):
            print tname, ":      Document counts, Expected = ( less than", doccount1, ")"
         else:
            print tname, ":      Document counts, Expected =", doccount1 
         print tname, ":                         Actual =", doccount2
      #end if
      counter += 1
   #end while

   casecount += 1
   if ( ue ):
      if ( doccount1 == doccount2 ):
         cs_pass += 1
         print tname, "   Case Passed"
      else:
         print tname, "   Case Failed"
   elif ( ee ):
      if ( doccount1 != doccount2 ):
         cs_pass += 1
         print tname, "   Case Passed"
      else:
         print tname, "   Case Failed"
   else:
      if ( doccount1 == doccount2 ):
         cs_pass += 1
         print tname, "   Case Passed"
      else:
         print tname, "   Case Failed"

   ####################################################################

   print tname, ":  ##################"
   print tname, ":  Set user/password to make collection data accessible"
   print tname, ":  The expectation is that the indexed data will"
   print tname, ":  be as it was from the original crawl."

   request_timeout = 'unset'
   connector_timeout = 'unset'
   max_bytes = 'unset'

   update_config_and_restart(base_file, collection_file,
                             collection_name, None)
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  ##################"
   print tname, ":  Get case data"
   counter = 0
   doccount2 = 0
   while ( counter < 10 ):
      if ( doccount2 <= doccount1 ):
         print tname, ":  Query to check data, pass =", counter + 1
         #
         #   Allow time for error-expires or uncrawled-expires to kick in.
         #
         time.sleep(10)
         resp = yy.api_qsearch(source=collection_name, num=1000000,
                               query='', filename='second_dump')

         doccount2 = yy.getTotalResults(resptree=resp, filename='second_dump')
         print tname, ":      Document counts, Expected =", doccount1 
         print tname, ":                         Actual =", doccount2
      #end if
      counter += 1
   #end while

   casecount += 1
   if ( doccount1 == doccount2 ):
      cs_pass += 1
      print tname, "   Case Passed"
   else:
      print tname, "   Case Failed"

   ####################################################################

   print tname, ":  ##################"
   print tname, ":  Reset user/password to make collection data accessible"
   print tname, ":  The previous access error now should be gone."
   print tname, ":  Set the following values:"
   print tname, ":     timeout = 1"
   print tname, ":     request-timeout = 1"
   print tname, ":     max-bytes = 1"

   request_timeout = '1'
   connector_timeout = '1'
   max_bytes = '1'

   update_config_and_restart(base_file, collection_file,
                             collection_name, None)
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  ##################"
   print tname, ":  Get case data"
   counter = 0
   doccount2 = 0
   while ( counter < 10 ):
      print tname, ":  Query to check data, pass =", counter + 1
      #
      #   Allow time for error-expires or uncrawled-expires to kick in.
      #
      time.sleep(10)
      resp = yy.api_qsearch(source=collection_name, num=1000000,
                            query='', filename='third_dump')

      doccount2 = yy.getTotalResults(resptree=resp, filename='third_dump')
      print tname, ":      Document counts, Expected =", doccount1 
      print tname, ":                         Actual =", doccount2
      counter += 1
   #end while

   casecount += 1
   if ( doccount1 == doccount2 ):
      cs_pass += 1
      print tname, "   Case Passed"
   else:
      print tname, "   Case Failed"

   outercount = 0
   while ( outercount < 2 ):
      update_config_and_restart(base_file, collection_file,
                                collection_name, None)
      xx.wait_for_idle(collection=collection_name)

      print tname, ":  ##################"
      print tname, ":  Second errored refresh"
      if ( ee ):
         print tname, ":  The New Value data should be smaller than Old Value"
      else:
         print tname, ":  The New Value data should be the same as the Old Value"

      print tname, ":  ##################"
      print tname, ":  Get case data"
      counter = 0
      doccount2 = 0
      while ( counter < 10 ):
         print tname, ":  Query to check data, pass =", counter + 1
         #
         #   Allow time for error-expires or uncrawled-expires to kick in.
         #
         time.sleep(10)
         resp = yy.api_qsearch(source=collection_name, num=1000000,
                               query='', filename='fourth_dump')

         doccount2 = yy.getTotalResults(resptree=resp, filename='fourth_dump')
         if ( ue ):
            print tname, ":  The following two values should be equal"
         else:
            print tname, ":  The Old Value should be >= New Value"
         print tname, ":      Document counts, Old Value =", doccount1 
         print tname, ":                       New Value =", doccount2
         counter += 1
      #end while

      casecount += 1
      if ( ue ):
         if ( doccount1 == doccount2 ):
            cs_pass += 1
            print tname, "   Case Passed"
         else:
            print tname, "   Case Failed"
      else:
         if ( doccount1 >= doccount2 ):
            cs_pass += 1
            print tname, "   Case Passed"
         else:
            print tname, "   Case Failed"
      outercount += 1
   #end while outercount

   #if ( ee and ue ):
   #   if ( int(uevalue) >= int(eevalue) ):
   #      if ( doccount1 == doccount2 ):
   #         cs_pass += 1
   #   else:
   #      if ( doccount1 != doccount2 ):
   #         cs_pass += 1
   #elif ( ee ):
   #      if ( doccount1 != doccount2 ):
   #         cs_pass += 1
   #else:
   #   if ( doccount1 == doccount2 ):
   #      cs_pass += 1

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

   if ( cs_pass == casecount ):
      yy.api_sc_delete(collection=collection_name)
      print tname, ":  Test Passed"
      os.remove(base_file)
      sys.exit(0)
   #end if

   print tname, ":  Test Failed"
   sys.exit(1)
