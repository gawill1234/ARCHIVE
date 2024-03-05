#!/usr/bin/python

#
# http://www.devarticles.com/c/a/XML/Parsing-XML-with-SAX-and-Python/1/
#
import os, sys, string
from xml.sax import make_parser
from xml.sax.handler import ContentHandler

class DocumentHandler(ContentHandler):

   def __init__ (self, searchTerm=None, termValue=None, outputlist=None):

      self.searchTerm = searchTerm
      self.termValue = termValue
      self.outputlist = outputlist

      self.donestring = ""

      self.isContent = 0
      self.documentCount = 0
      self.matchCount = 0
      self.docMatchCount = 0
      self.debugContent = 0
      self.contentLang = ""
      self.contentType = ""
      self.contentSize = ""
      self.contentTitle = ""
      self.totalUrls = None

   def returnResultString(self):
  
      return self.donestring

   def initContentItem(self):
      self.contentLang = ""
      self.contentType = ""
      self.contentSize = ""
      self.contentTitle = ""

      return

   def processContentItem(self, ch):
 
      if ( self.contentName == "size" ):
         self.contentSize += ch
      elif ( self.contentName == "filetype" ):
         self.contentType += ch
      elif ( self.contentName == "language" ):
         self.contentLang += ch
      elif ( self.contentName == "title" ):
         self.contentTitle += ch

      return
   
       
   def startElement(self, name, attrs):

      if ( name == 'document' ):     
         self.documentUrl = attrs.get('url',"")
         self.documentLas = attrs.get('la-score',"")
         self.documentVbs = attrs.get('vse-base-score',"")
         self.documentID = attrs.get('id',"")
         self.documentCount = self.documentCount + 1
      elif ( name == 'content' ):
         self.isContent = 1
         self.contentName = attrs.get('name', "")
         if ( self.contentName == 'vse-debug-content' ):
            self.debugContent = 1
      elif ( name == 'attribute' ):
         if ( attrs.get('name', "") == 'total-results' ):
            self.totalUrls = attrs.get('value', "")
      elif ( name == 'added-source' ):
         self.totalUrls = attrs.get('total-results', "")
      elif ( name == 'match' ):
         self.matchCount = self.matchCount + 1
         self.docMatchCount = self.docMatchCount + 1

      return

   def characters(self, ch):
      if ( self.isContent == 1 ):
         self.processContentItem(ch)

      return

   def setOutputList(self, outlist):

      if ( self.outputlist == None ):
         self.outputlist = outlist

      return

   def outputValues(self):

      doout = 1
      outstring = ""
      for item in self.outputlist:
         fizzystring = ""
         if ( item == "url" or item == "document" ):
            fizzystring = self.documentUrl
         elif ( item == "id" or item == "idlist" ):
            if ( self.documentID != "" ):
               fizzystring = self.documentID
         elif ( item == "url-match-counts" ):
            fizzystring = '%s' % self.docMatchCount
         elif ( item == "language" ):
            if ( self.contentLang != "" ):
               fizzystring = self.contentLang
         elif ( item == "type" ):
            if ( self.contentType != "" ):
               fizzystring = self.contentType
         elif ( item == "size" ):
            if ( self.contentSize != "" ):
               fizzystring = self.contentSize
         elif ( item == "title" ):
            if ( self.contentTitle != "" ):
               fizzystring = self.contentTitle
         elif ( item == "url-count" ):
            fizzystring = '%s' % self.totalUrls
         elif ( item == "match-count" ):
            fizzystring = '%s' % self.matchCount
         elif ( item == "document-count" ):
            fizzystring = '%s' % self.documentCount
         elif ( item == "no-stdout" ):
            doout = 0

         if ( fizzystring != "" ):
            if (outstring == "" ):
               outstring = fizzystring
            else:
               outstring = ''.join([outstring, '---', fizzystring])

      if ( outstring != "" ):
         if ( doout == 1 ):
            print outstring

      self.donestring = outstring

      return

   def endElement(self, name):

      if ( name == 'content' ):
         self.isContent = 0

      if ( self.searchTerm == None ):
         if ( name == 'document' ):
            print self.documentUrl

            if ( self.contentLang != "" ):
               print "   Language:", self.contentLang
            if ( self.contentSize != "" ):
               print "   Size    :", self.contentSize
            if ( self.contentType != "" ):
               print "   Type    :", self.contentType
            if ( self.contentTitle != "" ):
               print "   Title   :", self.contentTitle
            if ( self.debugContent == 1 ):
               print "   Document Matches   :", self.docMatchCount
            self.docMatchCount = 0

         if ( name == 'scope' or name == 'list' ):
            print "Total Documents:", self.documentCount
            print "Total Urls     :", self.totalUrls
            if ( self.debugContent == 1 ):
               print "Total Matches  :", self.matchCount
               if ( self.matchCount < self.documentCount ):
                  print "Document errors, match count is less than document count"
      else:

         if ( name == 'document' ):
            if ( self.searchTerm == 'document' ):
               self.setOutputList(['url'])
               self.outputValues()
            elif ( self.searchTerm == 'url-match-counts' ):
               self.setOutputList(['url', 'url-match-counts'])
               self.outputValues()
               self.docMatchCount = 0
            elif ( self.searchTerm == 'url-by-id' ):
               if ( self.documentID == self.termValue ):
                  self.setOutputList(['url'])
                  self.outputValues()
                  raise
            elif ( self.searchTerm == 'idlist' ):
               self.setOutputList(['id'])
               self.outputValues()
            elif ( self.searchTerm == 'match-url' ):
               if ( self.documentUrl == self.termValue ):
                  self.setOutputList(['url'])
                  self.outputValues()
                  raise 
            elif ( self.searchTerm == 'vbscore-minimum' ):
               if ( float(self.documentVbs) >= float(self.termValue) ):
                  self.setOutputList(['url'])
                  self.outputValues()
            elif ( self.searchTerm == 'lascore-minimum' ):
               if ( float(self.documentLas) >= float(self.termValue) ):
                  self.setOutputList(['url'])
                  self.outputValues()
            elif ( self.searchTerm == 'get-a-url' ):
               if ( self.documentCount == int(self.termValue) ):
                  self.setOutputList(['url'])
                  self.outputValues()
                  raise
            elif ( self.searchTerm == 'url-by-language' ):
               if ( self.contentLang == self.termValue ):
                  self.setOutputList(['url'])
                  self.outputValues()
            elif ( self.searchTerm == 'language' ):
               if ( self.contentLang != "" ):
                  self.setOutputList(['language'])
                  self.outputValues()
            elif ( self.searchTerm == 'filetype' ):
               if ( self.contentType != "" ):
                  self.setOutputList(['type'])
                  self.outputValues()
            elif ( self.searchTerm == 'filesize' ):
               if ( self.contentSize != "" ):
                  self.setOutputList(['size'])
                  self.outputValues()
            elif ( self.searchTerm == 'title' ):
               if ( self.contentTitle != "" ):
                  self.setOutputList(['title'])
                  self.outputValues()

            self.initContentItem()

         if ( name == 'scope' or name == 'list' ):
            if ( self.searchTerm == 'match-count' ):
               self.setOutputList(['match-count'])
               self.outputValues()
               raise
            elif ( self.searchTerm == 'document-count' ):
               self.setOutputList(['document-count'])
               self.outputValues()
               raise

         if ( name == 'attribute' or name == 'added-source' ):
            if ( self.searchTerm == 'url-count' ):
               if ( self.totalUrls != None ):
                  self.setOutputList(['url-count'])
                  self.outputValues()
                  raise
         





if __name__ == "__main__":
   parser = make_parser()   
   curHandler = DocumentHandler(searchTerm="match-url", termValue="file:///testenv/test_data/law/F3/467/467.F3d.1355.06-1064.html")
   parser.setContentHandler(curHandler)
   parser.parse(open('querywork/qry.Plaintiff.xml.rslt'))
