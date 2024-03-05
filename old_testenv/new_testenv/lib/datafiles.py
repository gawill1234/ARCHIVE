#!/usr/bin/python

import os, sys, string

############################################

class DATAFILES(object):

   query = None
   type = None

   result = None
   compare = None
   difffile = None

   uri_result = None
   uri_compare = None
   uri_difffile = None

   bin_result = None
   bin_compare = None
   bin_difffile = None

   #########################################

   def __init__(self, thing, thingtype):

      if ( thingtype == "query" ):
         self.doqueryfiles(thing)

      if ( thingtype == "binning" ):
         self.dobinningfiles(thing)

      if ( thingtype == "metadata" ):
         self.dometadatafiles(thing)

      return

   def doqueryfiles(self, thing):

      pfx = "qry"
      xml = "xml"
      uri = "uri"
      cmp = "cmp"
      rslt = "rslt"
      dff = "diff"

      namer = thing.replace(' ', '+')
      namer = namer.replace(':', '..')

      self.query = thing
      self.type = "query"

      self.result = ''.join([pfx, '.', namer, '.', xml, '.', rslt])
      self.compare = ''.join([pfx, '.', namer, '.', xml, '.', cmp])
      self.difffile = ''.join([pfx, '.', namer, '.', xml, '.', dff])

      self.uri_result = ''.join([pfx, '.', namer, '.', uri, '.', rslt])
      self.uri_compare = ''.join([pfx, '.', namer, '.', uri, '.', cmp])
      self.uri_difffile = ''.join([pfx, '.', namer, '.', uri, '.', dff])

      return

   def dobinningfiles(self, thing):

      pfx = "bin"
      xml = "xml"
      uri = "uri"
      bins = "bins"
      cmp = "cmp"
      rslt = "rslt"
      dff = "diff"

      namer = thing.replace(':', '..')

      self.query = thing
      self.type = "binning"

      self.result = ''.join([pfx, '.', namer, '.', xml, '.', rslt])
      self.compare = ''.join([pfx, '.', namer, '.', xml, '.', cmp])
      self.difffile = ''.join([pfx, '.', namer, '.', xml, '.', dff])

      self.uri_result = ''.join([pfx, '.', namer, '.', uri, '.', rslt])
      self.uri_compare = ''.join([pfx, '.', namer, '.', uri, '.', cmp])
      self.uri_difffile = ''.join([pfx, '.', namer, '.', uri, '.', dff])

      self.bin_result = ''.join([pfx, '.', namer, '.', bins, '.', rslt])
      self.bin_compare = ''.join([pfx, '.', namer, '.', bins, '.', cmp])
      self.bin_difffile = ''.join([pfx, '.', namer, '.', bins, '.', dff])

      return

   def dometadatafiles(self, thing):

      pfx = "mtd"
      xml = "xml"
      uri = "uri"
      cmp = "cmp"
      rslt = "rslt"
      dff = "diff"

      namer = thing.replace(':', '..')

      self.query = thing
      self.type = "metadata"

      self.result = ''.join([pfx, '.', namer, '.', xml, '.', rslt])
      self.compare = ''.join([pfx, '.', namer, '.', xml, '.', cmp])
      self.difffile = ''.join([pfx, '.', namer, '.', xml, '.', dff])

      self.uri_result = ''.join([pfx, '.', namer, '.', uri, '.', rslt])
      self.uri_compare = ''.join([pfx, '.', namer, '.', uri, '.', cmp])
      self.uri_difffile = ''.join([pfx, '.', namer, '.', uri, '.', dff])

      return

   def getwanted(self, which, content):

      if ( content == "xml" ):
         if ( which == "compare" ):
            return self.compare
         
         if ( which == "result" ):
            return self.result

         if ( which == "diff" ):
            return self.difffile

      elif ( content == "bins" ):
         if ( which == "compare" ):
            return self.bin_compare
         
         if ( which == "result" ):
            return self.bin_result

         if ( which == "diff" ):
            return self.bin_difffile

      else:
         if ( which == "compare" ):
            return self.uri_compare
         
         if ( which == "result" ):
            return self.uri_result

         if ( which == "diff" ):
            return self.uri_difffile

      return None



if __name__ == "__main__":
   filet = DATAFILES("Arizona", "query")
   print filet.result
   print filet.compare
   filet = DATAFILES("Arizona+Battleship", "query")
   print filet.result
   print filet.compare
   filet = DATAFILES("Arizona Battleship", "query")
   print filet.result
   print filet.compare
   filet = DATAFILES("Arizona,Battleship", "query")
   print filet.result
   print filet.compare
   filet = DATAFILES("SHIP_TYPE:Battleship", "binning")
   print filet.result
   print filet.compare
   filet = DATAFILES("SHIP_TYPE:Battleship", "metadata")
   print filet.result
   print filet.compare

