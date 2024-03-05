#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic 
import build_schema_node
import getopt, subprocess, host_environ
import velocityAPI
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


def enqueue_it(srvr, collection, crawl_urls):

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


def isInList(checkfor, thelist):

   for item in thelist:
      if ( item == checkfor ):
         return 1

   return 0

def create_server_file(collection_list):

   cmdstring = "cat basesrvrxml | sed -e \'s;REPLACE__WITH__ALL__CLIENTS;"

   for item in collection_list:
      cmdstring = cmdstring + item + "\\n"

   cmdstring = cmdstring + ";g\' > enqueue_to_srvr.xml"

   p = subprocess.Popen(cmdstring, shell=True)
   os.waitpid(p.pid, 0)

   return

def create_client_file(my_server, current_client):

   baseclnt = 'enq_clnt'

   client_name = baseclnt + "_" + current_client

   collection_file = client_name + ".xml"

   fsn = fullsysname(my_server)

   cmdstring = "cat baseclntxml | sed -e \'s;REPLACE__ME;" + fsn + ";g\' > nextclnt"

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

   print "dstidx-basic-30.tst -S <server> -C <client>"
   print "   <server> = server side machine, example: testbed14"
   print "   <client> = client side machine, example: testbed15 testbed11"
   print "   Example cmd:  dstidx-basic-30.tst -S testbed14 -C testbed15i testbed11"

   return

def do_crawl_urls(crawl_urls=None, filelist=None, synchro=None):

   usesynchro = ['none', 'indexed', 'none', 'enqueued', 'indexed-no-sync',
                  'to-be-indexed', 'indexed-no-sync', 'to-be-crawled',
                  'indexed-no-sync', 'enqueued']

   thingbomb = 0

   if ( filelist is None ):
      return []

   if ( crawl_urls is None ):
      crawl_urls = build_schema_node.create_crawl_urls()

   for item in filelist:

      if ( synchro == None ):
         whichone = thingbomb % 10
         thissynchro = usesynchro[whichone]
         thingbomb += 1
      else:
         thissynchro = synchro

      print item, thissynchro
      fname = os.path.basename(item)
      #fdir = os.path.dirname(item)
      #mydirpart = fdir.strip('/testenv/test_data/law/')
      print fname

      #url = ''.join(['http://junkurl/', mydirpart, '/', fname])
      url = ''.join(['file://', item])
      crawl_url = build_schema_node.create_crawl_url(url=url,
                  status='complete', enqueuetype='reenqueued',
                  synchronization=thissynchro, addnodeto=crawl_urls)
      crawl_data = build_schema_node.create_crawl_data(encoding='utf-8',
                   contenttype='text/html', addnodeto=crawl_url,
                   filename=item)

   return crawl_urls

def do_enqueues(dir, srvr, collection):

   global alltime

   usesynchro = [None, 'none', 'none', 'indexed-no-sync', 'enqueued',
                  'to-be-indexed', 'indexed-no-sync', 'to-be-crawled',
                  'indexed-no-sync', None]

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
            crawl_urls = do_crawl_urls(crawl_urls, filelist, synchro)
            print "============================="
            curcnt = 0
            lcnt -= 1
            beginning = time.time()
            resp = enqueue_it(srvr, collection, crawl_urls)
            endoftime = time.time()
            alltime = alltime + ( endoftime - beginning )
            #print etree.tostring(crawl_urls)
            filelist = []
            crawl_urls = None
            if ( lcnt == 0 ):
               lcnt = 103

      print "FILES ENQUEUED (interim):  ", filecount


   print "FILES ENQUEUED (final):  ", filecount

   return filecount


def set_up_server(server_collection, my_server, collection_list):

   global tname

   srvr = host_environ.HOSTENVIRON(hostname=my_server)

   create_server_file(collection_list)

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

def start_collection_services(srvr, clnt, serverfirst):

   global tname

   if ( serverfirst ):
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

   if ( not serverfirst ):
      print tname, ":  ##################"
      print tname, ":  Start server crawl (after clients)"
      srvr.vapi.api_sc_crawler_start(collection=server_collection)

   return

