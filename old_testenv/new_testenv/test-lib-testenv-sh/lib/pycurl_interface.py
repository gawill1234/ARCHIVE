#! /usr/bin/env python
# -*- coding: iso-8859-1 -*-
# vi:ts=4:et
# $Id: basicfirst.py,v 1.5 2005/02/11 11:09:11 mfx Exp $

import sys, os
import pycurl
import libxml2, urllib
from toolenv import VIVTENV

class doPyCurl:
   def __init__(self, **myparams):

      self.TENV = VIVTENV(envlist=[])

      self.contents = ''
      self.answer = ''
      postfile = None

      self.site = self.TENV.target
      self.cmd = '/vivisimo/cgi-bin/gronk'
      self.url = 'http://' + self.site + ':' + self.TENV.httpport

      #self.url = self.site + self.cmd + '?action=' + self.action + '&' + self.actionitem + '=' + self.actionitemvalue

      for key, value in myparams.items():
         if ( key == 'postfile' ):
            postfile = value

      for key, value in myparams.items():
         if ( key == 'cmd' ):
            self.url = self.url + value
            midchar = '?'

      for key, value in myparams.items():
         if ( key != 'cmd' and key != 'postfile' ):
            if ( key == 'action' ):
               self.url = self.url + midchar + "action=" + value
            else:
               self.url = self.url + midchar + key + "=" + value
            midchar = '&'

      if ( postfile is not None ):
         self.dopycurl_push_init(postfile)
      else:
         self.dopycurl_init()

      #print self.url

   def dopycurl_init(self):

      self.pycurler = pycurl.Curl()
      self.pycurler.setopt(self.pycurler.URL, self.url)
      self.pycurler.setopt(self.pycurler.WRITEFUNCTION, self.body_callback)

   def readit(self, filename):

      datasize = os.stat(filename).st_size
      fd = file(filename, 'rb', datasize)
      content = urllib.quote(fd.read())
      fd.close()
      return content

   def dopycurl_push_init(self, fname):

      hdr = ["Content-type: application/x-www-form-urlencoded"]

      #pf = [('field1', 'test test'),
      #      ('field2', (self.pycurler.FORM_FILE, 'test_file', optrepeat ...)),
      #      ('field3', (self.pycurler.FORM_CONTENTS, 'string of data ...'))
      #     ]

      #pf = [('sendfile', (self.pycurler.FORM_FILE, fname))]
      #self.pycurler.setopt(self.pycurler.HTTPPOST, pf)

      self.pycurler = pycurl.Curl()
      self.pycurler.setopt(self.pycurler.URL, self.url)
      self.pycurler.setopt(self.pycurler.POST, 1)
      self.pycurler.setopt(self.pycurler.HTTPHEADER, hdr)
      self.pycurler.setopt(self.pycurler.POSTFIELDS, self.readit(fname))

   def GetAnItem(self, itemtoget):

      mydir = ''

      doc = libxml2.parseDoc(self.contents)
      root = doc.children
      child = root.children
      while ( child is not None ):
         if ( child.name == itemtoget ):
            mydir = child.content
         child = child.next

      return mydir

   def body_callback(self, buf):
      self.contents = self.contents + buf

   def run_the_sob(self):

      self.pycurler.perform()
      self.pycurler.close()

   # print >>sys.stderr, 'Testing', pycurl.version

#myparams = {}
#myparams['cmd'] = "/vivisimo/cgi-bin/gronk"
#myparams['action'] = 'process-memory'
#myparams['pid'] = '9152'
#
#t = doPyCurl(**myparams)
#t.run_the_sob()
#
#print t.GetAnItem("DIRECTORY")
#print t.GetAnItem("MEMSIZE")
#print t.GetAnItem("VMEMSIZE")


