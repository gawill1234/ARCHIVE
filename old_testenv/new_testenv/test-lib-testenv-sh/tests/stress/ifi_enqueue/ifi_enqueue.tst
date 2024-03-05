#!/usr/bin/python

import threaded_work
import enqueue_tree
import os, sys, time, string
import Queue
import vapi_interface
import cgi_interface
import tc_generic
import getopt
import random
from threading import Thread
import thread
import subprocess

gfailure = 0
gfaillock = None
go_query = False

tname = "ifi_enqueue"

#####################################################
class MyThread(Thread):
   def __init__(self, collection=None, number=0,
                mytext=None, filename=None,
                ofile=None, qryfile=None):

      global tname

      Thread.__init__(self)
      self.collection_name = collection
      self.number = number
      self.mytext = mytext
      self.filename = filename
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
      maxhit = -1
      minhit = -1

      tc = tc_generic.TCINTERFACE()

      if ( self.filename is not None ):
         fd = open(self.filename)
      else:
         self.fd.write('%s :  Text file is not specified\n' % (tname))
         return 1

      tname = 'ifi_enqueue'
   
      self.fd.write('%s :  ################## BEGIN ##########################\n' % (tname))
      self.fd.write('%s :  CASE %d\n' %  (tname, self.number))
      if ( self.mytext is not None ):
         self.fd.write('%s :     %s\n' % ( tname, self.mytext))
   
      failure = 0
   
      qt, blurb, blub, mop  = self.read_line_into_list(fd, tc)
      while ( blurb is not None ):
   
         reslist = self.QueryThis(querytype=qt, queryString=blurb,
                                  expurlcount=int(blub), cop=mop)
  
         totalhitcount = totalhitcount + reslist[0]
         totalquerytime = totalquerytime + reslist[1]
         failure = failure + reslist[2]
         totalquerycount = totalquerycount + 1
         if ( reslist[0] > maxhit ):
            maxhit = reslist[0]
            if ( minhit == -1 ):
               minhit = reslist[0]
         if ( reslist[0] < minhit ):
            minhit = reslist[0]
   
         qt, blurb, blub, mop  = self.read_line_into_list(fd, tc)
   
      fd.close()
   
      tqaverage = totalquerytime / totalquerycount
      thaverage = totalhitcount / totalquerycount
      self.fd.write('%s :     TOTAL QUERIES EXECUTED FOR FILE\n' % (tname))
      self.fd.write('%s :     -------------------------------\n' % (tname))
      self.fd.write('%s :     %d\n\n' % (tname, totalquerycount))
   
      self.fd.write('%s :     TOTAL RETURNS OF ALL QUERIES\n' % (tname))
      self.fd.write('%s :     ----------------------------\n' % (tname))
      self.fd.write('%s :     %d\n\n' % (tname, totalhitcount))
   
      self.fd.write('%s :     TOTAL QUERY TIME OF ALL QUERIES\n' % (tname))
      self.fd.write('%s :     -------------------------------\n' % (tname))
      self.fd.write('%s :     %f\n\n' % (tname, totalquerytime))
   
      self.fd.write('%s :     AVERAGE QUERY TIME OF QUERIES\n' % (tname))
      self.fd.write('%s :     -----------------------------\n' % (tname))
      self.fd.write('%s :     %f\n\n' % (tname, tqaverage))
   
      self.fd.write('%s :     AVERAGE QUERY RESULTS PER QUERY\n' % (tname))
      self.fd.write('%s :     -------------------------------\n' % (tname))
      self.fd.write('%s :     %f\n\n' % (tname, thaverage))

      self.fd.write('%s :     MAXIMUM HITS ON A QUERY\n' % (tname))
      self.fd.write('%s :     -----------------------\n' % (tname))
      self.fd.write('%s :     %d\n\n' % (tname, maxhit))

      self.fd.write('%s :     MINIMUM HITS ON A QUERY\n' % (tname))
      self.fd.write('%s :     -----------------------\n' % (tname))
      self.fd.write('%s :     %d\n\n' % (tname, minhit))
   
   
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
   
   def QueryThis(self, querytype="query", queryString=None, expurlcount=0, cop='eq'):
   
      failure = 0
      tname = 'ifi_enqueue'
      reslist = []
   
      totalquerytime = 0.0
      singlequerytime = 0.0
   
      beginningoftime = time.time()
      if ( querytype == "ficond" ):
         resp = self.yy.api_qsearch(xx=self.xx, source=self.collection_name,
                             query='', qcondxp=queryString,
                             filename=self.qrydump, qsyn='Default', num=500)
      else:
         resp = self.yy.api_qsearch(xx=self.xx, source=self.collection_name,
                             query=queryString,
                             filename=self.qrydump, qsyn='Default', num=500)
      endoftime = time.time()
      singlequerytime = endoftime - beginningoftime
      totalquerytime = totalquerytime + (endoftime - beginningoftime)
   
      fnm = ''.join([self.qrydump, '.wazzat'])
      try:
         urlcount = self.yy.getResultUrlCount(resptree=resp)
         urlcount = int(urlcount)
      except:
         self.fd.write('%s :  get_query_data failure\n' % (tname))
         urlcount = 0
   
      self.fd.write('%s :  =============================================\n' %
                    (tname))
      self.fd.write('%s :  URL COUNT "%s" :           %d\n' %
                    (tname, queryString, urlcount))
      self.fd.write('%s :  QUERY TIME "%s" :           %d\n' %
                    (tname, queryString, singlequerytime))
      self.fd.write('%s :  =============================================\n' %
                    (tname))
   
      #if ( urlcount != expurlcount ):
      if ( docop(urlcount, cop, expurlcount) ):
         failure = failure + 1
         self.fd.write('%s :  =============================================\n' %
                       (tname))
         self.fd.write('%s "  FAIL FAIL FAIL FAIL FAIL FAIL FAIL FAIL FAIL\n' % 
                       (tname))
         self.fd.write('%s "  FAIL, Expected a urlcount of %d\n' %
                       (tname, expurlcount))
         self.fd.write('%s :  URL COUNT "%s" :           %d\n' %
                       (tname, queryString, urlcount))
         self.fd.write('%s :  =============================================\n' %
                       (tname))
   
      reslist.append(urlcount)
      reslist.append(totalquerytime)
      reslist.append(failure)
      return reslist
   
   
   
   def read_line_into_list(self, fd=None, tc=None):
   
      myline = fd.readline().strip('\n')
   
      if ( myline == '' or myline == None ):
         return None, None, None, None
   
      #
      #   Translate non-word characters into spaces
      #
      #myline = myline.translate(string.maketrans('".,;:[]{}\n\t', '           '))
      myline = myline.translate(string.maketrans('\n\t', '  '))
   
      myline = tc.listify(myline, '#')
   
      return myline[0], myline[1], myline[2], myline[3]

