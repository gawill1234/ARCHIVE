#!/usr/bin/python


import os, sys, time, cgi_interface, vapi_interface
import test_helpers

if __name__ == "__main__":

   maxcount = 10
   i = 0
   cs_pass = 0
   casecount = 0
   num = 500
   clustercount = 10
   cluster = 'true'
   perpage = 10

   tname = "wc-create-1"
   collection_name = "wc_create_1"
   colfile = ''.join([collection_name, '.xml'])
   basefile = ''.join([colfile, '.base'])

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  wc-create-1 (test 1)"
   print tname, ":  Test the creation of the wildcard dictionary"
   print tname, ":  in a new collection."
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   thelper = test_helpers.TEST_HELPERS(yy, xx, None, tname)
   thelper.set_linux_samba_collection_access_data(basefile, colfile)

   xx.create_collection(collection=collection_name, usedefcon=0)
   xx.start_crawl(collection=collection_name, which="live")
   thebeginning = time.time()
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"


   print tname, ":  ##################"
   print tname, ":  Case 1, test that dictionary was built"
   casecount = casecount + 1
   case_failed = 0

   xx.get_collection_admin_xml(collection=collection_name)
   md5name = xx.get_md5_name(collection=collection_name)
   if ( xx.TENV.targetos == "windows" ):
      sep = "\\"
   else:
      sep = "/"

   get_this = xx.get_crawl_dir(collection=collection_name) + sep + md5name

   if ( xx.TENV.targetos == "windows" ):
      fizzy = get_this.replace('\\', '/')
      dl_dict = os.path.basename(fizzy)
   else:
      dl_dict = os.path.basename(get_this)

   try:
      os.remove(dl_dict)
   except:
      pass

   xx.get_file(getfile=get_this, binary=1)

   if ( os.access(dl_dict, os.F_OK) != 0 ):
      print tname, ":  Successfully retrieved dictionary file "
      cs_pass = cs_pass + 1
   else:
      print tname, ":  Could not retrieve dictionary file "

   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  Case 2, normalize the dictionary file"
   casecount = casecount + 1
   case_failed = 0

   candidate_dict = "candidate_dict"

   try:
      os.remove(candidate_dict)
   except:
      pass

   os.system("normalize_dictionary.sh -I " + dl_dict + " -O " + candidate_dict)

   if ( os.access(candidate_dict, os.F_OK) != 0 ):
      print tname, ":  Successfully normalized dictionary file "
      cs_pass = cs_pass + 1
   else:
      print tname, ":  Could not normalize dictionary file "

   print tname, ":  ##################"


   print tname, ":  ##################"
   print tname, ":  Case 3, retrieved dictionary matches known good"
   casecount = casecount + 1
   case_failed = 0

   # Since dictionary includes words from urls, expected dictionary
   # depends on knowledge which samba share we use

   if ( ( os.getenv( 'VIV_SAMBA_LINUX_SERVER' ) ==
             "testbed5.bigdatalab.ibm.com" ) and
        ( os.getenv( 'VIV_SAMBA_LINUX_SHARE' ) == "testfiles" ) ):
      print "Using expected distionary for the old testbed5 samba share"
      good_dict = "good_dict_testbed5"
   elif ( ( os.getenv( 'VIV_SAMBA_LINUX_SERVER' ) ==
               "netapp1a.bigdatalab.ibm.com" ) and
          ( os.getenv( 'VIV_SAMBA_LINUX_SHARE' ) == "testbed5-data" ) ):
      print "Using expected distionary for the new netapp1a samba share"
      good_dict = "good_dict_netapp1a"
   else:
      print "Unknown samba share. Test may fail because of wrong expected dictionary"
      good_dict = "good_dict_testbed5"

   # Return value of system is shifted by 8 bits.
   result = os.system("diff -q " + candidate_dict + " " + good_dict) / 256
   if ( result != 0 ):
      print tname, ":  Dictionary file does not match known good "
   else:
      print tname, ":  Dictionary file does matches known good "
      cs_pass = cs_pass + 1

   print tname, ":  ##################"

   ##############################################################

   if ( cs_pass == casecount ):
      xx.delete_collection(collection=collection_name)
      os.remove(colfile)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
