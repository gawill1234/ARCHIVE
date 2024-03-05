#!/usr/bin/python

#
#   Test of the api
#   This test is for search-collection-create and
#   search-collection-delete.  It creates and deletes
#   a number of collections using different variations
#   of characters.
#

import sys, cgi_interface, vapi_interface 

if __name__ == "__main__":

   collection_list = ['letters', '1234', 'fuzzygrue', 'AB-CD-1',
                      'flabbergast', '123abc_DEF456', 'Z', '9']
   creation = deletion = 0
   listlen = 8

   print "api-create-delete-1:  search-collection-create/search-collection-delete"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   for collection_name in collection_list:

      print ""
      print "api-create-delete-1:  Working collection is", collection_name

      if ( xx.collection_exists(collection_name) == 0 ):
         print "api-create-delete-1:  Collection", collection_name, "does not exist, creating"
         yy.api_sc_create(xx=xx, collection=collection_name, vfunc='search-collection-create')
         if ( xx.collection_exists(collection_name) == 0 ):
            print "api-create-delete-1:  ERROR, Collection does not exist,", collection_name
         else:
            print "api-create-delete-1:  Collection", collection_name, "created"
            print "api-create-delete-1:     using search-collection-create"
            creation = creation + 1
            yy.api_sc_delete(xx=xx, collection=collection_name, vfunc='search-collection-delete')

            if ( xx.collection_exists(collection_name) == 0 ):
               print "api-create-delete-1:  Collection", collection_name, "deleted"
               print "api-create-delete-1:     using search-collection-delete"
               deletion = deletion + 1
            else:
               print "api-create-delete-1:  ERROR, Collection not deleted,", collection_name
      else:
         print "api-create-delete-1:  ERROR, Collection exists before test start,", collection_name


   xx.kill_all_services()

   if ( creation == listlen and deletion == listlen ):
      print "api-create-delete-1:  Test Passed"
      sys.exit(0)

   print "api-create-delete-1:  Test Failed"
   sys.exit(1)
