#!/usr/bin/python


import os, sys, time, cgi_interface, vapi_interface 

if __name__ == "__main__":

   maxcount = 10
   i = 0
   cs_pass = 0
   casecount = 0
   num = 500
   clustercount = 10
   cluster = 'true'
   perpage = 10

   tname = "wc-create-2"
   collection_name = "wc_create_2"
   colfile = ''.join([collection_name, '.xml'])

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  wc-create-2 (test 2)"
   print tname, ":  Test the creation of the wildcard dictionary"
   print tname, ":  in an existing."
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   xx.create_collection(collection=collection_name, usedefcon=0)
   xx.start_crawl(collection=collection_name, which="live")   
   thebeginning = time.time()
   xx.wait_for_idle(collection=collection_name)

   xx.stop_indexing(collection=collection_name, which="live")
   time.sleep(5)


   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"

   print tname, ":  ##################"
   print tname, ":  Case 1, test that no dictionary was built"
   casecount = casecount + 1
   case_failed = 0

   xx.get_collection_admin_xml(collection=collection_name)
   md5name = xx.get_md5_name(collection=collection_name)
   if ( md5name == "NOFILE" ):
      case_failed = 0
   else:
      case_failed = 1
   
   
   if ( case_failed == 1 ):
      print tname, ":  Collection XML contains dictionary "
   else:
      print tname, ":  Collection XML does not contain dictionary "
      cs_pass = cs_pass + 1
      
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  Case 2, Update configuration, restart indexer"
   print tname, ":  and test that dictionary was built"
   casecount = casecount + 1
   case_failed = 0

   xx.repo_update(importfile="wc_create_2_dict.xml")
   time.sleep(5)

   yy.api_sc_update_config(collection=collection_name)
   time.sleep(5)
   
   xx.resume_crawl(collection=collection_name, which="live")   
   xx.wait_for_idle(collection=collection_name)
   time.sleep(5)

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
   print tname, ":  Case 3, normalize the dictionary file"
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
   print tname, ":  Case 4, retrieved dictionary matches known good"
   casecount = casecount + 1
   case_failed = 0
   
   good_dict = "good_dict"
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
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)