#!/usr/bin/python

#
#   Test of the api
#   Test of the repository-add and repository-delete functions
#   This is very rudimentary, only testing the add of a very small
#   node.   This is due to http limitations on the amount of data
#   that can be sent as part of the url line.
#
#   This test does use repository-get to do verification, so if that
#   is broken, so is this test.
#

import sys
import cgi_interface
import vapi_interface
import velocityAPI


#
#   It was just easier to create a specific function for the add.
#   At least at the time, anyway.
#
def do_repo_add(xx=None, yy=None):

   vfunc = "repository-add"
   #
   #   This is what the node string looks like in human readable form.
   #      <testnode name="bogus"><abcd>Dog Butt</abcd></testnode>
   #
   #nodestring = "%3Ctestnode%20name%3D%22bogus%22%3E%3Cabcd%3EDog%20Butt%3C%2Fabcd%3E%3C%2Ftestnode%3E"
   nodestring = '<testnode name="bogus"><abcd>Dog Butt</abcd></testnode>'

   yy.api_repository_add(xx, xmlstr=nodestring)

   return

if __name__ == "__main__":

   lstcnt = 0
   fail = 0

   print "api-repo-add-del-1:  repository-add/delete"

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   
   print "api-repo-add-del-1:  Add a new node to the repository"
   do_repo_add(xx=xx, yy=yy)

   #
   #   repository-get of a testnode
   #
   print "api-repo-add-del-1:  Get the new node from the repository"
   yy.api_repository_get(xx=xx, vfunc="repository-get", elemtype="testnode",
                 elemname="bogus")

   colnm = yy.get_repo_elem_name(xx=xx, vfunc='repository-get', trib="testnode")
   if ( colnm != "bogus" ):
      print "api-repo-add-del-1:  get of type testnode failed"
      fail = 1
   else:
      print "api-repo-add-del-1:  testnode name, ", colnm

   print "api-repo-add-del-1:  Delete the new node from the repository"
   yy.api_repository_del(xx=xx, vfunc="repository-delete", elemtype="testnode",
                 elemname="bogus")

   print "api-repo-add-del-1:  Get the deleted node from the repository"
   try:
      yy.api_repository_get(xx=xx, vfunc="repository-get", elemtype="testnode",
                            elemname="bogus")
      print "api-repo-add-del-1:  get of type testnode failed"
      fail = 1
   except velocityAPI.VelocityAPIexception:
      print "api-repo-add-del-1:  testnode exception, as expected"


   #
   #   If any of the starts or stops failed, or if the wrong number
   #   of search services are running, skip to the end and fail
   #   Otherwise, test passed
   #
   if ( fail == 0 ):
      print "api-repo-add-del-1:  Test Passed"
      sys.exit(0)

   print "api-repo-add-del-1:  Test Failed"
   sys.exit(1)
