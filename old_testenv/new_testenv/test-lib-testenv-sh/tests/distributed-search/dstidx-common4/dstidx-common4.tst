#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic 
import build_schema_node, random
import getopt, subprocess, host_environ
import velocityAPI
from threading import Thread
from lxml import etree

#
#   Cheesy, but it works here.
#
def isfqdn(name=None):

   domain_tail = ['com', 'net', 'org', 'xxx']

   justthename = name.split(':')
   tail = justthename[0].split('.')

   z = len(tail)
   z = z - 1

   for item in domain_tail:
      if ( tail[z] == item ):
         return True

   return False

def fullsysname(name=None):

   if ( isfqdn(name) ):
      return name
   else:
      name = name + '.test.vivisimo.com'

   return name

###############################################################
#
#
#   Service killer thread class.
#
#
class doServiceDeath ( Thread ):

   crawler = 'crawler'
   indexer = 'indexer'

   def __init__(self, srvr, collection, which, maxinterval, isaclient):

      Thread.__init__(self)

      self.srvr = srvr
      self.collection = collection
      self.srvtokill = which
      self.maxinterval = maxinterval
      self.isaclient = isaclient

      self.__random_go = random.Random(time.time())

      return

   def get_interval(self):

      return self.__random_go.randint(2, self.maxinterval)
   

   def kill_indexer(self, srvr, collection):

      srvr.vapi.api_sc_indexer_stop(collection=collection, killit='true',
                                    subc='live')

      return

   def kill_indexer_loop(self, srvr, collection):

      global gogo

      while ( gogo ):
         time.sleep(self.get_interval())
         self.kill_indexer(srvr, collection)

      return

   def kill_crawler(self, srvr, collection):

      srvr.vapi.api_sc_crawler_stop(collection=collection, killit='true',
                                    subc='live')

      return

   def kill_crawler_loop(self, srvr, collection):

      global gogo

      while ( gogo ):
         time.sleep(self.get_interval())
         self.kill_crawler(srvr, collection)
         time.sleep(1)
         try:
            srvr.vapi.api_sc_crawler_start(collection=collection, subc='live')
         except:
            print "Crawler restart MAY have failed or it could already be on"

      return

   def run(self):

      global gogo

      while ( not gogo ):
         continue

      if ( self.srvtokill == self.crawler ):
         self.kill_crawler_loop(self.srvr, self.collection)
      else:
         self.kill_indexer_loop(self.srvr, self.collection)

      return

#
#   End service kill thread class
#
###############################################################

