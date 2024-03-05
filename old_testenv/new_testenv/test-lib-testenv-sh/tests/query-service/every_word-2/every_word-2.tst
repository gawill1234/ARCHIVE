#!/usr/bin/python

import os, sys, string, subprocess, time, test_helpers
import tc_generic, cgi_interface, vapi_interface


def fix_url_list(myurllist):

   newlist = []

   if ( xx.TENV.targetos == "windows" ):
      for item in myurllist:
         item = item.replace('%3a', ':')
         item = item.replace('%5c', '/')
         newlist.append(item)
      return(newlist)

   return myurllist

def is_in_list(xx=None, expvals=None, listtocheck=None):

   result = False

   for item in expvals:
      found = False
      for nitem in listtocheck:
         nitem = os.path.basename(nitem)
         if ( xx.TENV.targetos == "windows" ):
            iteml = item.lower()
            niteml = nitem.lower()
            if ( iteml == niteml ):
               found = True
         else:
            if ( item == nitem ):
               found = True
         if ( found ):
            result = True

   return result

def QueryThis(xx=None, queryString=None, must_have=[]):

   failure = 0
   tname = 'every_word-2'
   reslist = []

   totalquerytime = 0.0

   beginningoftime = time.time()
   yy.api_qsearch(xx=xx, source=collection_name,
                       query=queryString,
                       filename='qry2', qsyn='Default', num=200)
   endoftime = time.time()
   totalquerytime = totalquerytime + (endoftime - beginningoftime)

   urlcount = int(yy.get_query_data(xx=xx, filename='qry2.wazzat',
                                 trib="query-url-count"))

   #print tname, ":  ==================================================="
   #print '%(tname)s :  URL COUNT (\"%(qs)s\") :           %(cnt)d' % \
   #       {'tname': tname, 'qs':queryString, 'cnt':urlcount}
   #print tname, ":  ==================================================="

   if ( urlcount <= 0 ):
      failure = failure + 1
      print tname, ":  ==================================================="
      print tname, ":  FAIL, Expected a urlcount of at least 1"
      print '%(tname)s :  URL COUNT (\"%(qs)s\") :           %(cnt)d' % \
             {'tname': tname, 'qs':queryString, 'cnt':urlcount}
      print tname, ":  ==================================================="

   filename = yy.look_for_file(filename='qry2')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)
   urllist = fix_url_list(urllist)

   ret = is_in_list(xx=xx, expvals=must_have, listtocheck=urllist)
   if ( ret == False ):
      failure = failure + 1
      print tname, ":  ==================================================="
      print tname, ":  FAIL, ", must_have, " not found in urllist"
      print '%(tname)s :  URL COUNT (\"%(qs)s\") :           %(cnt)d' % \
             {'tname': tname, 'qs':queryString, 'cnt':urlcount}
      print tname, ":  ==================================================="


   reslist.append(urlcount)
   reslist.append(totalquerytime)
   reslist.append(failure)
   return reslist



def read_line_into_list(fd=None, tc=None):

   myline = fd.readline()

   if ( myline == '' or myline == None ):
      return None

   #
   #   Translate non-word characters into spaces
   #
   myline = myline.translate(string.maketrans('".,;:[]{}\n\t', '           '))

   myline = tc.listify(myline, ' ')

   return myline

def run_case(xx=None, number=0, mytext=None,
             filename=None, filelist=None):
   
   totalquerycount = 0
   totalhitcount = 0
   totalquerytime = 0.0

   tc = tc_generic.TCINTERFACE()

   if ( filename is not None ):
      fd = open(filename)
   else:
      print tname, ":  Text file is not specified"
      return 1

   tname = 'every_word-2'

   print tname, ":  ################## BEGIN ##########################"
   print tname, ":  CASE ", number
   if ( mytext is not None ):
      print tname, ":     ", mytext

   failure = 0

   if ( filelist is None ):
      print tname, ":  Must have list is not specified"
      return 1

   blurb = read_line_into_list(fd, tc)
   while ( blurb is not None ):

      for item in blurb:
         if ( item.isalnum() ):
            reslist = QueryThis(xx=xx, queryString=item,
                                must_have=filelist)

            totalhitcount = totalhitcount + reslist[0]
            totalquerytime = totalquerytime + reslist[1]
            failure = failure + reslist[2]
            totalquerycount = totalquerycount + 1

      blurb = read_line_into_list(fd, tc)

   fd.close()

   tqaverage = totalquerytime / totalquerycount
   thaverage = totalhitcount / totalquerycount
   print tname, ":     FILE NAME EXPECTED IN RESULTS"
   print tname, ":     -----------------------------"
   print tname, ":        ", filelist
   print tname

   print tname, ":     TOTAL QUERIES EXECUTED FOR FILE"
   print tname, ":     -------------------------------"
   print tname, ":        ", totalquerycount
   print tname

   print tname, ":     TOTAL QUERY TIME OF ALL QUERIES"
   print tname, ":     -------------------------------"
   print tname, ":        ", totalquerytime
   print tname

   print tname, ":     AVERAGE QUERY TIME OF QUERIES"
   print tname, ":     -----------------------------"
   print tname, ":        ", tqaverage
   print tname

   print tname, ":     AVERAGE QUERY RESULTS PER QUERY"
   print tname, ":     -------------------------------"
   print tname, ":        ", thaverage
   print tname


   if ( failure == 0 ):
      print tname, ":  CASE PASSED"
   else:
      print tname, ":  CASE FAILED"
   print tname, ":  ################### END ###########################"

   return failure


if __name__ == "__main__":


   collection_name = "every_word-2"
   tname = 'every_word-2'

   colfile = ''.join([collection_name, '.xml'])
   basefile = ''.join([colfile, '.base'])
   i = 0

   failure = 0

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  Query every word in various files"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   xx.version_check(7.5)

   thelper = test_helpers.TEST_HELPERS(yy, xx, None, tname)
   thelper.set_linux_samba_collection_access_data(basefile, colfile)

   xx.create_collection(collection=collection_name, usedefcon=0)
   xx.start_crawl(collection=collection_name)

   thebeginning = time.time()
   xx.wait_for_idle(collection=collection_name)

   #
   #   this contains the function to turn a string into a list
   #   of tokens.
   #

   filelist = ['employee_contact_info.xls']
   casetext = 'Every word in a xls file'
   failure = failure + run_case(xx=xx, number=1, mytext=casetext,
                                filename='employee_contact_info.csv',
                                filelist=filelist)

   filelist = ['iroquois.txt']
   casetext = 'Every word in a ascii text file'
   failure = failure + run_case(xx=xx, number=2, mytext=casetext,
                                filename='iroquois.txt',
                                filelist=filelist)

   filelist = ['constitution.doc']
   casetext = 'Every word in a .doc file'
   failure = failure + run_case(xx=xx, number=3, mytext=casetext,
                                filename='constitution.txt',
                                filelist=filelist)

   xx.kill_all_services()

   if ( failure == 0 ):
      xx.delete_collection(collection=collection_name)
      os.remove(colfile)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)