def docop(myint1, myop, myint2):

   if ( myop == "ne" ):
      #sys.stdout.write('COMPARE:  %d %s %d\n' % (myint1, myop, myint2))
      return ( (myint1 != myint2) )
   if ( myop == "lt" ):
      #sys.stdout.write('COMPARE:  %d %s %d\n' % (myint1, myop, myint2))
      return ( (myint1 < myint2) )
   if ( myop == "ge" ):
      #sys.stdout.write('COMPARE:  %d %s %d\n' % (myint1, myop, myint2))
      return ( (myint1 >= myint2) )
   if ( myop == "le" ):
      #sys.stdout.write('COMPARE:  %d %s %d\n' % (myint1, myop, myint2))
      return ( (myint1 <= myint2) )
   if ( myop == "eq" ):
      #sys.stdout.write('COMPARE:  %d %s %d\n' % (myint1, myop, myint2))
      return ( (myint1 == myint2) )
   if ( myop == "gt" ):
      #sys.stdout.write('COMPARE:  %d %s %d\n' % (myint1, myop, myint2))
      return ( (myint1 > myint2) )

   #sys.stdout.write('COMPARE(FAIL):  :%d: :%s: :%d:\n' % (myint1, myop, myint2))
   return( False )

def query_loop(collection=None, dummy=0):

    global go_query

    urlcountlist = []
    yy = vapi_interface.VAPIINTERFACE()
    while ( go_query ):
        fnf = ''.join(['qry.', collection, '.interim'])
        beginning = time.time()
        resp = yy.api_qsearch(source=collection,
                       query="NOT file:///bogusfile",
                       filename=fnf, qsyn='Default', num=10)
        endoftime = time.time()

        elapsed = endoftime - beginning
        try:
            urlcount = yy.getTotalResults(resptree=resp)
        except:
            print tname, ": concurrent query result failure"
            urlcount = 0

        print tname, ":  Concurrent query of Collection", collection, " - ", urlcount, "query time =", elapsed
        #urlcountlist.append(urlcount)
        time.sleep(2)

    return