###############################################################
#
#
#   Data enqueue thread class
#
#
class doTheEnqueue ( Thread ):

   def __init__(self, directory, srvr, collection, deleteoradd, doia):

      Thread.__init__(self)

      self.filecount = 0

      self.dodelete = deleteoradd
      self.doia = doia
      self.dir = directory
      self.collection = collection
      self.srvr = srvr

      return

   def get_filecount(self):

      return self.filecount

   def enqueue_it(self, srvr, collection, crawl_urls):

      global dumpofd

      dumpofd.write( etree.tostring(crawl_urls) )
      try:
         resp = srvr.vapi.api_sc_enqueue_xml(
                          collection=collection,
                          subc='live',
                          crawl_nodes=etree.tostring(crawl_urls))
         return resp
      except velocityAPI.VelocityAPIexception:
         ex_xml, ex_text = sys.exc_info()[1]
         success = ex_xml.get('name') == 'search-collection-enqueue-invalid'
         if not success:
            print "BARF, unexpected failure"
            print '%s:  %s' % (collection, ex_text)
            print "Enqueue failed"

      return None

   def do_crawl_urls(self, crawl_urls=None, filelist=None,
                     synchro=None, dodelete=False, doia=False):

      #usesynchro = ['none', 'indexed', 'none', 'enqueued', 'indexed-no-sync',
      #               'to-be-indexed', 'indexed-no-sync', 'to-be-crawled',
      #               'indexed-no-sync', 'enqueued']
      #usesynchro = ['enqueued', 'enqueued', 'enqueued', 'enqueued', 'enqueued',
      #              'enqueued', 'enqueued', 'enqueued',
      #              'enqueued', 'enqueued']
      usesynchro = ['indexed-no-sync', 'indexed-no-sync', 'indexed-no-sync', 
                    'indexed-no-sync', 'indexed-no-sync',
                    'indexed-no-sync', 'indexed-no-sync', 'indexed-no-sync',
                    'indexed-no-sync', 'indexed-no-sync']

      thingbomb = 0

      if ( filelist is None ):
         return []

      if ( crawl_urls is None ):
         if ( not doia ):
            print "------->>>>>>> Using crawl-urls schema node"
            crawl_urls = build_schema_node.create_crawl_urls()
         else:
            print "------->>>>>>> Using index-atomic schema node"
            crawl_urls = build_schema_node.create_index_atomic()

      for item in filelist:

         if ( synchro == None ):
            whichone = thingbomb % 10
            thissynchro = usesynchro[whichone]
            thingbomb += 1
         else:
            thissynchro = synchro

         #print item, thissynchro
         fname = os.path.basename(item)

         #print fname

         url = build_a_url(item)
         print url
  
         if ( dodelete ):
            crawl_delete = build_schema_node.create_crawl_delete(url=url,
                                             synchronization=thissynchro,
                                             addnodeto=crawl_urls)
         else:
            crawl_url = build_schema_node.create_crawl_url(url=url,
                        status='complete', enqueuetype='reenqueued',
                        synchronization=thissynchro, addnodeto=crawl_urls)
            crawl_data = build_schema_node.create_crawl_data(encoding='utf-8',
                         contenttype='text/html', addnodeto=crawl_url,
                         filename=item)

      return crawl_urls

   def do_enqueues(self, dir, srvr, collection, dodelete, doia):


      #usesynchro = [None, 'none', 'none', 'indexed-no-sync', 'enqueued',
      #               'to-be-indexed', 'indexed-no-sync', 'to-be-crawled',
      #               'indexed-no-sync', None]

      #usesynchro = ['enqueued', 'enqueued', 'enqueued', 'enqueued', 'enqueued',
      #              'enqueued', 'enqueued', 'enqueued',
      #              'enqueued', 'enqueued']
      usesynchro = ['indexed-no-sync', 'indexed-no-sync', 'indexed-no-sync', 
                    'indexed-no-sync', 'indexed-no-sync',
                    'indexed-no-sync', 'indexed-no-sync', 'indexed-no-sync',
                    'indexed-no-sync', 'indexed-no-sync']

      filecount = 0

      for path, dirs, files in os.walk(dir):

         filelist = []
         crawl_urls = None

         quitcounter = 0
         quitnum = len(files)

         lcnt = 103
         curcnt = 0

         for name in files:

            quitcounter += 1
            if ( quitcounter == quitnum ):
               curcnt = lcnt
            else:
               curcnt += 1

            fullpath = os.path.join(path, name)
            filelist.append(fullpath)
            filecount += 1

            if ( curcnt == lcnt ):
               which = filecount % 10
               synchro = usesynchro[which]
               print "=============================, ", synchro
               crawl_urls = self.do_crawl_urls(crawl_urls, filelist,
                                               synchro, dodelete, doia)
               print "============================="
               curcnt = 0
               lcnt -= 1
               resp = self.enqueue_it(srvr, collection, crawl_urls)
               #print etree.tostring(crawl_urls)
               filelist = []
               crawl_urls = None
               if ( lcnt == 0 ):
                  lcnt = 103
   
         if ( dodelete ):
            print "FILES DELETED (interim):  ", filecount
         else:
            print "FILES ENQUEUED (interim):  ", filecount


      if ( dodelete ):
         print "FILES DELETED (final):  ", filecount
      else:
         print "FILES ENQUEUED (final):  ", filecount

      return filecount

   def run(self):

      self.filecount = self.do_enqueues(self.dir, self.srvr,
                                        self.collection, self.dodelete,
                                        self.doia)

      return
#
#   End enqueue thread class
#
###############################################################

def az_constitution_check(checkfor, thisthing):

   f1 = os.path.basename(checkfor)
   f2 = os.path.basename(thisthing)

   if ( f1 == 'arizona.txt' or f1 == 'constitution.txt' ):
      if ( f2 == 'arizona.txt' or f2 == 'constitution.txt' ):
         print "arizona.txt matches constitution.txt (duplicates)"
         return 1

   return 0


def isInList(checkfor, thelist):

   for item in thelist:
      if ( item == checkfor ):
         return 1
      else:
         pseudo_match = az_constitution_check(checkfor, item)
         if ( pseudo_match == 1 ):
            return 1

   return 0

def create_server_file(collection_list, other_server_collection, lightcrawl,
                       basefile, srv_collection, other_server, srvr_audit):

   auditstring = "<crawl-option name=\"audit-log\">all</crawl-option>\\n<crawl-option name=\"audit-log-detail\">full</crawl-option>\\n<crawl-option name=\"audit-log-when\">finished</crawl-option>"

   root_dir = os.getenv('TEST_ROOT', '../dstidx-common4')

   filename = basefile
   outputfile = srv_collection + ".xml"
   fsn = fullsysname(other_server)

   interimfile = 'interimbase'

   if ( lightcrawl ):
      filename = root_dir + '/tests/distributed-search/dstidx-common4/' + filename
   else:
      filename = root_dir + '/tests/distributed-search/dstidx-common4/' + filename

   if ( srvr_audit ):
      cmdstring = "cat " + filename + " | sed -e \'s;AUDIT__LOG__REPLACE__ME;" + auditstring + ";g\' > remove_audit"
   else:
      cmdstring = "cat " + filename + " | sed -e \'s;AUDIT__LOG__REPLACE__ME;;g\' > remove_audit"

   p = subprocess.Popen(cmdstring, shell=True)
   os.waitpid(p.pid, 0)

   filename = 'remove_audit'

   cmdstring = "cat " + filename + " | sed -e \'s;REPLACE__WITH__ALL__CLIENTS;"

   for item in collection_list:
      cmdstring = cmdstring + item + "\\n"

   cmdstring = cmdstring + other_server_collection + "\\n"

   cmdstring = cmdstring + ";g\' > " + interimfile

   p = subprocess.Popen(cmdstring, shell=True)
   os.waitpid(p.pid, 0)

   cmdstring = "cat " + interimfile + " | sed -e \'s;REPLACE__ONE;"

   cmdstring = cmdstring + fsn

   cmdstring = cmdstring + ";g\' > " + outputfile

   p = subprocess.Popen(cmdstring, shell=True)
   os.waitpid(p.pid, 0)

   try:
      os.remove('remove_audit')
      os.remove('interimbase')
   except:
      print "Nothing to remove, oh well."

   return