def wait_for_everything_to_idle(srvr, clnt):

   global tname

   print tname, ":  ##################"
   print tname, ":  Wait for server crawl to go idle"
   srvr.cgi.wait_for_idle(collection=server_collection)

   cnum = 0
   for item in clnt:
      client_collection = collection_list[cnum]
      print tname, ":  ##################"
      print tname, ":  Wait for client crawl to go idle", client_collection
      item.cgi.wait_for_idle(collection=client_collection)
      cnum += 1

   return


if __name__ == "__main__":

   global alltime
   global tname
   global dumpofd

   opts, args = getopt.getopt(sys.argv[1:], "S:C:vl", ["server=", "client=", "verbose", "last"])

   alltime = 0
   fail = 0

   my_server = None
   my_client = None
   verbose = 0
   serverfirst = True

   dumpofd = open("what_i_did", "w+")
   dumpofd.write("<output>")

   datadir = "/testenv/test_data/law/F3/284"
   tname = "dstidx-enq-30"
   server_collection = "enqueue_to_srvr"
   my_client = None

   for o, a in opts:
      if o in ("-S", "--server"):
         my_server = a
      if o in ("-C", "--client"):
         if ( my_client is None ):
            my_client = a
         else:
            my_client = my_client + ' ' + a
      if o in ("-v", "--verbose"):
         verbose = 1
      if o in ("-l", "--last"):
         serverfirst = False

   if ( my_server is None ):
      my_server = os.getenv('VIVHOST', None)
      if ( my_server is None ):
         print "Exiting:  No server set"
         usage()
         sys.exit(1)

   if ( my_client is None ):
      my_client = os.getenv('VIVHOST', None)
      if ( my_client is None ):
         print "Exiting:  No client set"
         usage()
         sys.exit(1)

   print tname, ":  ##################"
   print tname, ":  Initialize"
   print tname, ":     Enqueue/crawl combined 1 to 1 or 1 to many"
   print tname, ":     distributed indexing test"

   client_list = my_client.split(' ')
   collection_list = []
   for item in client_list:
      collection_list.append(create_client_file(my_server, item))

   srvr = set_up_server(server_collection, my_server, collection_list)
   srvr.cgi.version_check(8.0)

   clnt = set_up_clients(collection_list, client_list)
   start_collection_services(srvr, clnt, serverfirst)

   expectedcnt = do_enqueues(datadir, srvr, server_collection)
   expectedcnt = expectedcnt + 359

   dumpofd.write("</output>")
   dumpofd.close()

   wait_for_everything_to_idle(srvr, clnt)

   print tname, ":  ##################"
   print tname, ":  Sleep for 5 seconds so any pending collection"
   print tname, ":  I/O can complete"
   time.sleep(5)

  ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"

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
      if ( srvridxcnt != item or srvridxcnt != expectedcnt or
           item != expectedcnt ):
         print tname, ":  total results differ between client and server"
         print tname, ":  client results = ", item
         print tname, ":  server results = ", srvridxcnt
         print tname, ":  expected results = ", expectedcnt
         fail = 1
      else:
         print tname, ":  total results are correct at ", srvridxcnt

   #
   #   Check that url counts are identical
   #
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
            print "ARRGHH!!!: ", item
            fail = 1
         else:
            if ( verbose == 1 ):
               print "found(srvr): ", item

   for item in clnturllst:
      for thing in item:
         x = isInList(thing, srvrurllst)
         if ( x != 1 ):
            print "again, ARRGHH!!!: ", item
            fail = 1
         else:
            if ( verbose == 1 ):
               print "found(clnt): ", item


   ##############################################################

   #xx.kill_all_services()

   if ( fail == 0 ):
      srvr.cgi.delete_collection(collection=server_collection)
      cnum = 0
      for item in clnt:
         client_collection = collection_list[cnum]
         item.cgi.delete_collection(collection=client_collection)
         cnum += 1
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"

   sys.exit(1)


