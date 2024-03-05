#!/usr/bin/python

import os, sys, time, host_environ
import getopt, subprocess
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

def isInList(checkfor, thelist):

   for item in thelist:
      if ( item == checkfor ):
         return 1

   return 0

def create_server_file(collection_list):

   cmdstring = "cat basesrvrxml | sed -e \'s;REPLACE__WITH__ALL__CLIENTS;"

   for item in collection_list:
      cmdstring = cmdstring + item + "\\n"

   cmdstring = cmdstring + ";g\' > orclsrvr.xml"

   p = subprocess.Popen(cmdstring, shell=True)
   os.waitpid(p.pid, 0)

   return

def create_client_file(my_server, current_client):

   baseclnt = 'orclclnt'

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

   print "dstidx-bug23441.tst -S <server> -C <client>"
   print "   <server> = server side machine, example: testbed14"
   print "   <client> = client side machine, example: testbed15 testbed11"
   print "   Example cmd:  dstidx-bug23441.tst -S testbed14 -C testbed15i testbed11"

   return


if __name__ == "__main__":

   opts, args = getopt.getopt(sys.argv[1:], "S:C:vfk", ["server=", "client=", "verbose", "first", "keep"])

   my_server = None
   my_client = None
   verbose = 0
   serverfirst = False
   keeper = False

   for o, a in opts:
      if o in ("-S", "--server"):
         my_server = a
      if o in ("-C", "--client"):
         my_client = a
      if o in ("-v", "--verbose"):
         verbose = 1
      if o in ("-f", "--first"):
         serverfirst = True
      if o in ("-k", "--keep"):
         keeper = True

   if ( my_server is None ):
      try:
         my_server = os.getenv('VIVHOST', None)
      except:
         my_server = None
      if ( my_server is None ):
         print "Exiting:  No server set"
         usage()
         sys.exit(1)

   if ( my_client is None ):
      try:
         my_client = os.getenv('VIVHOST', None)
      except:
         my_client = None
      if ( my_client is None ):
         print "Exiting:  No client set"
         usage()
         sys.exit(1)

   try:
      os.remove('orclclnt.xml')
   except:
      print "Nothing to remove, oh well."

   fsn = fullsysname(my_server)
   #cmdstring = "cat baseclntxml | sed -e \'s;REPLACE__ME;" + fsn + ";g\' > nextclnt"
   #subprocess.Popen(cmdstring, shell=True)

   fail = 0

   tname = "dstidx-bug23441"
   server_collection = "orclsrvr"
   client_list = my_client.split(' ')

   collection_list = []
   for item in client_list:
      collection_list.append(create_client_file(my_server, item))

   create_server_file(collection_list)

   server_file = server_collection + '.xml'

   ##############################################################

   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  distributed indexing basic test 30"

   srvr = host_environ.HOSTENVIRON(hostname=my_server)
   srvr.cgi.version_check(8.0)

   clnt = []
   print client_list
   for item in client_list:
      print item
      clnt.append(host_environ.HOSTENVIRON(hostname=item))

   print tname, ":  PERFORM CRAWLS"
   print tname, ":     Create empty collection", server_collection
   #
   #   Empty collections 
   #
   print tname, ":  ##################"
   print tname, ":  Creating empty server collection"
   cex = srvr.cgi.collection_exists(collection=server_collection)
   if ( cex == 1 ):
      srvr.cgi.delete_collection(collection=server_collection)
   srvr.vapi.api_sc_create(collection=server_collection, based_on='default')

   print tname, ":  ##################"
   print tname, ":  Setting up server collection"
   srvr.vapi.api_repository_update(xmlfile=server_file)

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

   if ( serverfirst ):
      print tname, ":  ##################"
      print tname, ":  Start server crawl (before clients)"
      srvr.vapi.api_sc_crawler_start(collection=server_collection)
      time.sleep(5)

   cnum = 0
   for item in clnt:
      client_collection = collection_list[cnum]
      print tname, ":  ##################"
      print tname, ":  Start client crawl", client_collection
      item.vapi.api_sc_crawler_start(collection=client_collection)
      cnum += 1

   if ( not serverfirst ):
      time.sleep(5)
      print tname, ":  ##################"
      print tname, ":  Start server crawl (after clients)"
      srvr.vapi.api_sc_crawler_start(collection=server_collection)

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

   print tname, ":  ##################"
   print tname, ":  Sleep for 5 seconds so any pending collection"
   print tname, ":  I/O can complete"
   time.sleep(5)


   ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"

   srvrresp = srvr.vapi.api_qsearch(source=server_collection, num=500,
                                    query='', filename='srvr_search')
   clntresp = []
   cnum = 0
   for item in clnt:
      client_collection = collection_list[cnum]
      clntresp.append(item.vapi.api_qsearch(source=client_collection, num=500,
                                         query='', filename='clnt_search'))
      cnum += 1

   #
   #   Check that recorded values are identical
   #
   expectedcnt = 359
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
      print tname, ":  Test Passed"
   else:
      print tname, ":  Test Failed"

   if ( not keeper ):
      srvr.cgi.delete_collection(collection=server_collection)
      cnum = 0
      for item in clnt:
         client_collection = collection_list[cnum]
         item.cgi.delete_collection(collection=client_collection)
         cnum += 1
   else:
      print tname, ":   WARNING"
      print tname, ":      The collections for this test still exist"
      print tname, ":      This could create issues with other tests"
      print tname, ":      which may use the same communications port."

   sys.exit(fail)
