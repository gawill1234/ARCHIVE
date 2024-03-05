#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic 
import build_schema_node, random
import getopt, subprocess, host_environ
import velocityAPI
from threading import Thread
from lxml import etree

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

      return self.__random_go.randint(12, self.maxinterval)
   

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

      usesynchro = ['enqueued', 'enqueued', 'enqueued', 
                    'enqueued', 'enqueued',
                    'enqueued', 'enqueued', 'enqueued',
                    'enqueued', 'enqueued']
      #usesynchro = ['enqueued', 'indexed', 'enqueued', 
      #              'enqueued', 'indexed-no-sync',
      #              'to-be-indexed', 'indexed-no-sync', 'to-be-crawled',
      #              'indexed-no-sync', 'enqueued']
      #usesynchro = ['indexed-no-sync', 'indexed-no-sync', 'indexed-no-sync', 
      #              'indexed-no-sync', 'indexed-no-sync',
      #              'indexed-no-sync', 'indexed-no-sync', 'indexed-no-sync',
      #              'indexed-no-sync', 'indexed-no-sync']

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

         print item, thissynchro
         fname = os.path.basename(item)

         print fname

         url = build_a_url(item)
  
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


      usesynchro = ['enqueued', 'enqueued', 'enqueued', 
                    'enqueued', 'enqueued',
                    'enqueued', 'enqueued', 'enqueued',
                    'enqueued', 'enqueued']

      #usesynchro = ['enqueued', 'indexed', 'enqueued', 
      #              'enqueued', 'indexed-no-sync',
      #              'to-be-indexed', 'indexed-no-sync', 'to-be-crawled',
      #              'indexed-no-sync', 'enqueued']

      #usesynchro = ['indexed-no-sync', 'indexed-no-sync', 'indexed-no-sync',
      #              'indexed-no-sync', 'indexed-no-sync',
      #              'indexed-no-sync', 'indexed-no-sync', 'indexed-no-sync',
      #              'indexed-no-sync', 'indexed-no-sync']

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


def isInList(checkfor, thelist):

   for item in thelist:
      if ( item == checkfor ):
         return 1

   return 0

def create_server_file(collection_list, lightcrawl):

   root_dir = os.getenv('TEST_ROOT', '../dstidx-common')

   if ( lightcrawl ):
      filename = root_dir + '/tests/distributed-search/dstidx-common/basesrvrlgtxml'
   else:
      filename = root_dir + '/tests/distributed-search/dstidx-common/basesrvrxml'

   cmdstring = "cat " + filename + " | sed -e \'s;REPLACE__WITH__ALL__CLIENTS;"
   #if ( lightcrawl ):
   #   cmdstring = "cat basesrvrlgtxml | sed -e \'s;REPLACE__WITH__ALL__CLIENTS;"
   #else:
   #   cmdstring = "cat basesrvrxml | sed -e \'s;REPLACE__WITH__ALL__CLIENTS;"

   for item in collection_list:
      cmdstring = cmdstring + item + "\\n"

   cmdstring = cmdstring + ";g\' > delete_from_srvr.xml"

   p = subprocess.Popen(cmdstring, shell=True)
   os.waitpid(p.pid, 0)

   return

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


def create_client_file(my_server, current_client, lightcrawl):

   baseclnt = 'del_clnt'

   client_name = baseclnt + "_" + current_client

   collection_file = client_name + ".xml"

   if ( isfqdn(my_server) ):
      fsn = my_server
   else:
      fsn = my_server + '.test.vivisimo.com'

   root_dir = os.getenv('TEST_ROOT', '../dstidx-common')

   if ( lightcrawl ):
      filename = root_dir + '/tests/distributed-search/dstidx-common/baseclntlgtxml'
   else:
      filename = root_dir + '/tests/distributed-search/dstidx-common/baseclntxml'

   cmdstring = "cat " + filename + " | sed -e \'s;REPLACE__ME;" + fsn + ";g\' > nextclnt"

   #if ( lightcrawl ):
   #   cmdstring = "cat baseclntlgtxml | sed -e \'s;REPLACE__ME;" + fsn + ";g\' > nextclnt"
   #else:
   #   cmdstring = "cat baseclntxml | sed -e \'s;REPLACE__ME;" + fsn + ";g\' > nextclnt"

   cmdstring2 = "cat nextclnt | sed -e \'s;REPLACE__THIS__CLIENT__NAME;" + client_name + ";g\' >" +  collection_file

   p = subprocess.Popen(cmdstring, shell=True)
   os.waitpid(p.pid, 0)
   p = subprocess.Popen(cmdstring2, shell=True)
   os.waitpid(p.pid, 0)

   try:
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
   except:
      print tname, ":  read only status error but continuing"
      return 'unknown'

   return crostat


