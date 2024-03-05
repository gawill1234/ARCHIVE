#!/usr/bin/python

import sys, os, random, time


class dbRecord:

   record_list = []
   current_record = 0

   def __init__(self, query_file):

      self.__current_seq = 1
      self.__current_conn = 1

      self.__query = 0
      self.__collection = 1
      self.__rslt_cnt = 2
      self.__fname = 3
      self.__otheropts = 4

      self.__current_query_number = 0

      self.__full_record_list = self.record_list_reader(query_file)
      self.__list_len = len(self.__full_record_list)

      return


   def dump_current_query(self):

      print "   CURRENT RECORD DATA"
      print "   =================="
      print "   COLUMN:               ", self.get_column_name()
      print "   COLUMN VALUE:         ", self.get_column_value()
      print "   =================="
      print ""

      return


   def get_column_name(self):

      return

   def get_column_value(self):

      return

   def file_read(self, file_name=None):

      file_data = None

      if os.access(file_name, os.R_OK) == 1:
         datasize = os.stat(file_name).st_size
         fd = file(file_name, 'rb', datasize)
         file_data = fd.read()
         fd.close()

      return(file_data)

   def get_record_data(self, keyval=None):

      data = self.record_list[self.current_record][keyval]

      col_val = keyval.split(',')
      if ( len(col_val) == 3 ):
         return col_val[0], col_val[1], col_val[2], data
      else:
         return col_val[0], None, data

   def next_record(self):

      self.current_record += 1

      return
      

   def get_current_record_keys(self):

      spingle = None
      lstlen = len(self.record_list)

      if ( self.current_record < lstlen ):
         spingle = self.record_list[self.current_record].iterkeys()

      return spingle


   def record_list_reader(self, db_record_file):
   
      f = open(db_record_file)

      for item in f.readlines():
         if ( item[0] != '#' ):
            item = item.strip('\n')
            item = item.split('::')
            if ( item[0][:6] == "insert" ):
               column_name = []
               for thing in item:
                  terd = thing.split(',')
                  if ( terd[0] == "insert" ):
                     local_table = terd[1]
                  column_name.append(thing)
               field_count = len(column_name)
            else:
               column_value = {}
               blue = 0
               for thing in column_name:
                  column_value[thing + "," + local_table] = item[blue]
                  blue += 1
               self.record_list.append(column_value)

      f.close()

      for item in self.record_list:
         for thing in item.iterkeys():
            if ( item[thing][:4] == 'file' ):
               fname = item[thing].split('(')[1].split(')')[0]
               item[thing] = self.file_read(file_name=fname)

      #for item in self.record_list:
      #   for thing in item.iterkeys():
      #      print thing, ":", item[thing]
      #   print "\n"


      return column_name

if __name__ == "__main__":

   thingy = dbRecord('dbData')

   dada = thingy.get_current_record_keys()
   while ( dada is not None ):
      for item in dada:
         a, b, c, d = thingy.get_record_data(keyval=item)
         print a, ":", b, ":", c, ":", d
      print ""
      thingy.next_record()
      dada = thingy.get_current_record_keys()

   #print thingy.get_full_term_list()

   #while ( thingy.get_current_query() is not None ):
   #   thingy.dump_current_query()
   #   thingy.next_query()

   sys.exit(0)
