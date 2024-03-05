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

def find_a_working_directory():

   global final_target_dir

   mypid = os.getpid()
   mypid = '%s' % mypid

   copytarget = '/testenv/samba_test_data/samba-dist-idx/doc-' + mypid + '_0/'

   i = 0
   while ( os.path.exists(copytarget) ):
      i += 1
      copytarget = '/testenv/samba_test_data/samba-dist-idx/doc-' + mypid + '_' + '%s' % i + '/'

   sharename = '/' + os.getenv( 'VIV_SAMBA_LINUX_SHARE' ) + '/samba_test_data/samba-dist-idx/doc-' + mypid + '_' + '%s' % i + '/'

   final_target_dir = copytarget

   return sharename

def remove_a_file(filename):

   global final_target_dir

   copytarget = final_target_dir

   filetoremove = copytarget + filename

   try:
      os.chmod(filetoremove, 0666)
   except:
      print "INFO:  No file to chmod(),", filetoremove
      return

   try:
      os.remove(filetoremove)
   except:
      print "INFO:  No file to remove,", filetoremove

   return


def copy_my_file(sourcefile, targetfile):

   global final_target_dir

   copytarget = final_target_dir
   copysource = '/testenv/samba_test_data/samba-dist-idx/altered-data/'

   filetocopy = copysource + sourcefile
   filetocreate = copytarget + targetfile

   try:
      os.chmod(filetocreate, 0666)
   except:
      print "INFO:  No file to chmod(),", filetocreate

   try:
      os.remove(filetocreate)
   except:
      print "INFO:  No file to remove,", filetocreate

   try:
      shutil.copy(filetocopy, filetocreate)
   except:
      print "ERROR:  Could not create file", filetocreate
      print "                         from", filetocopy

   try:
      os.chmod(filetocreate, 0666)
   except:
      print "Chmod failed, continuing:", filetocreate

   return

def restore_base_data():

   global final_target_dir

   copytarget = final_target_dir
   copysource = '/testenv/samba_test_data/samba-dist-idx/doc/'

   print "Created directory is", copytarget
   print "Copying data from", copysource

   try:
      os.mkdir(copytarget)
   except:
      print "Directory", copytarget, "already exists"

   try:
      os.chmod(copytarget, 0777)
   except:
      print "Directory", copytarget, "may not be usable"

   for path, dirs, files in os.walk(copysource):

      for name in files:

         filetocreate = copytarget + name
         filetocopy = copysource + name
         try:
            shutil.copy(filetocopy, filetocreate)
         except:
            print "Creation failed,   to:", filetocreate
            print "                 from:", filetocopy

         try:
            os.chmod(filetocreate, 0666)
         except:
            print "Chmod failed, continuing:", filetocreate

   return

def wait_for_all_idle(srvr, server_collection,
                      clnt, client_collection,
                      outerclnt, outer_client_collection, waitcount):

   if ( waitcount > 0 ):
      time.sleep(5)

   print tname, ":  ##################"
   print tname, ":  Wait for server crawl to go idle"
   srvr.cgi.wait_for_idle(collection=server_collection)
   s1 = srvr.vapi.api_get_crawler_sync_status(collection=server_collection)

   print tname, ":  ##################"
   print tname, ":  Wait for middle client crawl to go idle"
   clnt.cgi.wait_for_idle(collection=client_collection)
   c1 = clnt.vapi.api_get_crawler_sync_status(collection=client_collection)

   print tname, ":  ##################"
   print tname, ":  Wait for outer client crawl to go idle"
   outerclnt.cgi.wait_for_idle(collection=outer_client_collection)
   o1 = outerclnt.vapi.api_get_crawler_sync_status(
                  collection=outer_client_collection)

   if ( s1 == 'synchronizing' or
        o1 == 'synchronizing' or
        c1 == 'synchronizing' ):
      print "Synchronization not complete, wait some more"
      print "   Servers are      :", s1
      print "   Clients are      :", c1
      print "   Outer clients are:", o1
      waitcount += 1
      if ( waitcount < 3 ):
         wait_for_all_idle(srvr, server_collection,
                           clnt, client_collection,
                           outerclnt, outer_client_collection, waitcount)
      else:
         print "Synchronization not complete, but wait cycle is over"
         print "Test will likely fail for missing documents in client(s)"

   return

