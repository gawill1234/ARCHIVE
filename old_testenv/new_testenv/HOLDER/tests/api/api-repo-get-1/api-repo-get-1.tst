#!/usr/bin/python

#
#   Test of the api
#

import sys
import cgi_interface
import vapi_interface
import velocityAPI

if __name__ == "__main__":

   fail = 0

   print "api-repo-get-1:  repository-get"
   print "api-repo-get-1:  To pass, all names must not be empty"

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   #
   #   repository-get of a vse-collection
   #
   try:
      yy.api_repository_get(xx=xx, vfunc="repository-get",
                            elemtype="vse-collection",
                            elemname="enron-email-tutorial")
      colnm = yy.get_repo_elem_name(xx=xx, vfunc='repository-get',
                                    trib="collection")
   except:
      colnm = "FAIL"
   if ( colnm != "enron-email-tutorial" ):
      print "api-repo-get-1:  get of type vse-collection failed"
      fail = 1
   else:
      print "api-repo-get-1:  collection name, ", colnm

   #
   #   repository-get of a function
   #
   try:
      yy.api_repository_get(xx=xx, vfunc="repository-get",
                            elemtype="function",
                            elemname="core-help")
      fncnm = yy.get_repo_elem_name(xx=xx, vfunc='repository-get',
                                    trib="function")
   except:
      fncnm = "FAIL"
   if ( fncnm != "core-help" ):
      print "api-repo-get-1:  get of type function failed"
      fail = 1
   else:
      print "api-repo-get-1:  function name,   ", fncnm

   #
   #   repository-get of a application
   #
   try:
      yy.api_repository_get(xx=xx, vfunc="repository-get",
                            elemtype="application",
                            elemname="api-soap")
      appnm = yy.get_repo_elem_name(xx=xx, vfunc='repository-get',
                                    trib="application")
   except:
      appnm = "FAIL"
   if ( appnm != "api-soap" ):
      print "api-repo-get-1:  get of type application failed"
      fail = 1
   else:
      print "api-repo-get-1:  application name,", appnm

   #
   #   repository-get of a source
   #
   try:
      yy.api_repository_get(xx=xx, vfunc="repository-get",
                            elemtype="source",
                            elemname="CNN")
      srcnm = yy.get_repo_elem_name(xx=xx, vfunc='repository-get',
                                    trib="source")
   except:
      srcnm = "FAIL"
   if ( srcnm != "CNN" ):
      print "api-repo-get-1:  get of type source failed"
      fail = 1
   else:
      print "api-repo-get-1:  source name,     ", srcnm

   #
   #   repository-get of a report
   #
   try:
      yy.api_repository_get(xx=xx, vfunc="repository-get",
                            elemtype="report",
                            elemname="source-summary")
      rptnm = yy.get_repo_elem_name(xx=xx, vfunc='repository-get',
                                    trib="report")
   except:
      rptnm = "FAIL"

   if ( rptnm != "source-summary" ):
      print "api-repo-get-1:  get of type report failed: could not find source-summary"
      fail = 1
   else:
      print "api-repo-get-1:  report name,     ", rptnm

   #
   #   repository-get of a parser
   #
   try:
      yy.api_repository_get(xx=xx, vfunc="repository-get", elemtype="parser",
                    elemname="proxy")
      prsnm = yy.get_repo_elem_name(xx=xx, vfunc='repository-get', trib="parser")
   except:
      prsnm = "FAIL"
   if ( prsnm != "proxy" ):
      print "api-repo-get-1:  get of type parser failed"
      fail = 1
   else:
      print "api-repo-get-1:  parser name,     ", prsnm

   #
   #   repository-get of a macro
   #
   try:
      yy.api_repository_get(xx=xx, vfunc="repository-get", elemtype="macro",
                    elemname="url-state")
      mcrnm = yy.get_repo_elem_name(xx=xx, vfunc='repository-get', trib="macro")
   except:
      mcrnm = "FAIL"
   if ( mcrnm != "url-state" ):
      print "api-repo-get-1:  get of type macro failed"
      fail = 1
   else:
      print "api-repo-get-1:  macro name,      ", mcrnm

   #
   #   repository-get of a kb
   #
   try:
      yy.api_repository_get(xx=xx, vfunc="repository-get", elemtype="kb",
                    elemname="custom")
      kbnm = yy.get_repo_elem_name(xx=xx, vfunc='repository-get', trib="kb")
   except:
      kbnm = "FAIL"
   if ( kbnm != "custom" ):
      print "api-repo-get-1:  get of type kb failed"
      fail = 1
   else:
      print "api-repo-get-1:  kb name,         ", kbnm

   #
   #   repository-get of a dictionary
   #
   try:
      yy.api_repository_get(xx=xx, vfunc="repository-get",
                            elemtype="dictionary",
                            elemname="base")
      dctnm = yy.get_repo_elem_name(xx=xx, vfunc='repository-get',
                                    trib="dictionary")
   except:
      dctnm = "FAIL"
   if ( dctnm != "base" ):
      print "api-repo-get-1:  get of type dictionary failed"
      fail = 1
   else:
      print "api-repo-get-1:  dictionary name, ", dctnm

   #
   #   repository-get of a form
   #     Commented out until I develop a form to get.
   #
   #yy.api_repository_get(xx=xx, vfunc="repository-get", elemtype="form",
   #              elemname="simple-clusty-gov")
   #frmnm = yy.get_repo_elem_name(xx=xx, vfunc='repository-get', trib="form")
   #if ( frmnm != "simple-clusty-gov" ):
   #   print "api-repo-get-1:  get of type form failed"
   #   fail = 1
   #else:
   #   print "api-repo-get-1:  form name,       ", frmnm

   #
   #   repository-get of a non-existent type
   #
   try:
      yy.api_repository_get(xx=xx, vfunc="repository-get", elemtype="fizzybizzy",
                            elemname="simple-clusty-gov")
      print "api-repo-get-1:  get of type fizzybizzy failed"
      fail = 1
   except velocityAPI.VelocityAPIexception:
      exception = sys.exc_info()[1][0]
      if exception.get('name') == "repository-unknown-node":
         print "api-repo-get-1:  type fizzybizzy: good"
      else:
         print "api-repo-get-1:  get of type fizzybizzy failed"
         fail = 1

   #
   #   repository-get of a non-existent name
   #
   try:
      yy.api_repository_get(xx=xx, vfunc="repository-get", elemtype="application",
                            elemname="hardyharhar")
      print "api-repo-get-1:  get of type application failed"
      fail = 1
   except velocityAPI.VelocityAPIexception:
      exception = sys.exc_info()[1][0]
      if exception.get('name') == "repository-unknown-node":
         print "api-repo-get-1:  application name which does not exist: good"
      else:
         print "api-repo-get-1:  get of type application failed"
         fail = 1

   #
   #   If any of the starts or stops failed, or if the wrong number
   #   of search services are running, skip to the end and fail
   #   Otherwise, test passed
   #
   if ( fail == 0 ):
      print "api-repo-get-1:  Test Passed"
      sys.exit(0)

   print "api-repo-get-1:  Test Failed"
   sys.exit(1)
