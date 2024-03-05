#!/usr/bin/python


import sys, time, cgi_interface, vapi_interface 

def get_ranked_query(xx=None, filename=None, trib=None):

   cmd = "xsltproc"

   if ( trib == None ):
      return

   if ( filename == None ):
      return

   arg1 = ''.join([xx.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
   opts = ''.join(['--stringparam mynode query-url-by-rank --stringparam mytrib ', '%s' % trib])
   dumpit = ''.join(['querywork/', filename, '.wazzat'])

   cmdopts = ' '.join([opts, arg1, dumpit])

   y = xx.exec_command_stdout(cmd, cmdopts, None)

   return y


def get_query_data(xx=None, filename=None, trib=None):

   cmd = "xsltproc"

   if ( trib == None ):
      return

   if ( filename == None ):
      return

   arg1 = ''.join([xx.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
   opts = ''.join(['--stringparam mynode ', trib])
   dumpit = ''.join(['querywork/', filename, '.wazzat'])

   cmdopts = ' '.join([opts, arg1, dumpit])

   y = xx.exec_command_stdout(cmd, cmdopts, None)

   return y

def query_result_check(xx, casenum, clustercount, perpage, num, filename=None):

   if ( filename == None ):
      filename = 'query-search'

   cs_pass = 1

   aret = get_query_data(xx=xx, filename=filename, trib='query-retrieve-count')
   ares = get_query_data(xx=xx, filename=filename, trib='query-result-count')
   areq = get_query_data(xx=xx, filename=filename, trib='query-request-count')
   aurl = get_query_data(xx=xx, filename=filename, trib='query-url-count')
   apag = get_query_data(xx=xx, filename=filename, trib='query-page-count')
   aclu = get_query_data(xx=xx, filename=filename, trib='query-cluster-count')

   if ( aret == "" or aret == None ):
      aret = 0
   else:
      aret = int(aret)

   if ( ares == "" or ares == None ):
      ares = 0
   else:
      ares = int(ares)

   if ( areq == "" or areq == None ):
      areq = 0
   else:
      areq = int(areq)

   if ( apag == "" or apag == None ):
      apag = 0
   else:
      apag = int(apag)

   if ( aclu == "" or aclu == None ):
      aclu = 0
   else:
      aclu = int(aclu)

   if ( aurl == "" or aurl == None ):
      aurl = 0
   else:
      aurl = int(aurl)

   if ( ares > 0 ):
      if ( num > ares ):
         num = ares

   print "api-query-search-6:     Clusters:"
   print "api-query-search-6:        Expected:", clustercount
   print "api-query-search-6:        Actual:  ", aclu
   if ( clustercount != aclu ):
      cs_pass = 0
      print "api-query-search-6:        Check Failed"

   print "api-query-search-6:     URLs:"
   print "api-query-search-6:        Expected:", num
   print "api-query-search-6:        Actual:  ", aurl
   if ( num != aurl ):
      cs_pass = 0
      print "api-query-search-6:        Check Failed"

   print "api-query-search-6:     Retrieved:"
   print "api-query-search-6:        Expected:       ", num
   print "api-query-search-6:        Actual:         ", aret
   print "api-query-search-6:        Total Results:  ", ares
   if ( num != aret ):
      cs_pass = 0
      print "api-query-search-6:        Check Failed"

   if ( perpage != 0 ):
      expt = num / perpage
   else:
      expt = 1
   print "api-query-search-6:     Pages:"
   print "api-query-search-6:        Expected:", expt
   print "api-query-search-6:        Actual:  ", apag
   if ( expt != apag ):
      cs_pass = 0
      print "api-query-search-6:        Check Failed"

   if ( cs_pass == 1 ):
      print "api-query-search-6:     CASE", casenum, "PASSED"
   else:
      print "api-query-search-6:     CASE", casenum, "FAILED"

   return cs_pass

def check_result(xx, case=0, inn=None, ccount=None, out=None, filename=None):

   y = 0
   fails = 0
   cmd = "xsltproc"

   if ( filename == None ):
      return

   arg1 = ''.join([xx.TENV.testroot, '/utils/xsl/query_xml.xsl'])

   print "api-query-search-6:     ++++++++++++++++++++++++++++++"
   print "api-query-search-6:     Things that should be there"
   cnt = 0
   for thing in inn:
      y = 0
      opts = ''.join(['--stringparam mynode item_count --stringparam which ', thing])
      dumpit = ''.join(['querywork/', filename, '.wazzat'])

      cmdopts = ' '.join([opts, arg1, dumpit])

      y = int(xx.exec_command_stdout(cmd, cmdopts, None))
      print "api-query-search-6:     =================="
      print "api-query-search-6:     Expect value for", thing, ":", ccount[cnt]
      print "api-query-search-6:     Actual value for", thing, ":", y
      if ( y != ccount[cnt] ):
         print "api-query-search-6:     ABOVE RESULTE IS INCORRECT"
         fails = fails + 1
      print "api-query-search-6:     =================="

      cnt = cnt + 1
   print "api-query-search-6:     ++++++++++++++++++++++++++++++"

   print "api-query-search-6:     ++++++++++++++++++++++++++++++"
   print "api-query-search-6:     Things that should NOT be there"
   for thing in out:
      y = 0
      opts = ''.join(['--stringparam mynode item_count --stringparam which ', thing])
      dumpit = ''.join(['querywork/', filename, '.wazzat'])

      cmdopts = ' '.join([opts, arg1, dumpit])

      y = int(xx.exec_command_stdout(cmd, cmdopts, None))
      print "api-query-search-6:     =================="
      print "api-query-search-6:     Expect value for", thing, ": 0"
      print "api-query-search-6:     Actual value for", thing, ":", y
      if ( y != 0 ):
         print "api-query-search-6:     ABOVE RESULTE IS INCORRECT"
         fails = fails + 1
      print "api-query-search-6:     =================="
   print "api-query-search-6:     ++++++++++++++++++++++++++++++"

   return fails


if __name__ == "__main__":

   maxcount = 10
   i = 0
   cs_pass = 0
   num = 500
   clustercount = 10
   cluster = 'true'
   perpage = 10

   collection_name1 = "aqs-6a"
   collection_name2 = "aqs-6b"
   collection_name3 = "aqs-6db"
   sourcelist = "aqs-6a aqs-6db aqs-6b"

   ##############################################################
   print "api-query-search-6:  ##################"
   print "api-query-search-6:  INITIALIZE"
   print "api-query-search-6:  query-search (test 6)"
   print "api-query-search-6:     output-contents-mode/output-contents"
   print "api-query-search-6:     interaction tests"
   print "api-query-search-6:  Search is done on 3 collections"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   print "api-query-search-6:  PERFORM CRAWLS"
   print "api-query-search-6:     Crawl collection", collection_name1
   #
   #   Samba collection
   #
   xx.create_collection(collection=collection_name1, usedefcon=0)
   xx.start_crawl(collection=collection_name1)
   xx.wait_for_idle(collection=collection_name1)

   print "api-query-search-6:     Crawl collection", collection_name2
   #
   #   Samba collection (duplicate of above, yes I need it)
   #
   xx.create_collection(collection=collection_name2, usedefcon=0)
   xx.start_crawl(collection=collection_name2)
   xx.wait_for_idle(collection=collection_name2)

   print "api-query-search-6:     Crawl collection", collection_name3
   #
   #   DB collection
   #
   xx.create_collection(collection=collection_name3, usedefcon=0)
   xx.start_crawl(collection=collection_name3)
   xx.wait_for_idle(collection=collection_name3)
   print "api-query-search-6:  CRAWLS COMPLETE"

   thebeginning = time.time()

   ##############################################################
   print "api-query-search-6:  ##################"
   print "api-query-search-6:  TEST CASES BEGIN"


   print "api-query-search-6:  ##################"
   print "api-query-search-6:  CASE 1, DEFAULTS"
   print "api-query-search-6:     output-contents-mode = defaults"
   print "api-query-search-6:     output-contents = <empty>"

   checklist = ['filetype', 'size', 'language', 'snippet', 'title',
                'NATION', 'ALIGNED', 'SHIP_TYPE']
   if ( yy.TENV.targetos == "solaris" ):
      checkcount = [76, 82, 72, 346, 313, 267, 267, 267]
   else:
      checkcount = [82, 88, 78, 352, 319, 267, 267, 267]
   excludes = ['url', 'host', 'URL_LOCATER']

   yy.api_qsearch(xx=xx, vfunc='query-search',
        source=sourcelist, query='',
        cluster='false', fetchtimeout=10000, num=600, filename='defaults')

   res = check_result(xx, case=1, inn=checklist, ccount=checkcount,
                      out=excludes, filename='defaults')
   cs_pass = cs_pass + res
   if ( res == 0 ):
      print "api-query-search-6:  CASE 1 PASSED"
   else:
      print "api-query-search-6:  CASE 1 FAILED"

   print "api-query-search-6:  ##################"

   print "api-query-search-6:  ##################"
   print "api-query-search-6:  CASE 2, list with single output"
   print "api-query-search-6:     output-contents-mode = list"
   print "api-query-search-6:     output-contents = title"

   checklist = ['title']
   if ( yy.TENV.targetos == "solaris" ):
      checkcount = [313]
   else:
      checkcount = [319]
   excludes = ['filetype', 'size', 'language', 'snippet', 'NATION',
               'ALIGNED', 'SHIP_TYPE']

   yy.api_qsearch(xx=xx, vfunc='query-search',
        source=sourcelist, query='',
        cluster='false', fetchtimeout=10000, num=600, filename='title',
        ocmode='list', oclist='title', osumtf='false')

   res = check_result(xx, case=2, inn=checklist, ccount=checkcount,
                      out=excludes, filename='title')
   cs_pass = cs_pass + res
   if ( res == 0 ):
      print "api-query-search-6:  CASE 2 PASSED"
   else:
      print "api-query-search-6:  CASE 2 FAILED"

   print "api-query-search-6:  ##################"

   print "api-query-search-6:  ##################"
   print "api-query-search-6:  CASE 3, list with multiple output"
   print "api-query-search-6:     output-contents-mode = list"
   print "api-query-search-6:     output-contents = NATION ALIGNED"

   checklist = ['NATION', 'ALIGNED']
   checkcount = [267, 267]
   excludes = ['title', 'filetype', 'size', 'language', 'snippet', 'SHIP_TYPE']

   yy.api_qsearch(xx=xx, vfunc='query-search',
        source=sourcelist, query='',
        cluster='false', fetchtimeout=10000, num=600, filename='NATION_ALIGNED',
        ocmode='list', oclist='NATION ALIGNED', osumtf='false')

   res = check_result(xx, case=3, inn=checklist, ccount=checkcount,
                      out=excludes, filename='NATION_ALIGNED')
   cs_pass = cs_pass + res
   if ( res == 0 ):
      print "api-query-search-6:  CASE 3 PASSED"
   else:
      print "api-query-search-6:  CASE 3 FAILED"

   print "api-query-search-6:  ##################"

   print "api-query-search-6:  ##################"
   print "api-query-search-6:  CASE 4, list with multiple items"
   print "api-query-search-6:     output-contents-mode = list"
   print "api-query-search-6:     output-contents = title language"

   checklist = ['title', 'language']
   if ( yy.TENV.targetos == "solaris" ):
      checkcount = [313, 72]
   else:
      checkcount = [319, 78]
   excludes = ['filetype', 'size', 'snippet', 'NATION', 'ALIGNED', 'SHIP_TYPE']

   yy.api_qsearch(xx=xx, vfunc='query-search',
        source=sourcelist, query='',
        cluster='false', fetchtimeout=10000, num=600, filename='title_language',
        ocmode='list', oclist='title language', osumtf='false')

   res = check_result(xx, case=4, inn=checklist, ccount=checkcount,
                      out=excludes, filename='title_language')
   cs_pass = cs_pass + res
   if ( res == 0 ):
      print "api-query-search-6:  CASE 4 PASSED"
   else:
      print "api-query-search-6:  CASE 4 FAILED"

   print "api-query-search-6:  ##################"

   print "api-query-search-6:  ##################"
   print "api-query-search-6:  CASE 5, except with single exception"
   print "api-query-search-6:     output-contents-mode = exception"
   print "api-query-search-6:     output-contents = title"

   checklist = ['filetype', 'size', 'language', 'snippet', 'NATION',
                'ALIGNED', 'SHIP_TYPE']
   if ( yy.TENV.targetos == "solaris" ):
      checkcount = [76, 349, 72, 76, 267, 267, 267]
   else:
      checkcount = [82, 355, 78, 82, 267, 267, 267]
   excludes = ['title']

   yy.api_qsearch(xx=xx, vfunc='query-search',
        source=sourcelist, query='',
        cluster='false', fetchtimeout=10000, num=600, filename='notitle',
        ocmode='except', oclist='title', osumtf='false')

   res = check_result(xx, case=5, inn=checklist, ccount=checkcount,
                      out=excludes, filename='notitle')
   cs_pass = cs_pass + res
   if ( res == 0 ):
      print "api-query-search-6:  CASE 5 PASSED"
   else:
      print "api-query-search-6:  CASE 5 FAILED"

   print "api-query-search-6:  ##################"

   print "api-query-search-6:  ##################"
   print "api-query-search-6:  CASE 6, except with multiple exceptions"
   print "api-query-search-6:     output-contents-mode = except"
   print "api-query-search-6:     output-contents = title NATION"

   checklist = ['filetype', 'size', 'language',
                'ALIGNED', 'SHIP_TYPE', 'snippet',
                'last-modified', 'url', 'host']
   if ( yy.TENV.targetos == "solaris" ):
      checkcount = [76, 349, 72, 267, 267, 76, 86, 353, 353]
   else:
      checkcount = [82, 355, 78, 267, 267, 82, 92, 359, 359]
   excludes = ['title', 'NATION']

   yy.api_qsearch(xx=xx, vfunc='query-search',
        source=sourcelist, query='',
        cluster='false', fetchtimeout=10000, num=600, filename='notitle_NATION',
        ocmode='except', oclist='title NATION', osumtf='false')

   res = check_result(xx, case=6, inn=checklist, ccount=checkcount,
                      out=excludes, filename='notitle_NATION')
   cs_pass = cs_pass + res
   if ( res == 0 ):
      print "api-query-search-6:  CASE 6 PASSED"
   else:
      print "api-query-search-6:  CASE 6 FAILED"

   print "api-query-search-6:  ##################"

   print "api-query-search-6:  ##################"
   print "api-query-search-6:  CASE 7, list with empty content list"
   print "api-query-search-6:     output-contents-mode = list"
   print "api-query-search-6:     output-contents = <empty>"

   checklist = []
   checkcount = []
   excludes = ['title', 'filetype', 'size', 'url', 'host', 'URL_LOCATER',
               'language', 'snippet', 'NATION', 'ALIGNED', 'SHIP_TYPE']

   yy.api_qsearch(xx=xx, vfunc='query-search',
        source=sourcelist, query='',
        cluster='false', fetchtimeout=10000, num=600, filename='nothing',
        ocmode='list', oclist='', osumtf='false')

   res = check_result(xx, case=7, inn=checklist, ccount=checkcount,
                      out=excludes, filename='nothing')
   cs_pass = cs_pass + res
   if ( res == 0 ):
      print "api-query-search-6:  CASE 7 PASSED"
   else:
      print "api-query-search-6:  CASE 7 FAILED"

   print "api-query-search-6:  ##################"

   print "api-query-search-6:  ##################"
   print "api-query-search-6:  CASE 8, except with empty content list"
   print "api-query-search-6:     output-contents-mode = except"
   print "api-query-search-6:     output-contents = <empty>"

   checklist = ['title', 'filetype', 'size', 'url', 'host', 'URL_LOCATER',
                'language', 'snippet', 'NATION', 'ALIGNED', 'SHIP_TYPE',
                'last-modified']
   if ( yy.TENV.targetos == "solaris" ):
      checkcount = [313, 76, 349, 353, 353, 267, 72, 76, 267, 267, 267, 86]
   else:
      checkcount = [319, 82, 355, 359, 359, 267, 78, 82, 267, 267, 267, 92]
   excludes = []

   yy.api_qsearch(xx=xx, vfunc='query-search',
        source=sourcelist, query='',
        cluster='false', fetchtimeout=10000, num=600, filename='everything',
        ocmode='except', oclist='', osumtf='false')

   res = check_result(xx, case=8, inn=checklist, ccount=checkcount,
                      out=excludes, filename='everything')
   cs_pass = cs_pass + res
   if ( res == 0 ):
      print "api-query-search-6:  CASE 8 PASSED"
   else:
      print "api-query-search-6:  CASE 8 FAILED"

   print "api-query-search-6:  ##################"

   print "api-query-search-6:  ##################"
   print "api-query-search-6:  CASE 9, list with non-existant content"
   print "api-query-search-6:     output-contents-mode = list"
   print "api-query-search-6:     output-contents = herbie"

   checklist = []
   checkcount = []
   excludes = ['title', 'filetype', 'size', 'url', 'host', 'URL_LOCATER',
               'language', 'snippet', 'NATION', 'ALIGNED', 'SHIP_TYPE']

   yy.api_qsearch(xx=xx, vfunc='query-search',
        source=sourcelist, query='',
        cluster='false', fetchtimeout=10000, num=600, filename='herbie',
        ocmode='list', oclist='herbie', osumtf='false')

   res = check_result(xx, case=9, inn=checklist, ccount=checkcount,
                      out=excludes, filename='herbie')
   cs_pass = cs_pass + res
   if ( res == 0 ):
      print "api-query-search-6:  CASE 9 PASSED"
   else:
      print "api-query-search-6:  CASE 9 FAILED"

   print "api-query-search-6:  ##################"

   print "api-query-search-6:  ##################"
   print "api-query-search-6:  CASE 10, except with non-existant content"
   print "api-query-search-6:     output-contents-mode = except"
   print "api-query-search-6:     output-contents = hollywood"

   checklist = ['title', 'filetype', 'size', 'url', 'host', 'URL_LOCATER',
                'language', 'snippet', 'NATION', 'ALIGNED', 'SHIP_TYPE']
   if ( yy.TENV.targetos == "solaris" ):
      checkcount = [313, 76, 349, 353, 353, 267, 72, 76, 267, 267, 267]
   else:
      checkcount = [319, 82, 355, 359, 359, 267, 78, 82, 267, 267, 267]
   excludes = []

   yy.api_qsearch(xx=xx, vfunc='query-search',
        source=sourcelist, query='',
        cluster='false', fetchtimeout=10000, num=600, filename='noholly',
        ocmode='except', oclist='hollywood', osumtf='false')

   res = check_result(xx, case=10, inn=checklist, ccount=checkcount,
                      out=excludes, filename='noholly')
   cs_pass = cs_pass + res
   if ( res == 0 ):
      print "api-query-search-6:  CASE 10 PASSED"
   else:
      print "api-query-search-6:  CASE 10 FAILED"
 

   print "api-query-search-6:  ##################"
   #cs_pass = cs_pass + query_result_check(xx=xx, casenum=1, clustercount=0,
   #                                       perpage=4, num=4, filename='Ham1')
   #cs_pass = cs_pass + query_result_check(xx=xx, casenum=1, clustercount=0,
   #                                       perpage=2, num=2, filename='Ham2')
   print "api-query-search-6:  ##################"

   ##############################################################

   xx.kill_all_services()

   if ( cs_pass == 0 ):
      xx.delete_collection(collection=collection_name1)
      xx.delete_collection(collection=collection_name2)
      xx.delete_collection(collection=collection_name3)
      print "api-query-search-6:  Test Passed"
      sys.exit(0)

   print "api-query-search-6:  Test Failed"
   sys.exit(1)
