#!/usr/bin/python

#
#   Test of the api
#

import sys
import cgi_interface
import vapi_interface
import velocityAPI

def get_repo_elem_content(xx=None, yy=None, vfunc=None, trib="application"):

   cmd = "xsltproc"

   if ( vfunc == None ):
      return

   arg1 = ''.join([xx.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
   opts = ''.join(['--stringparam mynode repo-content --stringparam mytrib ', trib])
   dumpit = yy.look_for_file(vfunc)
 
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
   #      <testnode name="bogusmd5"><content>Dog Butt</content></testnode>
   #
   #nodestring = "%3Ctestnode%20name%3D%22bogusmd5%22%3E%3Ccontent%3EDog%20Butt%3C%2Fcontent%3E%3C%2Ftestnode%3E"

   nodestring = '<testnode name="bogusmd5"><content>Dog Butt</content></testnode>'
   yy.api_repository_add(xx, xmlstr=nodestring)

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
   #nodestring = "%3Ctestnode%20name%3D%22bogusmd5%22%3E%3Ccontent%3ECat%20Paws%3C%2Fcontent%3E%3C%2Ftestnode%3E"

   nodestring = "<testnode name=\"bogusmd5\"><content>Cat Paws</content></testnode>"

   yy.api_repository_update(xx, xmlstr=nodestring)

   return


if __name__ == "__main__":

   lstcnt = 0
   fail = 0

   print "api-repo-getmd5-1:  repository-update"

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   
   print "api-repo-getmd5-1:  Add a new node to the repository"
   do_repo_add(xx=xx, yy=yy)

   expmd5="QYeD21nWrPYGtFR0Q+xuDA=="
   yy.api_repository_get(xx=xx, vfunc="repository-get", elemtype="testnode",
                 elemname="bogusmd5")

   yy.api_repository_get_md5(xx=xx, vfunc="repository-get-md5", 
                 elemtype="testnode",
                 elemname="bogusmd5")

   colnm = yy.get_repo_elem_name(xx=xx, vfunc='repository-get', trib="testnode")
   if ( colnm != "bogusmd5" ):
      print "api-repo-getmd5-1:  get of type testnode failed"
      fail = 1
   else:
      print "api-repo-getmd5-1:  testnode name, ", colnm

   colnm = get_repo_elem_content(xx=xx, yy=yy, vfunc='repository-get', trib="testnode")
   if ( colnm != "Dog Butt" ):
      print "api-repo-getmd5-1:  get of type testnode failed"
      fail = 1
   else:
      print "api-repo-getmd5-1:  testnode content, ", colnm

   colnm = get_repo_elem_content(xx=xx, yy=yy, vfunc='repository-get-md5', trib="md5")
   if ( colnm != expmd5 ):
      print "api-repo-getmd5-1:  get of type md5 failed"
      print "api-repo-getmd5-1:     Expected:", expmd5
      print "api-repo-getmd5-1:     Actual:  ", colnm
      fail = 1
   else:
      print "api-repo-getmd5-1:  md5 content,      ", colnm

   print "api-repo-getmd5-1:  Update the new node in the repository"
   do_repo_update(xx=xx, yy=yy)

   #
   #   repository-get of a testnode
   #
   expmd5="mpEIliFDKXPz+KD6ygd1ww=="
   print "api-repo-getmd5-1:  Get the new node from the repository"
   yy.api_repository_get(xx=xx, vfunc="repository-get", elemtype="testnode",
                 elemname="bogusmd5")

   yy.api_repository_get_md5(xx=xx, vfunc="repository-get-md5", 
                 elemtype="testnode",
                 elemname="bogusmd5")

   colnm = yy.get_repo_elem_name(xx=xx, vfunc='repository-get', trib="testnode")
   if ( colnm != "bogusmd5" ):
      print "api-repo-getmd5-1:  get of type testnode failed"
      fail = 1
   else:
      print "api-repo-getmd5-1:  testnode name, ", colnm

   colnm = get_repo_elem_content(xx=xx, yy=yy, vfunc='repository-get', trib="testnode")
   if ( colnm != "Cat Paws" ):
      print "api-repo-getmd5-1:  get of type testnode failed"
      fail = 1
   else:
      print "api-repo-getmd5-1:  testnode content, ", colnm

   colnm = get_repo_elem_content(xx=xx, yy=yy, vfunc='repository-get-md5', trib="md5")
   if ( colnm != expmd5 ):
      print "api-repo-getmd5-1:  get of type md5 failed"
      print "api-repo-getmd5-1:     Expected:", expmd5
      print "api-repo-getmd5-1:     Actual:  ", colnm
      fail = 1
   else:
      print "api-repo-getmd5-1:  md5 content,      ", colnm

   print "api-repo-getmd5-1:  Delete the new node from the repository"
   yy.api_repository_del(xx=xx, vfunc="repository-delete", elemtype="testnode",
                 elemname="bogusmd5")

   print "api-repo-getmd5-1:  Get the deleted node from the repository"
   try:
      yy.api_repository_get(xx=xx, vfunc="repository-get", elemtype="testnode",
                            elemname="bogusmd5")
      print "api-repo-getmd5-1:  get of type testnode failed"
      fail = 1
   except velocityAPI.VelocityAPIexception:
      print "api-repo-getmd5-1:  testnode exception as expected"

   #
   #   If any of the starts or stops failed, or if the wrong number
   #   of search services are running, skip to the end and fail
   #   Otherwise, test passed
   #
   if ( fail == 0 ):
      print "api-repo-getmd5-1:  Test Passed"
      sys.exit(0)

   print "api-repo-getmd5-1:  Test Failed"
   sys.exit(1)