def enable_read_only(item, collection):

   try:
      err = item.vapi.api_sc_read_only(collection=collection, mode='enable')
   except:
      print tname, ":  read only enable error but continuing"

   curstat = get_read_only(item, collection)
   if ( curstat != 'enabled' ):
      time.sleep(5)
      curstat = get_read_only(item, collection)

   return curstat

def disable_read_only(item, collection):

   try:
      err = item.vapi.api_sc_read_only(collection=collection, mode='disable')
   except:
      print tname, ":  read only disable error but continuing"

   curstat = get_read_only(item, collection)
   if ( curstat != 'disabled' ):
      time.sleep(5)
      curstat = get_read_only(item, collection)

   return curstat

def build_a_url(fullname=None):

   url = ''.join(['file://', fullname])

   return url



def set_up_server(server_collection, my_server, collection_list, lightcrawl):

   global tname

   srvr = host_environ.HOSTENVIRON(hostname=my_server)

   create_server_file(collection_list, lightcrawl)

   server_file = server_collection + '.xml'

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

def start_collection_services(srvr, clnt):

   global tname

   print tname, ":  ##################"
   print tname, ":  Start server crawl (before clients)"
   srvr.vapi.api_sc_crawler_start(collection=server_collection)

   cnum = 0
   for item in clnt:
      client_collection = collection_list[cnum]
      print tname, ":  ##################"
      print tname, ":  Start client crawl", client_collection
      item.vapi.api_sc_crawler_start(collection=client_collection)
      cnum += 1


   return

def wait_for_everything_to_idle(srvr, clnt, waitcount):

   global tname

   print tname, ":  ##################"
   print tname, ":  Wait for server crawl to go idle"

   if ( waitcount > 0 ):
      time.sleep(5)

   srvr.cgi.wait_for_idle(collection=server_collection)
   s1 = srvr.vapi.api_get_crawler_sync_status(collection=server_collection)

   cnum = 0
   client_sync = 'synchronized'
   for item in clnt:
      client_collection = collection_list[cnum]
      print tname, ":  ##################"
      print tname, ":  Wait for client crawl to go idle", client_collection
      item.cgi.wait_for_idle(collection=client_collection)
      c1 = item.vapi.api_get_crawler_sync_status(collection=client_collection)
      if ( c1 != 'synchronized' ):
         client_sync = c1
      cnum += 1

   if ( s1 == 'synchronizing' or client_sync == 'synchronizing' ):
      print "Synchronization not complete, wait some more"
      print "   Servers are", s1
      print "   Clients are", client_sync
      waitcount += 1
      if ( waitcount < 3 ):
         wait_for_everything_to_idle(srvr, clnt, waitcount)
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

def set_read_only_value(a, srvro, crlro):

   if ( a == 'srvr' ):
      print "Server side will use read only mode"
      srvro = True

   if ( a == 'clnt' ):
      print "Client side(s) will use read only mode"
      crlro = True

   return srvro, crlro

def set_error_crash_value(a, crawlercrash, indexercrash):

   if ( a == 'srvr_crl' ):
      print "Server crawler will be periodically killed"
      crawlercrash = crawlercrash + 1

   if ( a == 'clnt_crl' ):
      print "Client crawler will be periodically killed"
      crawlercrash = crawlercrash + 2

   if ( a == 'srvr_idx' ):
      print "Server indexer will be periodically killed"
      indexercrash = indexercrash + 1

   if ( a == 'clnt_idx' ):
      print "Client indexer will be periodically killed"
      indexercrash = indexercrash + 2

   return crawlercrash, indexercrash

