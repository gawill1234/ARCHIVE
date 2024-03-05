#!/usr/bin/python

#
#   This test does a crawl then looks for every word in 3 of the
#   files in the collection.
#
#   This test runs 3 threads by default (one for each file) so there
#   are multiple queries occurring at the same time.
#
#   Options to the test are:
#      -n:  disable deletion of the collection
#      -N:  disable creation of the collection
#           The above two are useful for doing reruns where you only
#           need the crawl done once.
#      -b:  disable use of the big file
#      -m:  disable use of the medium file
#      -s:  disable use of the small file
#      -t:  modify the number of threads
#

import os, sys, string, subprocess, time
import tc_generic, cgi_interface, vapi_interface
from threading import Thread
import thread
import getopt

gfailure = 0
gfaillock = None

#####################################################
class MyThread(Thread):
   def __init__(self, collection=None, number=0,
                mytext=None, filename=None, filelist=None,
                ofile=None, qryfile=None):
      Thread.__init__(self)
      self.collection_name = collection
      self.number = number
      self.mytext = mytext
      self.filename = filename
      self.filelist = filelist
      self.xx = cgi_interface.CGIINTERFACE()
      self.yy = vapi_interface.VAPIINTERFACE()
      self.zz = tc_generic.TCINTERFACE()
      self.fd = open(ofile, 'w+')
      self.qrydump = qryfile

   def run(self):

      global gfailure, gfaillock
   
      totalquerycount = 0
      totalhitcount = 0
      totalquerytime = 0.0

      tc = tc_generic.TCINTERFACE()

      if ( self.filename is not None ):
         fd = open(self.filename)
      else:
         self.fd.write('%s :  Text file is not specified\n' % (tname))
         return 1

      tname = 'every_word-3'
   
      self.fd.write('%s :  ################## BEGIN ##########################\n' % (tname))
      self.fd.write('%s :  CASE %d\n' %  (tname, self.number))
      if ( self.mytext is not None ):
         self.fd.write('%s :     %s\n' % ( tname, self.mytext))
   
      failure = 0
   
      if ( self.filelist is None ):
         self.fd.write('%s :  Must have list is not specified\n' % (tname))
         return 1
   
      blurb = self.read_line_into_list(fd, tc)
      while ( blurb is not None ):
   
         for item in blurb:
            if ( item.isalnum() ):
               reslist = self.QueryThis(queryString=item,
                                   must_have=self.filelist)
   
               totalhitcount = totalhitcount + reslist[0]
               totalquerytime = totalquerytime + reslist[1]
               failure = failure + reslist[2]
               totalquerycount = totalquerycount + 1
   
         blurb = self.read_line_into_list(fd, tc)
   
      fd.close()
   
      tqaverage = totalquerytime / totalquerycount
      thaverage = totalhitcount / totalquerycount
      self.fd.write('%s :     FILE NAME EXPECTED IN RESULTS\n' % (tname))
      self.fd.write('%s :     -----------------------------\n' % (tname))
      self.fd.write('%s :     %s\n\n' % (tname, self.filelist))
   
      self.fd.write('%s :     TOTAL QUERIES EXECUTED FOR FILE\n' % (tname))
      self.fd.write('%s :     -------------------------------\n' % (tname))
      self.fd.write('%s :     %d\n\n' % (tname, totalquerycount))
   
      self.fd.write('%s :     TOTAL QUERY TIME OF ALL QUERIES\n' % (tname))
      self.fd.write('%s :     -------------------------------\n' % (tname))
      self.fd.write('%s :     %f\n\n' % (tname, totalquerytime))
   
      self.fd.write('%s :     AVERAGE QUERY TIME OF QUERIES\n' % (tname))
      self.fd.write('%s :     -----------------------------\n' % (tname))
      self.fd.write('%s :     %f\n\n' % (tname, tqaverage))
   
      self.fd.write('%s :     AVERAGE QUERY RESULTS PER QUERY\n' % (tname))
      self.fd.write('%s :     -------------------------------\n' % (tname))
      self.fd.write('%s :     %f\n\n' % (tname, thaverage))
   
   
      if ( failure == 0 ):
         self.fd.write('%s : CASE PASSED\n' % (tname))
      else:
         self.fd.write('%s : CASE FAILED\n' % (tname))
      self.fd.write('%s :  ################### END ###########################\n' % (tname))
   
      self.fd.close()

      gfaillock.acquire()
      gfailure = gfailure + failure
      gfaillock.release()

      return failure

   def fix_url_list(self, myurllist):
   
      newlist = []
   
      if ( xx.TENV.targetos == "windows" ):
         for item in myurllist:
            item = item.replace('%3a', ':')
            item = item.replace('%5c', '/')
            newlist.append(item)
         return(newlist)
   
      return myurllist
   
   def is_in_list(self, expvals=None, listtocheck=None):
   
      result = False
   
      for item in expvals:
         found = False
         for nitem in listtocheck:
            nitem = os.path.basename(nitem)
            if ( self.xx.TENV.targetos == "windows" ):
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
   
   def QueryThis(self, queryString=None, must_have=[]):
   
      failure = 0
      tname = 'every_word-3'
      reslist = []
   
      totalquerytime = 0.0
   
      beginningoftime = time.time()
      resp = self.yy.api_qsearch(xx=self.xx, source=self.collection_name,
                          query=queryString,
                          filename=self.qrydump, qsyn='Default', num=200)
      endoftime = time.time()
      totalquerytime = totalquerytime + (endoftime - beginningoftime)
   
      fnm = ''.join([self.qrydump, '.wazzat'])
      try:
         urlcount = self.yy.getResultUrlCount(resptree=resp)
      except:
         self.fd.write('%s :  get_query_data failure\n' % (tname))
         urlcount = 0
   
      #self.fd.write('%s :  =============================================\n' %
      #              (tname))
      #self.fd.write('%s :  URL COUNT "%s" :           %d\n' %
      #              (tname, queryString, urlcount))
      #self.fd.write('%s :  =============================================\n' %
      #              (tname))
   
      if ( urlcount <= 0 ):
         failure = failure + 1
         self.fd.write('%s :  =============================================\n' %
                       (tname))
         self.fd.write('%s "  FAIL, Expected a urlcount of at least 1\n' %
                       (tname))
         self.fd.write('%s :  URL COUNT "%s" :           %d\n' %
                       (tname, queryString, urlcount))
         self.fd.write('%s :  =============================================\n' %
                       (tname))
   
      try:
         urllist = self.yy.getResultUrls(resptree=resp)
         urllist = self.fix_url_list(urllist)
   
         ret = self.is_in_list(expvals=must_have, listtocheck=urllist)
         if ( ret == False ):
            failure = failure + 1
            self.fd.write('%s :  =============================================\n' %
                          (tname))
            self.fd.write('%s :  FAIL, %s not found in urllist\n' %
                          (tname, must_have))
            self.fd.write('%s :  URL COUNT "%s" :           %d\n' %
                          (tname, queryString, urlcount))
            self.fd.write('%s :  =============================================\n' %
                          (tname))
      except:
         failure = failure + 1
         self.fd.write('%s :  get url list failure\n' % (tname))
   
   
      reslist.append(urlcount)
      reslist.append(totalquerytime)
      reslist.append(failure)
      return reslist
   
   
   
   def read_line_into_list(self, fd=None, tc=None):
   
      myline = fd.readline()
   
      if ( myline == '' or myline == None ):
         return None
   
      #
      #   Translate non-word characters into spaces
      #
      myline = myline.translate(string.maketrans('".,;:[]{}\n\t', '           '))
   
      myline = tc.listify(myline, ' ')
   
      return myline
   
   
   
