#!/usr/bin/python

#
#   Test of Distributed Indexing
#   This is the basic proxy case where:
#      Server A sends collection A' to Server B
#      Server B sends collection A' to Server C
#      Servers A, B, and C should provide identical information.
#
import os, sys, time, host_environ, shutil
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


def check_data(srvr, clnt, outerclnt, verbose):

   fail = 0

   srvrresp = srvr.vapi.api_qsearch(source=server_collection, num=500,
                                    query='', filename='srvr_search')
   clntresp = clnt.vapi.api_qsearch(source=client_collection, num=500,
                                    query='', filename='clnt_search')
   outerclntresp = outerclnt.vapi.api_qsearch(source=outer_client_collection,
                                    num=500,
                                    query='', filename='outer_clnt_search')

   #
   #   Check that recorded values are identical
   #
   expectedcnt = 359
   srvridxcnt = srvr.vapi.getTotalResults(resptree=srvrresp,
                                          filename='srvr_search')
   clntidxcnt = clnt.vapi.getTotalResults(resptree=clntresp,
                                          filename='clnt_search')
   outerclntidxcnt = outerclnt.vapi.getTotalResults(resptree=outerclntresp,
                                          filename='outer_clnt_search')

   print tname, ":  ##################"


   if ( srvridxcnt != clntidxcnt or srvridxcnt != expectedcnt or
        clntidxcnt != expectedcnt or outerclntidxcnt != clntidxcnt ):
      print tname, ":  total results differ between client and server"
      print tname, ":  client results = ", clntidxcnt
      print tname, ":  outer client results = ", outerclntidxcnt
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
   clnturlcnt = clnt.vapi.getResultUrlCount(resptree=clntresp,
                                            filename='clnt_search')
   outerclnturlcnt = clnt.vapi.getResultUrlCount(resptree=outerclntresp,
                                            filename='outer_clnt_search')

   print tname, ":  ##################"


   if ( srvrurlcnt != clnturlcnt or clnturlcnt != outerclnturlcnt ):
      print tname, ":  total url results differ between client and server"
      print tname, ":  client results = ", clnturlcnt
      print tname, ":  outer client results = ", outerclnturlcnt
      print tname, ":  server results = ", srvrurlcnt
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
   outerclnturllst = clnt.vapi.getResultUrls(resptree=outerclntresp,
                                        filename='outer_clnt_search')

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

   return fail


def isInList(checkfor, thelist):

   for item in thelist:
      if ( item == checkfor ):
         return 1

   return 0

def usage():

   print "dstidx-proxy-6.tst -S <server> -C <client> -O <outer client>"
   print "   <server> = server side machine, example: testbed14"
   print "   <client> = client side machine, example: testbed15"
   print "   <outer client> = client to client machine, example: testbed15"
   print "   Example cmd:  dstidx-proxy-6.tst -S testbed14 -C testbed15"
   print "                                    -O testbed16-3"

   return


