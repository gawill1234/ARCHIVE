#!/usr/bin/python

import sys, os, random, time
import oracle_access, dbRecord
import file_interface

def get_my_data(filename=None):

   thingy = dbRecord.dbRecord(filename)

   return thingy

def do_inserts(thingy=None):

   burble = None
   indb = oracle_access.DB_ORACLE(user="gaw", pw="mustang5")

   dada = thingy.get_current_record_keys()
   while ( dada is not None ):
      for item in dada:
         a, b, c, d = thingy.get_record_data(keyval=item)
         #print a, ":", b, ":", c, ":", d
         if ( a == "insert" ):
            burble = oracle_access.SQL_STMT(tbl=c)
         else:
            if ( b == "number" ):
               burble.sql_insert_number(this_number=d, column_name=a)
            elif ( b == "char" ):
               burble.sql_insert_string(this_string=d, column_name=a)
            else:
               burble.sql_insert_structured(this_string=d, column_name=a)
      print ""
      mystring = burble.build_insert_sql()
      print mystring
      indb.do_db_insert(insert_string=mystring)
      thingy.next_record()
      dada = thingy.get_current_record_keys()

def build_the_file(tbl_acts=None, collection=None,
                   directory=None, filename=None, use_id=0):

#
#   Create a single XML file that looks like this from a collection
#   XML file.
#
#      <collection collection_id="<id>">
#         <collection_name>samba-1</collection_name>
#         <collection_description>
#            Collection XML for collection samba-1
#         </collection_description>
#         <collection_xml>
#            (my collection data)
#         </collection_xml>
#      </collection>
#

   fullfile = directory + '/' + filename
   targetfile = directory + '_tmp/' + filename
   infd = open(fullfile, 'r')
   outfd = open(targetfile, 'w')

   desc_string = "Collection XML for collection " + collection

   header = '<collection collection_id="' + '%s' % use_id + '">\n'
   name = '   <collection_name>' + collection + '</collection_name>\n'
   desc = '   <collection_description>\n      ' + desc_string + '\n   </collection_description>\n'
   body_header = '   <collection_xml>\n'
   trailer = '   </collection_xml>\n</collection>'

   outfd.write(header)
   outfd.write(name)
   outfd.write(desc)
   outfd.write(body_header)
   for item in infd.readlines():
      if ( item[:5] != '<?xml' ):
         outfd.write(item)
   outfd.write(trailer)

   infd.close()
   #
   #  Doing this across NFS so have to flush to make sure it gets to the
   #  other side before something else (like a database) tries to read it.
   #
   outfd.flush()
   os.fsync(outfd.fileno())
   outfd.close()

   return

def do_the_collection_table_sql(tbl_acts=None, collection=None,
                                filename=None):

   burble = oracle_access.SQL_STMT(tbl=tbl_acts.get_table_name())
   burble.sql_insert_by_bfilename(filename=filename, column_name=None,
                                  ora_directory='COLLECTIONXMLTMP')
   burble.build_insert_sql()
   mystring = burble.get_raw_sql(statement_type="insert")
 
   tbl_acts.execute_sql(sql_string=mystring)

   return

def do_the_collection_column_sql(tbl_acts=None, collection=None,
                          filename=None, use_id=0):

   desc_string = "Collection XML for collection " + collection
   burble = oracle_access.SQL_STMT(tbl=tbl_acts.get_table_name(),
                                   id_column=tbl_acts.get_table_id())
   burble.sql_insert_number(this_number=use_id, column_name=tbl_acts.get_table_id())
   burble.sql_insert_string(this_string=collection, column_name='collection_name')
   burble.sql_insert_string(this_string=desc_string, column_name='collection_description')
   burble.sql_insert_by_bfilename(filename=filename, column_name='collection_xml',
                                  ora_directory='XMLCOLLECTIONDIR')
   burble.build_insert_sql()
   mystring = burble.get_raw_sql(statement_type="insert")
 
   tbl_acts.execute_sql(sql_string=mystring)

   return

def load_collection_table_data_from_directory(tbl_acts=None, dirname=None, 
                                               do_duplicate=0):

   burp = file_interface.FILEINTERFACE()
   file_list = burp.get_directory_file_list(dirname=dirname)

   #use_id = tbl_acts.get_table_max_id()
   use_id = 3000
   use_id += 1
      
   for item in file_list:
      if ( len(item) > 1 ):
         collection = burp.collection_from_filename(filename=item[1])
         build_the_file(tbl_acts=tbl_acts, collection=collection,
                        directory=item[0], filename=item[1], use_id=use_id)
         do_the_collection_table_sql(tbl_acts=tbl_acts, collection=collection,
                               filename=item[1])
         use_id += 1

         if ( do_duplicate != 0 ):
            collection = collection + '-dup'
            build_the_file(tbl_acts=tbl_acts, collection=collection,
                           directory=item[0], filename=item[1], use_id=use_id)
            print "Adding duplicate:", collection
            do_the_collection_table_sql(tbl_acts=tbl_acts, collection=collection,
                                  filename=item[1])
            use_id += 1
         print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

   return


def load_collection_column_data_from_directory(tbl_acts=None, dirname=None, 
                                               do_duplicate=0):

   burp = file_interface.FILEINTERFACE()
   file_list = burp.get_directory_file_list(dirname=dirname)

   use_id = tbl_acts.get_table_max_id()
   use_id += 1
      
   for item in file_list:
      if ( len(item) > 1 ):
         collection = burp.collection_from_filename(filename=item[1])
         if ( tbl_acts.value_is_in_column(column='collection_name',
                                          value=collection) == 0 ):
            do_the_collection_column_sql(tbl_acts=tbl_acts, collection=collection,
                                  filename=item[1], use_id=use_id)
            use_id += 1

         if ( do_duplicate != 0 ):
            collection = collection + '-dup'
            if ( tbl_acts.value_is_in_column(column='collection_name',
                                             value=collection) == 0 ):
               print "Adding duplicate:", collection
               do_the_collection_column_sql(tbl_acts=tbl_acts, collection=collection,
                                     filename=item[1], use_id=use_id)
               use_id += 1

   return


if __name__ == "__main__":

   #thingy = get_my_data(filename="moreData")
   #do_inserts(thingy=thingy)


   dirname = '/testenv/test_data/dbdata/xmlType/collection_xml'

   ###################
   indb = oracle_access.DB_ORACLE(user="gaw", pw="mustang5")
   #flipper = oracle_access.DB_TABLE_ACTIONS(dbaccess=indb,
   #                                         tbl='collection_xml_column_table',
   #                                         id_column='collection_id')
   #load_collection_column_data_from_directory(tbl_acts=flipper,
   #                                           dirname=dirname,
   #                                           do_duplicate=1)
   flipper2 = oracle_access.DB_TABLE_ACTIONS(dbaccess=indb,
                                             tbl='collection_xml_table')
   load_collection_table_data_from_directory(tbl_acts=flipper2,
                                             dirname=dirname,
                                             do_duplicate=1)

   sys.exit(0)