def create_client_file(my_server, my_server2, current_client,
                       lightcrawl, clnt_audit):

   auditstring = "<crawl-option name=\"audit-log\">all</crawl-option>\\n<crawl-option name=\"audit-log-detail\">full</crawl-option>\\n<crawl-option name=\"audit-log-when\">finished</crawl-option>"

   baseclnt = 'idxB1B2_clnt'

   client_name = baseclnt + "_" + current_client

   collection_file = client_name + ".xml"

   fsn = fullsysname(my_server)
   fsn2 = fullsysname(my_server2)

   allfsn = fsn + "\\n" + fsn2

   root_dir = os.getenv('TEST_ROOT', '../dstidx-common4')

   if ( lightcrawl ):
      filename = root_dir + '/tests/distributed-search/dstidx-common4/purebaselgtxml'
   else:
      filename = root_dir + '/tests/distributed-search/dstidx-common4/purebasexml'

   if ( clnt_audit ):
      cmdstring0 = "cat " + filename + " | sed -e \'s;AUDIT__LOG__REPLACE__ME;" + auditstring + ";g\' > remove_audit"
   else:
      cmdstring0 = "cat " + filename + " | sed -e \'s;AUDIT__LOG__REPLACE__ME;;g\' > remove_audit"

   filename = 'remove_audit'

   cmdstring = "cat " + filename + " | sed -e \'s;CLIENT__COLLECTION;" + client_name + ";g\' > firstclnt"

   cmdstring1 = "cat firstclnt | sed -e \'s;REPLACE__TWO;" + fsn + ";g\' > nextclnt"

   cmdstring2 = "cat nextclnt | sed -e \'s;REPLACE__ONE;" + fsn2 + ";g\' >" +  collection_file

   p = subprocess.Popen(cmdstring0, shell=True)
   os.waitpid(p.pid, 0)
   p = subprocess.Popen(cmdstring, shell=True)
   os.waitpid(p.pid, 0)
   p = subprocess.Popen(cmdstring1, shell=True)
   os.waitpid(p.pid, 0)
   p = subprocess.Popen(cmdstring2, shell=True)
   os.waitpid(p.pid, 0)

   try:
      os.remove('firstclnt')
      #os.remove('remove_audit')
      os.remove('nextclnt')
   except:
      print "Nothing to remove, oh well."

   return client_name

def usage():

   print "dstidx-enq-del.tst -S <server> -C <client>"
   print "   <server> = server side machine, example: testbed14"
   print "   <client> = client side machine, example: testbed15 testbed11"
   print "   Example cmd:  dstidx-basic-30.tst -S testbed14 -C testbed15i testbed11"

   return

def get_read_only(item, collection):

   try:
      seefoo = item.vapi.api_sc_read_only(collection=collection,
                                          mode='status')
      crostat = item.vapi.getResultGenericTagValue(resptree=seefoo,
                                                   tagname='read-only-state',
                                                   attrname='mode')
   except velocityAPI.VelocityAPIexception:
      ex_xml, ex_text = sys.exc_info()[1]
      print tname, ":  read only status error but continuing"
      print ex_xml.get('name')
      print ex_text
      return 'unknown'

   return crostat


def enable_read_only(item, collection):

   print "Enable read-only on", collection

   try:
      err = item.vapi.api_sc_read_only(collection=collection, mode='enable')
   except velocityAPI.VelocityAPIexception:
      ex_xml, ex_text = sys.exc_info()[1]
      print tname, ":  read only enable error but continuing"
      print ex_xml.get('name')
      print ex_text

   curstat = get_read_only(item, collection)
   while ( curstat != 'enabled' ):
      print "Current read only mode:", curstat, collection
      time.sleep(5)
      curstat = get_read_only(item, collection)

   print "Final read only mode:", curstat, collection

   return curstat

def disable_read_only(item, collection):

   print "Disable read-only on", collection

   try:
      err = item.vapi.api_sc_read_only(collection=collection, mode='disable')
   except velocityAPI.VelocityAPIexception:
      ex_xml, ex_text = sys.exc_info()[1]
      print tname, ":  read only disable error but continuing"
      print ex_xml.get('name')
      print ex_text

   curstat = get_read_only(item, collection)
   while ( curstat != 'disabled' ):
      print "Current read only mode:", curstat, collection
      time.sleep(5)
      curstat = get_read_only(item, collection)

   print "Final read only mode:", curstat, collection

   return curstat

def build_a_url(fullname=None):

   myname = os.path.basename(fullname)

   url = ''.join(['file://', myname])

   return url



