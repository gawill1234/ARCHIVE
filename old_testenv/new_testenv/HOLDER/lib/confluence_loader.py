#!/usr/bin/python

import sys, os
from file_interface import FILEINTERFACE
from confluence import CONFLUENCE

class CONFLUENCE_LOADER:

   __path = None
   __file_hlpr = None
   __my_cnfl = None
   __verbose = False
   __debug = False
   __this_pass_load_count = 0
   __load_count = 0
   __created_spaces = 0
   __created_pages = 0

   def __init__(self, path=None,
                server_url='http://172.16.10.81:8090/rpc/xmlrpc',
                user_name='admin',
                pw='Baseball123'):

      if ( server_url is None ):
         server_url = "http://172.16.10.81:8090/rpc/xmlrpc"

      self.__path = path

      self.__file_hlpr = FILEINTERFACE()
      self.__my_cnfl = CONFLUENCE(server_url, user_name, pw)

      return

   def set_path(self, path):

      self.__path = path
      return

   def get_cnfl(self):

      return self.__my_cnfl

   #
   #   load_count is the accumulated number of attachments added.
   #   created_spaces is the number of spaces created
   #   created_pages is the number of pages created.
   #   Each will end up being incremented or decremented depending on
   #   whether an item is added or deleted.
   #
   #   Reset each of the counts back to zero.
   #
   def reset_create_counts(self):
      self.__load_count = 0
      self.__created_spaces = 0
      self.__created_pages = 0

      return

   #
   #   Return the current valued of all create count variables.
   #
   def get_create_counts(self):

      return self.__load_count, self.__created_pages, self.__created_spaces


   #
   #   Return only the value of the attachment load count
   #
   def get_load_count(self):
      return self.__load_count

   #
   #   Get the count of attachments loaded in THIS path.  There is no
   #   reset function for this because it is reset every time we start
   #   a new pass loading data.
   #
   def get_this_pass_load_counts(self):

      return self.__this_pass_load_count

   #
   #   set_verbose() and set_debug()
   #   These two functions increase the verbosity of the output.  Sometimes
   #   you need a lot.  Sometimes, you don't.
   #
   def set_verbose(self, TorF=False):

      self.__verbose = TorF
      if ( self.__my_cnfl is not None ):
         self.__my_cnfl.set_verbose(TorF=TorF)
      return

   def set_debug(self, TorF=False):

      self.__debug = TorF
      if ( self.__my_cnfl is not None ):
         self.__my_cnfl.set_debug(TorF=TorF)
      return

   def move_full_page(self, source_key, target_key):

      #
      #   If space_key is accidently sent as the full path,
      #   we can deal with it because we are always using
      #   the first element of the path as the space.
      #
      everything = self.__file_hlpr.dir_split(source_key)
      cnt = len(everything)
      if ( cnt > 1 ):
         src_space_key = everything[1]
         src_title = everything[cnt - 1]

      everything = self.__file_hlpr.dir_split(target_key)
      cnt = len(everything)
      if ( cnt > 1 ):
         trg_space_key = everything[1]
         trg_title = everything[cnt - 1]

      print "MOVING PAGE:", src_space_key, src_title
      print "         TO:", trg_space_key, trg_title
      self.__my_cnfl.movePage(src_space_key, src_title,
                              trg_space_key, trg_title)
      return


   #
   #   Delete a space if you have the key.  Deleting the space WILL
   #   delete the space and everything it contains.
   #
   def remove_base_space(self, space_key):

      #
      #   If space_key is accidently sent as the full path,
      #   we can deal with it because we are always using
      #   the first element of the path as the space.
      #
      everything = self.__file_hlpr.dir_split(space_key)
      cnt = len(everything)
      if ( cnt > 1 ):
         space_key = everything[1]

      self.__my_cnfl.deleteSpace(space_key)
      return

   #
   #   Currently removes the page which will take with it all of the
   #   contents.  Reset the create counts for now because I have no
   #   idea how many items were on that page.
   #
   def remove_the_page(self, full_path):

      everything = self.__file_hlpr.dir_split(full_path)
      cnt = len(everything)
      page = everything[cnt - 1]
      space = everything[1]

      self.__this_pass_load_count = 0

      myPage = self.__my_cnfl.getPage(space, page)

      if ( myPage != {} ):
         if ( self.__my_cnfl.deletePage(myPage['id']) ):
            self.reset_create_counts()
            print "Delete of", full_path, "successful"
         else:
            print "Delete of", full_path, "NOT successful"
      else:
         print "Delete of", full_path, "NOT successful because page not found"

      return

   #
   #   Given the original full path of a file, delete the file.  This
   #   only works if the this loader was used to create the file/attachment.
   #   Otherwise you will need to know the space key, page id, and attachment
   #   name.
   #
   def remove_the_file(self, full_path):

      #
      #   Within a full path:
      #      space_key is the first element
      #      attachment name is the last element
      #      page, as the other key to finding the attachment, is
      #         the second to the last element.
      #
      everything = self.__file_hlpr.dir_split(full_path)
      cnt = len(everything)
      attachment = everything[cnt - 1]
      page = everything[cnt - 2]
      space = everything[1]
      self.__this_pass_load_count = 0

      print "USING", space, page, attachment, "as access key"

      if (self.__my_cnfl.deleteAttachment(space, page, attachment)):
         print "Delete of", full_path, "successful"
         self.__load_count -= 1
         self.__this_pass_load_count -= 1
      else:
         print "Delete of", full_path, "NOT successful"

      return

   def move_the_file(self, source_path, target_path):

      #
      #   If space_key is accidently sent as the full path,
      #   we can deal with it because we are always using
      #   the first element of the path as the space.
      #
      everything = self.__file_hlpr.dir_split(source_path)
      cnt = len(everything)
      if ( cnt > 1 ):
         src_space_key = everything[1]
         src_title = everything[cnt - 2]
         src_name = everything[cnt - 1]

      everything = self.__file_hlpr.dir_split(target_path)
      cnt = len(everything)
      if ( cnt > 1 ):
         trg_space_key = everything[1]
         trg_title = everything[cnt - 2]
         trg_name = everything[cnt - 1]

      print "MOVING ATTACHMENT:", src_space_key, src_title, src_name
      print "               TO:", trg_space_key, trg_title, trg_name
      self.__my_cnfl.moveAttachment(src_space_key, src_title, src_name,
                                    trg_space_key, trg_title, trg_name)
      return

   def rename_the_file(self, source_path, new_name):

      #
      #   If space_key is accidently sent as the full path,
      #   we can deal with it because we are always using
      #   the first element of the path as the space.
      #
      everything = self.__file_hlpr.dir_split(source_path)
      cnt = len(everything)
      if ( cnt > 1 ):
         src_space_key = everything[1]
         src_title = everything[cnt - 2]
         src_name = everything[cnt - 1]
      else:
         print "FART:", everything

      print "RENAMING ATTACHMENT:", src_space_key, src_title, src_name
      print "                 TO:", src_space_key, src_title, new_name
      self.__my_cnfl.renameAttachment(src_space_key, src_title,
                                      src_name, new_name)
      return

   def build_base_space(self, spaceName=None, Description=None):

      space_data = self.__my_cnfl.createSpace(spaceName, spaceName, Description)

      return


   #  root will be a space
   #  following dir will be a page
   #  file will be an attachment
   #   /space/page/page/page/file

   def build_the_path(self, dirname):

      space_list = self.__file_hlpr.dir_split(dirname)
      space_data = None
      page_data = None

      for item in space_list:
         if ( item != "" ):
            if ( space_data is None ):
               if ( self.__debug ):
                  print "NEW SPACE", item
               space_data = self.__my_cnfl.getSpace(item)
               if ( space_data == {} or space_data is None ):
                  space_data = self.__my_cnfl.createSpace(item, item, item)
                  self.__created_spaces += 1
               else:
                  if ( self.__debug ):
                     print "   space exists  ====================="

               space_key = space_data['key']
               if ( self.__debug ):
                  print space_data
            else:
               if ( page_data is None ):
                  if ( self.__debug ):
                     print "NEW PAGE(no parent)", item
                  page_data = self.__my_cnfl.getPage(space_data['key'],
                                                     item)
                  if ( page_data == {} or page_data is None ):
                     page_data = self.__my_cnfl.createPage(space_data['key'],
                                                           item, item, None)
                     self.__created_pages += 1
                  else:
                     if ( self.__debug ):
                        print "   no parent page exists  ====================="
                  if ( self.__debug ):
                     print page_data
                  next_parent = item
               else:
                  if ( self.__debug ):
                     print "NEW PAGE(parent)", item
                  this_id = page_data['id']
                  page_data = self.__my_cnfl.getPage(space_data['key'],
                                                     item)
                  if ( page_data == {} or page_data is None ):
                     page_data = self.__my_cnfl.createPage(space_data['key'],
                                                           item, item,
                                                           this_id)
                     self.__created_pages += 1
                  else:
                     if ( page_data['parentId'] != this_id ):
                        page_data = self.__my_cnfl.createPage(space_data['key'],
                                                              item, item,
                                                              this_id)
                        self.__created_pages += 1
                     else:
                        if ( self.__debug ):
                           print "   parent page exists  ====================="
                  if ( self.__debug ):
                     print page_data
                  next_parent = item

      if ( page_data == {} or page_data is None ):
         return space_key, None
      else:
         return space_key, page_data['id']

   #
   #   If you set the path to a directory and then call this function,
   #   all of the files within that directory will be loaded into Confluence.
   #
   def load_a_directory(self):

      self.__this_pass_load_count = 0

      my_file_list = self.__file_hlpr.get_directory_file_list(self.__path, None)

      last_dir_added = None
      for item in my_file_list:
         if ( last_dir_added != item[0] ):
            space_key, parentId = last_dir_added = self.build_the_path(item[0])
            last_dir_added = item[0]

         fullPath = item[0] + '/' + item[1]
         if ( parentId is not None ):
            self.__my_cnfl.setParentId(parentId)
         try:
            crtd = self.__my_cnfl.createAttachment(space_key, item[1], fullPath)
            if ( crtd != {} and crtd is not None ):
               self.__load_count += 1
               self.__this_pass_load_count += 1
         except:
            print "Attachment name", item[1], "may already exist"

      return

