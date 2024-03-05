#!/usr/bin/python

import sys, os, random, time


class termsInject:

   """
   This takes data from a file and uses it to create terms to be
   injected into a file.
   parameters:

      term_file -- the file from which to get the data.  There is
                   no default.

   term_file format:
      a :: b :: c :: d :: e :: f :: g :: h
      1::t::na::1::una mujerzuela::10::2::6::-::2
      2::t::na::1::depravada::20::2::6::+::1
      3::t::na::2::scheisskopf::20::2::6
      4::t::na::3::schweinbumser::50::2::6
      5::t::na::4::alpha bravo foxtrot::10::1::9
      6::t::na::5::foxtrot uniform charlie kilo::30::1::9
      7::t::na::6::sierra hotel india tango::10::1::9
      8::t::na::5::yankee oscar uniform::30::1::9
      9::t::na::7::whiskey tango foxtrot::10::1::9
      10::t::na::8::mangez la merde::25::2::2
      11::i::motherf::1::fuck this::4::1::1::+::1
      12::i::quicksilver::1::mercury::5::1::1::+::1
      13::i::chumbucket::9::plankton::5::1::1::+::1
      14::i::crustycrab::10::mrcrabs::5::1::1::+::1
      15::i::na::2::None::20::1::1::+::1
      16::i::na::3::None::50::1::1::+::1
      17::i::na::4::None::10::1::1::+::1
      18::i::na::5::None::30::1::1::+::1
      19::i::na::6::None::10::1::1::+::1
      20::i::na::7::None::10::1::1::+::1
      21::i::na::8::None::25::1::1::+::1

      a = sequence number.  a unique row id.  sequential is probably best
          but is not necessary.
      b = element type ('t' = term, 'i' = fast index)
      c = fast index name (only if 'i' is used, otherwise enter 'na')
      d = set identifier.  The term is part of a set.  Any rows which
          have a matching set id will be used together in a document.
      e = term.  the term to be injected.
      f = number of docs.  the number of documents the term can appear in.
      g = minimum number.  the minimum number of times the term will appear
          in a doc.
      h = maximum number.  the maximum number of times the term will appear
          in a doc.

      the real number of time a term will appear in a doc is some random
      number between min and max.  If you want a set number, make min
      and max identical.

      Right now, the recommended approach to using the terms file is to
      use a language that is not the language of the random words being
      used to create the documents.  So, if you are creating random
      english docs, make the injected terms foreign words with english
      style spelling.
   """

   def __init__(self, term_file, type=None):

      self.__current_seq = 1
      self.__current_conn = 1

      self.__seq = 0
      self.__type = 1
      self.__finame = 2
      self.__connect = 3
      self.__term = 4
      self.__docs = 5
      self.__minperdoc = 6
      self.__maxperdoc = 7
      self.__precedence = 8
      self.__usewith = 9
      self.__value_in_doc = 10
      self.__curperdoc = 11

      self.__done = True
      self.__terms_complete = False
      self.__idx_complete = False

      self.__random_go = random.Random(time.time())

      self.__current_term_list = []

      self.__match_type = 't'

      if ( type is not None ):
         self.__match_type = type

      self.__full_term_list = self.term_list_reader(term_file)

      return

   def get_full_term_list(self):

      return self.__full_term_list

   def fast_index_line(self, list_item):

      finame = list_item[self.__finame]
      if ( finame == 'na' or finame is None ):
         return None

      mystring = list_item[self.__term]

      myword = ''.join(['\n   <content name="', finame, '" fast-index="set" type="text">', mystring, '</content>\n'])

      return myword

   def term_builder(self):

      myterm = None
      zeroes = 0
      maxz = 0

      ttype = 'term'

      if ( self.__done ):
         self.build_current_list()

      maxz = len(self.__current_term_list)
      if ( maxz > 0 ):
         item = self.__current_term_list[0]
      else:
         return None

      for item in self.__current_term_list:
         if ( item[self.__value_in_doc] > 0 ):
            if ( self.__match_type == 'i' ):
               if ( myterm is None ):
                  myterm = self.fast_index_line(item)
               else:
                  myterm = myterm + ' ' + self.fast_index_line(item)
            else:
               if ( myterm is None ):
                  myterm = item[self.__term]
               else:
                  myterm = myterm + ' ' + item[self.__term]
            item[self.__value_in_doc] -= 1
            if ( item[self.__value_in_doc] <= 0 ):
               zeroes += 1
         else:
            zeroes += 1

      if ( zeroes >= maxz ):
         self.__done = True

      return myterm

   def build_current_list(self):

      self.__done = False
      stillmore = 0

      try:
         for item in self.__current_term_list:
            if ( item[self.__docs] > 0 ):
               self.doc_reset(item)
               item[self.__docs] -= 1
               stillmore = 1

         if ( stillmore == 0 ):
            self.__current_term_list = []
         else:
            return
      except:
         self.__current_term_list = []

      for item in self.__full_term_list:
         if ( item[self.__connect] == self.__current_conn ):
            item[self.__docs] -= 1
            self.__current_term_list.append(item)

      self.__current_conn += 1

      if ( self.__current_term_list == [] ):
         self.__terms_complete = self.is_it_done()
         self.__done = True

      return

   def is_it_done(self):

      self.__terms_complete = True

      for item in self.__full_term_list:
         if ( item[self.__docs] != 0 ):
            self.__terms_complete = False

      return self.__terms_complete

   def get_list_max_docs(self):

      mymax = 0

      for item in self.__current_term_list:
         if ( item[self.__docs] > mymax ):
            mymax = item[self.__docs]

      return mymax

   def get_list_max_perdoc(self):

      mymax = 0

      for item in self.__current_term_list:
         if ( item[self.__value_in_doc] > mymax ):
            mymax = item[self.__value_in_doc]

      return mymax

   def get_current_list(self):

      if ( self.__done ):
         self.build_current_list()

      return self.__current_term_list

   def get_list_done_state(self):

      return self.__done

   def get_terms_done_state(self):

      return self.__terms_complete

   def get_idx_done_state(self):

      return self.__idx_complete

   def doc_reset(self, thing_to_reset):

      #   item[self.__value_per_doc]
      thing_to_reset[self.__value_in_doc] = self.__random_go.randint(
                                            thing_to_reset[self.__minperdoc], 
                                            thing_to_reset[self.__maxperdoc])

      return

   def term_list_reader(self, term_file):

   
      f = open(term_file)

      tmplist = []

      for item in f.readlines():
         if ( item[0] != '#' ):
            item = item.strip('\n')
            item = item.split('::')
            if ( item[self.__type] == self.__match_type ):
               tmplist.append(item)

      #
      #   Take all of those number "strings" and turn them
      #   into integers.
      #
      for item in tmplist:
         try:
            item[self.__docs] =  int(item[self.__docs])
            item[self.__minperdoc] =  int(item[self.__minperdoc])
            item[self.__maxperdoc] =  int(item[self.__maxperdoc])
            item[self.__seq] =  int(item[self.__seq])
            item[self.__connect] =  int(item[self.__connect])

            try:
               if ( item[self.__precedence] != '+' ):
                  if ( item[self.__precedence] != '-' ):
                     item[self.__precedence] = 'na'
            except:
               item.append('na')

            #   item[self.__usewith]
            try:
               item[self.__usewith] = int(item[self.__usewith])
            except:
               item.append(0)

            #   item[self.__value_per_doc]
            item.append(self.__random_go.randint(
                               item[self.__minperdoc], 
                               item[self.__maxperdoc]))

            #   item[self.__curperdoc]
            item.append(0)

         except:
            print "not a number", item

      f.close()

      return tmplist

   def get_these_terms(self, file_max, file_current):

      return term_string

if __name__ == "__main__":

   thingy = termsInject('terms')

   #print thingy.get_full_term_list()


   cur_list = thingy.get_current_list()

   while ( not thingy.get_terms_done_state() ):
      mdocs = thingy.get_list_max_docs()
      pdocs = thingy.get_list_max_perdoc()
      terms = thingy.term_builder()
      print mdocs, pdocs, " : ", terms
      cur_list = thingy.get_current_list()

   sys.exit(0)