def set_up_server(server_collection, other_server_collection, server_basefile, 
                  my_server, collection_list, lightcrawl, other_server,
                  srvr_audit):

   global tname

   srvr = host_environ.HOSTENVIRON(hostname=my_server)
   server_file = server_collection + '.xml'

   create_server_file(collection_list, other_server_collection, lightcrawl, 
                      server_basefile, server_collection,
                      other_server, srvr_audit)

   print tname, ":  ##################"
   print tname, ":  Creating empty server collection", server_collection
   cex = srvr.cgi.collection_exists(collection=server_collection)
   if ( cex == 1 ):
      srvr.cgi.delete_collection(collection=server_collection)

   srvr.vapi.api_sc_create(collection=server_collection, based_on='default-push')

   print tname, ":  ##################"
   print tname, ":  Setting up server collection from", server_file
   srvr.vapi.api_repository_update(xmlfile=server_file)

   return srvr

def set_up_clients(collection_list, client_list):

   global tname

   clnt = []
   print client_list
   for item in client_list:
      print item
      clnt.append(host_environ.HOSTENVIRON(hostname=item))

   cnum = 0
   for item in clnt:
      client_collection = collection_list[cnum]
      client_file = client_collection + ".xml"
      print tname, ":  ##################"
      print tname, ":  Creating empty client collection", client_collection
      cex = item.cgi.collection_exists(collection=client_collection)
      if ( cex == 1 ):
         item.cgi.delete_collection(collection=client_collection)
      item.vapi.api_sc_create(collection=client_collection, based_on='default')

      print tname, ":  ##################"
      print tname, ":  Setting up client collection with", client_file
      item.vapi.api_repository_update(xmlfile=client_file)
      cnum += 1

   return clnt

def start_collection_services(srvr, server_collection,
                              srvr2, server_collection2,
                              clnt, collection_list):

   global tname

   print tname, ":  ##################"
   print tname, ":  Start server crawl (before clients)"
   srvr.vapi.api_sc_crawler_start(collection=server_collection)
   srvr2.vapi.api_sc_crawler_start(collection=server_collection2)

   cnum = 0
   for item in clnt:
      client_collection = collection_list[cnum]
      print tname, ":  ##################"
      print tname, ":  Start client crawl", client_collection
      item.vapi.api_sc_crawler_start(collection=client_collection)
      cnum += 1


   return

def wait_for_everything_to_idle(srvr, server_collection,
                                srvr2, server_collection2, 
                                clnt, collection_list, waitcount,
                                wait_from):

   global tname

   print tname, ":  ##################"
   print tname, ":  Wait for server crawl to go idle"

   srvr.cgi.wait_for_idle(collection=server_collection)
   s1 = srvr.vapi.api_get_crawler_sync_status(collection=server_collection)

   srvr2.cgi.wait_for_idle(collection=server_collection2)
   s2 = srvr2.vapi.api_get_crawler_sync_status(collection=server_collection2)

   cnum = 0
   client_sync = 'synchronized'
   for item in clnt:
      client_collection = collection_list[cnum]
      print tname, ":  ##################"
      print tname, ":  Wait for client crawl to go idle", client_collection
      print tname, ":  Wait for idle point of origin is", wait_from
      item.cgi.wait_for_idle(collection=client_collection)
      c1 = item.vapi.api_get_crawler_sync_status(collection=client_collection)
      if ( c1 != 'synchronized' ):
         client_sync = c1
      cnum += 1

   if ( s1 == 'synchronizing' or
        s2 == 'synchronizing' or
        client_sync == 'synchronizing' ):
      print "Synchronization not complete, wait some more"
      print "   Servers are", s1, s2
      print "   Clients are", client_sync
      waitcount += 1
      if ( waitcount < 60 ):
         wait_for_everything_to_idle(srvr, server_collection,
                                     srvr2, server_collection2,
                                     clnt, collection_list,
                                     waitcount, wait_from)
      else:
         print "Synchronization not complete, but wait cycle is over"
         print "Test will likely fail for missing documents in client(s)"

   return

def deathWish(srvr, server_collection, 
              clnt, collection_list, 
              indexercrash, crawlercrash,
              numtocrash, killmaxinterval):

   vertigo = []
   numclnts = len(clnt)

   if ( numtocrash > numclnts ):
      numtocrash = numclnts

   #
   #   Take the server side stuff and start killing it.
   #

   #
   #   Server Indexer
   #
   if ( indexercrash == 1 or indexercrash == 3 ):
      deathangel = doServiceDeath(srvr, server_collection,
                                  "indexer", killmaxinterval, False)
      vertigo.append(deathangel)
      deathangel.start()

   #
   #   Server Crawler
   #
   if ( crawlercrash == 1 or crawlercrash == 3 ):
      deathangel = doServiceDeath(srvr, server_collection,
                                  "crawler", killmaxinterval + 5, False)
      vertigo.append(deathangel)
      deathangel.start()

   #
   #   Take the client side stuff and start killing it.
   #

   i = 0
   while ( i < numtocrash ):
      #
      #   Client Indexer
      #
      if ( indexercrash == 2 or indexercrash == 3 ):
         deathangel = doServiceDeath(clnt[i], collection_list[i],
                                     "indexer", killmaxinterval, True)
         vertigo.append(deathangel)
         deathangel.start()

      #
      #   Client Crawler
      #
      if ( crawlercrash == 2 or crawlercrash == 3 ):
         deathangel = doServiceDeath(clnt[i], collection_list[i], 
                                     "crawler", killmaxinterval + 5, True)
         vertigo.append(deathangel)
         deathangel.start()

      i += 1

   return vertigo

