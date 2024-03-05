#!/usr/bin/python

import os, sys, time, host_environ
import getopt, subprocess
from lxml import etree

srvr_tot_diff = clnt_tot_diff = 0
srvr_tot_diff_v = clnt_tot_diff_v = 0

def watch_memory(srvr=None, server_collection=None,
                 srv_lst_old={},
                 clnt=None, client_collection=None,
                 clt_lst_old={}):

   global srvr_tot_diff, clnt_tot_diff
   global srvr_tot_diff_v, clnt_tot_diff_v

   mem_watch_srv = {}
   mem_watch_clt = {}

   srvcrlst = srvr.cgi.get_service_pid_list(service='crawler',
                                            collection=server_collection)
   cltcrlst = clnt.cgi.get_service_pid_list(service='crawler',
                                            collection=client_collection)

   print "SERVER:", srvcrlst
   print "CLIENT:", cltcrlst

   for item in srvcrlst:
      key1 = ''.join([item, '-rss'])
      key2 = ''.join([item, '-vmsize'])
      rss, vmsize = srvr.cgi.get_process_memory(pid=item)
      mem_watch_srv[key1] = rss
      mem_watch_srv[key2] = vmsize
      print "Server RSS Memory for pid", item, ":", mem_watch_srv[key1]
      print "Server Virtual Memory for pid", item, ":", mem_watch_srv[key2]
      if ( srv_lst_old != {} ):
         print "Refresh SERVER crawler memory size:"
         try:
            print "Old RSS Server Memory for pid", item, ":", srv_lst_old[key1]
            print "Old Virtual Server Memory for pid", item, ":", srv_lst_old[key2]
            if ( int(mem_watch_srv[key2]) > int(srv_lst_old[key2]) ):
               sizediff_r = int(mem_watch_srv[key1]) - int(srv_lst_old[key1])
               sizediff_v = int(mem_watch_srv[key2]) - int(srv_lst_old[key2])
               print "   rss grown by", sizediff_r, "bytes"
               print "   virtual grown by", sizediff_v, "bytes"
               srvr_tot_diff = srvr_tot_diff + sizediff_r
               srvr_tot_diff_v = srvr_tot_diff_v + sizediff_v
            else:
               sizediff_r = int(srv_lst_old[key1]) - int(mem_watch_srv[key1])
               sizediff_v = int(srv_lst_old[key2]) - int(mem_watch_srv[key2])
               print "   rss shrunk by", sizediff_r, "bytes"
               print "   virtual shrunk by", sizediff_v, "bytes"
               srvr_tot_diff = srvr_tot_diff - sizediff_r
               srvr_tot_diff_v = srvr_tot_diff_v - sizediff_v
            print "Refresh SERVER total rss memory size change:", srvr_tot_diff
            print "Refresh SERVER total virtual memory size change:", srvr_tot_diff_v
         except KeyError:
            print "Old server entry for pid", item, "does not exist"

   for item in cltcrlst:
      key1 = ''.join([item, '-rss'])
      key2 = ''.join([item, '-vmsize'])
      rss, vmsize = clnt.cgi.get_process_memory(pid=item)
      mem_watch_clt[key1] = rss
      mem_watch_clt[key2] = vmsize
      print "Client RSS Memory for pid", item, ":", mem_watch_clt[key1]
      print "Client Virtual Memory for pid", item, ":", mem_watch_clt[key2]
      if ( clt_lst_old != {} ):
         print "Refresh CLIENT crawler memory size:"
         try:
            print "Old Client RSS Memory for pid", item, ":", clt_lst_old[key1]
            print "Old Client Virtual Memory for pid", item, ":", clt_lst_old[key2]
            if ( int(mem_watch_clt[key2]) > int(clt_lst_old[key2]) ):
               sizediff_r = int(mem_watch_clt[key1]) - int(clt_lst_old[key1])
               sizediff_v = int(mem_watch_clt[key2]) - int(clt_lst_old[key2])
               print "   rss grown by", sizediff_r, "bytes"
               print "   virtual grown by", sizediff_v, "bytes"
               clnt_tot_diff = clnt_tot_diff + sizediff_r
               clnt_tot_diff_v = clnt_tot_diff_v + sizediff_v
            else:
               sizediff_r = int(clt_lst_old[key1]) - int(mem_watch_clt[key1])
               sizediff_v = int(clt_lst_old[key2]) - int(mem_watch_clt[key2])
               print "   rss shrunk by", sizediff_r, "bytes"
               print "   virtual shrunk by", sizediff_v, "bytes"
               clnt_tot_diff = clnt_tot_diff - sizediff_r
               clnt_tot_diff_v = clnt_tot_diff_v - sizediff_v
            print "Refresh CLIENT total rss memory size change:", clnt_tot_diff
            print "Refresh CLIENT total virtual memory size change:", clnt_tot_diff_v
         except KeyError:
            print "Old client entry for pid", item, "does not exist"

   return mem_watch_srv, mem_watch_clt

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

   print "dstidx-mem-leak.tst -S <server> -C <client>"
   print "   <server> = server side machine, example: testbed14"
   print "   <client> = client side machine, example: testbed15"
   print "   Example cmd:  dstidx-basic-1.tst -S testbed14 -C testbed15"

   return


