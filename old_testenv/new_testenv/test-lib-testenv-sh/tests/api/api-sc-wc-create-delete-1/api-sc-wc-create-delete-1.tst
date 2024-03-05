#!/usr/bin/python

#
#   Test of the api
#   This test is for the dictionary functions
#   create/build/status/delete
#   It creates and builds a very simple dictionary based on
#   the base dictionary.  That is then deleted.
#
#   The test is quite basic
#

import sys
import cgi_interface
import vapi_interface
import velocityAPI


if __name__ == "__main__":

   collection_name = "ascwcf-1"
   collection_working_name = "ascwcf-1(working-copy)"
   runode = "repository-unknown-node"

   colfile = ''.join([collection_name, '.xml'])
   failure = 0

   ##############################################################
   print "api-sc-wc-create-delete-1:  ##################"
   print "api-sc-wc-create-delete-1:  INITIALIZE"
   print "api-sc-wc-create-delete-1:  search-collection-working-copy-create/delete"

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   ####################################################################
   #
   #   Create the initial collection
   #
   print "api-sc-wc-create-delete-1:  Create the initial collection"
   print "api-sc-wc-create-delete-1:     collection =", collection_name
   print "api-sc-wc-create-delete-1:     working collection =", collection_working_name
   print "api-sc-wc-create-delete-1:     collection absent =", runode
   xx.create_collection(collection=collection_name, usedefcon=1)

   xx.start_crawl(collection=collection_name)
   xx.wait_for_idle(collection=collection_name)

   print "api-sc-wc-create-delete-1:  Clear the initial collection"
   yy.api_sc_indexer_stop(xx=xx, collection=collection_name,
                 vfunc='search-collection-indexer-stop')

   yy.api_sc_clean(xx=xx, collection=collection_name,
                 vfunc='search-collection-clean')

   yy.api_repository_get(xx=xx, vfunc='repository-get',
                  elemname=collection_name)

   ####################################################################
   #
   #   Make sure the initial collection exists even after
   #   being cleared out.
   #
   wname = yy.get_repo_elem_name(xx=xx, vfunc='repository-get', trib='collection')
   if ( wname != collection_name ):
      print "api-sc-wc-create-delete-1:     Collection does not exist (error)"
      failure = 1
   else:
      print "api-sc-wc-create-delete-1:     Collection exists (pass)"

   ####################################################################
   #
   #   Create the working copy and make sure it is created
   #
   print "api-sc-wc-create-delete-1:  Create the working copy collection"
   yy.api_sc_working_copy_create(xx=xx, collection=collection_name,
                 vfunc='search-collection-working-copy-create')

   yy.api_repository_get(xx=xx, vfunc='repository-get',
                  elemname=collection_working_name)

   wname = yy.get_repo_elem_name(xx=xx, vfunc='repository-get', trib='collection')
   if ( wname != collection_working_name ):
      print "api-sc-wc-create-delete-1:     Working collection not created (pass)"
      failure = 1
   else:
      print "api-sc-wc-create-delete-1:     Working collection created (pass)"

   ####################################################################
   #
   #   Delete the working copy and make sure the collection still
   #   exists and the working copy is gone.
   #
   print "api-sc-wc-create-delete-1:  Delete the working copy collection"
   yy.api_sc_working_copy_delete(xx=xx, collection=collection_name,
                 vfunc='search-collection-working-copy-delete')

   try:
      yy.api_repository_get(xx=xx, vfunc='repository-get',
                            elemname=collection_working_name)
      print "api-sc-wc-create-delete-1:     Working collection still exists (error)"
      failure = 1
   except velocityAPI.VelocityAPIexception:
      print "api-sc-wc-create-delete-1:     Working collection deleted (pass)"

   ####################################################################
   #
   #   Recreate the working copy and make sure both the collection
   #   and working copy are there
   #
   print "api-sc-wc-create-delete-1:  Recreate the working copy collection"
   yy.api_sc_working_copy_create(xx=xx, collection=collection_name,
                 vfunc='search-collection-working-copy-create')

   yy.api_repository_get(xx=xx, vfunc='repository-get',
                  elemname=collection_name)

   wname = yy.get_repo_elem_name(xx=xx, vfunc='repository-get', trib='collection')
   if ( wname != collection_name ):
      print "api-sc-wc-create-delete-1:     Collection deleted (error)"
      failure = 1
   else:
      print "api-sc-wc-create-delete-1:     Collection still exists (pass)"

   yy.api_repository_get(xx=xx, vfunc='repository-get',
                  elemname=collection_working_name)

   wname = yy.get_repo_elem_name(xx=xx, vfunc='repository-get', trib='collection')
   if ( wname != collection_working_name ):
      print "api-sc-wc-create-delete-1:     Working collection not created (error)"
      failure = 1
   else:
      print "api-sc-wc-create-delete-1:     Working collection created (pass)"

   ####################################################################
   #
   #   Delete the entire collection and check that collection
   #   and working copy are gone
   #
   print "api-sc-wc-create-delete-1:  Delete the collection"
   yy.api_sc_delete(xx=xx, collection=collection_name,
                 vfunc='search-collection-delete')
   try:
      yy.api_repository_get(xx=xx, vfunc='repository-get',
                            elemname=collection_working_name)
      print "api-sc-wc-create-delete-1:     Collection not deleted (error)"
      failure = 1
   except velocityAPI.VelocityAPIexception:
      print "api-sc-wc-create-delete-1:     Collection deleted (pass)"

   try:
      yy.api_repository_get(xx=xx, vfunc='repository-get',
                            elemname=collection_name)
      print "api-sc-wc-create-delete-1:     Working collection not deleted (error)"
      failure = 1
   except velocityAPI.VelocityAPIexception:
      print "api-sc-wc-create-delete-1:     Working collection deleted (pass)"

   ####################################################################
   #
   #   Issue pass/fail
   #
   if ( failure == 1 ):
      print "api-sc-wc-create-delete-1:  Test Failed"
      sys.exit(1)

   print "api-sc-wc-create-delete-1:  Test Passed"
   sys.exit(0)
