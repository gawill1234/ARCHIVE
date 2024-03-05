#!/usr/bin/python

import sys, os, random, time


class queryData:


   def __init__(self, query_file):

      self.__current_seq = 1
      self.__current_conn = 1

      self.__query = 0
      self.__collection = 1
      self.__rslt_cnt = 2
      self.__fname = 3
      self.__otheropts = 4

      self.__current_query_number = 0

      self.__full_query_list = self.query_list_reader(query_file)
      self.__list_len = len(self.__full_query_list)

      return

   def next_query(self):
   
      self.__current_query_number += 1

      return

   def get_current_query(self):

      try:
         if ( self.__current_query_number < self.__list_len ):
            return self.__full_query_list[self.__current_query_number][self.__query]
         else:
            return None
      except:
         return None

   def get_current_otheropts(self):

      try:
         if ( self.__current_query_number < self.__list_len ):
            return self.__full_query_list[self.__current_query_number][self.__otheropts]
         else:
            return None
      except:
         return None

   def get_current_query_collection(self):

      try:
         if ( self.__current_query_number < self.__list_len ):
            return self.__full_query_list[self.__current_query_number][self.__collection]
         else:
            return None
      except:
         return None

   def get_current_query_result_count(self):

      try:
         if ( self.__current_query_number < self.__list_len ):
            return self.__full_query_list[self.__current_query_number][self.__rslt_cnt]
         else:
            return None
      except:
         return None

   def get_current_query_file(self):

      try:
         if ( self.__current_query_number < self.__list_len ):
            return self.__full_query_list[self.__current_query_number][self.__fname]
         else:
            return None
      except:
         return None


   def get_full_query_list(self):

      return self.__full_query_list

   def dump_current_query(self):

      print "   CURRENT QUERY DATA"
      print "   =================="
      print "   QUERY:                ", self.get_current_query()
      print "   COLLECTION:           ", self.get_current_query_collection()
      print "   EXPECTED RESULT COUNT:", self.get_current_query_result_count()
      print "   RESULT FILE:          ", self.get_current_query_file()
      print "   OTHER OPTIONS:        ", self.get_current_otheropts()
      print "   =================="
      print ""

      return


   def get_current_query_data(self):

      if ( self.__current_query_number < self.__list_len ):
         return self.__full_query_list[self.__current_query_number]
      else:
         return []

   def query_list_reader(self, query_file):
   
      f = open(query_file)

      tmplist = []

      for item in f.readlines():
         if ( item[0] != '#' ):
            item = item.strip('\n')
            item = item.split('::')
            tmplist.append(item)

      f.close()

      return tmplist

if __name__ == "__main__":

   thingy = queryData('queries')

   #print thingy.get_full_term_list()

   while ( thingy.get_current_query() is not None ):
      thingy.dump_current_query()
      thingy.next_query()

   sys.exit(0)
