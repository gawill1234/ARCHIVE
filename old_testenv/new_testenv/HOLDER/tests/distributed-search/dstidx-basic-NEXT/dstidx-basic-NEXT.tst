#!/usr/bin/python

import os, sys, time, host_environ
import getopt, subprocess
from lxml import etree

def isInList(checkfor, thelist):

   for item in thelist:
      if ( item == checkfor ):
         return 1

   return 0

def usage():

   print "dstidx-basic-29.tst -S <server> -C <client> -P <pure client>"
   print "   <server> = server side machine, example: testbed14"
   print "   <client> = client side machine, example: testbed15"
   print "   <pure client> = client side machine, example: testbed11"
   print "   Example cmd:  dstidx-basic-1.tst -S testbed14 -C testbed15 -P testbed11"

   return


if __name__ == "__main__":

   opts, args = getopt.getopt(sys.argv[1:], "S:C:P:v", ["server=", "client=", "pure_client=", "verbose"])

   my_server = None
   my_client = None
   pure_client = None
   verbose = 0

   for o, a in opts:
      if o in ("-S", "--server"):
         my_server = a
      if o in ("-C", "--client"):
         my_client = a
      if o in ("-P", "--pure_client"):
         pure_client = a
      if o in ("-v", "--verbose"):
         verbose = 1

   if ( my_server is None ):
      print "Exiting:  No server set"
      usage()
      sys.exit(1)

   if ( my_client is None ):
      print "Exiting:  No client set"
      usage()
      sys.exit(1)

   #
   #   Set up the final collection configuration files.
   #
   try:
      os.remove('idxbasic1A.xml')
      os.remove('idxbasic1B.xml')
      os.remove('pure_client.xml')
      os.remove('interimbase')
   except:
      print "Nothing to remove, oh well."

   fsn = my_server + '.test.vivisimo.com'
   fsn2 = my_client + '.test.vivisimo.com'
   fsn_pure = pure_client + '.test.vivisimo.com'

   cmdstring = "cat idxb1basexml | sed -e \'s;REPLACE__ONE;" + fsn2 + ";g\' > idxbasic1A.xml"
   subprocess.Popen(cmdstring, shell=True)

   cmdstring = "cat purebasexml | sed -e \'s;REPLACE__ONE;" + fsn2 + ";g\' > interimbase"
   subprocess.Popen(cmdstring, shell=True)

   cmdstring = "cat idxb2basexml | sed -e \'s;REPLACE__TWO;" + fsn + ";g\' > idxbasic1B.xml"
   subprocess.Popen(cmdstring, shell=True)
   cmdstring = "cat interimbase | sed -e \'s;REPLACE__TWO;" + fsn + ";g\' > pure_client.xml"
   subprocess.Popen(cmdstring, shell=True)

   fail = 0

   tname = "dstidx-basic-29"
   server_collection = "idxbasic1A"
   client_collection = "idxbasic1B"
   pure_collection = "pure_client"

   server_file = server_collection + '.xml'
   client_file = client_collection + '.xml'
   pure_file = pure_collection + '.xml'

   ##############################################################

   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  distributed indexing basic test 29"
   print tname, ":  many to one case."

   srvr = host_environ.HOSTENVIRON(hostname=my_server)
   clnt = host_environ.HOSTENVIRON(hostname=my_client)
   pure = host_environ.HOSTENVIRON(hostname=pure_client)

   print tname, ":  PERFORM CRAWLS"
   print tname, ":     Create empty collection", server_collection
   #
   #   Empty collections 
   #
   try:
      print tname, ":  ##################"
      print tname, ":  Creating empty server collection"
      cex = srvr.cgi.collection_exists(collection=server_collection)
      if ( cex == 1 ):
         srvr.cgi.delete_collection(collection=server_collection)
      srvr.vapi.api_sc_create(collection=server_collection, based_on='default')

      print tname, ":  ##################"
      print tname, ":  Setting up server collection"
      srvr.vapi.api_repository_update(xmlfile=server_file)
   except:
      print "Could not create collection from", server_file
      print "Failed host is", my_server
      sys.exit(1)

   try:
      print tname, ":  ##################"
      print tname, ":  Creating empty client collection"
      cex = clnt.cgi.collection_exists(collection=client_collection)
      if ( cex == 1 ):
         clnt.cgi.delete_collection(collection=client_collection)
      clnt.vapi.api_sc_create(collection=client_collection, based_on='default')

      print tname, ":  ##################"
      print tname, ":  Setting up client collection"
      clnt.vapi.api_repository_update(xmlfile=client_file)
   except:
      print "Could not create collection from", client_file
      print "Failed host is", my_client
      sys.exit(1)

   try:
      print tname, ":  ##################"
      print tname, ":  Creating empty pure client collection"
      cex = pure.cgi.collection_exists(collection=pure_collection)
      if ( cex == 1 ):
         pure.cgi.delete_collection(collection=pure_collection)
      pure.vapi.api_sc_create(collection=pure_collection, based_on='default')

      print tname, ":  ##################"
      print tname, ":  Setting up pure client collection"
      pure.vapi.api_repository_update(xmlfile=pure_file)
   except:
      print "Could not create collection from", pure_file
      print "Failed host is", pure_client
      sys.exit(1)

   print tname, ":  ##################"
   print tname, ":  Start server crawl"
   srvr.vapi.api_sc_crawler_start(collection=server_collection)

   print tname, ":  ##################"
   print tname, ":  Start client crawl"
   clnt.vapi.api_sc_crawler_start(collection=client_collection)

   print tname, ":  ##################"
   print tname, ":  Start pure client crawl"
   pure.vapi.api_sc_crawler_start(collection=pure_collection)

   print tname, ":  ##################"
   print tname, ":  Wait for server crawl to go idle"
   srvr.cgi.wait_for_idle(collection=server_collection)

   print tname, ":  ##################"
   print tname, ":  Wait for client crawl to go idle"
   clnt.cgi.wait_for_idle(collection=client_collection)

   print tname, ":  ##################"
   print tname, ":  Wait for pure client crawl to go idle"
   pure.cgi.wait_for_idle(collection=pure_collection)

   print tname, ":  ##################"
   print tname, ":  Sleep for 60 seconds so any pending collection"
   print tname, ":  I/O can complete"

   time.sleep(60)

   print tname, ":  ##################"
   print tname, ":  Wait for server crawl to go idle, possible update"
   srvr.cgi.wait_for_idle(collection=server_collection)

   print tname, ":  ##################"
   print tname, ":  Wait for client crawl to go idle, possible update"
   clnt.cgi.wait_for_idle(collection=client_collection)

   print tname, ":  ##################"
   print tname, ":  Wait for pure client crawl to go idle, possible update"
   pure.cgi.wait_for_idle(collection=pure_collection)


   ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"

   srvrresp = srvr.vapi.api_qsearch(source=server_collection, num=500,
                                    query='', filename='srvr_search',
                                    odup='true')
   clntresp = clnt.vapi.api_qsearch(source=client_collection, num=500,
                                    query='', filename='clnt_search',
                                    odup='true')

   pureresp = pure.vapi.api_qsearch(source=pure_collection, num=500,
                                    query='', filename='pure_search',
                                    odup='true')

   #
   #   Check that recorded values are identical
   #
   expectedcnt = 406
   srvridxcnt = srvr.vapi.getTotalResults(resptree=srvrresp,
                                          filename='srvr_search')
   clntidxcnt = clnt.vapi.getTotalResults(resptree=clntresp,
                                          filename='clnt_search')
   pureidxcnt = pure.vapi.getTotalResults(resptree=pureresp,
                                          filename='pure_search')

   print tname, ":  ##################"


   if ( srvridxcnt != clntidxcnt or srvridxcnt != expectedcnt or
        clntidxcnt != expectedcnt or pureidxcnt != srvridxcnt ):
      print tname, ":  total results differ between client and server"
      print tname, ":  client results = ", clntidxcnt
      print tname, ":  server results = ", srvridxcnt
      print tname, ":  pure client results = ", pureidxcnt
      print tname, ":  expected results = ", expectedcnt
      fail = 1
   else:
      print tname, ":  total results are correct at ", srvridxcnt

   #
   #   Check that url counts are identical
   #
   srvrurlcnt = srvr.vapi.getResultUrlCount(resptree=srvrresp,
                                            filename='srvr_search')
   clnturlcnt = clnt.vapi.getResultUrlCount(resptree=clntresp,
                                            filename='clnt_search')
   pureurlcnt = pure.vapi.getResultUrlCount(resptree=pureresp,
                                            filename='pure_search')

   print tname, ":  ##################"


   if ( srvrurlcnt != clnturlcnt or pureurlcnt != clnturlcnt ):
      print tname, ":  total url results differ between client and server"
      print tname, ":  client results = ", clnturlcnt
      print tname, ":  server results = ", srvrurlcnt
      print tname, ":  pure client results = ", pureurlcnt
      fail = 1
   else:
      print tname, ":  total url results are correct at ", srvrurlcnt

   #
   #   Check the urls are as identical as they should be
   #
   srvrurllst = srvr.vapi.getResultUrls(resptree=srvrresp,
                                        filename='srvr_search')
   clnturllst = clnt.vapi.getResultUrls(resptree=clntresp,
                                        filename='clnt_search')
   pureurllst = pure.vapi.getResultUrls(resptree=pureresp,
                                        filename='pure_search')

   print tname, ":  ##################"

   for item in srvrurllst:
      x = isInList(item, clnturllst)
      if ( x != 1 ):
         print "ARRGHH!!!: ", item
         fail = 1
      else:
         if ( verbose == 1 ):
            print "found(srvr): ", item

   for item in clnturllst:
      x = isInList(item, srvrurllst)
      if ( x != 1 ):
         print "again, ARRGHH!!!: ", item
         fail = 1
      else:
         if ( verbose == 1 ):
            print "found(clnt): ", item

   for item in pureurllst:
      x = isInList(item, srvrurllst)
      if ( x != 1 ):
         print "pure, ARRGHH!!!: ", item
         fail = 1
      else:
         if ( verbose == 1 ):
            print "found(pure): ", item

   for item in clnturllst:
      x = isInList(item, pureurllst)
      if ( x != 1 ):
         print "pure, ARRGHH!!!: ", item
         fail = 1
      else:
         if ( verbose == 1 ):
            print "found(pure): ", item


   ##############################################################

   #xx.kill_all_services()
   #
   #   Having this file around at the end is annoying.
   #   Remove it.
   #
   try:
      os.remove('interimbase')
   except:
      print "Nothing to remove, oh well."

   if ( fail == 0 ):
      srvr.cgi.delete_collection(collection=server_collection)
      clnt.cgi.delete_collection(collection=client_collection)
      pure.cgi.delete_collection(collection=pure_collection)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"

   sys.exit(1)