def query_thread(collection=None, threadcount=1, dummy=0):

    threads = [threaded_work.worker(target=query_loop,
                                    args=(collection, dummy))
               for i in xrange(threadcount)]

    for thread in threads:
       thread.join()
   

def usage():

   print 'usage: %s -D <local directory> [-C <collection>] [-u <fake url>]' % sys.argv[0]
   print "  -D directory    :  directory of files to enqueue (required).  Can be"
   print "                     multiple directories provided.  For example"
   print "                     -D <dir1> -D <dir2> ..."
   print "                     Directory use is recursive."
   print "  -C collection   :  default = bigmesstest, Can be multiple uses for"
   print "                     multiple collections.   For example"
   print "                     -C <collection1> -C <collection2> ..."
   print "  -u fake_url     :  default = http://www.bigmesstest.com"
   print "  -t thread_count :  number of threads for enqueue"
   print "  -q              :  if the collections already/still exist, you can"
   print "                     simply query the collections without a new create."
   print "  -d <deletenum>  :  means 1 of every <deletenum> will be deleted"
   print "                     If 0 (zero) is specified, deletenum will be random."
   print "                     If not set, no deletions are done."

   sys.exit(1)

def update_collection_xml(collection=None):

   if ( collection is None ):
      return None

   filename = 'basecollection.xml'
   collfile = collection + '.xml'

   cmdstring = "cat " + filename + " | sed -e \'s;__REPLACE_ME__;" + collection + ";g\' > " + collfile
   p = subprocess.Popen(cmdstring, shell=True)
   os.waitpid(p.pid, 0)

   return collfile


