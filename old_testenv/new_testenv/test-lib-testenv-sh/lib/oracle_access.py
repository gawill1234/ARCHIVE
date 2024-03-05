#!/usr/bin/python

import cx_Oracle
import os

class DB_ORACLE(object):

   db_cnxn_string = None
   cnxn = None
   cursor = None
   exec_holder = None
   current_sql = None

   def __init__(self, user, pw, host="testbed6-4.test.vivisimo.com",
                      port="1521", sid="orcl"):

      self.db_cnxn_string = user + "/" + pw + "@" + host + ":" + port + "/" + sid
      try:
         self.cnxn = cx_Oracle.connect(self.db_cnxn_string)
      except:
         print "Connection failed for:", self.db_cnxn_string

      self.cursor = self.cnxn.cursor()

      return

   def do_db_commit(self):

      self.cnxn.commit()
      return

   def do_db_sql(self, sql_string=None):

      if ( sql_string == None ):
         print "No sql specified."
         return

      self.current_sql = sql_string

      print self.current_sql

      return(self.cursor.execute(self.current_sql))


   def get_one_query_row(self):
   
      return self.exec_holder.fetchone()

   def get_all_query_rows(self):
   
      return self.exec_holder.fetchall()

   def do_db_query(self, query_string=None):

      if ( query_string == None ):
         print "No query specified.  Query needed to do a query."
         return

      self.exec_holder = self.do_db_sql(sql_string=query_string)

      return

   def do_db_insert(self, insert_string=None):

      if ( insert_string == None ):
         print "No insert specified.  Insert needed to do an insert."
         return

      self.do_db_sql(sql_string=insert_string)
      self.do_db_commit()

      return

   def do_db_delete(self, delete_string=None):

      if ( delete_string == None ):
         print "No delete specified.  Delete needed to do a delete."
         return

      self.do_db_sql(sql_string=delete_string)
      self.do_db_commit()

      return

