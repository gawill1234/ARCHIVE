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
import time
import cgi_interface
import vapi_interface
import velocityAPI


if __name__ == "__main__":

   dictionary_list = ['test_dictionary', '1234567890', 'AB-12-cd',
                      'abcdefghijklmnopqrstuvwxyz',
                      'ABCDEFGHIJKLMNOPQRSTUVWXYZ']

   ##############################################################
   print "api-dict-stop-1:  ##################"
   print "api-dict-stop-1:  INITIALIZE"
   print "api-dict-stop-1:  dictionary-create/build/status/delete"
   print ""
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   for dictionary_name in dictionary_list:

      print "api-dict-stop-1:  Dictionary name,", dictionary_name
     
      ##############################################################
      print "api-dict-stop-1:  Make sure test dictionary does not exist"
      try:
         yy.api_repository_get(xx=xx,  elemtype="dictionary",
                               elemname=dictionary_name)
         colnm = yy.get_repo_elem_name(xx=xx, vfunc='repository-get',
                                       trib='dictionary')
         if ( colnm == dictionary_name ):
            print "api-dict-stop-1:  Test dictionary exists, deleting"
            try:
               yy.api_dictionary_stop(xx=xx, dictionary_name=dictionary_name)
               yy.api_dictionary_delete(xx=xx, dictionary_name=dictionary_name)
            except velocityAPI.VelocityAPIexception:
               print "api-dict-stop-1:  Test dictionary exists, could not delete"
               print "api-dict-stop-1:  Exiting"
               sys.exit(1)
      except velocityAPI.VelocityAPIexception:
         pass
   
      thebeginning = time.time()
      
      ##############################################################
      #
      #   Create the dictionary
      #
      print "api-dict-stop-1:  Create the dictionary"
      yy.api_dictionary_create(xx=xx, dictionary_name=dictionary_name)
      print "api-dict-stop-1:     Get the dictionary node from the repository"
      yy.api_repository_get(xx=xx, elemtype="dictionary",
                            elemname=dictionary_name)
      colnm = yy.get_repo_elem_name(xx=xx, vfunc='repository-get',
                                    trib='dictionary')
   
      if ( colnm != dictionary_name ):
         print "api-dict-stop-1:     Dictionary creation failed,", colnm
         print "api-dict-stop-1:     Test can not continue"
         sys.exit(1)
      else:
         print "api-dict-stop-1:     Dictionary creation succeeded,", colnm
   
      ##############################################################
      #
      #   Build the dictionary (start it anyway)
      #
      print "api-dict-stop-1:  Build the dictionary (start)"
      yy.api_dictionary_build(xx=xx, dictionary_name=dictionary_name)

      ##############################################################
      #
      #   Stop the dictionary (or try) during the build
      #
      print "api-dict-stop-1:  Stop the dictionary (while building)"
      yy.api_dictionary_stop(xx=xx, dictionary_name=dictionary_name)
      dstat = yy.api_dictionary_status(xx=xx, dictionary_name=dictionary_name)
      while ( dstat != "aborted" ) and ( dstat != "finished" ):
         print "api-dict-stop-1:     Current build status,", dstat
         time.sleep(1)
         print "api-dict-stop-1:     Recheck the dictionary status"
         dstat = yy.api_dictionary_status(xx=xx,
                                          dictionary_name=dictionary_name)

      if ( dstat != "finished" ):
         ##############################################################
         #
         #   Build the dictionary (start it anyway)
         #
         if ( dstat == 'aborted' ):
            print "api-dict-stop-1:  Build the dictionary (restart)"
            yy.api_dictionary_build(xx=xx, dictionary_name=dictionary_name)
   
         ##############################################################
   
      ##############################################################
   
      ##############################################################
      #
      #   Check the status of the dictionary
      #
      print "api-dict-stop-1:  Check the dictionary status"
      dstat = yy.api_dictionary_status(xx=xx, dictionary_name=dictionary_name)
   
      while ( dstat != "finished" ):
         print "api-dict-stop-1:     Current build status,", dstat
         time.sleep(1)
         print "api-dict-stop-1:     Recheck the dictionary status"
         dstat = yy.api_dictionary_status(xx=xx,
                                          dictionary_name=dictionary_name)
   
      ##############################################################
      #
      #   final build status
      #
      print "api-dict-stop-1:     Final build status,", dstat
   
      print "api-dict-stop-1:  Get the dictionary node from the repository"
      yy.api_repository_get(xx=xx, elemtype="dictionary",
                            elemname=dictionary_name)
      colnm = yy.get_repo_elem_name(xx=xx, vfunc='repository-get',
                                    trib='dictionary')
   
      if ( colnm != dictionary_name ):
         print "api-dict-stop-1:  Dictionary build failed,", colnm
         print "api-dict-stop-1:  Test can not continue"
         sys.exit(1)
      else:
         print "api-dict-stop-1:  Dictionary build succeeded,", colnm
   
      ##############################################################
      #
      #   Delete the dictionary
      #
      print "api-dict-stop-1:  Delete the dictionary"
      yy.api_dictionary_delete(xx=xx, dictionary_name=dictionary_name)
      try:
         yy.api_repository_get(xx=xx, elemtype="dictionary",
                               elemname=dictionary_name)
         print "api-dict-stop-1:     Dictionary deletion failed"
         print "api-dict-stop-1:     Test can not continue"
         sys.exit(1)
      except velocityAPI.VelocityAPIexception:
         print "api-dict-stop-1:     Dictionary deletion succeeded,", dictionary_name
   
      ##############################################################
      print ""
   
   print "api-dict-stop-1:  Test Passed"
   sys.exit(0)
