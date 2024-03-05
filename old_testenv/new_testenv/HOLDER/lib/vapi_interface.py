#!/usr/bin/python

import os
import re
import string
import sys
import time
import traceback
import urllib
import velocityAPI
from toolenv import VIVTENV
from lxml import etree

############################################

class VAPIINTERFACE(object):

   def __init__(self, environment=[], use_cba=False):

      self.TENV = VIVTENV(envlist=environment)

      if use_cba:
        # CBA requires Velocity to use SSL
        protocol="https"
      else:
        protocol="http"

      self.vapi = velocityAPI.VelocityAPI(protocol=protocol, use_cba=use_cba)

      subdir = os.getenv('VIVASPXDIR', 'cgi-bin')
      grok = ''.join(['/cgi-bin/gronk'])
      admn = ''.join(['/cgi-bin/admin'])
      qrym = ''.join(['/cgi-bin/query-meta'])
      vlcy = ''.join(['/', subdir, '/velocity'])

      if ( subdir != 'cgi-bin' ):
         self.apps = ''.join(['/', subdir, vlcy, '.aspx'])
      else:
         if ( self.TENV.targetos == "windows" ):
            self.apps = ''.join(['/', self.TENV.virtualdir, vlcy, '.exe'])
         else:
            self.apps = ''.join(['/', self.TENV.virtualdir, vlcy])

      if ( self.TENV.targetos == "windows" ):
         self.gronk = ''.join(['/', self.TENV.virtualdir, grok, '.exe'])
         self.admin = ''.join(['/', self.TENV.virtualdir, admn, '.exe'])
         self.qmeta = ''.join(['/', self.TENV.virtualdir, qrym, '.exe'])
         self.dump = 'dump.exe'
      else:
         self.gronk = ''.join(['/', self.TENV.virtualdir, grok])
         self.admin = ''.join(['/', self.TENV.virtualdir, admn])
         self.qmeta = ''.join(['/', self.TENV.virtualdir, qrym])
         self.dump = 'dump'

      return

   ###################################################################
   def dumpdata(self, filename=None, mydata=None):

      #print "FILE:", filename
      ofd = open(filename, 'w')
      ofd.write(mydata)
      ofd.close()

      return

   #
   #   These were done using getiterator because it does not
   #   distinguish between list/document and tree/document or document.
   #   All three of those can be returned in various instances.  It
   #   has its own problems, but the initial uses of these functions
   #   do not care about url duplication, etc. when two of the above
   #   nodes appear in the XML, which is also possible.
   #
   #def getAuditLogData(self, filename=None, resptree=None,
   #                    attrname=None, tagname=None):

   def getResultData(self, filename=None, tagname=None, attrname=None,
                     ri=None, resptree=None, attrvalue=None,
                     returnattr=None):
      count = 0
      attrvaluecount = 0
      attrtotal = 0
      mylist = []

      if ( resptree == None ):
         realfile = self.look_for_file(filename=filename)
         fd = open(realfile, "r+")
         data = fd.read()
         fd.close()
         mytree = etree.fromstring(data)
      else:
         mytree = resptree

      if ( ri == 'totalresult' ):
         totalres = mytree.xpath("//added-source/@total-results-with-duplicates")
         if ( totalres == [] ):
            returnres = 0
         else:
            returnres = int(totalres[0])

         return returnres

      if ( ri == 'totalresultnodup' ):
         totalres = mytree.xpath("//added-source/@total-results")
         if ( totalres == [] ):
            returnres = 0
         else:
            returnres = int(totalres[0])

         return returnres

      if ( ri == 'auditlogtoken' ):
         tokenval = mytree.xpath("//audit-log-retrieve-response/@token")
         if ( tokenval == [] ):
            returnres = ''
         else:
            returnres = tokenval[0]
         return returnres

      if ( ri == 'value' ):
         myxp = '//' + tagname + '/@' + attrname
         tokenval = mytree.xpath(myxp)
         if ( tokenval == [] ):
            returnres = ''
         else:
            returnres = tokenval[0]
         return returnres

      if ( ri == 'nodestring' ):
         for elt in mytree.getiterator( tagname ):
            thing = etree.tostring(elt)
            thing = thing.replace('\n', '')
            mylist.append( thing )
         return mylist

      if ( ri == 'valuelist' ):
         for elt in mytree.getiterator( tagname ):
            if ( attrname is not None ):
               if ( elt.attrib.has_key( attrname ) ):
                  mylist.append( elt.get( attrname ) )
         return mylist

      if ( ri == 'contenturl' ):
         for elt in mytree.getiterator( tagname ):
            if ( attrname is not None ):
               if ( elt.attrib.has_key( attrname ) ):
                  if ( elt.get( attrname ) == attrvalue ):
                     mylist.append( elt.text )
         return mylist

      if ( ri == 'othervalue' ):
         returnres = ''
         for elt in mytree.getiterator( tagname ):
            if ( elt.get( attrname ) == attrvalue ):
               returnres = elt.get( returnattr )
               return returnres
         return ''

      if ( ri == 'attrtotal' ):
         for elt in mytree.getiterator( tagname ):
            if ( attrname is not None ):
               if ( elt.attrib.has_key( attrname ) ):
                  mylist.append( elt.get( attrname ) )
         for item in mylist:
            attrtotal = attrtotal + int(item)

         return attrtotal

      for elt in mytree.getiterator( tagname ):
         count = count + 1
         if ( attrname is not None ):
            if ( elt.attrib.has_key( attrname ) ):
               mylist.append( elt.get( attrname ) )
               if ( attrvalue is not None ):
                  if ( elt.get( attrname) == attrvalue ):
                     attrvaluecount += 1

      if ( ri == 'count' ):
         if ( attrvalue is None ):
            return count
         else:
            return attrvaluecount

      return mylist

   def getResultGenericTagString(self, filename=None, resptree=None,
                           tagname=None, attrname=None, attrvalue=None):

      value = self.getResultData(filename=filename, tagname=tagname,
                                  attrname=attrname, ri='nodestring',
                                  resptree=resptree, attrvalue=attrvalue)
      return value

   def getResultGenericTagValue(self, filename=None, resptree=None,
                           tagname=None, attrname=None, attrvalue=None):

      value = self.getResultData(filename=filename, tagname=tagname,
                                  attrname=attrname, ri='value',
                                  resptree=resptree, attrvalue=attrvalue)
      return value

   def getResultGenericTagList(self, filename=None, resptree=None,
                           tagname=None, attrname=None, attrvalue=None):

      value = self.getResultData(filename=filename, tagname=tagname,
                                  attrname=attrname, ri='valuelist',
                                  resptree=resptree, attrvalue=attrvalue)
      return value

   def getResultGenericOtherAttrValue(self, filename=None, resptree=None,
                           tagname=None, attrname=None, attrvalue=None,
                           returnattr=None):

      value = self.getResultData(filename=filename, tagname=tagname,
                                  attrname=attrname, ri='othervalue',
                                  resptree=resptree, attrvalue=attrvalue,
                                  returnattr=returnattr)
      return value

   def getResultGenericTagCount(self, filename=None, resptree=None,
                           tagname=None, attrname=None, attrvalue=None):

      count = self.getResultData(filename=filename, tagname=tagname,
                                  attrname=attrname, ri='count',
                                  resptree=resptree, attrvalue=attrvalue)
      return count

   def getResultGenericTagIntAttrTotal(self, filename=None, resptree=None,
                           tagname=None, attrname=None, attrvalue=None):

      count = self.getResultData(filename=filename, tagname=tagname,
                                  attrname=attrname, ri='attrtotal',
                                  resptree=resptree, attrvalue=attrvalue)
      return count

   def getAuditLogSuccessCount(self, filename=None, resptree=None):

      count = self.getResultData(filename=filename, tagname='audit-log-entry',
                                  attrname='status', ri='count',
                                  resptree=resptree, attrvalue='successful')
      return count

   def getAuditLogEntryCount(self, filename=None, resptree=None):

      count = self.getResultData(filename=filename, tagname='audit-log-entry',
                                  attrname='status', ri='count',
                                  resptree=resptree)
      return count

   def getAuditLogEntryCrawlUrlCount(self, filename=None, resptree=None):

      count = self.getResultData(filename=filename, tagname='crawl-url',
                                  attrname=None, ri='count',
                                  resptree=resptree)
      return count

   def getAuditLogEntryCrawlUrlsCount(self, filename=None, resptree=None):

      count = self.getResultData(filename=filename, tagname='crawl-urls',
                                  attrname=None, ri='count',
                                  resptree=resptree)
      return count

   def getAuditLogEntryCrawlDeleteCount(self, filename=None, resptree=None):

      count = self.getResultData(filename=filename, tagname='crawl-delete',
                                  attrname=None, ri='count',
                                  resptree=resptree)
      return count

   def getAuditLogEntryIndexAtomicCount(self, filename=None, resptree=None):

      count = self.getResultData(filename=filename, tagname='index-atomic',
                                  attrname=None, ri='count',
                                  resptree=resptree)
      return count

   def getResultUrls(self, filename=None, resptree=None):

      mylist = self.getResultData(filename=filename, tagname='document',
                                  attrname='url', ri='urllist',
                                  resptree=resptree)
      return mylist

   def getContentUrls(self, filename=None, resptree=None):

      mylist = self.getResultData(filename=filename, tagname='content',
                                  attrname='name', attrvalue='url',
                                  ri='contenturl',
                                  resptree=resptree)
      return mylist

   def getResultUrlCount(self, filename=None, resptree=None):

      count = self.getResultData(filename=filename, tagname='document',
                                  attrname='url', ri='count',
                                  resptree=resptree)
      return count

   def getAuditLogToken(self, filename=None, resptree=None):

      count = self.getResultData(filename=filename,
                                 ri='auditlogtoken',
                                 resptree=resptree)
      return count

   def getTotalResults(self, filename=None, resptree=None):

      count = self.getResultData(filename=filename,
                                 ri='totalresult',
                                 resptree=resptree)
      return count

   def getTotalResultsNoDups(self, filename=None, resptree=None):

      count = self.getResultData(filename=filename,
                                 ri='totalresultnodup',
                                 resptree=resptree)
      return count

   def getAddedSourceUrlCount(self, filename=None, resptree=None,
                           tagname=None, attrname=None, attrvalue=None):

      value = self.getResultData(filename=filename, tagname="added-source",
                                  attrname="total-results-with-duplicates",
                                  ri='valuelist',
                                  resptree=resptree)

      x = 0
      if ( value is not None and value != [] ):
         for item in value:
            x = x + int(item)

      return x

   def httpstr_appnd(self, httpstr=None, argname=None, argval=None, dorep=0):

      plusisspace = 1
      keepplus = 2
      psign = 0

      if ( argname is not None ):
         if ( argval is not None ):

            try:
               pls = re.findall(r'\+', argval)
               if ( pls != [] ):
                  psign = 1
            except:
               pls = []
               psign = 0

            #
            #  if we have a % followed by 2 hex digits, the argval
            #  string is considered to be already url encoded so
            #  skip that step.
            #
            try:
               zz = re.findall(r'%[0-9a-fA-F]{2}', argval)
            except:
               zz = []
            if ( zz == [] ):
               httpstring2 = urllib.urlencode({argname:argval})

               if ( dorep == plusisspace or psign == 0 ):
                  httpstring2 = httpstring2.replace('+', '%20')

               if ( dorep == keepplus ):
                  httpstring2 = httpstring2.replace('%2B', '+')
            else:
               httpstring2 = ''.join([argname, "=", argval])


            if ( httpstr is not None ):
               httpstring = ''.join([httpstr, '&', httpstring2])
            else:
               httpstring = httpstring2

      return httpstring

   ###################################################################
   def get_repo_elem_name(self, xx=None, vfunc=None, trib="application"):

      cmd = "xsltproc"

      if ( vfunc == None ):
         return

      arg1 = ''.join([xx.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
      opts = ''.join(['--stringparam mynode repo-item --stringparam mytrib ', trib])
      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      cmdopts = ' '.join([opts, arg1, dumpit])

      y = xx.exec_command_stdout(cmd, cmdopts, None)

      if ( y == '' ):
         y = None

      return y

   ###################################################################

   def look_for_file(self, filename=None):

      if ( filename == None ):
         return None

      f2 = ''.join(['querywork/', filename])
      f3 = ''.join(['querywork/', filename, '.wazzat'])

      if ( os.access(filename, os.R_OK) == 1 ):
         return filename

      if ( os.access(f2, os.R_OK) == 1 ):
         return f2

      if ( os.access(f3, os.R_OK) == 1 ):
         return f3

      return None

   ###################################################################
   def get_item_count(self, xx=None, vfunc=None,
                         item=None, filename=None):

      cmd = "xsltproc"

      if ( item == None ):
         return 0

      if ( filename == None ):
         if ( vfunc == None ):
            return 0

      arg1 = ''.join([self.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
      opts = ''.join(['--stringparam mynode content-item-count --stringparam mytrib ', item])
      if ( filename == None ):
         dumpit = ''.join(['querywork/', vfunc, '.wazzat'])
      else:
         dumpit = self.look_for_file(filename=filename)

      cmdopts = ' '.join([opts, arg1, dumpit])

      y = xx.exec_command_stdout(cmd, cmdopts, None)

      return y

   def get_doc_attr_count(self, xx=None, vfunc=None,
                          item=None, filename=None):

      cmd = "xsltproc"

      if ( item == None ):
         return 0

      if ( filename == None ):
         if ( vfunc == None ):
            return 0

      arg1 = ''.join([self.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
      opts = ''.join(['--stringparam mynode document-attr-count --stringparam mytrib \'', item, '\''])
      if ( filename == None ):
         dumpit = ''.join(['querywork/', vfunc, '.wazzat'])
      else:
         dumpit = self.look_for_file(filename=filename)

      cmdopts = ' '.join([opts, arg1, dumpit])

      y = xx.exec_command_stdout(cmd, cmdopts, None)

      return y

   #
   #   Turn returned string into a list and remove any empty
   #   list elements
   #
   def listify(self, mystring=None, sep=' '):

      mylist = []

      if ( mystring == None ):
         return mylist

      z = mystring.split(sep)
      for item in z:
         if ( item != '' ):
            mylist.append(item)

      return mylist

   def get_content_values(self, xx=None, vfunc=None,
                           item=None, filename=None):

      cmd = "xsltproc"

      if ( item == None ):
         return 0

      if ( filename == None ):
         if ( vfunc == None ):
            return
         else:
            filename = vfunc

      #
      #   Done this way to support the original way I used these
      #   functions which I am gradually moving away from.
      #
      dumpit = self.look_for_file(filename=filename)

      arg1 = ''.join([self.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
      opts = ''.join(['--stringparam mynode content-values --stringparam mytrib \'', item, '\''])

      cmdopts = ' '.join([opts, arg1, dumpit])

      y = xx.exec_command_stdout(cmd, cmdopts, None)
      y = self.listify(y, '\n')

      return y

   def get_content_attr_values_by_name(self, xx=None, vfunc=None,
                           item=None, filename=None, name=None):

      cmd = "xsltproc"

      if ( item == None ):
         return []

      if ( name == None ):
         return []

      if ( filename == None ):
         if ( vfunc == None ):
            return
         else:
            filename = vfunc

      #
      #   Done this way to support the original way I used these
      #   functions which I am gradually moving away from.
      #
      dumpit = self.look_for_file(filename=filename)

      arg1 = ''.join([self.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
      opts = ''.join(['--stringparam mynode content-attr-values-by-name --stringparam mytrib \'', item, '\'', ' --stringparam myname \'', name, '\''])

      cmdopts = ' '.join([opts, arg1, dumpit])

      #print cmdopts
      y = xx.exec_command_stdout(cmd, cmdopts, None)
      y = self.listify(y, '\n')

      return y

   def get_cb_collection_service_status(self, xx=None, vfunc=None,
                           service=None, filename=None):

      cmd = "xsltproc"

      if ( filename == None ):
         if ( vfunc == None ):
            return
         else:
            filename = vfunc

      #
      #   Done this way to support the original way I used these
      #   functions which I am gradually moving away from.
      #
      dumpit = self.look_for_file(filename=filename)

      arg1 = ''.join([self.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
      if ( service is not None ):
         opts = ''.join(['--stringparam mynode cb-collection-service-status --stringparam mytrib \'', service, '\''])
      else:
         opts = ''.join(['--stringparam mynode cb-collection-service-status'])

      cmdopts = ' '.join([opts, arg1, dumpit])

      #print cmdopts
      y = xx.exec_command_stdout(cmd, cmdopts, None)
      y = self.listify(y, '\n')

      return y

   def get_cbs_collection_attr_values_by_collection(self,
                           xx=None, vfunc=None, item=None,
                           filename=None, name=None):

      cmd = "xsltproc"

      if ( item == None ):
         return []

      if ( name == None ):
         return []

      if ( filename == None ):
         if ( vfunc == None ):
            return
         else:
            filename = vfunc

      #
      #   Done this way to support the original way I used these
      #   functions which I am gradually moving away from.
      #
      dumpit = self.look_for_file(filename=filename)

      arg1 = ''.join([self.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
      opts = ''.join(['--stringparam mynode cbs-collection-attr-values-by-name --stringparam mytrib \'', item, '\'', ' --stringparam myname \'', name, '\''])

      cmdopts = ' '.join([opts, arg1, dumpit])

      #print cmdopts
      y = xx.exec_command_stdout(cmd, cmdopts, None)
      y = self.listify(y, '\n')

      return y

   def get_content_attr_values(self, xx=None, vfunc=None,
                           item=None, filename=None):

      cmd = "xsltproc"

      if ( item == None ):
         return 0

      if ( filename == None ):
         if ( vfunc == None ):
            return
         else:
            filename = vfunc

      #
      #   Done this way to support the original way I used these
      #   functions which I am gradually moving away from.
      #
      dumpit = self.look_for_file(filename=filename)

      arg1 = ''.join([self.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
      opts = ''.join(['--stringparam mynode content-attr-values --stringparam mytrib \'', item, '\''])

      cmdopts = ' '.join([opts, arg1, dumpit])

      print cmdopts
      y = xx.exec_command_stdout(cmd, cmdopts, None)
      y = self.listify(y, '\n')

      return y

   def check_list(self, expvals=None, listtocheck=None):

      lchk = 0
      if ( expvals == None ):
         return 0

      if ( listtocheck == None ):
         return 0

      for item in listtocheck:
         found = 0
         for nitem in expvals:
            if ( self.TENV.targetos == "windows" ):
               iteml = item.lower()
               niteml = nitem.lower()
               if ( iteml == niteml ):
                  found = 1
            else:
               if ( item == nitem ):
                  found = 1
         if ( found == 0 ):
            print "lists do not match"
            print "   ", item, "new item not found in expected values"
            lchk = 1

      for item in expvals:
         found = 0
         for nitem in listtocheck:
            if ( self.TENV.targetos == "windows" ):
               iteml = item.lower()
               niteml = nitem.lower()
               if ( iteml == niteml ):
                  found = 1
            else:
               if ( item == nitem ):
                  found = 1
         if ( found == 0 ):
            print "lists do not match"
            print "   ", item, "expected item not found in new items"
            lchk = 1

      return lchk

   def get_cb_collection_list(self, xx=None, vfunc=None,
                              filename=None):

      cmd = "xsltproc"

      if ( filename == None ):
         if ( vfunc == None ):
            return 0

      arg1 = ''.join([self.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
      opts = ''.join(['--stringparam mynode cbs-collection-list'])

      if ( filename == None ):
         dumpit = ''.join(['querywork/', vfunc, '.wazzat'])
      else:
         dumpit = self.look_for_file(filename=filename)

      cmdopts = ' '.join([opts, arg1, dumpit])

      y = xx.exec_command_stdout(cmd, cmdopts, None)
      y = self.listify(y, '\n')

      return y

   def get_doc_attr_values(self, xx=None, vfunc=None,
                           item=None, filename=None):

      cmd = "xsltproc"

      if ( item == None ):
         return 0

      if ( filename == None ):
         if ( vfunc == None ):
            return 0

      arg1 = ''.join([self.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
      opts = ''.join(['--stringparam mynode document-attr-value --stringparam mytrib \'', item, '\''])
      if ( filename == None ):
         dumpit = ''.join(['querywork/', vfunc, '.wazzat'])
      else:
         dumpit = self.look_for_file(filename=filename)

      cmdopts = ' '.join([opts, arg1, dumpit])

      y = xx.exec_command_stdout(cmd, cmdopts, None)
      y = self.listify(y, ' ')

      return y

   ###################################################################
   #
   #   Valid items to "mytrib" are:
   #      vseconfig, crawlconfig, indexconfig, converters, crawlstatus,
   #      indexstatus, runconig, collectionservicestatus, vsestatus
   #
   def get_collection_elem_count(self, xx=None, vfunc=None,
                                 trib="vseconfig", fname=None):

      cmd = "xsltproc"

      if ( vfunc == None ):
         if ( fname == None ):
            return 0
         else:
            dumpit = ''.join(['querywork/', fname])
      else:
         dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      arg1 = ''.join([xx.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
      opts = ''.join(['--stringparam mynode collection-item-count --stringparam mytrib ', trib])

      cmdopts = ' '.join([opts, arg1, dumpit])

      y = xx.exec_command_stdout(cmd, cmdopts, None)

      if ( y == '' ):
         y = 0

      return y

   ###################################################################
   def check_collection_xml_node_count(self, xx=None, fname=None,
                                       vfunc=None, collection=None):

      if ( collection == None ):
         collection = 'unknown'

      OK = 1

      vcfg = self.get_collection_elem_count(xx=xx, vfunc=vfunc,
                                            trib="vseconfig", fname=fname)
      vstt = self.get_collection_elem_count(xx=xx, vfunc=vfunc,
                                            trib="vsestatus", fname=fname)
      crlcfg = self.get_collection_elem_count(xx=xx, vfunc=vfunc,
                                            trib="crawlconfig", fname=fname)
      idxcfg = self.get_collection_elem_count(xx=xx, vfunc=vfunc,
                                            trib="indexconfig", fname=fname)
      cnvcfg = self.get_collection_elem_count(xx=xx, vfunc=vfunc,
                                            trib="converters", fname=fname)
      crlstt = self.get_collection_elem_count(xx=xx, vfunc=vfunc,
                                            trib="crawlstatus", fname=fname)
      idxstt = self.get_collection_elem_count(xx=xx, vfunc=vfunc,
                                            trib="indexstatus", fname=fname)
      rcfg = self.get_collection_elem_count(xx=xx, vfunc=vfunc,
                                            trib="runconfig", fname=fname)
      csrvstt = self.get_collection_elem_count(xx=xx, vfunc=vfunc,
                                            trib="collectionservicestatus",
                                            fname=fname)

      if ( vcfg < 1 ):
         OK = 0
         print "No vse-config nodes found in collection", collection
      else:
         print collection, "vse-config node count:", vcfg

      if ( vstt < 1 ):
         OK = 0
         print "No vse-status nodes found in collection", collection
      else:
         print collection, "vse-status node count:", vstt

      if ( crlcfg < 1 ):
         OK = 0
         print "No crawler nodes found in collection", collection
      else:
         print collection, "crawler node count:", crlcfg

      if ( idxcfg < 1 ):
         OK = 0
         print "No vse-index nodes found in collection", collection
      else:
         print collection, "vse-index node count:", idxcfg

      if ( cnvcfg < 1 ):
         OK = 0
         print "No converter nodes found in collection", collection
      else:
         print collection, "converters node count:", cnvcfg

      if ( crlstt < 1 ):
         OK = 0
         print "No crawler-status nodes found in collection", collection
      else:
         print collection, "crawler-status node count:", crlstt

      if ( idxstt < 1 ):
         OK = 0
         print "No vse-index-status nodes found in collection", collection
      else:
         print collection, "vse-index-status node count:", idxstt

      if ( rcfg < 1 ):
         OK = 0
         print "No vse-run nodes found in collection", collection
      else:
         print collection, "vse-run node count:", rcfg

      if ( csrvstt < 1 ):
         OK = 0
         print "No collection-service-status nodes found in collection", collection
      else:
         print collection, "collection-service-status node count:", csrvstt

      return OK


   ###################################################################
   def get_vse_status_data(self, xx=None, vfunc=None,
                           trib=None, fname=None):

      cmd = "xsltproc"

      if ( trib == None ):
         return

      arg1 = ''.join([xx.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
      opts = ''.join(['--stringparam mynode ', trib])

      if ( vfunc is not None ):
         dumpit = ''.join(['querywork/', vfunc, '.wazzat'])
      else:
         if ( fname is not None ):
            dumpit = ''.join(['querywork/', fname])
         else:
            return

      cmdopts = ' '.join([opts, arg1, dumpit])

      y = xx.exec_command_stdout(cmd, cmdopts, None)

      return y

   ###################################################################

   def get_status_value(self, xx=None, vfunc=None):

      cmd = "xsltproc"

      if ( vfunc == None ):
         return

      arg1 = ''.join([self.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
      opts = "--stringparam mynode search-service-status"

      #
      #   Done this way to support the original way I used these
      #   functions which I am gradually moving away from.
      #
      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])
      if ( os.access(dumpit, os.F_OK) == 0 ):
         dumpit = ''.join(['querywork/', vfunc])

      cmdopts = ' '.join([opts, arg1, dumpit])

      y = xx.exec_command_stdout(cmd, cmdopts, None)

      return y

   ###################################################################

   def get_qresult_file(self, xx=None, filename=None):

      cmd = "xsltproc"

      if ( filename == None ):
         return

      arg1 = ''.join([self.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
      opts = "--stringparam mynode query-result-file"

      #
      #   Done this way to support the original way I used these
      #   functions which I am gradually moving away from.
      #
      dumpit = ''.join(['querywork/', filename, '.wazzat'])
      if ( os.access(dumpit, os.F_OK) == 0 ):
         dumpit = ''.join(['querywork/', filename])

      cmdopts = ' '.join([opts, arg1, dumpit])

      y = xx.exec_command_stdout(cmd, cmdopts, None)

      return y

   ###################################################################

   def get_query_data(self, xx=None, filename=None, trib=None, vfunc=None):

      cmd = "xsltproc"

      if ( trib == None ):
         return

      if ( filename == None ):
         if ( vfunc == None ):
            return
         else:
            filename = vfunc

      arg1 = ''.join([self.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
      opts = ''.join(['--stringparam mynode ', trib])

      #
      #   Done this way to support the original way I used these
      #   functions which I am gradually moving away from.
      #
      dumpit = self.look_for_file(filename=filename)

      cmdopts = ' '.join([opts, arg1, dumpit])

      y = xx.exec_command_stdout(cmd, cmdopts, None)

      return y

   ###################################################################
   def query_result_check(self, xx, casenum, clustercount, perpage,
                          num, tr=None, filename=None, testname=None,
                          multibinning='false'):

      if ( filename == None ):
         filename = 'query-search'

      if ( testname == None ):
         testname = 'unspecified test'

      cs_pass = 1

      aretl = self.get_query_data(xx=xx, filename=filename,
                                 trib='query-retrieve-count')
      aretl = self.listify(aretl, '\n')

      aresl = self.get_query_data(xx=xx, filename=filename,
                                 trib='query-result-count')
      aresl = self.listify(aresl, '\n')

      areq = self.get_query_data(xx=xx, filename=filename,
                                 trib='query-request-count')
      aurl = self.get_query_data(xx=xx, filename=filename,
                                 trib='query-url-count')
      apag = self.get_query_data(xx=xx, filename=filename,
                                 trib='query-page-count')
      aclu = self.get_query_data(xx=xx, filename=filename,
                                 trib='query-cluster-count')

      if ( aresl == "" or aresl == None or aresl == []):
         ares = 0
      else:
         ares = 0
         for item in aresl:
            ares = ares + int(item)

      if ( aretl == "" or aretl == None or aretl == []):
         aret = 0
      else:
         aret = 0
         for item in aretl:
            aret = aret + int(item)

      if ( areq == "" or areq == None ):
         areq = 0
      else:
         areq = int(areq)

      if ( apag == "" or apag == None ):
         apag = 0
      else:
         apag = int(apag)

      if ( aclu == "" or aclu == None ):
         aclu = 0
      else:
         aclu = int(aclu)

      if ( aurl == "" or aurl == None ):
         aurl = 0
      else:
         aurl = int(aurl)

      #if ( ares > 0 ):
      #   if ( num > ares ):
      #      num = ares

      print testname, ":     Clusters:"
      print testname, ":        Expected:", clustercount
      print testname, ":        Actual:  ", aclu
      if ( clustercount != aclu ):
         cs_pass = 0
         print testname, ":        Check Failed"

      print testname, ":     URLs:"
      print testname, ":        Expected:", num
      print testname, ":        Actual:  ", aurl
      if ( num != aurl ):
         cs_pass = 0
         print testname, ":        Check Failed"

      print testname, ":     Retrieved:"
      print testname, ":        Expected:       ", num
      print testname, ":        Actual:         ", aret
      print testname, ":        Total Results:  ", ares
      if ( tr is not None ):
         print testname, ":        Total Results(exp):  ", tr
         if ( tr != ares ):
            cs_pass = 0
            print testname, ":        Check Failed(total results)"
      if ( num != aret ):
         cs_pass = 0
         print testname, ":        Check Failed"

      if ( perpage != 0 ):
         if ( ( num % perpage ) == 0 ):
            expt = num / perpage
         else:
            expt = ( num / perpage ) + 1
      else:
         expt = 1
      print testname, ":     Pages:"
      print testname, ":        Expected:", expt
      print testname, ":        Actual:  ", apag
      if ( multibinning == 'false' ):
         if ( expt != apag ):
            cs_pass = 0
            print testname, ":        Check Failed"
      else:
         print testname, ":        Multiple bins make page testing impossible"

      if ( cs_pass == 1 ):
         print testname, ":     QUERY", casenum, "PASSED"
      else:
         print testname, ":     QUERY", casenum, "FAILED"

      return cs_pass

   ###################################################################
   #
   #   search-collection-enqueue-url api function
   #
   #       Optional params default values:
   #
   #          synchro='enqueued',
   #          enq_type='none',
   #          subc='live',
   #          fallow='false'
   #
   def api_sc_enqueue_url(self, xx=None, collection=None,
                          vfunc=None, url=None, synchro=None,
                          enq_type=None, subc=None,
                          fallow=None, stype='resume'):

      if ( collection == None ):
         return

      if ( url == None ):
         return

      if ( vfunc == None ):
         vfunc = 'search-collection-enqueue-url'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      zoo = self.vapi.search_collection_enqueue_url(collection=collection,
                                               subcollection=subc,
                                               synchronization=synchro,
                                               enqueue_type=enq_type,
                                               force_allow=fallow,
                                               url=url, crawl_type=stype)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   def api_sc_update_config(self, vfunc=None, xx=None, collection=None):

      if ( collection == None ):
         return

      if ( vfunc == None ):
         vfunc = 'search-collection-update-configuration'

      print "api_sc_update_config():  Updating collection", collection

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      zoo = self.vapi.search_collection_update_configuration(
                                               collection=collection)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################

   ###################################################################
   def api_sc_working_copy_create(self, vfunc=None, xx=None, collection=None):

      if ( collection == None ):
         return

      if ( vfunc == None ):
         vfunc = 'search-collection-working-copy-create'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      zoo = self.vapi.search_collection_working_copy_create(
                                               collection=collection)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   def api_sc_working_copy_delete(self, vfunc=None, xx=None, collection=None):

      if ( collection == None ):
         return

      if ( vfunc == None ):
         vfunc = 'search-collection-working-copy-delete'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      zoo = self.vapi.search_collection_working_copy_delete(
                                               collection=collection)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   def api_sc_set_xml(self, xx=None, collection=None,
                      vfunc=None, url=None,
                      large=0, urlfile=None):

      if collection == None:
         return

      if vfunc == None:
         vfunc = 'search-collection-set-xml'

      if url == None:
         if urlfile == None:
            return
         else:
            large = 1
            if os.access(urlfile, os.R_OK) == 1:
               datasize = os.stat(urlfile).st_size
               fd = file(urlfile, 'rb', datasize)
               url = fd.read()
               fd.close()

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      # Note that this XML parse will raise an exception for invalid XML.
      xml_doc = etree.fromstring(url)
      if type(xml_doc) == etree._ElementTree:
         root = xml_doc.getroot()
      elif type(xml_doc) == etree._Element:
         root = xml_doc

      # If we have a vse-collection (and we should)
      # and the collection name isn't right, just fix it.
      if root.tag == 'vse-collection' \
             and collection != root.get('name'):
         root.set('name', collection)
         url = etree.tostring(root)

      # Do the magic index options.
      if os.environ.has_key('INDEX_OPTIONS'):
         vse_indicies = root.xpath('/vse-collection/vse-config/vse-index')
         if vse_indicies:
            vse_index = vse_indicies[0]
            opts = dict([nv.split('=') for nv in
                         os.environ['INDEX_OPTIONS'].split(',')])
            for name, value in opts.iteritems():
               index_option = vse_index.xpath('vse-index-option[@name="%s"]'%name)
               if index_option:
                  # Grab the last one (should be the only one).
                  index_option = index_option[-1]
               else:
                  # Create a new index option element.
                  index_option = etree.SubElement(vse_index,
                                                  'vse-index-option',
                                                  name=name)
               index_option.text = value
            url = etree.tostring(root)

      #print url
      zoo = self.vapi.search_collection_set_xml(collection=collection,
                                                xml=url)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)
      # Punt the test if the set-xml failed.
      assert zoo.tag == '__CONTAINER__', self.vapi.data

      return zoo



   ###################################################################
   #
   #   search-collection-enqueue api function
   #
   #   Optional params defaults:
   #      subc = 'live'
   #      eonfail = 'false'
   #
   def api_sc_enqueue(self, xx=None, collection=None,
                      vfunc=None, url=None, subc=None,
                      eonfail=None, large=0,
                      urlfile=None, stype='resume'):

      if ( collection == None ):
         return

      if ( vfunc == None ):
         vfunc = 'search-collection-enqueue'

      if ( url == None ):
         if ( urlfile == None ):
            return
         else:
            large = 1
            if (os.access(urlfile, os.R_OK) == 1 ):
               datasize = os.stat(urlfile).st_size
               fd = file(urlfile, 'rb', datasize)
               url = fd.read()
               fd.close()

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      zoo = self.vapi.search_collection_enqueue(collection=collection,
                                               subcollection=subc,
                                               exception_on_failure=eonfail,
                                               crawl_urls=url, crawl_type=stype)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   search-collection-enqueue-deletes api function
   #
   #   Optional params defaults:
   #      subc = 'live'
   #      eonfail = 'false'
   #
   def api_sc_enqueue_deletes(self, xx=None, collection=None,
                      vfunc=None, url=None, subc=None,
                      eonfail=None, stype='resume'):

      if ( collection == None ):
         return

      if ( url == None ):
         return

      if ( vfunc == None ):
         vfunc = 'search-collection-enqueue-deletes'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      zoo = self.vapi.search_collection_enqueue_deletes(collection=collection,
                                               subcollection=subc,
                                               exception_on_failure=eonfail,
                                               crawl_deletes=url,
                                               crawl_type=stype)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   search-collection-enqueue-xml api function
   #
   #   Optional params defaults:
   #      subc = 'live'
   #      eonfail = 'false'
   #
   def api_sc_enqueue_xml(self, xx=None, collection=None,
                      vfunc=None, crawl_nodes=None, subc=None,
                      eonfail=None, url=None, stype='resume'):

      if ( collection == None ):
         return

      if ( crawl_nodes == None ):
         crawl_nodes = url
         if ( crawl_nodes == None ):
            return

      if ( vfunc == None ):
         vfunc = 'search-collection-enqueue-xml'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      zoo = self.vapi.search_collection_enqueue_xml(collection=collection,
                                               subcollection=subc,
                                               exception_on_failure=eonfail,
                                               crawl_nodes=crawl_nodes,
                                               crawl_type=stype)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   #######################################################
   #
   #   Read only api functions.
   #
   #      Mode can be one of: enable, disable, status
   #
   #
   def api_sc_read_only_all(self, mode=None):

      qsargs = {}

      if ( mode == None ):
         return None

      vfunc = 'search-collection-read-only-all'
      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      qsargs['mode'] = mode

      zoo = self.vapi.search_collection_read_only_all(**qsargs)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   def api_sc_read_only(self, collection=None, mode=None):

      qsargs = {}

      vfunc = 'search-collection-read-only'
      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      if ( mode == None ):
         return None

      if ( collection == None ):
         return None

      qsargs['mode'] = mode
      qsargs['collection'] = collection

      zoo = self.vapi.search_collection_read_only(**qsargs)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   #
   ##########################################################
   #

   def api_qsearch(self, xx=None, source=None, vfunc=None, query=None,
                     num=None, cluster=None, clustercount=None,
                     fetch=None, fetchtimeout=None, qsyn=None,
                     filename=None, ocmode=None, oclist=None, osumtf=None,
                     start=None, num_per_src=None, num_max=None,
                     browse=None, browse_num=None, browse_start=None,
                     browse_clusters_num=None, ficond=None, brnum=None,
                     qcondxp=None, odup=None, oscore=None, oshing=None,
                     okey=None, qobj=None, qcondobj=None, aggr=None,
                     osortkey=None, aggrmaxpass=None, num_ovr_req=None,
                     ocacheref=None, ocachedata=None, user=None, passwd=None,
                     obc=None, obce=None, bincfg=None, bincol=None,
                     binmode=None, binstate=None, generror=None,
                     tmaxexpand=None, dexpwcminlen=None, rights=None,
                     qarena=None, debug=False):

      qsargs = {}

      if ( source == None ):
         return

      if ( vfunc == None ):
         vfunc = 'query-search'

      if ( filename == None ):
         filename = vfunc

      if ( fetchtimeout == None ):
         fetchtimeout = 2500000

      dumpit = ''.join(['querywork/', filename, '.wazzat'])

      defsyntax = 'AND and () CONTAINING CONTENT %field%: + NEAR - NOT NOTCONTAINING NOTWITHIN OR or quotes stem THRU BEFORE FOLLOWEDBY weight wildcard wildchar WITHIN WORDS site regex'

      if ( qsyn == 'Default' ):
         qsyn = defsyntax

      if ( generror is not None ):
         qsargs['fake_error'] = "ERROR"

      if ( qarena is not None ):
         qsargs['arena'] = qarena

      if ( debug ):
         qsargs['debug'] = 'true'

      qsargs['sources'] = source
      qsargs['query'] = query
      qsargs['query_object'] = qobj
      qsargs['query_condition_object'] = qcondobj
      qsargs['query_condition_xpath'] = qcondxp
      qsargs['cluster'] = cluster
      qsargs['num_per_source'] = num_per_src

      qsargs['authorization_username'] = user
      qsargs['authorization_password'] = passwd
      qsargs['authorization_rights'] = rights

      qsargs['binning_configuration'] = bincfg
      qsargs['collapse_binning'] = bincol
      qsargs['binning_mode'] = binmode
      qsargs['binning_state'] = binstate

      qsargs['num_over_request'] = num_ovr_req
      if ( num is not None ):
         qsargs['num'] = '%s' % num
      else:
         qsargs['num'] = num

      if ( tmaxexpand is not None ):
         qsargs['term_expand_max_expansions'] = '%s' % tmaxexpand

      if ( dexpwcminlen is not None ):
         qsargs['dict_expand_wildcard_min_length'] = '%s' % dexpwcminlen

      if ( num_max is not None ):
         qsargs['num_max'] = '%s' % num_max
      else:
         if ( num is not None ):
            newmax = num * 10
         else:
            newmax = 100
         qsargs['num_max'] = '%s' % newmax

      if ( brnum is not None ):
         qsargs['browse_num'] = '%s' % brnum
      else:
         qsargs['browse_num'] = brnum

      qsargs['browse'] = browse
      qsargs['browse_clusters_num'] = clustercount

      qsargs['output_bold_contents'] = obc
      qsargs['output_bold_contents_except'] = obce
      qsargs['output_duplicates'] = odup
      qsargs['output_score'] = oscore
      qsargs['output_shingles'] = oshing
      qsargs['output_key'] = okey
      qsargs['output_cache_references'] = ocacheref
      qsargs['output_cache_data'] = ocachedata
      qsargs['output_sort_keys'] = osortkey
      qsargs['output_contents_mode'] = ocmode
      qsargs['output_summary'] = osumtf
      qsargs['output_contents'] = oclist

      qsargs['fetch'] = fetch
      qsargs['start'] = start
      qsargs['fetch_timeout'] = fetchtimeout

      qsargs['aggregate'] = aggr
      qsargs['aggregate_max_passes'] = aggrmaxpass

      if ( qsyn is not None ):
         qsargs['syntax_operators'] = qsyn

      qsargs['fi_cond'] = ficond

      zoo = self.vapi.query_search(**qsargs)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo
   ###################################################################
   def api_query_search(self, xx=None, source=None, vfunc=None, query="",
                     num=10, cluster='false', clustercount=10,
                     fetch='true', fetchtimeout=60000, qsyn=None,
                     filename=None, ocmode=None, oclist=None, osumtf='true',
                     start=0, num_per_src=None, num_max=None,
                     browse='false', browse_num=10, browse_start=0,
                     browse_clusters_num=0):

      if ( source == None ):
         return

      if ( vfunc == None ):
         vfunc = 'query-search'

      if ( ocmode == None ):
         ocmode = 'defaults'

      if ( filename == None ):
         filename = vfunc

      httpcmd = self.apps

      dumpit = ''.join(['querywork/', filename, '.wazzat'])

      defsyntax = 'AND%20and%20()%20CONTAINING%20CONTENT%20%25field%25%3A%20%2B%20NEAR%20-%20NOT%20NOTCONTAINING%20NOTWITHIN%20OR%20or%20quotes%20stem%20THRU%20BEFORE%20FOLLOWEDBY%20weight%20wildcard%20wildchar%20WITHIN%20WORDS%20site'
      appname = 'api-rest'
      vtype = 'public-api'

      if ( qsyn == None ):
         qsyn = defsyntax

      print "Querying from VAPIINTERFACE api_query_search"

      if ( oclist == None ):
         httpstring = ''.join(['v.app=', appname,
                               '&v.type=', vtype,
                               '&v.function=', vfunc,
                               '&query=', query,
                               '&fetch=', fetch,
                               '&syntax-operators=', qsyn,
                               '&output-summary=', osumtf,
                               '&output-contents-mode=', ocmode,
                               '&fetch-timeout=', '%s' % fetchtimeout,
                               '&browse-clusters-num=', '%s' % clustercount,
                               '&num=', '%s' % num,
                               '&browse-num=', '%s' % num,
                               '&cluster=', cluster,
                               '&sources=', source])
      else:
         httpstring = ''.join(['v.app=', appname,
                               '&v.type=', vtype,
                               '&v.function=', vfunc,
                               '&query=', query,
                               '&fetch=', fetch,
                               '&syntax-operators=', qsyn,
                               '&output-summary=', osumtf,
                               '&output-contents-mode=', ocmode,
                               '&output-contents=', oclist,
                               '&fetch-timeout=', '%s' % fetchtimeout,
                               '&browse-clusters-num=', '%s' % clustercount,
                               '&num=', '%s' % num,
                               '&browse-num=', '%s' % num,
                               '&cluster=', cluster,
                               '&sources=', source])


      err = xx.HTTP.doget(tocmd=httpcmd, argstring=httpstring, dumpfile=dumpit)

      return

   ###################################################################
   #
   #   search-collection-clean api function
   #
   #   Optional params defaults:
   #      subc = 'live'
   #
   def api_sc_clean(self, xx=None, collection=None,
                    vfunc=None, subc=None):

      if ( collection == None ):
         return

      if ( vfunc == None ):
         vfunc = 'search-collection-clean'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "Cleaning the collection from VAPIINTERFACE api_sc_clean"

      zoo = self.vapi.search_collection_clean(collection=collection,
                                               subcollection=subc)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   search-collection-create api function
   #
   #   All params required
   #
   def api_sc_create(self, xx=None, collection=None, vfunc=None,
                     based_on=None):

      qsargs = {}

      if ( collection == None ):
         return

      qsargs['collection'] = collection
      qsargs['based_on'] = based_on

      if ( vfunc == None ):
         vfunc = 'search-collection-create'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "Creating the collection", collection, "from VAPIINTERFACE api_sc_create"

      #zoo = self.vapi.search_collection_create(collection=collection)
      try:
         zoo = self.vapi.search_collection_create(**qsargs)
      except velocityAPI.VelocityAPIexception:
         print "Could not create collection", collection
         return None

      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   search-collection-delete api function
   #
   #   All params required
   #
   def api_sc_delete(self, xx=None, collection=None, vfunc=None):

      if ( collection == None ):
         return

      if ( vfunc == None ):
         vfunc = 'search-collection-delete'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "Deleting the collection", collection, "from VAPIINTERFACE api_sc_delete"

      zoo = self.vapi.search_collection_delete(collection=collection)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   search-collection-indexer-start api function
   #
   #   Optional params defaults:
   #      subc = 'live'
   #
   def api_sc_indexer_start(self, xx=None, collection=None,
                            vfunc=None, subc=None):

      if ( collection == None ):
         return

      if ( vfunc == None ):
         vfunc = 'search-collection-indexer-start'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "Starting the indexer from VAPIINTERFACE api_sc_indexer_start"

      zoo = self.vapi.search_collection_indexer_start(collection=collection,
                                               subcollection=subc)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   search-collection-indexer-full-merge api function
   #
   #   Optional params defaults:
   #      subc = 'live'
   #
   def api_sc_indexer_full_merge(self, xx=None, collection=None,
                                 vfunc=None, subc=None):

      if ( collection == None ):
         return

      if ( vfunc == None ):
         vfunc = 'search-collection-indexer-full-merge'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "Starting the index merge from VAPIINTERFACE api_sc_indexer_full_merge"

      zoo = self.vapi.search_collection_indexer_full_merge(
                                                collection=collection,
                                                subcollection=subc)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   search-collection-indexer-restart api function
   #
   #   Optional params defaults:
   #      subc = 'live'
   #
   def api_sc_indexer_restart(self, xx=None, collection=None,
                            vfunc=None, subc=None):

      if ( collection == None ):
         return

      if ( vfunc == None ):
         vfunc = 'search-collection-indexer-restart'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "Starting the indexer from VAPIINTERFACE api_sc_indexer_restart"

      zoo = self.vapi.search_collection_indexer_restart(collection=collection,
                                               subcollection=subc)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   search-collection-indexer-stop api function
   #
   #   Optional params defaults:
   #      subc = 'live'
   #      killit = 'false'
   #
   def api_sc_indexer_stop(self, xx=None, collection=None, vfunc=None,
                           killit=None, subc=None, num=None,
                           filename=None):

      zoo = None
      if ( collection == None ):
         return

      if ( vfunc == None ):
         vfunc = 'search-collection-indexer-stop'

      if ( filename == None ):
         filename = ''.join([vfunc, '.wazzat'])

      dumpit = ''.join(['querywork/', filename])

      if ( num is not None ):
         if ( ( num % 2 ) == 0 ):
            killit = 'false'
         else:
            killit = 'true'

      print "Stopping the indexer from VAPIINTERFACE api_sc_indexer_stop"

      try:
         zoo = self.vapi.search_collection_indexer_stop(collection=collection,
                                                  kill=killit,
                                                  subcollection=subc)

         #
         #   If killit is 'true', the stop should be immediate so
         #   do not bother to wait.  If it is not immediate, it is a
         #   bug.
         #
         if ( killit == 'false' ):
            count = 0
            rstat = self.api_get_indexer_run_status(collection=collection,
                                                    subcollection=subc)
            if ( rstat is not None ):
               while ( rstat[0] != 'stopped' and count < 30 ):
                  time.sleep(30)
                  rstat = self.api_get_indexer_run_status(collection=collection,
                                                          subcollection=subc)
                  if ( rstat is None ):
                     print "Error getting collection status"
                     break
                  count += 1
               if ( count > 30 and rstat[0] != 'stopped' ):
                  print "WARNING:  Waited 15 minutes for indexer stop and it did not happen"
               else:
                  print "Indexer stopped in", (count * 30), "seconds"

         self.dumpdata(filename=dumpit, mydata=self.vapi.data)
      except:
         print "Collection", collection, "does not exist(indexer stop)."

      return zoo

   ###################################################################
   #
   #   search-collection-url-status-query function
   #
   def api_sc_url_status_query(self, xx=None, collection=None,
                            vfunc=None, subc='live', cusnode=None,
                            forcesync=True):

      if ( collection == None ):
         return

      if ( cusnode is None ):
         return

      if ( vfunc is None ):
         vfunc = 'search-collection-url-status-query'


      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "URL status query from VAPIINTERFACE api_sc_url_status_query"

      zoo = self.vapi.search_collection_url_status_query(collection=collection,
                                               subcollection=subc,
                                               crawl_url_status=cusnode,
                                               force_sync=forcesync)

      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   search-collection-crawler-restart api function
   #
   #   Optional params defaults:
   #      subc = 'live'
   #
   def api_sc_crawler_restart(self, xx=None, collection=None,
                            vfunc=None, subc=None):

      if ( collection == None ):
         return

      if ( vfunc == None ):
         vfunc = 'search-collection-crawler-restart'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "Starting the crawler from VAPIINTERFACE api_sc_crawler_restart"

      zoo = self.vapi.search_collection_crawler_restart(collection=collection,
                                               subcollection=subc)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   search-collection-crawler-start api function
   #
   #   Optional params defaults:
   #      subc = 'live'
   #      stype = 'new'  possibilities are:
   #                     new, resume, resume-and-idle,
   #                     refresh-inplace, refresh-new, apply-changes
   #
   def api_sc_crawler_start(self, xx=None, collection=None,
                            vfunc=None, stype='resume', subc='live',
                            filename=None):

      if ( collection == None ):
         return

      if ( vfunc == None ):
         vfunc = 'search-collection-crawler-start'

      if ( filename == None ):
         filename = ''.join([vfunc, '.wazzat'])

      dumpit = ''.join(['querywork/', filename])

      print "Starting the crawler from VAPIINTERFACE api_sc_crawler_start"

      zoo = self.vapi.search_collection_crawler_start(collection=collection,
                                               subcollection=subc,
                                               type=stype)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   search-collection-crawler-stop api function
   #
   #   Optional params defaults:
   #      subc = 'live'
   #      killit = 'false'
   #
   def api_sc_crawler_stop(self, xx=None, collection=None, vfunc=None,
                           subc=None, killit=None, num=None,
                           filename=None):

      zoo = None
      if ( collection == None ):
         return

      if ( vfunc == None ):
         vfunc = 'search-collection-crawler-stop'

      if ( filename == None ):
         filename = ''.join([vfunc, '.wazzat'])

      dumpit = ''.join(['querywork/', filename])

      if ( num is not None ):
         if ( ( num % 2 ) == 1 ):
            killit = 'true'
         else:
            killit = 'false'

      print "Stopping the crawler from VAPIINTERFACE api_sc_crawler_stop"

      try:
         zoo = self.vapi.search_collection_crawler_stop(collection=collection,
                                                  subcollection=subc,
                                                  kill=killit)
         #
         #   If killit is 'true', the stop should be immediate so
         #   do not bother to wait.  If it is not immediate, it is a
         #   bug.
         #
         if ( killit == 'false' ):
            count = 0
            rstat = self.api_get_crawler_run_status(collection=collection,
                                                    subcollection=subc)
            if ( rstat is not None ):
               while ( rstat[0] != 'stopped' and count < 30 ):
                  time.sleep(30)
                  rstat = self.api_get_crawler_run_status(collection=collection,
                                                          subcollection=subc)
                  if ( rstat is None ):
                     print "Error getting collection status"
                     break
                  count += 1
               if ( count > 30 and rstat[0] != 'stopped' ):
                  print "WARNING:  Waited 15 minutes for crawler stop and it did not happen"
               else:
                  print "Crawler stopped in", (count * 30), "seconds"

         self.dumpdata(filename=dumpit, mydata=self.vapi.data)
      except:
         print "Collection", collection, "does not exist(crawler stop)."

      return zoo

   ###################################################################
   #
   #   scheduler-service-start api function
   #
   #   All params are required
   #
   def api_sched_srv_start(self, xx=None, vfunc=None):

      if ( vfunc == None ):
         vfunc = 'scheduler-service-start'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "Starting the scheduler service from VAPIINTERFACE api_sched_srv_start"

      zoo = self.vapi.scheduler_service_start()
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   scheduler-service-stop api function
   #
   #   All params are required
   #
   def api_sched_srv_stop(self, xx=None, vfunc=None):

      if ( vfunc == None ):
         vfunc = 'scheduler-service-stop'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "Stopping the scheduler service from VAPIINTERFACE api_sched_srv_stop"

      zoo = self.vapi.scheduler_service_stop()
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   search-service reset
   #
   #   Different than restart in that we do the stop and start
   #   without relying on the actual restart function.
   #
   def api_ss_reset(self):

      print "Reset the search service from VAPIINTERFACE api_ss_reset"
      zoo = self.api_ss_stop()
      zoo = self.api_ss_start()

      return zoo

   ###################################################################
   #
   #   search-service-stop api function
   #
   #   All params are required
   #
   def api_ss_stop(self, xx=None, vfunc=None):

      if ( vfunc == None ):
         vfunc = 'search-service-stop'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "Stopping the search service from VAPIINTERFACE api_ss_stop"

      zoo = self.vapi.search_service_stop()
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   search-service-start api function
   #
   #   All params are required
   #
   def api_ss_set(self, xx=None, minit="0", maxit="5",
                        maxt="0", port="7205",
                        allip="*"):

      qsargs = {}

      firstline = '<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>\n'
      hoohaa = 'http://' + self.TENV.target + '/vivisimo/cgi-bin/admin'

      header = '<vse-qs admin-url="' + hoohaa + '">\n'
      trailer = '</vse-qs>\n'

      portstr = '   <vse-qs-option name="port"><![CDATA[' + \
                 port + ']]></vse-qs-option>\n'
      aipstr = '   <vse-qs-option name="allow-ips"><![CDATA[' + \
                 allip + ']]></vse-qs-option>\n'
      minitstr = '   <vse-qs-option name="min-idle-threads"><![CDATA[' + \
                 minit + ']]></vse-qs-option>\n'
      maxitstr = '   <vse-qs-option name="max-idle-threads"><![CDATA[' + \
                 maxit + ']]></vse-qs-option>\n'
      maxtstr = '   <vse-qs-option name="max-threads"><![CDATA[' + \
                 maxt + ']]></vse-qs-option>\n'

      vfunc = 'search-service-set'

      qs_node = ''.join([firstline, header, portstr, aipstr, minitstr, maxitstr, maxtstr, trailer])
      #qsargs['configuration'] = ''.join([header, portstr, aipstr, minitstr, maxitstr, maxtstr, trailer])
      #print qs_node

      #dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "Setting search service params from VAPIINTERFACE api_ss_set"
      outfd = open('query-service.xml', 'w')
      outfd.write(qs_node)
      outfd.close()

      targdata = xx.vivisimo_dir(which="data")
      xx.put_file(putfile="query-service.xml", targetdir=targdata)

      #zoo = self.vapi.search_service_set(**qsargs)
      #self.dumpdata(filename=dumpit, mydata=self.vapi.data)
      #return zoo

      return 0


   ###################################################################
   #
   #   search-service-start api function
   #
   #   All params are required
   #
   def api_ss_start(self, xx=None, vfunc=None):

      if ( vfunc == None ):
         vfunc = 'search-service-start'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "Starting the search service from VAPIINTERFACE api_ss_start"

      zoo = self.vapi.search_service_start()
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   search-service-restart api function
   #
   #   All params are required
   #
   def api_ss_restart(self, xx=None, vfunc=None):

      if ( vfunc == None ):
         vfunc = 'search-service-restart'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "Restarting the search service from VAPIINTERFACE api_ss_restart"

      zoo = self.vapi.search_service_restart()
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   search-service-status api function
   #
   #   All params are required
   #
   def api_ss_status(self, xx=None, vfunc=None):

      if ( vfunc == None ):
         vfunc = 'search-service-status'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "Get status of search service from VAPIINTERFACE api_ss_status"

      zoo = self.vapi.search_service_status_xml()
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   search-service-set-ping api function
   #
   #   All params are required
   #
   def api_ss_set_ping(self, xx=None, vfunc=None, presp='pong'):

      if ( vfunc == None ):
         vfunc = 'search-service-set-ping'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "Set ping of search service from VAPIINTERFACE api_ss_set_ping"

      zoo = self.vapi.search_service_set_ping(ping=presp)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   search-collection-status api function
   #
   #   Optional params defaults:
   #      staleok = 'false'
   #      subc = 'live'
   #
   def api_sc_status(self, xx=None, collection=None, vfunc=None,
                           subc=None, staleok=None, filename=None):

      if ( collection == None ):
         return

      if ( vfunc == None ):
         vfunc = 'search-collection-status'

      if ( filename == None ):
         dumpit = ''.join(['querywork/', vfunc, '.wazzat'])
      else:
         dumpit = filename

      print "Getting the collection status from VAPIINTERFACE api_sc_status"

      zoo = self.vapi.search_collection_status(collection=collection,
                                               subcollection=subc,
                                               stale_ok=staleok)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   def api_get_crawler_run_status(self, collection=None,
                                  subcollection='live',
                                  staleok=None):

      if ( collection is None ):
         return None

      try:
         zoo = self.api_sc_status(collection=collection,
                                  subc=subcollection,
                                  staleok=staleok)

         status = zoo.xpath("//crawler-status/@service-status")
         if ( status is not None ):
            if ( status == [] ):
               status = None
      except:
         return None

      return status

   def api_get_indexer_run_status(self, collection=None,
                                  subcollection='live',
                                  staleok=None):

      if ( collection is None ):
         return None

      try:
         zoo = self.api_sc_status(collection=collection,
                                  subc=subcollection,
                                  staleok=staleok)

         status = zoo.xpath("//vse-index-status/@service-status")
         if ( status is not None ):
            if ( status == [] ):
               status = None
      except:
         return None

      return status

   def api_get_crawler_sync_status(self, collection=None,
                                  subcollection='live',
                                  staleok=None, filename=None):

      if ( collection is None ):
         return None

      try:
         zoo = self.api_sc_status(collection=collection,
                                  subc=subcollection,
                                  staleok=staleok, filename=filename)

         status1 = zoo.xpath("//crawler-status/crawl-remote-all-status/crawl-remote-server-status/crawl-remote-connection-status/crawl-remote-collection-status/@state")
         retval = 'synchronized'
         for item in status1:
            synmess = item.split(':')
            if ( synmess[0] != 'synchronized' ):
               retval = 'synchronizing'

         status2 = zoo.xpath("//crawler-status/crawl-remote-all-status/crawl-remote-client-status/crawl-remote-connection-status/crawl-remote-collection-status/@state")
         for item in status2:
            synmess = item.split(':')
            if ( synmess[0] != 'synchronized' ):
               retval = 'synchronizing'
      except:
         return 'synchronized'

      return retval

   ###################################################################
   #
   #   search-collection-xml api function
   #
   #   Optional params defaults:
   #      staleok = 'false'
   #
   def api_sc_xml(self, xx=None, collection=None,
                  vfunc=None, staleok=None):

      if ( collection == None ):
         return

      if ( vfunc == None ):
         vfunc = 'search-collection-xml'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "Getting the collection xml from VAPIINTERFACE api_sc_xml"

      zoo = self.vapi.search_collection_xml(collection=collection,
                                            stale_ok=staleok)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   def get_dictionary_status_string(self, xx=None, vfunc=None):

      cmd = "xsltproc"

      if ( vfunc == None ):
         return

      arg1 = ''.join([self.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
      opts = ''.join(['--stringparam mynode dictionary-status'])
      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      cmdopts = ' '.join([opts, arg1, dumpit])

      y = xx.exec_command_stdout(cmd, cmdopts, None)

      return y


   ###################################################################
   #
   #   dictionary-stop api function
   #
   #   Optional params defaults:
   #      killit = 'false'
   #
   def api_dictionary_stop(self, xx=None, dictionary_name=None,
                           killit=None, vfunc=None):

      if ( dictionary_name == None ):
         return

      if ( vfunc == None ):
         vfunc = 'dictionary-stop'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      zoo = self.vapi.dictionary_stop(dictionary=dictionary_name,
                                      kill=killit)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   dictionary-build api function
   #
   #   All params are required
   #
   def api_dictionary_build(self, xx=None, dictionary_name=None,
                           vfunc=None):

      if ( dictionary_name == None ):
         return

      if ( vfunc == None ):
         vfunc = 'dictionary-build'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      zoo = self.vapi.dictionary_build(dictionary=dictionary_name)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   dictionary-delete api function
   #
   #   All params are required
   #
   def api_dictionary_delete(self, xx=None, dictionary_name=None,
                           vfunc=None):

      if ( dictionary_name == None ):
         return

      if ( vfunc == None ):
         vfunc = 'dictionary-delete'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      zoo = self.vapi.dictionary_delete(dictionary=dictionary_name)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   dictionary-status api function
   #
   #   All params are required
   #
   def api_dictionary_status(self, xx=None, dictionary_name=None,
                           vfunc=None):

      dictstat = None

      if ( dictionary_name == None ):
         return

      if ( vfunc == None ):
         vfunc = 'dictionary-status'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      zoo = self.vapi.dictionary_status_xml(dictionary=dictionary_name)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      dictstat = self.get_dictionary_status_string(xx=xx, vfunc=vfunc)

      return dictstat

   ###################################################################
   #
   #   dictionary-status api function
   #
   #   All params are required
   #
   def api_dictionary_list_xml(self, vfunc=None):

      dictstat = None

      if ( vfunc == None ):
         vfunc = 'dictionary-list-xml'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      zoo = self.vapi.dictionary_list_xml()
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)
      etree.tostring(zoo)

      #dictstat = self.get_dictionary_status_string(xx=xx, vfunc=vfunc)

      #return dictstat
      return

   ###################################################################
   #
   #   dictionary-create api function
   #
   #   Optional params defaults:
   #      based = 'base'
   #
   def api_dictionary_create(self, xx=None, dictionary_name=None,
                             based=None, vfunc=None):

      if ( dictionary_name == None ):
         return

      if ( vfunc == None ):
         vfunc = 'dictionary-create'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      zoo = self.vapi.dictionary_create(dictionary=dictionary_name,
                                        based_on=based)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   autocomplete-suggest function
   #
   #
   def api_autocomplete_suggest(self, dictionary_name=None,
                                basestr=None, num=10, rights=None,
                                filter=None, bow=False, vfunc=None):

      qsargs = {}

      if ( dictionary_name is None ):
         return

      if ( basestr is None ):
         return

      if ( vfunc == None ):
         vfunc = 'autocomplete-suggest'

      #
      #   these two are required items
      #
      qsargs['dictionary'] = dictionary_name
      qsargs['str'] = basestr

      if ( num != 10 ):
         qsargs['num'] = num
      if ( rights is not None ):
         qsargs['rights'] = rights
      if ( filter is not None ):
         qsargs['filter'] = filter
      if ( bow ):
         qsargs['bag_of_words'] = bow

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      zoo = self.vapi.autocomplete_suggest(**qsargs)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)
      phrase_list = zoo.xpath('//phrase/text()')

      return phrase_list

   ###################################################################
   def api_repository_update(self, xx=None,
                       vfunc=None, xmlstr=None, xmlfile=None):

      if ( vfunc == None ):
         vfunc = 'repository-update'

      if ( xmlstr == None ):
         if ( xmlfile == None ):
            return
         else:
            if (os.access(xmlfile, os.R_OK) == 1 ):
               datasize = os.stat(xmlfile).st_size
               fd = file(xmlfile, 'rb', datasize)
               xmlstr = fd.read()
               fd.close()

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "Updating repository in VAPIINTERFACE api_repository_update"

      zoo = self.vapi.repository_update(node=xmlstr)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo


   ###################################################################
   def api_repository_add(self, xx=None,
                       vfunc=None, xmlstr=None, xmlfile=None):

      if ( vfunc == None ):
         vfunc = 'repository-add'

      if ( xmlstr == None ):
         if ( xmlfile == None ):
            return
         else:
            if (os.access(xmlfile, os.R_OK) == 1 ):
               datasize = os.stat(xmlfile).st_size
               fd = file(xmlfile, 'rb', datasize)
               xmlstr = fd.read()
               fd.close()

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "Adding to repository in VAPIINTERFACE api_repository_add"

      zoo = self.vapi.repository_add(node=xmlstr)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo


   ###################################################################
   #
   #   repository-get api function
   #
   #   All params are required.
   #
   #   elemtypes are:
   #      vse-collection, function, application, source, report,
   #      parser, macro, kb (knowledge base), dictionary, form
   #
   def api_repository_get_md5(self, xx=None, elemtype=None, elemname=None,
                           vfunc=None):

      if ( elemtype == None ):
         elemtype = "vse-collection"

      if ( elemname == None ):
         return

      if ( vfunc == None ):
         vfunc = 'repository-get-md5'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "Getting", elemname, "from repository in VAPIINTERFACE api_repository_get"

      zoo = self.vapi.repository_get_md5(element=elemtype,
                                     name=elemname)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   repository-get api function
   #
   #   All params are required.
   #
   #   elemtypes are:
   #      vse-collection, function, application, source, report,
   #      parser, macro, kb (knowledge base), dictionary, form
   #
   def api_repository_get(self, xx=None, elemtype=None, elemname=None,
                           vfunc=None):

      if ( elemtype == None ):
         elemtype = "vse-collection"

      if ( elemname == None ):
         return

      if ( vfunc == None ):
         vfunc = 'repository-get'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "Getting", elemname, "from repository in VAPIINTERFACE api_repository_get"

      zoo = self.vapi.repository_get(element=elemtype,
                                     name=elemname)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   def repository_node_exists(self, elemtype=None, elemname=None):
 
 
      if ( elemtype == "collection" or elemtype == "vse-collection" ):
         getstring = "//vse-collection/@name"
         elemtype = "vse-collection"
      elif ( elemtype == "source" ):
         getstring = "//source/@name"
      elif ( elemtype == "function" ):
         getstring = "//function/@name"
      elif ( elemtype == "application" ):
         getstring = "//application/@name"
      elif ( elemtype == "report" ):
         getstring = "//report/@name"
      elif ( elemtype == "parser" ):
         getstring = "//parser/@name"
      elif ( elemtype == "macro" ):
         getstring = "//macro/@name"
      elif ( elemtype == "kb" or elemtype == "knowledge-base" ):
         getstring = "//kb/@name"
         elemtype = "kb"
      elif ( elemtype == "dictionary" ):
         getstring = "//dictionary/@name"
      elif ( elemtype == "form" ):
         getstring = "//form/@name"
      elif ( elemtype == "syntax" ):
         getstring = "//syntax/@name"
      elif ( elemtype == "options" ):
         getstring = "//options/@name"
      else:
         print "Unrecognized repository node type: ", elemtype
         return 0
 
      try:
         reponode = self.api_repository_get(elemtype=elemtype, elemname=elemname)
      except:
         e = sys.exc_info()
         e_value=str(e[1])
         if ( e_value.find("repository-unknown-node") >= 0 ):
            return 0
            
	 print "Failure to get %s with %s : %s caused by %s \n %s"%(elemtype, elemname, e[0], e[1],'\n\t'.join(traceback.format_tb( e[2] )))
         return 0
 
      if ( reponode is not None ):
         myname = reponode.xpath(getstring)[0]
 
         if ( myname == elemname ):
            return 1
 
      return 0
 

   def api_repository_list(self, xx=None, vfunc=None):

      if ( vfunc == None ):
         vfunc = 'repository-list-xml'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "Getting list from repository in VAPIINTERFACE api_repository_list"

      zoo = self.vapi.repository_list_xml()
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   repository-get api function
   #
   #   All params are required.
   #
   #   elemtypes are:
   #      vse-collection, function, application, source, report,
   #      parser, macro, kb (knowledge base), dictionary, form
   #
   def api_repository_del(self, xx=None, elemtype=None,
                          elemname=None, vfunc=None):

      if ( elemtype == None ):
         return

      if ( elemname == None ):
         return

      if ( vfunc == None ):
         vfunc = 'repository-delete'

      dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

      print "Deleting", elemname, "from repository in VAPIINTERFACE api_repository_del"

      zoo = self.vapi.repository_delete(element=elemtype,
                                     name=elemname)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   query-browse api function
   #
   #   Optional params defaults:
   #   ? means that the documentation does not specify the default
   #      state = 'root'
   #      brwsnm = ?
   #      brwstrt = ?
   #      obc = ?
   #      obce = ?
   #      obcr = ?
   #      obccr = ?
   #
   def api_query_browse(self, xx=None, qbfname=None, state=None,
                        brwsnm=None, brwstrt=None, obc=None,
                        obce=None, obcr=None, obccr=None,
                        vfunc=None, filename=None):

      qsargs = {}

      if ( qbfname == None ):
         return

      if ( vfunc == None ):
         vfunc = 'query-browse'

      if ( filename == None ):
         dumpit = ''.join(['querywork/', vfunc, '.wazzat'])
      else:
         dumpit = ''.join(['querywork/', filename])

      appname = 'api-rest'


      qsargs['file'] = qbfname
      qsargs['state'] = state
      qsargs['browse_num'] = brwsnm
      qsargs['browse_start'] = brwstrt
      qsargs['output_bold_contents'] = obc
      qsargs['output_bold_contents_except'] = obce
      qsargs['output_bold_class_root'] = obcr
      qsargs['output_bold_cluster_class_root'] = obccr

      zoo = self.vapi.query_browse(**qsargs)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   collection-broker-collection-status
   #
   def api_cb_collection_status(self, xx=None, collection=None,
                                vfunc=None, filename=None):

      if ( collection == None ):
         return

      if ( vfunc == None ):
         vfunc = 'collection-broker-collection-status'

      if ( filename == None ):
         filename = ''.join([vfunc, '.wazzat'])

      dumpit = ''.join(['querywork/', filename])

      print "Collection status from VAPIINTERFACE api_cb_collection_status"

      zoo = self.vapi.collection_broker_collection_status(collection=collection)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   collection-broker-status
   #
   def api_cb_status(self, xx=None, vfunc=None, filename=None):

      if ( vfunc == None ):
         vfunc = 'collection-broker-status'

      if ( filename == None ):
         filename = ''.join([vfunc, '.wazzat'])

      dumpit = ''.join(['querywork/', filename])

      print "Collection broker status from VAPIINTERFACE api_cb_status"

      zoo = self.vapi.collection_broker_status()
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   collection-broker-status
   #
   def api_cb_get(self, xx=None, vfunc=None, filename=None):

      if ( vfunc == None ):
         vfunc = 'collection-broker-get'

      if ( filename == None ):
         filename = ''.join([vfunc, '.wazzat'])

      dumpit = ''.join(['querywork/', filename])

      print "Collection broker configuration from VAPIINTERFACE api_cb_get"

      zoo = self.vapi.collection_broker_get()
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   collection-broker-start
   #
   def api_cb_start(self, xx=None, vfunc=None, filename=None):

      if ( vfunc == None ):
         vfunc = 'collection-broker-start'

      if ( filename == None ):
         filename = ''.join([vfunc, '.wazzat'])

      dumpit = ''.join(['querywork/', filename])

      print "Staring the collection broker from VAPIINTERFACE api_cb_start"

      zoo = self.vapi.collection_broker_start()
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   collection-broker-stop
   #
   def api_cb_stop(self, xx=None, vfunc=None, filename=None):

      if ( vfunc == None ):
         vfunc = 'collection-broker-stop'

      if ( filename == None ):
         filename = ''.join([vfunc, '.wazzat'])

      dumpit = ''.join(['querywork/', filename])

      print "Stopping the collection broker from VAPIINTERFACE api_cb_stop"

      zoo = self.vapi.collection_broker_stop()
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   collection-broker-set
   #
   def api_cb_set(self, xx=None, vfunc=None,
                  xmlstr=None, xmlfile=None, xmlnode=None):

      if ( vfunc == None ):
         vfunc = 'collection-broker-set'

      if ( xmlstr is None and xmlfile is None and xmlnode is None ):
         return
      else:
         if ( xmlfile is not None ):
            if (os.access(xmlfile, os.R_OK) == 1 ):
               datasize = os.stat(xmlfile).st_size
               fd = file(xmlfile, 'rb', datasize)
               xmlstr = fd.read()
               fd.close()
         else:
            if ( xmlnode is not None ):
               xmlstr = etree.tostring(xmlnode)

      if ( xmlfile == None ):
         xmlfile = ''.join([vfunc, '.wazzat'])

      dumpit = ''.join(['querywork/', xmlfile])

      print "Setting the collection broker from VAPIINTERFACE api_cb_set"

      zoo = self.vapi.collection_broker_set(configuration=xmlstr)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo


   ###################################################################
   #
   #   collection-broker-search
   #
   def api_cb_search(self, xx=None, source=None, vfunc=None, query=None,
                     num=None, cluster=None, clustercount=None,
                     fetch=None, fetchtimeout=None, qsyn=None,
                     filename=None, ocmode=None, oclist=None, osumtf=None,
                     start=None, num_per_src=None, num_max=None,
                     browse=None, browse_num=None, browse_start=None,
                     browse_clusters_num=None, ficond=None, brnum=None,
                     qcondxp=None, odup=None, oscore=None, oshing=None,
                     okey=None, qobj=None, qcondobj=None, aggr=None,
                     osortkey=None, aggrmaxpass=None, num_ovr_req=None,
                     ocacheref=None, ocachedata=None, user=None, passwd=None,
                     obc=None, obce=None, bincfg=None, bincol=None,
                     binmode=None, binstate=None):

      qsargs = {}

      if ( source == None ):
         return

      if ( vfunc == None ):
         vfunc = 'collection-broker-search'

      if ( filename == None ):
         filename = vfunc

      if ( fetchtimeout == None ):
         fetchtimeout = 2500000

      dumpit = ''.join(['querywork/', filename, '.wazzat'])

      defsyntax = 'AND and () CONTAINING CONTENT %field%: + NEAR - NOT NOTCONTAINING NOTWITHIN OR or quotes stem THRU BEFORE FOLLOWEDBY weight wildcard wildchar WITHIN WORDS site regex'

      if ( qsyn == 'Default' ):
         qsyn = defsyntax

      qsargs['collection'] = source
      qsargs['query'] = query
      qsargs['query_object'] = qobj
      qsargs['query_condition_object'] = qcondobj
      qsargs['query_condition_xpath'] = qcondxp
      qsargs['cluster'] = cluster
      qsargs['num_per_source'] = num_per_src

      qsargs['authorization_username'] = user
      qsargs['authorization_password'] = passwd

      qsargs['binning_configuration'] = bincfg
      qsargs['collapse_binning'] = bincol
      qsargs['binning_mode'] = binmode
      qsargs['binning_state'] = binstate

      qsargs['num_over_request'] = num_ovr_req
      if ( num is not None ):
         qsargs['num'] = '%s' % num
      else:
         qsargs['num'] = num

      if ( num_max is not None ):
         qsargs['num_max'] = '%s' % num_max
      else:
         if ( num is not None ):
            newmax = num * 10
         else:
            newmax = 100
         qsargs['num_max'] = '%s' % newmax

      if ( brnum is not None ):
         qsargs['browse_num'] = '%s' % brnum
      else:
         qsargs['browse_num'] = brnum

      qsargs['browse'] = browse
      qsargs['browse_clusters_num'] = clustercount

      qsargs['output_bold_contents'] = obc
      qsargs['output_bold_contents_except'] = obce
      qsargs['output_duplicates'] = odup
      qsargs['output_score'] = oscore
      qsargs['output_shingles'] = oshing
      qsargs['output_key'] = okey
      qsargs['output_cache_references'] = ocacheref
      qsargs['output_cache_data'] = ocachedata
      qsargs['output_sort_keys'] = osortkey
      qsargs['output_contents_mode'] = ocmode
      qsargs['output_summary'] = osumtf
      qsargs['output_contents'] = oclist

      qsargs['fetch'] = fetch
      qsargs['start'] = start
      qsargs['fetch_timeout'] = fetchtimeout

      qsargs['aggregate'] = aggr
      qsargs['aggregate_max_passes'] = aggrmaxpass

      qsargs['syntax_operators'] = qsyn

      qsargs['fi_cond'] = ficond

      zoo = self.vapi.collection_broker_search(**qsargs)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo
   ###################################################################
   #
   #   collection-broker-enqueue-xml api function
   #
   #   Optional params defaults:
   #      subc = 'live'
   #      eonfail = 'false'
   #
   def api_cb_enqueue_xml(self, xx=None, collection=None,
                      vfunc=None, url=None,
                      eonfail=None, filename=None, crawl_nodes=None):

      if ( collection == None ):
         return

      if ( crawl_nodes == None ):
         crawl_nodes = url
         if ( crawl_nodes == None ):
            return

      if ( vfunc == None ):
         vfunc = 'collection-broker-enqueue-xml'

      if ( filename == None ):
         filename = ''.join([vfunc, '.wazzat'])

      dumpit = ''.join(['querywork/', filename])

      print "Enqueue xml from VAPIINTERFACE api_cb_enqueue_xml"
      zoo = self.vapi.collection_broker_enqueue_xml(collection=collection,
                                             exception_on_failure=eonfail,
                                             crawl_nodes=crawl_nodes)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   def api_cb_crawler_offline_status(self, xx=None, collection=None,
                                     vfunc=None, filename=None):

      if ( collection == None ):
         return

      if ( vfunc == None ):
         vfunc = 'collection-broker-crawler-offline-status'

      if ( filename == None ):
         filename = ''.join([vfunc, '.wazzat'])

      dumpit = ''.join(['querywork/', filename])

      print "Offline status from VAPIINTERFACE api_cb_crawler_offline_status"
      zoo = self.vapi.collection_broker_crawler_offline_status(
                                        collection=collection)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   def getOfflineQueueSize(self, collection=None):

      if ( collection is None ):
         return None

      resptree = self.api_cb_crawler_offline_status(collection=collection)

      value = self.getResultData(tagname='crawler-offline-status',
                                 attrname='n-offline-queue', ri='value',
                                 resptree=resptree)

      return value


   ###################################################################
   #
   #   collection-broker-export-data
   #
   def api_cb_export_data(self, xx=None, source=None, vfunc=None, query=None,
                     num=None, cluster=None, clustercount=None,
                     fetch=None, fetchtimeout=None, qsyn=None,
                     filename=None, ocmode=None, oclist=None, osumtf=None,
                     start=None, num_per_src=None, num_max=None,
                     browse=None, browse_num=None, browse_start=None,
                     browse_clusters_num=None, ficond=None, brnum=None,
                     qcondxp=None, odup=None, oscore=None, oshing=None,
                     okey=None, qobj=None, qcondobj=None, aggr=None,
                     osortkey=None, aggrmaxpass=None, num_ovr_req=None,
                     ocacheref=None, ocachedata=None, user=None, passwd=None,
                     obc=None, obce=None, bincfg=None, bincol=None,
                     binmode=None, binstate=None, srccoll=None,
                     dstcoll=None, dstcollmeta=None):

      qsargs = {}

      if ( srccoll == None ):
         return

      if ( dstcoll == None ):
         return

      if ( vfunc == None ):
         vfunc = 'collection-broker-export-data'

      if ( filename == None ):
         filename = vfunc

      if ( fetchtimeout == None ):
         fetchtimeout = 2500000

      dumpit = ''.join(['querywork/', filename, '.wazzat'])

      defsyntax = 'AND and () CONTAINING CONTENT %field%: + NEAR - NOT NOTCONTAINING NOTWITHIN OR or quotes stem THRU BEFORE FOLLOWEDBY weight wildcard wildchar WITHIN WORDS site regex'

      if ( qsyn == 'Default' ):
         qsyn = defsyntax

      qsargs['source_collection'] = srccoll
      qsargs['destination_collection'] = dstcoll
      qsargs['destination_collection_meta'] = dstcollmeta

      qsargs['sources'] = source
      qsargs['query'] = query
      qsargs['query_object'] = qobj
      qsargs['query_condition_object'] = qcondobj
      qsargs['query_condition_xpath'] = qcondxp
      qsargs['cluster'] = cluster
      qsargs['num_per_source'] = num_per_src

      qsargs['authorization_username'] = user
      qsargs['authorization_password'] = passwd

      qsargs['binning_configuration'] = bincfg
      qsargs['collapse_binning'] = bincol
      qsargs['binning_mode'] = binmode
      qsargs['binning_state'] = binstate

      qsargs['num_over_request'] = num_ovr_req
      if ( num is not None ):
         qsargs['num'] = '%s' % num
      else:
         qsargs['num'] = num

      if ( num_max is not None ):
         qsargs['num_max'] = '%s' % num_max
      else:
         if ( num is not None ):
            newmax = num * 10
         else:
            newmax = 100
         qsargs['num_max'] = '%s' % newmax

      if ( brnum is not None ):
         qsargs['browse_num'] = '%s' % brnum
      else:
         qsargs['browse_num'] = brnum

      qsargs['browse'] = browse
      qsargs['browse_clusters_num'] = clustercount

      qsargs['output_bold_contents'] = obc
      qsargs['output_bold_contents_except'] = obce
      qsargs['output_duplicates'] = odup
      qsargs['output_score'] = oscore
      qsargs['output_shingles'] = oshing
      qsargs['output_key'] = okey
      qsargs['output_cache_references'] = ocacheref
      qsargs['output_cache_data'] = ocachedata
      qsargs['output_sort_keys'] = osortkey
      qsargs['output_contents_mode'] = ocmode
      qsargs['output_summary'] = osumtf
      qsargs['output_contents'] = oclist

      qsargs['fetch'] = fetch
      qsargs['start'] = start
      qsargs['fetch_timeout'] = fetchtimeout

      qsargs['aggregate'] = aggr
      qsargs['aggregate_max_passes'] = aggrmaxpass

      qsargs['syntax_operators'] = qsyn

      qsargs['fi_cond'] = ficond

      zoo = self.vapi.collection_broker_export_data(**qsargs)
      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo


   def wait_for_collection_stop(self, collection, max_wait=10):
      """Wait for a collection to stop.

      Repeatedly check the crawler and indexer status until they both
      show 'stopped' or the max_wait time has been exceeded.

      Return True if the service statuses show 'stopped'.
      Return False if the max_wait was exceeded"""

      for i in xrange(max_wait):
         time.sleep(1)
         scs = self.vapi.search_collection_status(collection=collection)
         if scs.xpath('crawler-status/@service-status') == ['stopped'] and \
                scs.xpath('vse-index-status/@service-status') == ['stopped']:
            return True
      # Not stopped within max_wait checks:
      return False


   def cleanup_collection(self,
                          collection,
                          delete=False,
                          kill=False,
                          retry=False):
      """Stop and optionally delete a collection.

      Returns True  if the cleanup was successful and
              False if the cleanup failed."""
      if delete or kill:
         kill_parameter = 'true'
      else:
         kill_parameter = None
      success = False
      retrying = True
      while retrying and not success:
         retrying = retry
         try:
            self.vapi.search_collection_crawler_stop(collection=collection,
                                                     kill=kill_parameter)
            self.vapi.search_collection_indexer_stop(collection=collection,
                                                     kill=kill_parameter)
            if delete:
               self.wait_for_collection_stop(collection=collection)
               self.vapi.search_collection_delete(collection=collection)
            success = True
         except velocityAPI.VelocityAPIexception:
            ex_xml, ex_text = sys.exc_info()[1]
            # Collection doesn't exist? Then we're fine...
            success = ex_xml.get('name') == 'search-collection-invalid-name'
            if not success:
               print 'cleanup_collection failed for %s: %s' \
                   % (collection, ex_text)
               if retrying:
                  time.sleep(2) # Don't pound too hard...

      return success


   def create_multiple_collections(self,
                                   count,
                                   format='test-collection-%d',
                                   based_on=None,
                                   delete_first=True):
      """Create many collections.

      'count' is the number of collections to create.
      'format' is the Python format for each collection name. There needs to
               be a single integer spec (such as: %d or %3d) in this string.
      'based_on' is passed on to the search-collection-create API call.
      'delete_first' True means delete a same named collection and recreate it.
                     Flase means just leave any existing collection in place.

       Returns a list of the collection names that were created.
       Any failure is raised as a Python exception.
       """

      collection_name_list = [(format % i) for i in xrange(int(count))]
      for collection in collection_name_list:
         try:
            self.vapi.search_collection_create(collection=collection,
                                               based_on=based_on)
         except velocityAPI.VelocityAPIexception:
            ex_xml, ex_text = sys.exc_info()[1]
            if ex_xml.get('name') != 'search-collection-already-exists':
               raise
            if delete_first:
               print 'removing pre-existing collection "%s".' % collection
               self.cleanup_collection(collection, delete=True, retry=True)
               self.vapi.search_collection_create(collection=collection,
                                                  based_on=based_on)

      return collection_name_list

   ###################################################################
   #
   #   audit-log-retrieval api function
   #   offset - skip how many before return the first one following
   #   originator - opaque addition, must have been specified in
   #                crawl-url, crawl-delete, or index-atomic
   #   limit - max number to return
   #   collection
   #   sub-collection
   #
   def api_sc_audit_log_retrieve(self, xx=None, origin=None, limit=None,
                     offset=None, vfunc=None, collection=None, subc=None,
                     filename=None):

      qsargs = {}

      if ( origin is not None ):
         qsargs['originator'] = origin
      if ( limit is not None ):
         qsargs['limit'] = '%s' % limit
      if ( offset is not None ):
         qsargs['offset'] = offset
      if ( collection is not None ):
         qsargs['collection'] = collection
      if ( subc is not None ):
         qsargs['sub-collection'] = subc

      if ( vfunc == None ):
         vfunc = 'audit-log-retrieval'

      if ( filename == None ):
         filename = vfunc

      dumpit = ''.join(['querywork/', filename, '.wazzat'])

      print "Retrieve audit log for", collection, "from VAPIINTERFACE api_audit_log_retrieval"

      zoo = self.vapi.search_collection_audit_log_retrieve(**qsargs)

      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo

   ###################################################################
   #
   #   audit-log-purge api function
   #   token
   #   audit-log-entry
   #   collection
   #   sub-collection
   #
   def api_sc_audit_log_purge(self, xx=None, token=None, vfunc=None,
                           collection=None, subc=None, auditlogentry=None,
                           filename=None):

      qsargs = {}

      if ( token is not None ):
         qsargs['token'] = token
      if ( auditlogentry is not None ):
         qsargs['audit-log-entry'] = auditlogentry
      if ( collection is not None ):
         qsargs['collection'] = collection
      if ( subc is not None ):
         qsargs['sub-collection'] = subc

      if ( vfunc == None ):
         vfunc = 'audit-log-purge'

      if ( filename == None ):
         filename = vfunc

      dumpit = ''.join(['querywork/', filename, '.wazzat'])

      print "Purge audit log for", collection, "from VAPIINTERFACE api_audit_log_purge"

      zoo = self.vapi.search_collection_audit_log_purge(**qsargs)

      self.dumpdata(filename=dumpit, mydata=self.vapi.data)

      return zoo
