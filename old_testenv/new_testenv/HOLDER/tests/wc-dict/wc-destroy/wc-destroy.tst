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

   tname = "wc-destroy"
   collection_name = "wc_destroy"
   colfile = ''.join([collection_name, '.xml'])

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  wc-destroy"
   print tname, ":  Test the deletion of the wildcard dictionary"
   print tname, ":  from an existing collection."
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   xx.create_collection(collection=collection_name, usedefcon=0)
   xx.start_crawl(collection=collection_name, which="live")   
   thebeginning = time.time()
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"


   print tname, ":  ##################"
   print tname, ":  Case 1, Attempt to retrieve the dictionary file"
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
      print tname, ":  Case 1 FAILED"
   
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
      print tname, ":  Case 2 FAILED"
   
   print tname, ":  ##################"
   

   print tname, ":  ##################"
   print tname, ":  Case 3, retrieved dictionary matches known good"
   casecount = casecount + 1
   case_failed = 0
   
   good_dict = "good_dict"
   # Return value of system is shifted by 8 bits.
   result = os.system("diff -q " + candidate_dict + " " + good_dict) / 256
   if ( result != 0 ):
      print tname, ":  Dictionary file does not match known good "
      print tname, ":  Case 3 FAILED"
   else:
      print tname, ":  Dictionary file does matches known good "
      cs_pass = cs_pass + 1
   
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  Case 4, update configuration, test that "
   print tname, ":  collection XML no longer references dictionary"
   casecount = casecount + 1
   case_failed = 0

   xx.stop_indexing(collection=collection_name, which="live")
   time.sleep(5)

   xx.repo_update(importfile="wc_destroy_no_dict.xml")
   time.sleep(5)

   yy.api_sc_update_config(collection=collection_name)
   time.sleep(5)
   xx.delete_file(get_this)
   
   xx.resume_crawl(collection=collection_name, which="live")
   xx.wait_for_idle(collection=collection_name)
   time.sleep(5)

   xx.get_collection_admin_xml(collection=collection_name)
   md5name = xx.get_md5_name(collection=collection_name)
   if ( md5name == "NOFILE" ):
      case_failed = 0
   else:
      case_failed = 1
      
   if ( case_failed == 1 ):
      print tname, ":  Collection XML still contains dictionary "
      print tname, ":  Case 4 FAILED"
   else:
      print tname, ":  Collection XML  no longer contains dictionary "
      cs_pass = cs_pass + 1

   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  Case 5, attempt to DL old dictionary file "
   casecount = casecount + 1
   case_failed = 0

   # delete the old copy of the file
   try:
      print tname, ":  Case 5, remove old dictionary (unnormalized), ", dl_dict
      os.remove(dl_dict)
   except:
      print tname, ":  Case 5, old dictionary (unnormalized) not removed"
      pass

   # attempt to download again.
   xx.get_file(getfile=get_this, binary=1)

   # get_file creates a file whether it was downloaded or not.
   # If it was not downloaded, the filesize will be 0.
   if ( os.path.getsize(dl_dict) != 0 ):
      case_failed = 1

   if ( case_failed == 1 ):
      print tname, ":  Successfully retrieved dictionary file "
      print tname, ":  Case 5 FAILED"
   else:
      print tname, ":  Could not retrieve dictionary file "
      cs_pass = cs_pass + 1
   
   print tname, ":  ##################"

   ##############################################################

   if ( cs_pass == casecount ):
      xx.delete_collection(collection=collection_name)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
