#!/usr/bin/python


import random
import time
import os
import termsetup
import getopt

class GenDoc:
   """
   This class generates documents.  Each document will be
   within a few bytes of a specified size.  There will be a 
   specified number of documents in a specified directory.
   
   parameters:
      doc_size -- the approximate size of the generated docs.
                  default is 1024 bytes (chars)
      doc_cnt  -- the number of documents to generate.
                  default is 100 documents.
      word_file -- the name of the file from which to get the
                   words to be put into each of the files.
                   default is '$TEST_ROOT/lib/words'
      term_file -- a file containing specific terms for a specific
                   number of files.
                   default is 'terms'
                  see 'termsetup.py' file of terms file format.
      dumpdir --  the place to put all of the generated files.
                  default is 'enqueue_data'
   """

   def __init__(self, doc_size=1024, doc_cnt=100, word_file=None,
                dumpdir=None, term_file=None, dovxml=None, simplefi=None):

      troot = os.getenv('TEST_ROOT', '.')

      self.__rand = random.Random(time.time())

      #
      #   The location of the file used to get words to build
      #   file content.
      #
      self.__word_file = word_file
      if ( self.__word_file is None ):
         if ( troot != '.' ):
            self.__word_file = troot + '/lib/' + 'words'
         else:
            self.__word_file = 'words'

      #
      #   The location of the file used to get terms to build
      #   file content.  These items will turn up in exactly X
      #   documents a specified number of times.
      #
      self.__term_file = term_file

      #
      #   The directory where the files should be put.
      #
      self.__data_dir = dumpdir
      if ( self.__data_dir is None ):
         self.__data_dir = 'enqueue_data'

      f = open(self.__word_file)

      self.__word_list = [word.strip() for word in f.readlines()]
      self.__list_len = len(self.__word_list)
      self.__doc_len = doc_size
      self.__doc_count = doc_cnt
      self.__file_pfx = ''
      self.tinject = None
      self.__findex_str = ''

      #
      #   Set the option to build the content to a random size
      #
      if ( self.__doc_len == -1 ):
         self.__random_len = True
      else:
         self.__random_len = False

      #
      #   Set the option to build the content as vxml
      #
      self.__vxml = dovxml
      if ( self.__vxml == None ):
         self.__vxml = False
      if ( self.__vxml != False ):
         self.__vxml = True

      #
      #   Set the option to build the content with fast indexes
      #
      self.__findex = simplefi
      if ( self.__findex == None ):
         self.__findex = False
      if ( self.__findex != False ):
         self.__findex = True

      if ( self.__term_file is not None ):
         if ( os.access(self.__term_file, os.R_OK) == 1 ):
            self.tinject = termsetup.termsInject(self.__term_file, 't')
            if ( self.__findex ):
               print "build findex class"
               self.fast_index = termsetup.termsInject(self.__term_file, 'i')
         else:
            print "Specified term file not found: ", self.__term_file
            print "Exiting"
            sys.exit(1)

      #print self.__cur_list

      self.__file_count = 0

      try:
         os.mkdir(self.__data_dir)
      except:
         print "mkdir failed, assuming directory exists"
 
      return

   #
   #   Pseudo-random way of creating a term for the content.
   #   Do not want it all to be the same and would like similar
   #   terms to be seperated from each other.
   #
   def term_odds(self, totlen, thissize):

      if ( self.tinject is None ):
         return 0

      occsleft = self.tinject.get_list_max_perdoc()
      if ( occsleft <= 0 ):
         return 0

      ratio = float(totlen) / float(thissize)
      if ( ratio > .9 ):
         return 1
  
      randy = self.__rand.randint(0, thissize)
      
      r1 = float(self.__doc_len) * 0.4
      r2 = float(self.__doc_len) * 0.99

      #print randy, r1, r2
      if ( totlen == 0 ):
         if ( float(randy) > r1 ):
            return 1
      else:
         if ( float(randy) > r2 ):
            return 1

      return 0

   #
   #   Generate a random size to create a file with.
   #
   def gen_file_size(self):

      fsize = 0
      smlsize = [0, 2048]
      medsize = [2048, 8192]
      lrgsize = [8192, 16384]
      xlrgsize = [16384, 131072]
      allsizes = [smlsize, medsize, lrgsize, xlrgsize]

      randy = self.__rand.randint(0, 100)

      if ( randy < 80 ):
         selector = 0
      elif ( randy < 95 ):
         selector = 1
      elif ( randy < 99 ):
         selector = 2
      else:
         selector = 3

      fsize = self.__rand.randint(allsizes[selector][0], allsizes[selector][1])

      return fsize


   #
   #   Create the newt word string to go into a document.
   #
   def get_doc_word(self, totlen, thissize):

      if ( ( self.term_odds(totlen, thissize) ) and
           ( self.tinject is not None ) ):
         myword = self.tinject.term_builder()
      else:
         myword = self.__word_list[self.__rand.randint(0, self.__list_len - 1)]

      return myword

   #
   #   Create the content for a document
   #
   def gen_doc(self):

      mydoc = ''

      totlen = 0

      if ( self.__random_len is True ):
         indoc_len = self.gen_file_size()
      else:
         indoc_len = self.__doc_len

      if ( self.tinject is not None ):
         self.__cur_list = self.tinject.get_current_list()

      #print "NEW LEN:", self.__doc_len

      while ( totlen < indoc_len ):
         myword = self.get_doc_word(totlen, indoc_len)
         totlen = totlen + len(myword) + 1
         if ( myword != '' ):
            if ( mydoc == '' ):
               mydoc = myword
            else:
               if ( (len(mydoc) % 85) < 8 ):
                  mydoc = mydoc + '\n'
                  mydoc = mydoc + myword
               else:
                  mydoc = mydoc + ' ' + myword

      return mydoc

   #
   #   Dump the content to a file.
   #
   def do_file_output(self, mine):

      myword = self.__word_list[self.__rand.randint(0, self.__list_len - 1)]
      file_name = ''.join([self.__data_dir, '/', myword, '.', "%s" % self.__file_count])
      self.__file_count += 1

      ofd = open(file_name, 'w')
      if ( self.__vxml ):
         #ofd.write("<vce>\n")
         docstring = ''.join(['<document name="', file_name, '">\n'])
         ofd.write(docstring)
         if ( self.__findex ):
            myfilist = self.fast_index.get_current_list()
            if ( not self.fast_index.get_terms_done_state() ):
               self.__findex_str = self.fast_index.term_builder()
               if ( self.__findex_str != '' and self.__findex_str is not None ):
                  ofd.write(self.__findex_str)
               self.__findex_str = ''
         ofd.write("   <content name=\"snippet\">\n")
      ofd.write(mine)
      if ( self.__vxml ):
         ofd.write("\n      </content>\n")
         ofd.write("</document>\n")
         #ofd.write("</vce>\n")
      ofd.close()

   #
   #   Create the documents to be generated based on the initialization
   #   parameters.
   #
   def do_all_docs(self):

      doc_cnt = 0
 
      while ( doc_cnt < self.__doc_count ):
         mine = self.gen_doc()
         doc_cnt += 1
         self.do_file_output(mine)

      return

if __name__ == "__main__":

    import sys
    # Defaults
    doc_count = 10000
    doc_length = 10240

    word_file = None
    dump_dir = None
    term_file = None
    usevxml = False
    dofastindex = False

    opts, args = getopt.getopt(sys.argv[1:], "D:W:T:c:s:vf", ["datadir=", "wordfile=", "termfile=", "filesize=", "filecount=", "vxml", "findex"])

    for o, a in opts:
       if o in ("-W", "--wordfile"):
          word_file = a
       if o in ("-T", "--termfile"):
          term_file = a
       if o in ("-s", "--filesize"):
          try:
             doc_length = int(a)
          except:
             doc_length = -1
       if o in ("-c", "--filecount"):
          doc_count = int(a)
       if o in ("-D", "--datadir"):
          dump_dir = a
       if o in ("-v", "--vxml"):
          usevxml = True
       if o in ("-f", "--findex"):
          dofastindex = True

    doit = GenDoc(doc_size=doc_length, doc_cnt=doc_count,
                  word_file=word_file, term_file=term_file,
                  dumpdir=dump_dir, dovxml=usevxml, simplefi=dofastindex)

    mine = doit.do_all_docs()

    sys.exit(0)