if __name__ == "__main__":

   burble = CONFLUENCE_LOADER()
   burble.move_full_page("/testenv/test_data", "/testenv/test_data_upd")

   ##burble.load_a_directory()
   #burble.remove_base_space("testenv")
   #burble.rename_the_file("/testenv/test_data/document/PDF/squirrel.xls",
   #                     "chipmunk.xls")

   #fromDocs = ['/testenv/test_data/document/PPT/Master.ppt',
   #            '/testenv/test_data/document/PPT/2050.ppt',
   #            '/testenv/test_data/document/DOC/handbook.doc',
   #            '/testenv/test_data/document/DOC/California.doc',
   #            '/testenv/test_data/document/DOC/moonews.doc',
   #            '/testenv/test_data/document/XLS/test.xls']

   #toDocs = ['/testenv/test_data/document/PPTX/Master.ppt',
   #          '/testenv/test_data/document/PPTX/2050.ppt',
   #          '/testenv/test_data/document/DOCX/handbook.doc',
   #          '/testenv/test_data/document/DOCX/California.doc',
   #          '/testenv/test_data/document/DOCX/moonews.doc',
   #          '/testenv/test_data/document/XLSX/test.xls']

   #count = 0
   #for item in fromDocs:
   #   burble.move_the_file(item, toDocs[count])
   #   count += 1

   sys.exit(0)