def check_data(srvr, clnt, verbose, expectedcnt, sro, cro, ccrsh, icrsh):

   fail = 0

   if ( sro ):
      Sexpected = expectedcnt
      Cexpected = 0
      Cexpected1 = expectedcnt
   elif ( cro ):
      Sexpected = expectedcnt
      Cexpected = 0
      Cexpected1 = 0
   else:
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
      if ( ccrsh > 0 or icrsh > 0):
         print tname, ":  total results differ between client and server"
         print tname, ":  client results = ", item
         print tname, ":  server results = ", srvridxcnt
         print tname, ":  expected results(clients) = ", Cexpected
         print tname, ":  expected results(servers) = ", Sexpected
         if ( item == srvridxcnt ):
            print tname, ":  Due to crashes, unexpected results are OK"
            print tname, ":  as long as client and server results are equal."
         else:
            print tname, ":  server and client results should be equal."
            fail = 1
      else:
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
               print "Expected URL not found(client item not on server): ", item
               fail = 1
            else:
               if ( verbose == 1 ):
                  print "found(clnt): ", item

   return fail

def compare_audit_log_data(srvr, server_collection, clnt, collection_list):

   fail = 0

   print "#######################################################"
   print tname, ":  Audit numbers for client(s)/server compare"

   resp = srvr.vapi.api_sc_audit_log_retrieve(
                           collection=server_collection, limit=100000)

   srvr_successcount = srvr.vapi.getAuditLogSuccessCount(resptree=resp)
   srvr_cucount = srvr.vapi.getAuditLogEntryCrawlUrlCount(resptree=resp)
   srvr_cuscount = srvr.vapi.getAuditLogEntryCrawlUrlsCount(resptree=resp)
   srvr_cdcount = srvr.vapi.getAuditLogEntryCrawlDeleteCount(resptree=resp)
   srvr_idxacount = srvr.vapi.getAuditLogEntryIndexAtomicCount(resptree=resp)
   srvr_entrycount = srvr.vapi.getAuditLogEntryCount(resptree=resp)
   srvr_token = srvr.vapi.getAuditLogToken(resptree=resp)

   cnum = 0
   for item in clnt:
      clntfail = 0
      print "################################"
      resp = item.vapi.api_sc_audit_log_retrieve(
                       collection=collection_list[cnum], limit=100000)

      clnt_successcount = item.vapi.getAuditLogSuccessCount(resptree=resp)
      clnt_cucount = item.vapi.getAuditLogEntryCrawlUrlCount(resptree=resp)
      clnt_cuscount = item.vapi.getAuditLogEntryCrawlUrlsCount(resptree=resp)
      clnt_cdcount = item.vapi.getAuditLogEntryCrawlDeleteCount(resptree=resp)
      clnt_idxacount = item.vapi.getAuditLogEntryIndexAtomicCount(resptree=resp)
      clnt_entrycount = item.vapi.getAuditLogEntryCount(resptree=resp)
      clnt_token = item.vapi.getAuditLogToken(resptree=resp)

      if ( clnt_successcount != srvr_successcount ):
         clntfail += 1
      if ( clnt_entrycount != srvr_entrycount ):
         clntfail += 1
      if ( clnt_cucount != srvr_cucount ):
         clntfail += 1
      if ( clnt_cuscount != srvr_cuscount ):
         clntfail += 1
      if ( clnt_cdcount != srvr_cdcount ):
         clntfail += 1
      if ( clnt_idxacount != srvr_idxacount ):
         clntfail += 1

      if ( clntfail != 0 ):
         print tname, ":   Audit Log Entry compare failed"

      print tname, ":(server)   Total Audit Log Entries,   ", srvr_entrycount
      print tname, ":(client)   Total Audit Log Entries,   ", clnt_entrycount

      print tname, ":(server)   Total Audit Log Successes, ", srvr_successcount
      print tname, ":(client)   Total Audit Log Successes, ", clnt_successcount

      print tname, ":(server)       crawl-url,             ", srvr_cucount
      print tname, ":(client)       crawl-url,             ", clnt_cucount

      print tname, ":(server)       crawl-urls,            ", srvr_cuscount
      print tname, ":(client)       crawl-urls,            ", clnt_cuscount

      print tname, ":(server)       crawl-deletes,         ", srvr_cdcount
      print tname, ":(client)       crawl-deletes,         ", clnt_cdcount

      print tname, ":(server)       index-atomic,          ", srvr_idxacount
      print tname, ":(client)       index-atomic,          ", clnt_idxacount
      print "################################"
      cnum += 1
      fail = fail + clntfail

   return fail

