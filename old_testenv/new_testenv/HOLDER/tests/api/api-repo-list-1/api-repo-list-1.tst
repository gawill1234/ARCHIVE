#!/usr/bin/python

#
#   Test of the api
#   This test is for search-collection-create and
#   search-collection-delete.  It creates and deletes
#   a number of collections using different variations
#   of characters.
#

import sys, time, cgi_interface, vapi_interface 

def get_repo_list_count(xx=None, vfunc=None, trib="application"):

   cmd = "xsltproc"

   if ( vfunc == None ):
      return

   arg1 = ''.join([xx.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
   opts = ''.join(['--stringparam mynode repo-list --stringparam mytrib ', trib])
   dumpit = ''.join(['querywork/', vfunc, '.wazzat'])
 
   cmdopts = ' '.join([opts, arg1, dumpit])

   y = xx.exec_command_stdout(cmd, cmdopts, None)

   return y

if __name__ == "__main__":

   lstcnt = 0

   print "api-repo-list-1:  repository-list"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   yy.api_repository_list(xx=xx, vfunc="repository-list-xml")

   appcnt = int(get_repo_list_count(xx=xx, vfunc='repository-list-xml', trib="application"))
   frmcnt = int(get_repo_list_count(xx=xx, vfunc='repository-list-xml', trib="form"))
   fnccnt = int(get_repo_list_count(xx=xx, vfunc='repository-list-xml', trib="function"))
   srccnt = int(get_repo_list_count(xx=xx, vfunc='repository-list-xml', trib="source"))
   colcnt = int(get_repo_list_count(xx=xx, vfunc='repository-list-xml', trib="collection"))
   rptcnt = int(get_repo_list_count(xx=xx, vfunc='repository-list-xml', trib="report"))
   prscnt = int(get_repo_list_count(xx=xx, vfunc='repository-list-xml', trib="parser"))
   mcrcnt = int(get_repo_list_count(xx=xx, vfunc='repository-list-xml', trib="macro"))
   kbcnt = int(get_repo_list_count(xx=xx, vfunc='repository-list-xml', trib="kb"))
   dctcnt = int(get_repo_list_count(xx=xx, vfunc='repository-list-xml', trib="dictionary"))

   print "api-repo-list-1:  To pass, all counts must be greater than 0"

   print "api-repo-list-1:  application count,", appcnt
   print "api-repo-list-1:  form count,       ", frmcnt
   print "api-repo-list-1:  function count,   ", fnccnt
   print "api-repo-list-1:  source count,     ", srccnt
   print "api-repo-list-1:  collection count, ", colcnt
   print "api-repo-list-1:  report count,     ", rptcnt
   print "api-repo-list-1:  parser count,     ", prscnt
   print "api-repo-list-1:  macro count,      ", mcrcnt
   print "api-repo-list-1:  kb count,         ", kbcnt
   print "api-repo-list-1:  dictionary count, ", dctcnt

   #
   #   If any of the starts or stops failed, or if the wrong number
   #   of search services are running, skip to the end and fail
   #   Otherwise, test passed
   #
   if ( appcnt > 0 and frmcnt > 0 and fnccnt > 0 and srccnt > 0 and
        colcnt > 0 and rptcnt > 0 and prscnt > 0 and mcrcnt > 0 and
        kbcnt > 0 and dctcnt > 0):
      print "api-repo-list-1:  Test Passed"
      sys.exit(0)

   print "api-repo-list-1:  Test Failed"
   sys.exit(1)
