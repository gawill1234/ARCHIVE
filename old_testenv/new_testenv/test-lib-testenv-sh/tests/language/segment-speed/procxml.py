#!/usr/bin/python

import os, sys, string, subprocess, time
import urllib, urllib2
import libxml2, re, random, shutil
from lxml import etree

class GETXMLDATA(object):

   def __init__(self, mydoc=None):

      fd = open(mydoc, "r")

      contents = fd.read()

      #print contents

      self.doc = libxml2.parseDoc(contents)
      self.root = None

      return

   def get_segmenter(self):

      blah = self.child.children
      while ( blah is not None ):
         if ( blah.name == 'segmenter' ):
            return blah.content
         blah = blah.next

      return None

   def get_data(self):

      blah = self.child.children
      while ( blah is not None ):
         if ( blah.name == 'data' ):
            return blah.content
         blah = blah.next

      return None

   def get_stemmer(self):

      blah = self.child.children
      while ( blah is not None ):
         if ( blah.name == 'stemmer' ):
            return blah.content
         blah = blah.next

      return None

   def get_kb(self):

      blah = self.child.children
      while ( blah is not None ):
         if ( blah.name == 'kb' ):
            return blah.content
         blah = blah.next

      return None


   def getNextTest(self):

      validChild = True
      noMoreChildren = False

      if ( self.root is None ):
         self.root = self.doc.children
         self.child = self.root.children
      else:
         self.child = self.child.next

      while ( self.child is not None ):
         if ( self.child.name != 'test' ):
            self.child = self.child.next
         else:
            return validChild

      if ( self.child is None ):
         return noMoreChildren
      else:
         return validChild

   def runTransform(self, data=None, segmenter=None, stemmer=None, kb=None):

      ldpath = "LD_LIBRARY_PATH=/var/www/html/vivisimo/lib"
      cmd = "/var/www/html/vivisimo/bin/transform"
      stsheet = "/home/gaw/testenv/tests/language/segment-speed/frompy.xsl"
      dummy = "/home/gaw/testenv/tests/language/segment-speed/dummy.xml"

      dparam = '-xsl'

      if ( data is not None ):
         dparam = dparam + ' ' + '-param data ' + '"' + data + '"'

      if ( segmenter is not None ):
         dparam = dparam + ' ' + '-param segmenter ' + '"' + segmenter + '"'

      if ( stemmer is not None ):
         dparam = dparam + ' ' + '-param stemmer ' + '"' + stemmer + '"'

      if ( kb is not None ):
         dparam = dparam + ' ' + '-param kb ' + '"' + kb + '"'
   
      fullcmd = ldpath + ' ' + cmd + ' ' + dparam + ' ' +  stsheet + ' ' + dummy

      print fullcmd

      p = None

      try:
         #print self.wget, wgetopts
         start = time.time()
         p = subprocess.Popen(fullcmd, shell=True)
         os.waitpid(p.pid, 0)
         end = time.time()
         print '<td align="center"><i>', end - start, '</i></td>'
      except OSError, e:
         print "Could not execute ", fullcmd, ": ", e

      #print p

      return

      

if __name__ == "__main__":
   filet = GETXMLDATA("/home/gaw/testenv/tests/language/segment-speed/garbage.xml")

   while ( filet.getNextTest() ):
      mydata = filet.get_data()
      myseg = filet.get_segmenter()
      mystem = filet.get_stemmer()
      mykb = filet.get_kb()

      print "DATA:", mydata
      print "Segmenter:", myseg
      print "Stemmer:", mystem
      print "KB:", mykb

      filet.runTransform(data=mydata, segmenter=myseg,
                         stemmer=mystem, kb=mykb)


