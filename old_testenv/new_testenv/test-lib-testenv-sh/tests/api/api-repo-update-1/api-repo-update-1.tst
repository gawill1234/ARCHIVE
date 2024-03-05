#!/usr/bin/python

#
#   Test of the api
#   Test of the repository-update function.
#   This is very rudimentary, only testing the update of a very small
#   node.   This is due to http limitations on the amount of data
#   that can be sent as part of the url line.
#
#   This test does use repository-get to do verification, so if that
#   is broken, so is this test.
#   It also uses repository-add and repository-delete.
#

import sys
import cgi_interface
import vapi_interface
import velocityAPI

def get_repo_elem_content(xx=None, vfunc=None, trib="application"):

   cmd = "xsltproc"

   if ( vfunc == None ):
      return

   arg1 = ''.join([xx.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
   opts = ''.join(['--stringparam mynode repo-content --stringparam mytrib ', trib])
   dumpit = ''.join(['querywork/', vfunc, '.wazzat'])
 
   cmdopts = ' '.join([opts, arg1, dumpit])

   y = xx.exec_command_stdout(cmd, cmdopts, None)

   return y

#
#   It was just easier to create a specific function for the add.
#   At least at the time, anyway.
#
def do_repo_add(xx=None, yy=None):

   vfunc = "repository-add"
   #
   #   This is what the node string looks like in human readable form.
   #      <testnode name="boguscat"><content>Dog Butt</content></testnode>
   #
   #nodestring = "%3Ctestnode%20name%3D%22boguscat%22%3E%3Ccontent%3EDog%20Butt%3C%2Fcontent%3E%3C%2Ftestnode%3E"
   nodestring = '<testnode name="boguscat"><content>Dog Butt</content></testnode>'

   yy.api_repository_add(xx=xx, xmlstr=nodestring)

   return

#
#   It was just easier to create a specific function for the add.
#   At least at the time, anyway.
#
def do_repo_update(xx=None, yy=None):

   vfunc = "repository-update"
   #
   #   This is what the node string looks like in human readable form.
   #      <testnode name="bogus"><content>Cat Paws</content></testnode>
   #
   #nodestring = "%3Ctestnode%20name%3D%22boguscat%22%3E%3Ccontent%3ECat%20Paws%3C%2Fcontent%3E%3C%2Ftestnode%3E"
   nodestring = '<testnode name="boguscat"><content>Cat Paws</content></testnode>'

   yy.api_repository_update(xx=xx, xmlstr=nodestring)

   return


if __name__ == "__main__":

   lstcnt = 0
   fail = 0

   print "api-repo-update-1:  repository-update"

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   
   print "api-repo-update-1:  Add a new node to the repository"
   do_repo_add(xx=xx, yy=yy)

   yy.api_repository_get(xx=xx, vfunc="repository-get", elemtype="testnode",
                 elemname="boguscat")
   colnm = yy.get_repo_elem_name(xx=xx, vfunc='repository-get', trib="testnode")
   if ( colnm != "boguscat" ):
      print "api-repo-update-1:  get of type testnode failed"
      fail = 1
   else:
      print "api-repo-update-1:  testnode name, ", colnm

   colnm = get_repo_elem_content(xx=xx, vfunc='repository-get', trib="testnode")
   if ( colnm != "Dog Butt" ):
      print "api-repo-update-1:  get of type testnode failed"
      fail = 1
   else:
      print "api-repo-update-1:  testnode content, ", colnm

   print "api-repo-update-1:  Update the new node in the repository"
   do_repo_update(xx=xx, yy=yy)

   #
   #   repository-get of a testnode
   #
   print "api-repo-update-1:  Get the new node from the repository"
   yy.api_repository_get(xx=xx, vfunc="repository-get", elemtype="testnode",
                 elemname="boguscat")

   colnm = yy.get_repo_elem_name(xx=xx, vfunc='repository-get', trib="testnode")
   if ( colnm != "boguscat" ):
      print "api-repo-update-1:  get of type testnode failed"
      fail = 1
   else:
      print "api-repo-update-1:  testnode name, ", colnm

   colnm = get_repo_elem_content(xx=xx, vfunc='repository-get', trib="testnode")
   if ( colnm != "Cat Paws" ):
      print "api-repo-update-1:  get of type testnode failed"
      fail = 1
   else:
      print "api-repo-update-1:  testnode content, ", colnm

   print "api-repo-update-1:  Delete the new node from the repository"
   yy.api_repository_del(xx=xx, vfunc="repository-delete", elemtype="testnode",
                 elemname="boguscat")

   print "api-repo-update-1:  Get the deleted node from the repository"
   try:
      yy.api_repository_get(xx=xx, vfunc="repository-get", elemtype="testnode",
                            elemname="boguscat")
      print "api-repo-update-1:  get of type testnode failed"
      fail = 1
   except velocityAPI.VelocityAPIexception:
      print "api-repo-update-1:  testnode  exception as expected"

   #
   #   If any of the starts or stops failed, or if the wrong number
   #   of search services are running, skip to the end and fail
   #   Otherwise, test passed
   #
   if ( fail == 0 ):
      print "api-repo-update-1:  Test Passed"
      sys.exit(0)

   print "api-repo-update-1:  Test Failed"
   sys.exit(1)