class SQL_STMT(object):

   insert_stmt = None
   select_stmt = None
   delete_stmt = None
   update_stmt = None
   field_data = {}
   column_names = []
   table = None
   id_column = None

   def __init__(self, tbl=None, id_column=None):

      self.table = tbl
      self.field_data = {}
      self.column_names = []
      self.id_column = id_column

      return

   def get_raw_sql(self, statement_type="select"):

      if ( statement_type == "update" ):
         return(self.update_stmt)
      elif ( statement_type == "insert" ):
         return(self.insert_stmt)
      elif ( statement_type == "delete" ):
         return(self.delete_stmt)
      elif ( statement_type == "select" ):
         return(self.select_stmt)
      else:
         return(None)


   def set_raw_sql(self, sql_string=None, statement_type="select"):

      if ( sql_string == None ):
         print "No sql specified."
         return

      if ( statement_type == "update" ):
         self.update_stmt = sql_string
      elif ( statement_type == "insert" ):
         self.insert_stmt = sql_string
      elif ( statement_type == "delete" ):
         self.delete_stmt = sql_string
      else:
         self.select_stmt = sql_string

      return sql_string


   def count_table_rows(self):

      count_string = "select count(*) from " + self.table

      self.select_stmt = count_string
      
      return count_string

   def does_it_exist(self, colval=None, colname=None):

      query_string = "select " + colname + " from " + self.table \
                      + " where " + colname + " = \'" + colval + "\'"

      self.select_stmt = query_string
      
      return query_string

   def get_max_id(self):

      max_string = "select max(" + self.id_column + ") from " + self.table

      self.select_stmt = max_string
      
      return max_string


   def sql_select_string(self, column_name=None):

      self.column_names.append(column_name)

      return


   def build_select_sql(self):

      field_count = len(self.column_names)

      if ( field_count == 0 ):
         col_string = "*"
      else:
         wcnt = 1
         col_string = "("
         for item in self.column_names:
            col_string = col_string + item
            if ( wcnt < field_count ):
               col_string = col_string + ", "
            wcnt += 1
         col_string = col_string + ")"

      select_string = "select " + col_string
      select_string = select_string + " from " + self.table

      self.select_stmt = select_string

      return select_string


   def sql_insert_string(self, this_string=None, column_name=None):

      self.column_names.append(column_name)
      self.field_data[column_name] = "\'" + this_string + "\'"

      #print self.field_data[column_name]

      return

   def sql_insert_structured(self, this_string=None, data_type="XMLType",
                                column_name=None):

      self.column_names.append(column_name)
      this_string = this_string.replace('\n', '')

      if ( data_type == "XMLType" ):
         self.field_data[column_name] = "XMLType(\'" + this_string + "\')"
      else:
         self.field_data[column_name] = "\'" + this_string + "\'"

      #print self.field_data[column_name]

      return

   def sql_insert_by_bfilename(self, filename=None, data_type="XMLType",
                               column_name=None, ora_directory=None):

      self.column_names.append(column_name)
      filename = filename.replace('\n', '')

      bfilestring = "bfilename(\'" + ora_directory + "\', \'" + filename + "\')"
      nci = "nls_charset_id(\'AL32UTF8\')"

      fullString = bfilestring + "," + nci

      if ( data_type == "XMLType" ):
         self.field_data[column_name] = "XMLType(" + fullString + ")"
      else:
         self.field_data[column_name] = "\'" + fullString + "\'"

      #print self.field_data[column_name]

      return


   def sql_insert_number(self, this_number=None, column_name=None):

      self.column_names.append(column_name)
      self.field_data[column_name] = '%s' % this_number

      #print self.field_data[column_name]

      return


   def file_read(self, file_name=None, data_type="XMLType", column_name=None):

      if os.access(file_name, os.R_OK) == 1:
         datasize = os.stat(file_name).st_size
         fd = file(file_name, 'rb', datasize)
         file_data = fd.read()
         fd.close()

      self.column_names.append(column_name)
      if ( data_type == "XMLType" ):
         self.field_data[column_name] = "XMLType(\'" + file_data + "\')"
      else:
         self.field_data[column_name] = "\'" + file_data + "\'"

      #print self.field_data[column_name]

      return


   def build_insert_sql(self):

      field_count = len(self.column_names)

      wcnt = 1
      print ":", self.column_names, ":", len(self.column_names)
      col_string = ''
      if ( len(self.column_names) > 0 ):
         col_string = "("
         for item in self.column_names:
            if ( item is not None ):
               col_string = col_string + item
               if ( wcnt < field_count ):
                  col_string = col_string + ", "
            wcnt += 1
         col_string = col_string + ")"
         if ( col_string == '()' ):
            col_string = ''

      wcnt = 1
      val_string = "("
      for item in self.column_names:
         val_string = val_string + self.field_data[item]
         if ( wcnt < field_count ):
            val_string = val_string + ", "
         wcnt += 1
      val_string = val_string + ")"

      insert_string = "insert into " +  self.table
      insert_string = insert_string + " " + col_string
      insert_string = insert_string + " values"
      insert_string = insert_string + " " + val_string

      self.insert_stmt = insert_string

      return insert_string


def file_tests():

   other_query = "select case_id, e.case_xml.getStringVal() from test_xml_column_table e"

   burble = SQL_STMT(tbl="test_xml_column_table")


   burble.sql_insert_number(this_number=999999, column_name="case_id")
   burble.sql_insert_string(this_string="vxml", column_name="case_selector")
   burble.sql_insert_string(this_string="file thingy2.vxml", column_name="case_description")
   burble.file_read(file_name="thingy2.vxml", column_name="case_xml")

   mystring = burble.build_insert_sql()

   print mystring
   thing = DB_ORACLE(user="gaw", pw="mustang5")

   thing.do_db_insert(insert_string=mystring)
   thing.do_db_query(query_string=other_query)
   row = thing.get_one_query_row()
   while ( row != None ):
      for item in row:
         print item
      row = thing.get_one_query_row()

   cnt_string = burble.count_table_rows()
   thing.do_db_query(query_string=cnt_string)
   print thing.get_one_query_row()[0]

   return