#####################################################################
#   
#   Yes, these routines do the same thing.  But they print different
#   things.  If I didn't need the output, I'd have combined these
#   three routines into one since they are all basically identical.
#   Since the logic for the print is easier this way, I did not.
#
#   And it is easier to see what I'm doing.
#
#
def set_light_crawler_value(a, srvlight, crllight):

   if ( a == 'srvr' ):
      print "Server side will use light crawler"
      srvlight = True

   if ( a == 'clnt' ):
      print "Client side(s) will use light crawler"
      crllight = True

   return srvlight, crllight

def process_ia_flags(a, doia1, doia2):

   if ( a == 'srvr1' ):
      print "Server1 will have index atomic enabled"
      doia1 = True

   if ( a == 'srvr2' ):
      print "Server2 will have index atomic enabled"
      doia2 = True

   if ( a == 'None' ):
      print "No servers will have index atomic enabled"
      doia1 = False
      doia2 = False

   return doia1, doia2

def final_check(clnt, collection_list):

   fail = 0

   exp1 = 'file://164.US.686.213.html'
   exp2 = 'file://164.US.1.48.html'

   clntresp = []
   cnum = 0
   for item in clnt:
      client_collection = collection_list[cnum]
      clntresp.append(item.vapi.api_qsearch(source=client_collection,
                                            num=100000,
                                            query='flandip', 
                                            filename='clnt_search'))
      cnum += 1

   clnturllst = []
   cnum = 0
   for item in clnt:
      clnturllst.append(item.vapi.getResultUrls(resptree=clntresp[cnum],
                                                filename='clnt_search'))
      cnum += 1

   for thing in clnturllst:
      for item in thing:
         if ( item != exp1 ):
            print "Expected URL:", exp2
            print "Actual URL:", item
            fail += 1


   clntresp = []
   cnum = 0
   for item in clnt:
      client_collection = collection_list[cnum]
      clntresp.append(item.vapi.api_qsearch(source=client_collection,
                                            num=100000,
                                            query='Ford AND Prefect', 
                                            filename='clnt_search'))
      cnum += 1

   clnturllst = []
   cnum = 0
   for item in clnt:
      clnturllst.append(item.vapi.getResultUrls(resptree=clntresp[cnum],
                                                filename='clnt_search'))
      cnum += 1

   for thing in clnturllst:
      for item in thing:
         if ( item != exp2 ):
            print "Expected URL:", exp2
            print "Actual URL:", item
            fail += 1


   return fail


def check_data(srvr, server_collection, clnt, verbose, expectedcnt):

   fail = 0

   Sexpected = expectedcnt
   Cexpected = expectedcnt
   Cexpected1 = expectedcnt

   srvrresp = srvr.vapi.api_qsearch(source=server_collection, num=100000,
                                    query='', filename='srvr_search')
   clntresp = []
   cnum = 0
   for item in clnt:
      client_collection = collection_list[cnum]
      clntresp.append(item.vapi.api_qsearch(source=client_collection,
                                            num=100000,
                                            query='', filename='clnt_search'))
      cnum += 1

   #
   #   Check that recorded values are identical
   #
   srvridxcnt = srvr.vapi.getTotalResults(resptree=srvrresp,
                                          filename='srvr_search')
   clntidxcnt = []
   cnum = 0
   for item in clnt:
      clntidxcnt.append(item.vapi.getTotalResults(resptree=clntresp[cnum],
                                               filename='clnt_search'))
      cnum += 1

   print tname, ":  ##################"


   for item in clntidxcnt:
      if ( srvridxcnt != Sexpected or
           ( item != Cexpected and item != Cexpected1 ) ):
         print tname, ":  total results differ between client and server"
         print tname, ":  client results = ", item
         print tname, ":  server results = ", srvridxcnt
         print tname, ":  expected results(clients) = ", Cexpected
         print tname, ":  expected results(servers) = ", Sexpected
         fail = 1
      else:
         print tname, ":  total results are correct at ", Cexpected, Sexpected

   #
   #   Check that url counts are identical
   #

   if ( Cexpected == Sexpected ):
      srvrurlcnt = srvr.vapi.getResultUrlCount(resptree=srvrresp,
                                               filename='srvr_search')

      cnum = 0
      clnturlcnt = []
      for item in clnt:
         clnturlcnt.append(item.vapi.getResultUrlCount(resptree=clntresp[cnum],
                                                       filename='clnt_search'))
         cnum += 1

      print tname, ":  ##################"


      for item in clnturlcnt:
         if ( srvrurlcnt != item ):
            print tname, ":  total url results differ between client and server"
            print tname, ":  client results = ", item
            print tname, ":  server results = ", srvrurlcnt
            fail = 1
         else:
            print tname, ":  total url results are correct at ", srvrurlcnt

      #
      #   Check the urls are as identical as they should be
      #
      srvrurllst = srvr.vapi.getResultUrls(resptree=srvrresp,
                                        filename='srvr_search')

      clnturllst = []
      cnum = 0
      for item in clnt:
         clnturllst.append(item.vapi.getResultUrls(resptree=clntresp[cnum],
                                                   filename='clnt_search'))
         cnum += 1

      print tname, ":  ##################"

      for item in srvrurllst:
         for thing in clnturllst:
            x = isInList(item, thing)
            if ( x != 1 ):
               print "Expected URL not found(server item not on client): ", item
               fail = 1
            else:
               if ( verbose == 1 ):
                  print "found(srvr): ", item

      for item in clnturllst:
         for thing in item:
            x = isInList(thing, srvrurllst)
            if ( x != 1 ):
               print "Expected URL not found(client item not on server): ", thing
               fail = 1
            else:
               if ( verbose == 1 ):
                  print "found(clnt): ", thing

   return fail