if __name__ == "__main__":

    opts, args = getopt.getopt(sys.argv[1:], "C:D:u:t:qd:e:r:", ["collection=", "directory=", "url=", "threads=", "queryonly", "delete=", "expected=", "randomenq=="])

    base_url = 'http://www.bigmesstest.com'
    collection_list = []
    thread_count = 5
    local_directory = []
    queryonly = False
    delete_which = 0
    ecount = -1
    renq = "True"
    synctype = "indexed"

    g = random.Random(time.time())

    for o, a in opts: 
        if o in ("-C", "--collection"):
           collection_list.append(a)
        if o in ("-D", "--directory"):
           local_directory.append(a)
        if o in ("-u", "--url"):
           base_url = a
        if o in ("-t", "--threads"):
           thread_count = int(a)
        if o in ("-q", "--queryonly"):
           queryonly = True
        if o in ("-e", "--expected"):
           ecount = int(a)
        if o in ("-r", "--randomenq"):
           renq = a
        if o in ("-d", "--delete"):
           delete_which = int(a)
           if ( delete_which <= 0 ): 
              delete_which = g.randint(10, 100)

    if ( renq.lower() == "true" ):
       direct_enqueue = True
    else:
       if ( renq.lower() == "false" ):
          direct_enqueue = False
       else:
          direct_enqueue = "Random"

    if ( collection_list == [] ):
       collection_list.append('bigmesstest')

    if ( not queryonly ):
       if ( local_directory == [] ):
          usage()

    yy = vapi_interface.VAPIINTERFACE()
    xx = cgi_interface.CGIINTERFACE()

    print "Deleting 1 url in every", delete_which

    #yy.api_repository_update(xmlfile='syntax.xml')
    if ( not queryonly ):
       for item in collection_list:
          cex = xx.collection_exists(collection=item)
          if ( cex == 1 ):
             xx.delete_collection(collection=item)

       for item in collection_list:
          yy.api_sc_create(collection=item, based_on='default-push')
          collfile=update_collection_xml(collection=item)
          yy.api_repository_update(xmlfile=collfile)
          yy.api_sc_crawler_start(collection=item,subc='live')
    
       threaded_work.allow_control_c()

       start_query = True
       #
       #   Run queries concurrent with enqueues
       #
       if ( start_query ):
          threadcount = 2
          go_query = True
          qrylist = []
          dummy = 0
          for item in collection_list:
             query_q = threaded_work.top(target=query_thread,
                                         args=(item, threadcount, dummy))
             qrylist.append(query_q)

       for adir in local_directory:
          control_list = []
          for item in collection_list:
             control_q = threaded_work.top(target=enqueue_tree.enqueue_tree,
                                           args=(item,
                                                 adir,
                                                 base_url,
                                                 thread_count,
                                                 delete_which,
                                                 synctype,
                                                 direct_enqueue))
             control_list.append(control_q)

          time.sleep(2)
          for item in control_list:
             status = item.get()
             print 'Final status is', status

          time.sleep(2)

       go_query = False

       for item in collection_list:
          print "Wait for collection: ", item
          xx.wait_for_idle(collection=item)

       time.sleep(3)

    gfaillock = thread.allocate_lock()
    tlist = []
    colz = 0
    for item in collection_list:
       zz = 0
       numthreads = thread_count
       while ( numthreads > 0 ):
  
          casetext = ''.join(['Query of collection ', item])
          if ( numthreads > 0 ):
             zz = zz + 1
             colz = colz + 1
             fnf = ''.join(['qry.', item, '.', "%s" % zz])
             csf = ''.join(['case.', item, '.', "%s" % zz])
             anitem = MyThread(number=zz, mytext=casetext,
                         collection=item,
                         filename='query_list',
                         ofile=csf, qryfile=fnf)
             tlist.append(anitem)
             anitem.start()
             numthreads = numthreads - 1
 
 
    print tname, ":  Thread started, ", colz
 
    for item in tlist:
       print "joining ..."
       item.join()

    #
    #   We are all done.  All of the collections should be the same.
    #   Do a blank query an make sure all collections have the same
    #   final number of urls.
    #
    urlcountlist = []
    yy = vapi_interface.VAPIINTERFACE()
    for item in collection_list:
        fnf = ''.join(['qry.', item, '.final'])
        fnf2 = ''.join(['qry1000.', item, '.final'])
        stime = time.time()
        resp = yy.api_qsearch(source=item,
                       query="",
                       filename=fnf, qsyn='Default', num=10)
        etime = time.time()
        elapse1 = etime - stime

        stime = time.time()
        resp2 = yy.api_qsearch(source=item,
                       query="",
                       filename=fnf2, qsyn='Default', num=10, start=400)
        etime = time.time()
        elapse2 = etime - stime

        try:
            urlcount = yy.getTotalResults(resptree=resp)
        except:
            print tname, ": get final result failure"
            urlcount = 0

        try:
            urlcount2 = yy.getTotalResults(resptree=resp2)
        except:
            print tname, ": get final result failure"
            urlcount = 0

        print tname, ":  Collection", item, " - ", urlcount
        print tname, ":  Collection, s1000,", item, " - ", urlcount2
        print tname, ":  Query times, s0:", elapse1, " s1000:", elapse2
        urlcountlist.append(urlcount)

    if ( ecount >= 0 ):
       basecount = ecount
    else:
       basecount = urlcountlist[0]
    for thing in urlcountlist:
       if ( thing != basecount ):
          gfailure = gfailure + 1
          print tname, ":  Final result check failed"
          print tname, ":     Number of urls in query differ"
          print tname, ":  ", basecount, thing
 
    xx.kill_all_services()
 
    if ( gfailure == 0 ):
       if ( not queryonly ):
          for item in collection_list:
             xx.delete_collection(collection=item)
             collfile = item + '.xml'
             os.remove(collfile)
       print tname, ":  Test Passed"
       sys.exit(0)
 
    print tname, ":  Test Failed"
    sys.exit(1)
 
 