if __name__ == "__main__":

   opts, args = getopt.getopt(sys.argv[1:], "S:C:vO:k", ["server=", "client=", "verbose", "outerclient=", "keepit"])

   keepit = False
   my_server = None
   my_client = None
   my_outerclient = None
   verbose = 0

   for o, a in opts:
      if o in ("-S", "--server"):
         my_server = a
      if o in ("-C", "--client"):
         my_client = a
      if o in ("-O", "--outerclient"):
         my_outerclient = a
      if o in ("-v", "--verbose"):
         verbose = 1
      if o in ("-k", "--keepit"):
         keepit = True

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

   if ( my_outerclient is None ):
      my_outerclient = os.getenv('VIVHOST', None)
      if ( my_outerclient is None ):
         print "Exiting:  No outer client set"
         usage()
         sys.exit(1)

   try:
      os.remove('orclclnt.xml')
   except:
      print "Nothing to remove, oh well."

   fsn = fullsysname(my_server)
   cmdstring = "cat basemiddlexml | sed -e \'s;REPLACE__SERVER__NAME;" + fsn + ";g\' > orclmiddle.xml"
   p = subprocess.Popen(cmdstring, shell=True)
   os.waitpid(p.pid, 0)

   cmdstring = "cat baseclntxml | sed -e \'s;REPLACE__SERVER__NAME;" + fsn + ";g\' > interimxml"
   p = subprocess.Popen(cmdstring, shell=True)
   os.waitpid(p.pid, 0)

   fsn = fullsysname(my_client)
   cmdstring = "cat interimxml | sed -e \'s;REPLACE__MIDDLE__SERVER;" + fsn + ";g\' > orclclnt.xml"
   p = subprocess.Popen(cmdstring, shell=True)
   os.waitpid(p.pid, 0)

   shutil.copy("basesrvrxml", "orclsrvr.xml")

   fail = 0

   tname = "dstidx-proxy-6"
   server_collection = "orclsrvr"
   client_collection = "orclmiddle"
   outer_client_collection = "orclclnt"

   server_file = server_collection + '.xml'
   client_file = client_collection + '.xml'
   outer_client_file = outer_client_collection + '.xml'

   ##############################################################

   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  distributed indexing basic cascading client test"
   print tname, ":  Basically tests ability of middle to act as proxy"
   print tname, ":  \"-->\" = \"SERVES DATA TO\""
   print tname, ":  SRVR     --> CLNTSRVR   --> CLNT"
   print tname, ":   |                           ^"
   print tname, ":   |                           |"
   print tname, ":   -----------------------------"
   print tname, ":  SRVR     --> CLNTSRVR   --> CLNT"
   print tname, ":  SRVR     --> CLNTSRVR   --> CLNT"
   print tname, ":  orclsrvr --> orclmiddle"
   print tname, ":               orclsrvr   --> orclclnt"
 
   print tname, ":  Getting server", my_server
   srvr = host_environ.HOSTENVIRON(hostname=my_server)
   srvr.cgi.version_check(8.0)
   print tname, ":  Done"

   print tname, ":  Getting middle", my_client
   clnt = host_environ.HOSTENVIRON(hostname=my_client)
   print tname, ":  Done"

   print tname, ":  Getting client", my_outerclient
   outerclnt = host_environ.HOSTENVIRON(hostname=my_outerclient)
   print tname, ":  Done"

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

   print tname, ":  ##################"
   print tname, ":  Creating empty client collection"
   cex = clnt.cgi.collection_exists(collection=client_collection)
   if ( cex == 1 ):
      clnt.cgi.delete_collection(collection=client_collection)
   clnt.vapi.api_sc_create(collection=client_collection, based_on='default')

   print tname, ":  ##################"
   print tname, ":  Setting up client collection"
   clnt.vapi.api_repository_update(xmlfile=client_file)

   print tname, ":  ##################"
   print tname, ":  Creating empty client collection"
   cex = outerclnt.cgi.collection_exists(collection=outer_client_collection)
   if ( cex == 1 ):
      outerclnt.cgi.delete_collection(collection=outer_client_collection)
   outerclnt.vapi.api_sc_create(collection=outer_client_collection,
                                based_on='default')

   print tname, ":  ##################"
   print tname, ":  Setting up client collection"
   outerclnt.vapi.api_repository_update(xmlfile=outer_client_file)

   print tname, ":  ##################"
   print tname, ":  Start server crawl"
   srvr.vapi.api_sc_crawler_start(collection=server_collection)

   print tname, ":  ##################"
   print tname, ":  Start middle client crawl"
   clnt.vapi.api_sc_crawler_start(collection=client_collection)

   print tname, ":  ##################"
   print tname, ":  Start outer client crawl"
   outerclnt.vapi.api_sc_crawler_start(collection=outer_client_collection)

   print tname, ":  ##################"
   print tname, ":  Wait for server crawl to go idle"
   srvr.cgi.wait_for_idle(collection=server_collection)

   print tname, ":  ##################"
   print tname, ":  Wait for middle client crawl to go idle"
   clnt.cgi.wait_for_idle(collection=client_collection)

   print tname, ":  ##################"
   print tname, ":  Wait for outer client crawl to go idle"
   outerclnt.cgi.wait_for_idle(collection=outer_client_collection)

   print tname, ":  ##################"
   print tname, ":  Sleep for 5 seconds so any pending collection"
   print tname, ":  I/O can complete"
   time.sleep(5)


   ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"

   #
   #   Check that all collection data is correct
   #
   print tname, ":  Initial data check"
   fail = check_data(srvr, clnt, outerclnt, verbose)

   #
   #   If the check failed, try again just to make sure we were
   #   not stuck in the middle of an update when we tried to
   #   check the data.
   #
   if ( fail == 1 ):
      print tname, ":  Initial data check failed, checking again ..."
      time.sleep(10)
      fail = check_data(srvr, clnt, outerclnt, verbose)

   ##############################################################

   #xx.kill_all_services()

   #
   #   Due to possible port confusion, these tests ALWAYS delete
   #   the existing collection unless the -k option is specified
   #   as part of the test.  This way subsequent tests will run
   #   correctly.
   #
   if ( not keepit ):
      print tname, ":  Deleting all collections to prevent port confusion"
      srvr.cgi.delete_collection(collection=server_collection)
      clnt.cgi.delete_collection(collection=client_collection)
      outerclnt.cgi.delete_collection(collection=outer_client_collection)
   else:
      print tname, ":  WARNING, the collections still exist.  It is"
      print tname, ":           possible that other tests may have issues"
      print tname, ":           due to the ports these collections use"

   if ( fail == 0 ):
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"

   sys.exit(1)
