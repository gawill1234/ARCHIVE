#!/usr/bin/python


import sys, time, cgi_interface, vapi_interface 

if __name__ == "__main__":

   maxcount = 10
   i = 0
   cs_pass = 0
   casecount = 0
   num = 500
   clustercount = 10
   cluster = 'true'
   perpage = 10
   fail = 0

   tname = "17296"
   collection_name = "17296"
   colfile = ''.join([collection_name, '.xml'])

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  17296 (bug test)"
   print tname, ":  Groupnet test with Japanese defaults"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   xx.create_collection(collection=collection_name, usedefcon=0)
   xx.start_crawl(collection=collection_name)

   thebeginning = time.time()
   xx.wait_for_idle(collection=collection_name)

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"


   print tname, ":  ##################"
   print tname, ":  CASE 1, query is blank"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='', num=2500)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1, clustercount=0,
                                          perpage=1992, num=1992,
                                          tr=2032, testname=tname)

   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 2, query is blank"
   print tname, ":          output dups is true"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='',
                  num=2500, odup='true', filename="dups")

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2, clustercount=0,
                                          perpage=2032, num=2032,
                                          tr=2032, testname=tname,
                                          filename="dups")

   print tname, ":  ##################"

   ##############################################################

   if ( cs_pass == casecount and fail == 0 ):
      xx.delete_collection(collection=collection_name)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