if __name__ == "__main__":

   global srvr_tot_diff, clnt_tot_diff
   global srvr_tot_diff_v, clnt_tot_diff_v

   opts, args = getopt.getopt(sys.argv[1:], "S:C:vk", ["server=", "client=", "verbose", "keepit"])

   keepit = False
   my_server = None
   my_client = None
   verbose = 0

   for o, a in opts:
      if o in ("-S", "--server"):
         my_server = a
      if o in ("-C", "--client"):
         my_client = a
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

   try:
      os.remove('orclgetsmb.xml')
      os.remove('smbgetorcl.xml')
   except:
      print "Nothing to remove, oh well."

   fsn = fullsysname(my_server)
   fsn2 = fullsysname(my_client)

   cmdstring = "cat ogsbasexml | sed -e \'s;REPLACE__ME;" + fsn2 + ";g\' > orclgetsmb.xml"
   subprocess.Popen(cmdstring, shell=True)

   cmdstring = "cat sgobasexml | sed -e \'s;REPLACE__ME;" + fsn + ";g\' > smbgetorcl.xml"
   subprocess.Popen(cmdstring, shell=True)

   fail = 0

   tname = "dstidx-mem-leak"
   server_collection = "orclgetsmb"
   client_collection = "smbgetorcl"

   server_file = server_collection + '.xml'
   client_file = client_collection + '.xml'

   ##############################################################

   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  distributed indexing basic test 28"
   print tname, ":  1 to 1"
   print tname, ":  client is a server and"
   print tname, ":  server is a client"

   srvr = host_environ.HOSTENVIRON(hostname=my_server)
   clnt = host_environ.HOSTENVIRON(hostname=my_client)

   srvr.cgi.version_check(8.0)

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

   print tname, ":  ##################"
   print tname, ":  Start server crawl"
   srvr.vapi.api_sc_crawler_start(collection=server_collection)

   print tname, ":  ##################"
   print tname, ":  Start client crawl"
   clnt.vapi.api_sc_crawler_start(collection=client_collection)

   print tname, ":  ##################"
   print tname, ":  Wait for server crawl to go idle"
   srvr.cgi.wait_for_idle(collection=server_collection)

   print tname, ":  ##################"
   print tname, ":  Wait for client crawl to go idle"
   clnt.cgi.wait_for_idle(collection=client_collection)

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


   ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"

   srvrresp = srvr.vapi.api_qsearch(source=server_collection, num=500,
                                    query='', filename='srvr_search',
                                    odup='true')
   clntresp = clnt.vapi.api_qsearch(source=client_collection, num=500,
                                    query='', filename='clnt_search',
                                    odup='true')

   #
   #   Check that recorded values are identical
   #
   expectedcnt = 406
   srvridxcnt = srvr.vapi.getTotalResults(resptree=srvrresp,
                                          filename='srvr_search')
   clntidxcnt = clnt.vapi.getTotalResults(resptree=clntresp,
                                          filename='clnt_search')

   print tname, ":  ##################"


   if ( srvridxcnt != clntidxcnt or srvridxcnt != expectedcnt or
        clntidxcnt != expectedcnt ):
      print tname, ":  total results differ between client and server"
      print tname, ":  client results = ", clntidxcnt
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

   print tname, ":  ##################"


   if ( srvrurlcnt != clnturlcnt ):
      print tname, ":  total url results differ between client and server"
      print tname, ":  client results = ", clnturlcnt
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

   srv_lst_old = {}
   clt_lst_old = {}
   i = 0
   while ( i < 20 ):
      srv_lst_old, clt_lst_old = watch_memory(
                   srvr=srvr, server_collection=server_collection,
                   srv_lst_old=srv_lst_old,
                   clnt=clnt, client_collection=client_collection,
                   clt_lst_old=clt_lst_old)
      srvr.vapi.api_sc_crawler_start(collection=server_collection,
                                     stype='refresh-inplace')
      srvr.cgi.wait_for_idle(collection=server_collection)
      clnt.cgi.wait_for_idle(collection=client_collection)
      i += 1

   srv_lst_old, clt_lst_old = watch_memory(
                srvr=srvr, server_collection=server_collection,
                srv_lst_old=srv_lst_old,
                clnt=clnt, client_collection=client_collection,
                clt_lst_old=clt_lst_old)

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
   else:
      print tname, ":  WARNING, the collections still exist.  It is"
      print tname, ":           possible that other tests may have issues"
      print tname, ":           due to the ports these collections use"

   if ( fail == 0 ):
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"

   sys.exit(1)
