#!/usr/bin/python

#
#   Test of the api
#   This test is for search-collection-create and
#   search-collection-delete.  It creates and deletes
#   a number of collections using different variations
#   of characters.
#

import sys, time, cgi_interface, vapi_interface


if __name__ == "__main__":

   collection_name = "dynamic-fi-1"
   tname = 'dynamic-fi-1'

   crlurlnd = '<crawl-url url="oracle://testbed5.test.vivisimo.com:1521/orcl/vessel_view?key-val=294" enqueue-type="reenqueued" status="complete"><crawl-data content-type="application/vxml" encoding="xml"><document url="oracle://testbed5.test.vivisimo.com:1521/orcl/vessel_view?key-val=294"><content name="GOOBER" fast-index="set" type="text">GermanBattle</content></document></crawl-data><curl-options><curl-option name="default-allow" added="added">allow</curl-option><curl-option name="max-hops" added="added">1</curl-option></curl-options></crawl-url>'

   colfile = ''.join([collection_name, '.xml'])
   maxcount = 10
   i = 0
   cs_pass = 0

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  Content base fast index"
   print tname, ":     Simple fast index creation"
   print tname, ":     Query of non-existent fi"
   
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   xx.version_check(7.1)

   print tname, ":  Create and check the base collection"
   xx.create_collection(collection=collection_name, usedefcon=1)

   thebeginning = time.time()
   xx.start_crawl(collection=collection_name)
   xx.wait_for_idle(collection=collection_name)

   xx.run_query(collection=collection_name, query="Germany",
                  defoutput='querywork/germany.wazzat')

   gval10 = int(xx.count_query_urls(filenm='querywork/germany.wazzat'))
   gval20 = int(xx.query_url_count(filenm='querywork/germany.wazzat'))

   xx.run_query(collection=collection_name, query="Germany",
                  ficond='$SHIP_TYPE = \"Battleship\"',
                  defoutput='querywork/battleships.wazzat')

   bval10 = int(xx.count_query_urls(filenm='querywork/battleships.wazzat'))
   bval20 = int(xx.query_url_count(filenm='querywork/battleships.wazzat'))


   print tname, ":  ##################"
   print tname, ":  The actual enqueue"
   print tname, ":  enqueue url (Database url)"
   yy.api_sc_enqueue(xx=xx, collection=collection_name,
                      url=crlurlnd)
   xx.wait_for_idle(collection=collection_name)

   xx.run_query(collection=collection_name, query="Germany",
                  defoutput='querywork/figermany.wazzat')

   gval11 = int(xx.count_query_urls(filenm='querywork/figermany.wazzat'))
   gval21 = int(xx.query_url_count(filenm='querywork/figermany.wazzat'))

   xx.run_query(collection=collection_name, query="Germany",
                  ficond='$SHIP_TYPE = \"Battleship\"',
                  defoutput='querywork/fibattleships.wazzat')

   bval11 = int(xx.count_query_urls(filenm='querywork/fibattleships.wazzat'))
   bval21 = int(xx.query_url_count(filenm='querywork/fibattleships.wazzat'))

   print tname, ":  Query fi cond GOOBER"
   xx.run_query(collection=collection_name, query="",
                  ficond='$GOOBER = \"GermanBattle\"',
                  defoutput='querywork/fibattleships.wazzat')

   print tname, ":  Query fi cond ZOTS (does not exist)"
   xx.run_query(collection=collection_name, query="",
                  ficond='$ZOTS = \"GermanBattle\"',
                  defoutput='querywork/fibattleships2.wazzat')

   gooval1 = int(xx.count_query_urls(filenm='querywork/fibattleships.wazzat'))
   gooval2 = int(xx.query_url_count(filenm='querywork/fibattleships.wazzat'))
   gooval3 = int(xx.count_query_urls(filenm='querywork/fibattleships2.wazzat'))
   gooval4 = int(xx.query_url_count(filenm='querywork/fibattleships2.wazzat'))

   if ( ( (bval10 - bval11) != 1 ) or
        ( (bval20 - bval21) != 1 ) or
        ( (gval10 - gval11) != 1 ) or
        ( (gval20 - gval21) != 1 ) ):
      print tname, ":  Simple fast index failed (query elimination)"
      cs_pass = 1

   if ( gooval1 != 1 and gooval2 != 1 ):
      print tname, ":  Simple fast index failed (FI query)"
      cs_pass = 1

   if ( gooval3 != 0 and gooval4 != 0 ):
      print tname, ":  Simple fast index worked? (FI query does not exist)"
      cs_pass = 1

   if ( cs_pass == 0 ):
      print tname, ":  Test Passed"
      xx.stop_crawl(collection=collection_name, force=1)
      xx.stop_indexing(collection=collection_name, force=1)
      xx.delete_collection(collection=collection_name)
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