def set_expected_clnt_results(doia1, doia2, which, listlen1, listlen2, dellen):

   successcount = 0
   cucount = 1
   cuscount = 2
   cdcount = 3
   idxacount = 4
   entrycount = 5

   clnt_results = [0, 0, 0, 0, 0, 0]

   if ( which == 0 ):
      clnt_results[successcount] = 7147
      clnt_results[cucount] = 7152
      clnt_results[cuscount] = 0
      clnt_results[cdcount] = 0
      clnt_results[idxacount] = 0
      clnt_results[entrycount] = 7152
      if ( doia1 ):
         clnt_results[idxacount] = clnt_results[idxacount] + listlen1
      if ( doia2 ):
         clnt_results[idxacount] = clnt_results[idxacount] + listlen2
   else:
      clnt_results[successcount] = 7972
      clnt_results[cucount] = 7152
      clnt_results[cuscount] = 0
      clnt_results[cdcount] = 825
      clnt_results[idxacount] = 0
      clnt_results[entrycount] = 7977
      if ( doia1 ):
         clnt_results[idxacount] = clnt_results[idxacount] + listlen1 + dellen
      if ( doia2 ):
         clnt_results[idxacount] = clnt_results[idxacount] + listlen2

   return clnt_results

#
#   End of identical routines, sort of.
#
#####################################################################