def check_data(srvr, clnt, outerclnt, verbose, expectedcnt):

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
   srvridxcnt = srvr.vapi.getTotalResults(resptree=srvrresp,
                                          filename='srvr_search')
   srvrndidxcnt = srvr.vapi.getTotalResultsNoDups(resptree=srvrresp,
                                          filename='srvr_search')
   clntidxcnt = clnt.vapi.getTotalResults(resptree=clntresp,
                                          filename='clnt_search')
   outerclntidxcnt = outerclnt.vapi.getTotalResults(resptree=outerclntresp,
                                          filename='outer_clnt_search')

   print tname, ":  ##################"

   allowedmisses = srvridxcnt - srvrndidxcnt

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
   
   miss = 0
   lfail = 0
   for item in srvrurllst:
      x = isInList(item, clnturllst)
      if ( x != 1 ):
         print "Expected URL not found(server item not on client): ", item
         lfail = 1
      else:
         if ( verbose == 1 ):
            print "found(srvr): ", item

   for item in clnturllst:
      x = isInList(item, srvrurllst)
      if ( x != 1 ):
         miss += 1
         print "increment miss", miss
         print "Expected URL not found(client item not on server): ", item
         lfail = 1
      else:
         if ( verbose == 1 ):
            print "found(clnt): ", item

   if ( lfail > 0 ):
      if ( miss > allowedmisses ):
         fail += lfail

   return fail

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

def usage():

   print "dstidx-proxy-2.tst -S <server> -C <client> -O <outer client>"
   print "   <server> = server side machine, example: testbed14"
   print "   <client> = client side machine, example: testbed15"
   print "   <outer client> = client to client machine, example: testbed15"
   print "   Example cmd:  dstidx-proxy-2.tst -S testbed14 -C testbed15"
   print "                                    -O testbed16-3"

   return