if __name__ == "__main__":


   collection_name = "every_word-3"
   tname = 'every_word-3'

   colfile = ''.join([collection_name, '.xml'])
   basefile = "".join([colfile, ".base"])
   i = 0

   f = open( basefile, 'r' )
   config = f.read()
   f.close()
   config = config.replace( 'VIV_SAMBA_LINUX_SERVER',
     os.getenv( 'VIV_SAMBA_LINUX_SERVER' ) )
   config = config.replace( 'VIV_SAMBA_LINUX_USER',
     os.getenv( 'VIV_SAMBA_LINUX_USER' ) )
   config = config.replace( 'VIV_SAMBA_LINUX_PASSWORD',
     os.getenv( 'VIV_SAMBA_LINUX_PASSWORD' ) )
   config = config.replace( 'VIV_SAMBA_LINUX_SHARE',
     os.getenv( 'VIV_SAMBA_LINUX_SHARE' ) )
   f = open( colfile, 'w' )
   f.write( config )
   f.close()

   #
   #   Option is only to set the number of concurrent threads.
   #   Default is 5
   #
   opts, args = getopt.getopt(sys.argv[1:], "t:nNbms", ["threads=", "nodelete", "nocreate", "bigfile", "mediumfile", "smallfile"])

   docreate = True
   dodelete = True
   bigfile = True
   medfile = True
   smallfile = True
   numthreads = 3
   print tname, ":  max threads =", numthreads
   print tname, ":  delete colletion is true"
   print tname, ":  create collection is true"
   print tname, ":  use of large file is true"
   print tname, ":  use of medium file is true"
   print tname, ":  use of small file is true"
   for o, a in opts:
      if o in ("-t", "--threads"):
         numthreads = int(a)
         print tname, ":  (USE CHANGE)max threads =", numthreads
      if o in ("-n", "--nodelete"):
         dodelete = False
         print tname, ":  (USE CHANGE)delete colletion is false"
      if o in ("-N", "--nocreate"):
         docreate = False
         print tname, ":  (USE CHANGE)create collection is false"
      if o in ("-b", "--bigfile"):
         bigfile = False
         print tname, ":  (USE CHANGE)use of large file is false"
      if o in ("-m", "--mediumfile"):
         medfile = False
         print tname, ":  (USE CHANGE)use of medium file is false"
      if o in ("-s", "--smallfile"):
         smallfile = False
         print tname, ":  (USE CHANGE)use of small file is false"

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  Query every word in various files"
   xx = cgi_interface.CGIINTERFACE()
   xx.version_check(7.5)

   if ( docreate ):
      xx.create_collection(collection=collection_name, usedefcon=0)
      xx.start_crawl(collection=collection_name)
      xx.wait_for_idle(collection=collection_name)

   thebeginning = time.time()

   #
   #   this contains the function to turn a string into a list
   #   of tokens.
   #

   gfaillock = thread.allocate_lock()
   zz = 0
   tlist = []
   while ( numthreads > 0 ):
 
      #
      #   Smaller xls file
      #
      if ( smallfile ):
         filelist = ['employee_contact_info.xls']
         casetext = 'Every word in a xls file'
         if ( numthreads > 0 ):
            zz = zz + 1
            fnf = ''.join(['qry', "%s" % zz])
            csf = ''.join(['case', "%s" % zz])
            anitem = MyThread(number=zz, mytext=casetext,
                        collection=collection_name,
                        filename='employee_contact_info.csv',
                        filelist=filelist, ofile=csf, qryfile=fnf)
            tlist.append(anitem)
            anitem.start()
            numthreads = numthreads - 1

      #
      #   Large text file
      #
      if ( bigfile ):
         filelist = ['iroquois.txt']
         casetext = 'Every word in a ascii text file'
         if ( numthreads > 0 ):
            zz = zz + 1
            fnf = ''.join(['qry', "%s" % zz])
            csf = ''.join(['case', "%s" % zz])
            anitem = MyThread(number=zz, mytext=casetext,
                        collection=collection_name,
                        filename='iroquois.txt',
                        filelist=filelist, ofile=csf, qryfile=fnf)
            tlist.append(anitem)
            anitem.start()
            numthreads = numthreads - 1

      #
      #   Medium doc file
      #
      if ( medfile ):
         filelist = ['constitution.doc']
         casetext = 'Every word in a .doc file'
         if ( numthreads > 0 ):
            zz = zz + 1
            fnf = ''.join(['qry', "%s" % zz])
            csf = ''.join(['case', "%s" % zz])
            anitem = MyThread(number=zz, mytext=casetext,
                        collection=collection_name,
                        filename='constitution.txt',
                        filelist=filelist, ofile=csf, qryfile=fnf)
            tlist.append(anitem)
            anitem.start()
            numthreads = numthreads - 1

   print tname, ":  Thread started, ", zz

   for item in tlist:
      print "joining ..."
      item.join()

   xx.kill_all_services()

   if ( gfailure == 0 ):
      os.remove( colfile )
      if ( dodelete ):
         xx.delete_collection(collection=collection_name)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)