#
#   End of identical routines, sort of.
#
#####################################################################

if __name__ == "__main__":

   global tname
   global dumpofd
   global gogo

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
   doia = False
   audit = False

   #
   #   The max interval in seconds between service kills (above)
   #
   killmaxinterval = 30
   #
   #   End service crash control options
   #
   #################################################################

   dumpofd = open("what_i_did", "w+")
   dumpofd.write("<output>")

   tname = "dstidx-common"
   server_collection = "delete_from_srvr"
   my_client = None

   #####################################################################
   #
   #   Options processing
   #
   #####################################################################
   #
   #   Define options
   #
   opts, args = getopt.getopt(sys.argv[1:], "IS:C:vlD:d:kE:n:m:L:i:R:T:A", ["server=", "client=", "verbose", "last", "data=", "delete=", "keepit", "error=", "number=", "killinterval=", "light=", "readonly=", "testname=", "indexatomic", "auditlog"])
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
      if o in ("-n", "--num"):
         numtocrash = int(a)
      if o in ("-v", "--verbose"):
         verbose = 1
      if o in ("-I", "--indexatomic"):
         doia = True
      if o in ("-A", "--auditlog"):
         audit = True
      if o in ("-k", "--keepit"):
         keepit = True
      if o in ("-T", "--testname"):
         tname = a
      if o in ("-S", "--server"):
         my_server = a
      if o in ("-C", "--client"):
         if ( my_client is None ):
            my_client = a
         else:
            my_client = my_client + ' ' + a
      if o in ("-D", "--data"):
         if ( datadir is None ):
            datadir = a
         else:
            datadir = datadir + ' ' + a
      if o in ("-d", "--delete"):
         if ( deletedir is None ):
            deletedir = a
         else:
            deletedir = deletedir + ' ' + a
      if o in ("-E", "--error"):
         crawlercrash, indexercrash = set_error_crash_value(a, 
                                          crawlercrash, indexercrash)
         if ( numtocrash == 0 ):
            numtocrash = 1
      if o in ("-i", "--killinterval"):
         killmaxinterval = int(a)

      if o in ("-L", "--light"):
         srvlight, crllight = set_light_crawler_value(a,
                                        srvlight, crllight)

      if o in ("-R", "--readonly"):
         srvro, crlro = set_read_only_value(a,
                                        srvro, crlro)

   #
   #
   #####################################################################

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

   print tname, ":  Data to add to collection, directory list"
   print tname, ":       ", datalist

   print tname, ":  Data to delete from collection, directory list"
   print tname, ":       ", deletelist

   ########################################################

   print tname, ":  ##################"
   print tname, ":  Initialize"
   print tname, ":     Enqueue/crawl combined 1 to 1 or 1 to many"
   print tname, ":     distributed indexing test"

   client_list = my_client.split(' ')
   collection_list = []
   for item in client_list:
      collection_list.append(create_client_file(my_server, item, crllight))

   srvr = set_up_server(server_collection, my_server,
                        collection_list, srvlight)
   srvr.cgi.version_check(8.0)
   srvr.cgi.is_testenv_mounted()

   clnt = set_up_clients(collection_list, client_list)

   start_collection_services(srvr, clnt)

   if ( srvro ):
      enable_read_only(srvr, server_collection)

   if ( crlro ):
      cnum = 0
      for item in clnt:
         client_collection = collection_list[cnum]
         enable_read_only(item, client_collection)
         cnum += 1

   if ( crawlercrash > 0 or indexercrash > 0 ):
      allvertigo = deathWish(srvr, server_collection,
                             clnt, collection_list, 
                             indexercrash, crawlercrash,
                             numtocrash, killmaxinterval)

   zooboo = []
   for item in datalist:
      thing = doTheEnqueue(item, srvr, server_collection, False, doia)
      thing.start()
      if ( not gogo ):
         gogo = True
      zooboo.append(thing)

   expectedcnt = 359
   for thing in zooboo:
      thing.join()
      interimcount = thing.get_filecount()
      expectedcnt = expectedcnt + interimcount
      print "CURRENT COUNT:", expectedcnt

   gogo = False

   if ( crawlercrash > 0 or indexercrash > 0 ):
      for item in allvertigo:
         item.join()

   if ( srvro ):
      disable_read_only(srvr, server_collection)
      expectedcnt = 359

   wait_for_everything_to_idle(srvr, clnt, 0)

   print tname, ":  ##################"
   print tname, ":  Sleep for 5 seconds so any pending collection"
   print tname, ":  I/O can complete"
   time.sleep(5)

   wait_for_everything_to_idle(srvr, clnt, 0)

  ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"

   tfail = 0
   tfail = check_data(srvr, clnt, verbose, expectedcnt,
                      srvro, crlro, crawlercrash, indexercrash)
   if ( tfail > 0 ):
      tfail = 0
      time.sleep(10)
      tfail = check_data(srvr, clnt, verbose, expectedcnt,
                         srvro, crlro, crawlercrash, indexercrash)
   fail = tfail

   if ( crlro ):
      cnum = 0
      for item in clnt:
         client_collection = collection_list[cnum]
         disable_read_only(item, client_collection)
         cnum += 1

   if ( audit ):
      tfail = compare_audit_log_data(srvr, server_collection, 
                                     clnt, collection_list)
      fail = fail + tfail

   ##############################################################

   if ( fail == 0 ):
      zooboo = []
      for item in deletelist:
         thing = doTheEnqueue(item, srvr, server_collection, True, doia)
         thing.start()
         zooboo.append(thing)

      for thing in zooboo:
         thing.join()
         interimcount = thing.get_filecount()
         expectedcnt = expectedcnt - interimcount
         print "DELETED COUNT:", expectedcnt

      wait_for_everything_to_idle(srvr, clnt, 0)

      #
      #   Since, when the server is in read-only mode, all enqueues
      #   should be rejected, set the expected number of items
      #   to be related only to the database data (359 records).
      #
      if ( srvro ):
         expectedcnt = 359

      tfail = 0
      tfail = check_data(srvr, clnt, verbose, expectedcnt, 
                         False, False, crawlercrash, indexercrash)
      if ( tfail > 0 ):
         tfail = 0
         time.sleep(10)
         tfail = check_data(srvr, clnt, verbose, expectedcnt,
                            False, False, crawlercrash, indexercrash)
      fail = fail + tfail

      if ( audit ):
         tfail = compare_audit_log_data(srvr, server_collection, 
                                        clnt, collection_list)
         fail = fail + tfail


   dumpofd.write("</output>")
   dumpofd.close()

   if ( not keepit ):
      print tname, ":  Deleting all collections to prevent port confusion"
      srvr.cgi.delete_collection(collection=server_collection)
      cnum = 0
      for item in clnt:
         client_collection = collection_list[cnum]
         item.cgi.delete_collection(collection=client_collection)
         cnum += 1
   else:
      print tname, ":  WARNING, the collections still exist.  It is"
      print tname, ":           possible that other tests may have issues"
      print tname, ":           due to the ports these collections use"

   #xx.kill_all_services()

   if ( fail == 0 ):
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"

   sys.exit(1)


