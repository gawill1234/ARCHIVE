#!/usr/bin/python


import sys, time, cgi_interface, vapi_interface, shutil

if __name__ == "__main__":

   maxcount = 10
   i = 0
   cs_pass = 0
   casecount = 0
   num = 500
   clustercount = 10
   cluster = 'true'
   perpage = 10

   tname = 'api-query-browse-1'
   collection_name = "aqb-1"
   colfile = ''.join([collection_name, '.xml'])

   ##############################################################
   print tname, ":  ########################"
   print tname, ":  INITIALIZE"
   print tname, ":  query-browse (test 1)"
   print tname, ":     Basic create and use query-browse file"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   xx.create_collection(collection=collection_name, usedefcon=0)
   xx.start_crawl(collection=collection_name)

   thebeginning = time.time()
   xx.wait_for_idle(collection=collection_name)

   ##############################################################
   print tname, ":  ########################"
   print tname, ":  TEST CASES BEGIN"



   print tname, ":  ########################"
   print tname, ":  CASE 1, Basic query-browse"
   casecount = casecount + 4
   spt = 2
   yy.api_qsearch(xx=xx, source=collection_name, query='Hamilton',
                  num=10, filename='Ham1')

   yy.api_qsearch(xx=xx, source=collection_name, query='Hamilton',
                  num=10, filename='Ham2', browse='true')
  
   dumpfile = yy.get_qresult_file(xx=xx, filename='Ham2')

   print tname, ":  Do the query-browse on the query-search file"
   print tname, ":     and save the file to HamQB"
   yy.api_query_browse(xx=xx, qbfname=dumpfile, filename="HamQB")

   print tname, ":  Get the file created by query-search for query-browse"
   print tname, ":     and save the file to querywork/", dumpfile
   if ( dumpfile != 'None' ):
      sep = '/'
      if ( yy.TENV.targetos == "windows" ):
         sep = "\\"
      mydir = xx.vivisimo_dir(which="tmp")
      fullfile = ''.join([mydir, sep, dumpfile])
      xx.get_file(getfile=fullfile)
      shutil.move(dumpfile, "querywork")


   print tname, ":  ########################"
   print tname, ":  CASE 1A"
   print tname, ":  Ham1 data, straight query-search"
   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum="1a",
                                             clustercount=0,
                                             perpage=3, num=3, filename='Ham1',
                                             testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum="1a",
                                             clustercount=0,
                                             perpage=4, num=4, filename='Ham1',
                                             testname=tname)

   print tname, ":  ########################"
   print tname, ":  CASE 1B"
   print tname, ":  Ham2 data, query-search with browse = true"
   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum="1b",
                                             clustercount=0,
                                             perpage=3, num=3, filename='Ham2',
                                             testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum="1b",
                                             clustercount=0,
                                             perpage=4, num=4, filename='Ham2',
                                             testname=tname)

   print tname, ":  ########################"
   print tname, ":  CASE 1C"
   print tname, ": ", dumpfile, "data, should be identical to Ham2"
   print tname, ":    the target file created by query-search"
   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum="1c",
                                             clustercount=0,
                                             perpage=3, num=3,
                                             testname=tname, filename=dumpfile)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum="1c",
                                             clustercount=0,
                                             perpage=4, num=4,
                                             testname=tname, filename=dumpfile)

   print tname, ":  ########################"
   print tname, ":  CASE 1D"
   print tname, ":  HamQB data, should be identical to Ham2"
   print tname, ":    the target file retrieved by query-browse"
   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum="1d",
                                             clustercount=0,
                                             perpage=3, num=3,
                                             testname=tname, filename="HamQB")
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum="1d",
                                             clustercount=0,
                                             perpage=4, num=4,
                                             testname=tname, filename="HamQB")
   print tname, ":  ########################"

   ##############################################################

   xx.kill_all_services()

   if ( cs_pass == casecount ):
      xx.stop_crawl(collection=collection_name, force=1)
      xx.stop_indexing(collection=collection_name, force=1)
      xx.delete_collection(collection=collection_name)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
