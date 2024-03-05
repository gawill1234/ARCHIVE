#!/usr/bin/python

import sys, os, random, time, getopt, shutil
import vapi_interface, cgi_interface

class Query:

   #
   #   Query object:
   #   Parameters:
   #      collection_name:  the collection or sources to query
   #      query:  The query to get data for.
   #      outfile:  Where to dump the data.
   #      otheroptions:  A string containing the other options
   #                     to be used in the query.  Can not yet
   #                     use 'node' type arguments.
   #      use_cb:  Use collection broker or not.  Default is not.
   #
   def __init__(self, collection_name=None, query=None,
                outfile=None, otheroptions=None, use_cb=False):

      self.set_the_collection(collection_name=collection_name)
      self.set_the_query(query=query)

      self.__query_increment = 0
      self.__query_dir = 'querywork'
      self.__compare_dir = 'query_cmp_files'
      self.__qsargs = {}

      self.__node_items = ['sort-xpaths', 'spelling-corrector-configuration',
                           'output-axl', 'collapse-sort-xpaths',
                           'binning-set', 'extra-xml', 'query-object',
                           'query-condition-object', 'syntax-field-mappings']

      self.__use_cb = use_cb

      self.__newtestsave = os.getenv('NEWTESTSAVE', "No")

      self.set_query_arguments(otheroptions=otheroptions)

      self.set_the_output_file(filename=outfile)
      self.set_the_compare_file(filename=outfile)

      self.__vapi = vapi_interface.VAPIINTERFACE()

      return

   def isInList(self, checkfor, thelist):

      for item in thelist:
         if ( item == checkfor ):
            return 1

      return 0

   def get_file_data(self, filetoread=None):

      if ( filetoread is None ):
         return ''

      fd = open(filetoread, 'r+')

      mydata = fd.read()

      fd.close()

      return mydata

   #
   #   Convert 'otheroptions' from a string of the form
   #    opt1=value1&opt2=value2&opt3=value3
   #   to the qsargs parameter form that python can use.
   #
   #   This is not a good way to handle 'node' arguments.
   #   Still have to find a good way of doing that.
   #   Handling node args this way will not work at all.
   #
   def set_other_opts(self, otheroptions=None):

      if ( otheroptions is not None ):
         commalist = otheroptions.split('&')

      for item in commalist:
         eqlist = item.split('=')
         if ( self.isInList(eqlist[0], self.__node_items) ):
            fdata = self.get_file_data(eqlist[1])
            self.__qsargs[eqlist[0]] = fdata
         else:
            eqlist[1] = eqlist[1].replace('<2eq>', '==')
            eqlist[1] = eqlist[1].replace('<eq>', '=')
            eqlist[1] = eqlist[1].replace('<cr>', '\n')
            eqlist[1] = eqlist[1].replace('<empty>', '')
            eqlist[1] = eqlist[1].replace('<sp>', ' ')
            eqlist[1] = eqlist[1].replace('<lt>', '<')
            eqlist[1] = eqlist[1].replace('<lteq>', '<=')
            eqlist[1] = eqlist[1].replace('<gt>', '>')
            eqlist[1] = eqlist[1].replace('<gteq>', '>=')
            eqlist[1] = eqlist[1].replace('<brkop>', '[')
            eqlist[1] = eqlist[1].replace('<brkcl>', ']')
            eqlist[1] = eqlist[1].replace('<fsl>', '/')
            eqlist[1] = eqlist[1].replace('<bsl>', '\\')
            eqlist[1] = eqlist[1].replace('<2amp>', '&&')
            eqlist[1] = eqlist[1].replace('<2bar>', '||')

            self.__qsargs[eqlist[0]] = eqlist[1]

      return

   #
   #   Set up the arguments to be used in the query.
   #
   def set_query_arguments(self, otheroptions=None):

      self.__qsargs['output-score'] = 'true'
      self.__qsargs['num'] = '1000000'

      if ( otheroptions is not None ):
         self.set_other_opts(otheroptions)

      if ( self.__collection is not None ):
         if ( self.__use_cb is not True ):
            self.__qsargs['sources'] = self.__collection
         else:
            self.__qsargs['collection'] = self.__collection

      if ( self.__query is not None ):
         self.__qsargs['query'] = self.__query

      return

   #
   #   Add a new query argument
   #
   def add_query_argument(self, argname=None, argvalue=None):

      if ( argname is not None ):
         if ( argvalue is not None ):
            self.__qsargs[argname] = argvalue

      return

   #
   #   Remove an existing query argument
   #
   def remove_query_argument(self, argname=None):

      if ( argname is not None ):
         self.__qsargs[argname] = None

      return

   #
   #   return the name of the query data output file
   #
   def get_query_file(self):

      #return self.__vapi.look_for_file(filename=self.__queryfile)
      return self.__queryfile

   #
   #   return the name of the query data compare file
   #
   def get_compare_file(self):

      return self.__compare_file

   #
   #   build the complete relative path of the output file.
   #
   def set_the_output_file(self, filename=None):

      if ( filename is None ):
         self.__queryfile = self.__query_dir + '/' + 'QueryFile.' + '%s' % self.__query_increment
         self.__query_increment += 1
         print "QUERY OUTPUT FILE SET TO DEFAULT: ", self.__queryfile
         return

      self.__queryfile = self.__query_dir + '/' + filename

      return

   #
   #   build the complete relative path of the compare file.
   #
   def set_the_compare_file(self, filename=None):

      if ( filename is None ):
         self.__compare_file = self.__compare_dir + '/' + 'QueryFile.' + '%s' % self.__query_increment + '.cmp'
         self.__query_increment += 1
         print "QUERY COMPARE FILE SET TO DEFAULT: ", self.__compare_file
         return

      self.__compare_file = self.__compare_dir + '/' + filename + '.cmp'

      return

   #
   #   Actually run the query through the api use query_search or
   #   collection_broker_search as indicated by use_cb.
   #   Dump the data to the query data output file.
   #
   def run_the_query(self):

      self.set_query_arguments(otheroptions=None)

      if ( self.__use_cb is not True ):
         self.__vapi.vapi.query_search(**self.__qsargs)
      else:
         self.__vapi.vapi.collection_broker_search(**self.__qsargs)

      self.__vapi.dumpdata(filename=self.__queryfile,
                           mydata=self.__vapi.vapi.data)

      if ( self.__newtestsave == 'Yes' ):
         try:
            os.mkdir(self.__compare_dir)
         except:
            print self.__compare_dir, "exists"
         print "COPYING FROM:", self.__queryfile
         print "        TO  :", self.__compare_file
         shutil.copy(self.__queryfile, self.__compare_file)

      return

   #
   #   Reset the name of the collection
   #
   def set_the_collection(self, collection_name=None):

      if ( collection_name is None ):
         self.__collection = None
         print "COLLECTION SET ERROR:  No collection specified"
         return

      self.__collection = collection_name

      return

   #
   #   Update the query.
   #
   def set_the_query(self, query=None):

      if ( query is None ):
         self.__query = None
         print "QUERY SET ERROR:  No query specified"
         return

      self.__query = query

      return


if __name__ == "__main__":

   collection = None
   query = None
   outfile = None

   opts, args = getopt.getopt(sys.argv[1:], "Q:F:C:", ["collection=", "file=", "query="])

   for o, a in opts:
      if o in ("-C", "--collection"):
         collection = a
      if o in ("-F", "--file"):
         outfile = a
      if o in ("-Q", "--query"):
         query = a

   otheropts = "sources=oracle-1&query=bismarck"

   thingy = Query(collection_name=collection, query=query,
                  outfile=outfile, otheroptions=otheropts)

   thingy.run_the_query()

   print thingy.get_query_file()

   sys.exit(0)