if __name__ == "__main__":

   global tname
   global dumpofd
   global gogo

   root_dir = os.getenv('TEST_ROOT', '../dstidx-common4')
   test_root = root_dir + '/tests/distributed-search/dstidx-common4/'

   #
   #   Global fail flag.  As long as this stays 0, the test will pass.
   #   Any failed case will increment this flag.  Any increment will
   #   cause the test to fail.
   #
   fail = 0

   #
   #   Global thread lock.  Threads wait for this value to be true
   #   before proceeding past a wait loop.  The threads will continue
   #   after that until this flag is again set to False.
   #
   gogo = False

   #
   #   Client/servers to use with program.
   #
   #   Use -S <host name> for setting target server
   #   Use -C <host name> [-C <host name> ...] for setting clients.
   #   There can be many -C options in a command line.
   #
   my_server = None
   my_server2 = None
   my_client = None

   #
   #   Set the data directories (from where data will be read to be
   #   enqueued.
   #   Use -D <data directory> [-D <data directory> ...]
   #
   datadir = None
   datalist = []

   #
   #   Set the delete directories (from where file names will be read to be
   #   used to create deletion urls.
   #   Use -d <delete directory> [-d <delete directory> ...]
   #
   deletedir = None
   deletelist = []

   #
   #   Verbose and/or keep collection flags.
   #   -v  runs in verbose mode
   #   -k  runs and keeps the collections from the test around.
   #   the default is to remove all collections for these tests
   #   so ports that may be reused do not get in the way of other
   #   tests.
   #
   verbose = 0
   keepit = False

   #
   #   Light crawler flags.  Default to false.  Use -L <srvr|clnt> to set
   #
   srvlight = False
   crllight = False

   #
   #   Read only flags.  Default to false.  Use -R <srvr|clnt> to set
   #
   srvro = False
   crlro = False

   #################################################################
   #
   #   The following options control service crashes, i.e. killing
   #   either the crawler or the indexer or both.
   #
   #   Do error flags.  Default to false.
   #   Use -E <srvr_crl|srvr_idx|clnt_crl|clnt_idx> to set
   #      srvr_crl = kill the server side crawler
   #      srvr_idx = kill the server side indexer
   #      clnt_crl = kill the client side crawler
   #      clnt_idx = kill the client side indexer
   #
   crawlercrash = 0
   indexercrash = 0

   #
   #   The number of the clients for which the errors (above) will apply
   #
   numtocrash = 0

   #
   #   Use index atomic nodes for the enqueues
   #
   doia1 = False
   doia2 = False

   #
   #   The max interval in seconds between service kills (above)
   #
   killmaxinterval = 10
   #
   #   End service crash control options
   #
   #################################################################

   dumpofd = open("what_i_did", "w+")
   dumpofd.write("<output>")

   tname = "dstidx-common4"
   server_collection = "idxbasic1A"
   basefile1 = "idxb1basexml"
   server_collection2 = "idxbasic1B"
   basefile2 = "idxb2basexml"
   my_client = None

   print tname, ":  ##################"
   print tname, ":  What is this?"
   print tname, ":     2 servers and any number of clients"
   print tname, ":     the 2 servers each have a different"
   print tname, ":     collection that they serve to each"
   print tname, ":     other and all of the clients."
   print tname, ":     Simplest config:"
   print tname, ":        SRVR(a) -->   SRVR"
   print tname, ":         one   <-- (b)two"
   print tname, ":          \           /"
   print tname, ":           \         /"
   print tname, ":            \       /"
   print tname, ":             \     /"
   print tname, ":              v   v"
   print tname, ":              CLNTs"
   print tname, "######################################"
   print tname, ":   Test that the client finds the correct update"
   print tname, ":   when two updates are applied to two servers in"
   print tname, ":   a situation where the client must choose the"
   print tname, ":   correct update from the two servers."
   print tname, "######################################"

   #####################################################################
   #
   #   Options processing
   #
   #####################################################################
   #
   #   Define options
   #
   opts, args = getopt.getopt(sys.argv[1:], "L:I:S:C:vkm:T:", ["light=", "server=", "client=", "verbose", "keepit", "testname=", "indexatomic="])
   #
   #
   #####################################################################
   #
   #  -C clients
   #  -S servers
   #  -k  (keep collections)
   #  -v  (verbose)
   #  -D  data directory
   #  -d  delete directory
   #  -E  error
   #      clnt_crl, clnt_idx, srvr_crl, srvr_idx
   #  -n  <number>  Number of E to do
   #  -i  kill interval time (seconds)
   #
   #  -R  read only
   #      clnt, srvr
   #  -A  (use index atomic)
   #  -L  (light crawler)
   #      clnt, srvr
   #  -I  use index atomic nodes
   #


   for o, a in opts:
      if o in ("-v", "--verbose"):
         verbose = 1
      if o in ("-I", "--indexatomic"):
         doia1, doia2  = process_ia_flags(a, doia1, doia2)
      if o in ("-k", "--keepit"):
         keepit = True
      if o in ("-T", "--testname"):
         tname = a
      if o in ("-S", "--server"):
         if ( my_server is None ):
            my_server = a
         else:
            my_server2 = a
      if o in ("-C", "--client"):
         if ( my_client is None ):
            my_client = a
         else:
            my_client = my_client + ' ' + a
      if o in ("-L", "--light"):
         srvlight, crllight = set_light_crawler_value(a,
                                        srvlight, crllight)


   #
   #
   #####################################################################

   if ( srvlight ):
      basefile1 = "idxb1baselgtxml"
      basefile2 = "idxb2baselgtxml"

   basefile2_param = "".join([basefile2, ".base"])   

   srvr2_updates = test_root + 'srvr2_updates'
   srvr1_updates = test_root + 'srvr1_updates'

   if ( datadir is None ):
      datalist = ["/testenv/test_data/law/US/1",
                  "/testenv/test_data/law/US/450",
                  "/testenv/test_data/law/F2/450",
                  "/testenv/test_data/law/US/164",
                  "/testenv/test_data/law/US/13",
                  "/testenv/test_data/law/F3/6",
                  "/testenv/test_data/law/F3/351",
                  "/testenv/test_data/law/US/528",
                  "/testenv/test_data/law/US/99",
                  "/testenv/test_data/law/US/316",
                  "/testenv/test_data/law/F2/646",
                  "/testenv/test_data/law/US/27",
                  "/testenv/test_data/law/F2/992",
                  "/testenv/test_data/law/US/75",
                  "/testenv/test_data/law/US/202"]
      deletelist = ["/testenv/test_data/law/US/75",
                    "/testenv/test_data/law/F2/992"]
   else:
      datalist = datadir.split(' ')
      if ( deletedir is not None ):
         deletelist = deletedir.split(' ')

   if ( my_server is None ):
      print "Exiting:  No server set"
      usage()
      sys.exit(1)

   if ( my_client is None ):
      print "Exiting:  No client set"
      usage()
      sys.exit(1)

   print tname, ":  Data to add to idxbasic1A, directory list"
   print tname, ":       ", datalist

   print tname, ":  Data to delete from idxbasic1A, directory list"
   print tname, ":       ", deletelist

   ########################################################

   print tname, ":  ##################"
   print tname, ":  Initialize"
   print tname, ":     Enqueue/crawl combined 1 to 1 or 1 to many"
   print tname, ":     distributed indexing test"

   f = open( ''.join( [test_root, basefile2_param] ), 'r' )
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
   f = open( ''.join( [test_root, basefile2] ), 'w' )
   f.write( config )
   f.close()

   client_list = my_client.split(' ')
   collection_list = []
   for item in client_list:
      collection_list.append(create_client_file(my_server, my_server2, 
                                                item, crllight, False))

   srvr = set_up_server(server_collection, server_collection2, 
                        basefile1, my_server,
                        collection_list, srvlight, my_server2, False)
   srvr.cgi.is_testenv_mounted()
   srvr.cgi.version_check(8.0)

   srvr2 = set_up_server(server_collection2, server_collection, 
                        basefile2, my_server2,
                        collection_list, srvlight, my_server, False)

   clnt = set_up_clients(collection_list, client_list)

   start_collection_services(srvr, server_collection,
                             srvr2, server_collection2, 
                             clnt, collection_list)

   wait_for_everything_to_idle(srvr, server_collection,
                               srvr2, server_collection2, 
                               clnt, collection_list, 0, "LINE 1228")

   zooboo = []
   for item in datalist:
      thing = doTheEnqueue(item, srvr, server_collection, False, doia1)
      thing.start()
      if ( not gogo ):
         gogo = True
      zooboo.append(thing)

   #
   #   359 database records + 44 samba files = 403
   #
   expectedcnt = 403
   for thing in zooboo:
      thing.join()

   for thing in zooboo:
      interimcount = thing.get_filecount()
      expectedcnt = expectedcnt + interimcount
      print "CURRENT COUNT:", expectedcnt

   gogo = False

   wait_for_everything_to_idle(srvr, server_collection,
                               srvr2, server_collection2, 
                               clnt, collection_list, 0, "LINE 1254")

   print tname, ":  ##################"
   print tname, ":  Sleep for 5 seconds so any pending collection"
   print tname, ":  I/O can complete"
   time.sleep(15)

   cnum = 0
   for item in clnt:
      client_collection = collection_list[cnum]
      enable_read_only(item, client_collection)
      cnum += 1

   enable_read_only(srvr, server_collection)

  ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"

   zooboo = []
   for item in deletelist:
      thing = doTheEnqueue(item, srvr2, server_collection2, True, doia2)
      thing.start()
      zooboo.append(thing)

   for thing in zooboo:
      thing.join()

   for thing in zooboo:
      interimcount = thing.get_filecount()
      expectedcnt = expectedcnt - interimcount
      print "DELETED COUNT:", expectedcnt

   #
   #   Acount for multiple index.html files that are now being
   #   IDed for updates
   #
   expectedcnt = expectedcnt - 13

   wait_for_everything_to_idle(srvr, server_collection,
                               srvr2, server_collection2, 
                               clnt, collection_list, 0, "LINE 1295")

   cnum = 0
   for item in clnt:
      client_collection = collection_list[cnum]
      disable_read_only(item, client_collection)
      cnum += 1
   disable_read_only(srvr, server_collection)

   time.sleep(5)

   wait_for_everything_to_idle(srvr, server_collection,
                               srvr2, server_collection2, 
                               clnt, collection_list, 0, "LINE 1308")


   tfail2 = tfail = 0
   tfail = check_data(srvr, server_collection, clnt, verbose, expectedcnt)
   tfail2 = check_data(srvr2, server_collection2, clnt, verbose, expectedcnt)
   if ( tfail > 0 or tfail2 > 0 ):
      tfail = 0
      time.sleep(10)
      tfail = check_data(srvr, server_collection, clnt, verbose, expectedcnt)
      tfail2 = check_data(srvr2, server_collection2, clnt, verbose, expectedcnt)

   fail = fail + tfail + tfail2

   cnum = 0
   for item in clnt:
      client_collection = collection_list[cnum]
      enable_read_only(item, client_collection)
      cnum += 1
   enable_read_only(srvr2, server_collection2)

   thing = doTheEnqueue(srvr1_updates, srvr, server_collection, False, doia1)
   thing.start()
   thing.join()

   time.sleep(10)

   enable_read_only(srvr, server_collection)
   disable_read_only(srvr2, server_collection2)

   thing = doTheEnqueue(srvr2_updates, srvr2, server_collection2, False, doia2)
   thing.start()
   thing.join()

   cnum = 0
   for item in clnt:
      client_collection = collection_list[cnum]
      disable_read_only(item, client_collection)
      cnum += 1
   disable_read_only(srvr, server_collection)

   time.sleep(5)

   wait_for_everything_to_idle(srvr, server_collection,
                               srvr2, server_collection2, 
                               clnt, collection_list, 0, "LINE 1353")


   tfail2 = tfail = 0
   tfail = check_data(srvr, server_collection, clnt, verbose, expectedcnt)
   tfail2 = check_data(srvr2, server_collection2, clnt, verbose, expectedcnt)
   if ( tfail > 0 or tfail2 > 0 ):
      tfail = 0
      time.sleep(10)
      tfail = check_data(srvr, server_collection, clnt, verbose, expectedcnt)
      tfail2 = check_data(srvr2, server_collection2, clnt, verbose, expectedcnt)

   fail = fail + tfail + tfail2

   dumpofd.write("</output>")
   dumpofd.close()

   fail += final_check(clnt, collection_list)

   if ( not keepit ):
      print tname, ":  Deleting all collections to prevent port confusion"
      srvr.cgi.delete_collection(collection=server_collection)
      srvr2.cgi.delete_collection(collection=server_collection2)
      cnum = 0
      for item in clnt:
         client_collection = collection_list[cnum]
         item.cgi.delete_collection(collection=client_collection)
         cnum += 1
   else:
      print tname, ":  WARNING, the collections still exist.  It is"
      print tname, ":           possible that other tests may have issues"
      print tname, ":           due to the ports these collections use"


   if ( fail == 0 ):
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"

   sys.exit(1)