if __name__ == "__main__":

   global final_target_dir

   opts, args = getopt.getopt(sys.argv[1:], "AS:C:vO:kdamunT:", ["server=", "client=", "verbose", "outerclient=", "keepit", "add", "delete", "modify", "uriadd", "urimodify", "all", "testname="])

   keepit = False
   my_server = None
   my_client = None
   my_outerclient = None
   verbose = 0
   dothedelete = False
   dothefileadd = False
   dotheuriadd = False
   dothemodify = False
   dotheurimod = False

   tname = "dstidx-common2"

   for o, a in opts:
      if o in ("-T", "--testname"):
         tname = a
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
      if o in ("-d", "--delete"):
         dothedelete = True
      if o in ("-a", "--add"):
         dothefileadd = True
      if o in ("-m", "--modify"):
         dothemodify = True
      if o in ("-u", "--uriadd"):
         dotheuriadd = True
      if o in ("-n", "--urimodify"):
         dotheuriadd = True
         dotheurimod = True
      if o in ("-A", "--all"):
         dothedelete = True
         dothefileadd = True
         dothemodify = True
         dotheuriadd = True
         dotheurimod = True

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

   print tname, ":  Getting server", my_server
   srvr = host_environ.HOSTENVIRON(hostname=my_server)
   srvr.cgi.version_check(8.0)
   print tname, ":  Done", srvr.get_fqdn()

   srvr.dump_host_data()

   print tname, ":  Getting middle", my_client
   clnt = host_environ.HOSTENVIRON(hostname=my_client)
   print tname, ":  Done", clnt.get_fqdn()

   clnt.dump_host_data()

   print tname, ":  Getting client", my_outerclient
   outerclnt = host_environ.HOSTENVIRON(hostname=my_outerclient)
   print tname, ":  Done", outerclnt.get_fqdn()

   outerclnt.dump_host_data()

   root_dir = os.getenv('TEST_ROOT', '../dstidx-common2')
   full_dir = root_dir + '/tests/distributed-search/dstidx-common2/'
   filename = full_dir + 'basemiddlexml'

   fsn = srvr.get_fqdn()
   cmdstring = "cat " + filename + " | sed -e \'s;REPLACE__SERVER__NAME;" + fsn + ";g\' > orclmiddle.xml"
   p = subprocess.Popen(cmdstring, shell=True)
   os.waitpid(p.pid, 0)
   filename = full_dir + 'baseclntxml'

   fsn = clnt.get_fqdn()
   cmdstring = "cat " + filename + " | sed -e \'s;REPLACE__MIDDLE__SERVER;" + fsn + ";g\' > orclclnt.xml"
   p = subprocess.Popen(cmdstring, shell=True)
   os.waitpid(p.pid, 0)

   sharename = find_a_working_directory()
   filename = full_dir + 'basesrvrxml'

   f = open( filename, 'r' )
   config = f.read()
   f.close()
   config = config.replace( 'VIV_SAMBA_LINUX_SERVER',
     os.getenv( 'VIV_SAMBA_LINUX_SERVER' ) )
   config = config.replace( 'VIV_SAMBA_LINUX_USER',
     os.getenv( 'VIV_SAMBA_LINUX_USER' ) )
   config = config.replace( 'VIV_SAMBA_LINUX_PASSWORD',
     os.getenv( 'VIV_SAMBA_LINUX_PASSWORD' ) )
   config = config.replace( 'MY__NEW__PID', sharename )
   f = open( "orclsrvr.xml", 'w' )
   f.write( config )
   f.close()

   fail = 0

   restore_base_data()

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
   print tname, ":  orclsrvr --> orclmiddle"
   print tname, ":               orclsrvr   --> orclclnt"

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

   wait_for_all_idle(srvr, server_collection,
                     clnt, client_collection,
                     outerclnt, outer_client_collection, 0)

   print tname, ":  ##################"
   print tname, ":  Sleep for 5 seconds so any pending collection"
   print tname, ":  I/O can complete"
   time.sleep(5)


   ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"
   basecount = 406
   deler = 0
   adder = 0
   refuri = 0
   refdat = 0

   #
   #   Check that all collection data is correct
   #
   ecount = basecount
   print tname, ":  Initial data check"
   tfail = check_data(srvr, clnt, outerclnt, verbose, ecount)

   #
   #   If the check failed, try again just to make sure we were
   #   not stuck in the middle of an update when we tried to
   #   check the data.
   #
   if ( tfail == 1 ):
      print tname, ":  Initial data check failed, checking again ..."
      time.sleep(10)
      tfail = check_data(srvr, clnt, outerclnt, verbose, ecount)

   fail += tfail

   #####################################################################
   if ( dothedelete ):
      print "##########"
      print "##########"
      print tname, ":  Remove a file from the collection"

      srvr.vapi.api_sc_crawler_stop(subc='live', killit='true',
                                    collection=server_collection)

      remove_a_file('thing.txt')
      time.sleep(5)

      srvr.vapi.api_sc_crawler_start(subc='staging', stype='refresh-new',
                                    collection=server_collection)

      wait_for_all_idle(srvr, server_collection,
                        clnt, client_collection,
                        outerclnt, outer_client_collection, 0)

      print tname, ":  Remove data check"
      time.sleep(5)
      deler -= 1
      ecount = basecount + deler + adder + refuri + refdat
      tfail = check_data(srvr, clnt, outerclnt, verbose, ecount)
      if ( tfail == 1 ):
         print tname, ":  Initial data check failed, checking again ..."
         time.sleep(20)
         tfail = check_data(srvr, clnt, outerclnt, verbose, ecount)

      fail += tfail

   ####################################################################

   ####################################################################

   if ( dothefileadd ):
      print "##########"
      print "##########"
      print tname, ":  Add a file to the collection"

      srvr.vapi.api_sc_crawler_stop(subc='live', killit='true',
                                    collection=server_collection)

      copy_my_file('addedfile.txt', 'addedfile.txt')
      time.sleep(1)

      srvr.vapi.api_sc_crawler_start(subc='staging', stype='refresh-new',
                                    collection=server_collection)

      wait_for_all_idle(srvr, server_collection,
                        clnt, client_collection,
                        outerclnt, outer_client_collection, 0)

      print tname, ":  Add data check"
      time.sleep(5)
      adder = 1
      ecount = basecount + deler + adder + refuri + refdat
      tfail = check_data(srvr, clnt, outerclnt, verbose, ecount)
      if ( tfail == 1 ):
         print tname, ":  Initial data check failed, checking again ..."
         time.sleep(10)
         tfail = check_data(srvr, clnt, outerclnt, verbose, ecount)

      fail += tfail

   ####################################################################

   ####################################################################

   if ( dothemodify ):
      print "##########"
      print "##########"
      print tname, ":  Refresh data to change an existing file"

      srvr.vapi.api_sc_crawler_stop(subc='live', killit='true',
                                    collection=server_collection)

      copy_my_file('arizona.txt.mod', 'arizona.txt')
      time.sleep(1)
      srvr.vapi.api_sc_crawler_start(subc='staging', stype='refresh-new',
                                    collection=server_collection)

      wait_for_all_idle(srvr, server_collection,
                        clnt, client_collection,
                        outerclnt, outer_client_collection, 0)

      print tname, ":  Refresh data check"
      time.sleep(5)
      ecount = basecount + deler + adder + refuri + refdat

      tfail = check_data(srvr, clnt, outerclnt, verbose, ecount)
      if ( tfail == 1 ):
         print tname, ":  Initial data check failed, checking again ..."
         time.sleep(10)
         tfail = check_data(srvr, clnt, outerclnt, verbose, ecount)

      fail += tfail

   ####################################################################

   ####################################################################


   if ( dotheuriadd ):
      print "##########"
      print "##########"
      print tname, ":  Refresh data for uri update"

      srvr.vapi.api_sc_crawler_stop(subc='live', killit='true',
                                    collection=server_collection)

      copy_my_file('uristocrawl.orig', 'uristocrawl.html')
      time.sleep(1)
      srvr.vapi.api_sc_crawler_start(subc='live', stype='resume',
                                    collection=server_collection)
      srvr.vapi.api_sc_crawler_start(subc='live', stype='refresh-inplace',
                                    collection=server_collection)

      wait_for_all_idle(srvr, server_collection,
                        clnt, client_collection,
                        outerclnt, outer_client_collection, 0)

      print tname, ":  Refresh data check(uri addition)"
      time.sleep(5)
      refuri = 1
      ecount = basecount + deler + adder + refuri + refdat
      tfail = check_data(srvr, clnt, outerclnt, verbose, ecount)
      if ( tfail == 1 ):
         print tname, ":  Initial data check failed, checking again ..."
         time.sleep(10)
         tfail = check_data(srvr, clnt, outerclnt, verbose, ecount)

      fail += tfail

   ####################################################################

   ####################################################################

   if ( dotheurimod ):
      print "##########"
      print "##########"
      print tname, ":  Refresh data to do a uri update"

      srvr.vapi.api_sc_crawler_stop(subc='live', killit='true',
                                    collection=server_collection)

      copy_my_file('uristocrawl.mod', 'uristocrawl.html')
      time.sleep(1)
      srvr.vapi.api_sc_crawler_start(subc='live', stype='refresh-inplace',
                                    collection=server_collection)

      wait_for_all_idle(srvr, server_collection,
                        clnt, client_collection,
                        outerclnt, outer_client_collection, 0)

      print tname, ":  Refresh data check(uri update)"
      time.sleep(5)
      refuri = 1
      ecount = basecount + deler + adder + refuri + refdat
      tfail = check_data(srvr, clnt, outerclnt, verbose, ecount)
      if ( tfail == 1 ):
         print tname, ":  Initial data check failed, checking again ..."
         time.sleep(10)
         tfail = check_data(srvr, clnt, outerclnt, verbose, ecount)

      fail += tfail

   ####################################################################
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
      print tname, ":  Deleting the working directory"
      try:
         shutil.rmtree(final_target_dir)
      except:
         print tname, ":  Directory delete failed.  Does not effect"
         print tname, ":  test outcome."
   else:
      print tname, ":  WARNING, the collections still exist.  It is"
      print tname, ":           possible that other tests may have issues"
      print tname, ":           due to the ports these collections use"

   if ( fail == 0 ):
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"

   sys.exit(1)