def db_tests():

   #
   #   Test queries/inserts/deletes
   #
   my_query = "select * from vessel_view"
   other_query = "select e.case_xml.getCLOBVal() from test_xml_column_table e"
   delete_sql = "delete from test_xml_column_table where case_id = 999999"

   insert_sql = "insert into test_xml_column_table \
values(999999, \'vxml\', \'small vxml node\', XMLType(\'\
<vce>\
<document url=\"http://vivisimo.com?alpha\">\
<content name=\"text\">abcdefghijklmnopqrstuvwxyz</content>\
<content name=\"empty1\"/>\
<content name=\"type\">lower case alphabet</content>\
<content name=\"empty2\"/>\
</document>\
</vce>\
\'))"

   #
   #   End test data set up
   #

   #
   #   Test initialization
   #
   c1 = c2 = c3 = c4 = 0
   thing = DB_ORACLE(user="gaw", pw="mustang5")

   #
   #   Begin test execution
   #
   thing.do_db_query(query_string=my_query)
   row = thing.get_one_query_row()
   while ( row != None ):
      print row[0]
      row = thing.get_one_query_row()
      c1 += 1

   print "==========================="

   thing.do_db_query(query_string=my_query)
   rows = thing.get_all_query_rows()
   for row in rows:
      print row[0], row[3], row[1]
      c2 += 1

   print "==========================="

   thing.do_db_insert(insert_string=insert_sql)
   thing.do_db_query(query_string=other_query)
   row = thing.get_one_query_row()
   while ( row != None ):
      print row[0]
      row = thing.get_one_query_row()
      c3 += 1
 
   print "==========================="

   thing.do_db_delete(delete_string=delete_sql)
   thing.do_db_query(query_string=other_query)
   row = thing.get_one_query_row()
   while ( row != None ):
      print row[0]
      row = thing.get_one_query_row()
      c4 += 1

   print "==========================="

   print "???????????????????????????"

   if ( c1 != 359 ):
      print "First query failed"
   else:
      print "First query passed"

   print "???????????????????????????"

   if ( c2 != 359 ):
      print "Second  query failed"
   else:
      print "Second query passed"

   print "???????????????????????????"

   if ( c3 != 3 ):
      print "Third  query failed"
   else:
      print "Third query passed"

   print "???????????????????????????"

   if ( c4 != 2 ):
      print "Fourth  query failed"
   else:
      print "Fourth query passed"

   print "???????????????????????????"

   return

class DB_TABLE_ACTIONS(object):

   db_access = None
   table = None
   table_id = None

   def __init__(self, dbaccess=None, tbl=None, id_column=None):

      self.db_access = dbaccess
      self.table = tbl
      self.table_id = id_column

      return

   def get_table_name(self):

      return self.table

   def get_table_id(self):

      return self.table_id

   def get_table_max_id(self):

      burble = None
      indb = self.db_access

      burble = SQL_STMT(tbl=self.table,
                                      id_column=self.table_id)
      mystring = burble.get_max_id()

      indb.do_db_query(query_string=mystring)
      stickleback = indb.get_one_query_row()

      if ( stickleback is not None ):
         if ( len(stickleback) > 0 ):
            print "MAX:", stickleback[0]
            return stickleback[0]

      print "MAX:  None"
      return None


   def value_is_in_column(self, column=None, value=None):

      burble = None
      indb = self.db_access

      burble = SQL_STMT(tbl=self.table)
      mystring = burble.does_it_exist(colname=column, colval=value)

      indb.do_db_query(query_string=mystring)
      stickleback = indb.get_one_query_row()

      if ( stickleback is not None ):
         if ( len(stickleback) > 0 ):
            my_col_val = stickleback[0]
            print my_col_val
            if ( stickleback[0] == value ):
               print "exists"
               return 1

      print "does not exist"
      return 0

   def execute_sql(self, sql_string=None):

      burble = None
      indb = self.db_access

      print sql_string

      indb.do_db_sql(sql_string=sql_string)
      indb.do_db_commit()

      return


if __name__ == "__main__":

   #db_tests()
   file_tests()
