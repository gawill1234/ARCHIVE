#!/usr/bin/python

import sys, os, random, time, getopt
import vapi_interface, cgi_interface


class Collection:

   #
   #   build_collection:
   #      yes, no, rebuild

   def __init__(self, collection_name=None, build_collection=None,
                build_basis=None):

      self.set_the_collection(collection_name=collection_name)

      self.__vapi = vapi_interface.VAPIINTERFACE()
      self.__cgi = cgi_interface.CGIINTERFACE()

      self.__build = 'yes'
      self.__basis = 'default'
      self.__cex = 0

      self.reset_collection_build_value(build_collection=build_collection)
      self.reset_collection_basis_value(build_basis=build_basis)

      if ( self.__collection is not None ):
         self.full_collection_setup()

      return

   def set_the_collection(self, collection_name=None):

      if ( collection_name is None ):
         self.__collection = None
         self.__cfg_file = None
         print "COLLECTION SET ERROR:  No collection specified"
         return

      self.__collection = collection_name
      self.__cfg_file = self.__collection + '.xml'

      return

   def full_collection_setup(self):

      if ( self.__collection is not None ):
         if ( self.__build != 'no' ):
            self.does_the_collection_exist()
            self.create_the_collection()
            self.collection_services_start()
            self.wait_for_collection_to_complete()
         else:
            self.does_the_collection_exist()
            print "SETUP NOT DONE:  collection build value is no"
            return
      else:
         print "SETUP ERROR:  No collection specified"
         return

      return

   def reset_collection_basis_value(self, build_basis=None):

      if ( build_basis == None ):
         print "No build_basis value specified"
         print "build_basis value is still:", self.__basis
         return

      self.__basis = build_basis

      return self.__basis

   def reset_collection_build_value(self, build_collection=None):

      if ( build_collection == None ):
         print "No build_collection value specified"
         print "build_collection value is still:", self.__build
         return

      if ( build_collection.lower() != 'yes' ):
         if ( build_collection.lower() != 'no' ):
            if ( build_collection.lower() != 'rebuild' ):
               print "Invalid build_collection value:", build_collection
               print "build_collection value is still:", self.__build
               return

      self.__build = build_collection.lower()

      return self.__build

   def collection_existence_current_status(self):

      if ( self.__cex == 1 ):
         return 'yes'

      return 'no'

   def does_the_collection_exist(self):

      self.__cex = self.__cgi.collection_exists(collection=self.__collection)

      return  self.collection_existence_current_status()

   def wait_for_collection_to_complete(self):

      self.__cgi.wait_for_idle(collection=self.__collection)

      return

   def collection_services_start(self):

      self.__vapi.api_sc_indexer_start(collection=self.__collection,
                                       subc='live')

      self.__vapi.api_sc_crawler_start(collection=self.__collection,
                                       subc='live', stype='resume')

      return

   def collection_services_stop(self):

      self.__vapi.api_sc_crawler_stop(collection=self.__collection,
                                      killit='true', subc='live')
      self.__vapi.api_sc_crawler_stop(collection=self.__collection,
                                      killit='true', subc='staging')

      self.__vapi.api_sc_indexer_stop(collection=self.__collection,
                                      killit='true', subc='live')
      self.__vapi.api_sc_indexer_stop(collection=self.__collection,
                                      killit='true', subc='staging')

      self.__vapi.api_cb_stop()

      return

   def create_the_collection(self):

      dobuild = 0

      print "COLLECTION TO BUILD:", self.__collection

      if ( self.__build == 'no' ):
         self.does_the_collection_exist()
         return

      if ( self.__cex != 1 ):
         dobuild = 1
      else:
         if ( self.__build == 'rebuild' ):
            dobuild = 1
         else:
            print "COLLECTION EXISTS, NOT REBUILDING"

      if ( dobuild == 1 ):
         if ( os.access(self.__cfg_file, os.F_OK) ):
            if ( self.__cex == 1 ):
               self.delete_the_collection()

            if ( self.__basis == 'default' ):
               self.__vapi.api_sc_create(collection=self.__collection)
               self.__vapi.api_repository_update(xmlfile=self.__cfg_file)
            else:
               self.__vapi.api_sc_create(collection=self.__collection,
                                         based_on=self.__basis)

      self.does_the_collection_exist()

      return

   def delete_the_collection(self):

      self.collection_services_stop()
      #time.sleep(60)

      self.__vapi.api_sc_delete(collection=self.__collection)

      self.does_the_collection_exist()
 
      return


if __name__ == "__main__":

   collection = None
   dobuild = None
   basis = None

   opts, args = getopt.getopt(sys.argv[1:], "C:b:B:", ["collection=", "basis=", "build="])

   for o, a in opts:
      if o in ("-C", "--collection"):
         collection = a
      if o in ("-B", "--build"):
         dobuild = a
      if o in ("-b", "--basis"):
         basis = a


   thingy = Collection(collection_name=collection, build_collection=dobuild,
                       build_basis=basis)

   #thingy.delete_the_collection()

   sys.exit(0)

