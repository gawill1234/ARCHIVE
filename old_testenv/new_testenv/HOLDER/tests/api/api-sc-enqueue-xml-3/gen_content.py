#!/usr/bin/python

import sys, os, time, random
import generate
import build_schema_node
from lxml import etree

WORD_LIST = []


def gen_docs(doc_count=5, average_doc_size=1024):

   global WORD_LIST

   if ( WORD_LIST == [] ):
      f = open('words')
      WORD_LIST = [word.strip() for word in f.readlines()]
      f.close()

   randomnum = time.time()

   c = generate.Collection(WORD_LIST,
                           doc_count,
                           average_doc_size,
                           stddev=average_doc_size/100.0,
                           random_seed=randomnum)


   return c


def gen_url(baseurl='http://test_garbage', num='0', letterpart=None):


   
   if ( letterpart != None ):
      myurl = ''.join([baseurl, '_', num, '.com?', num, '_', letterpart])
   else:
      myurl = ''.join([baseurl, '_', num, '.com'])

   return myurl


def gen_cname(nameaddto='0'):

   name = ''.join(['fakeName-', nameaddto])

   return name

def do_content_nodes(addnodesto=None, cnamenum=None, text=None):

   nums = '00022105001100011000'
   letter = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

   g = random.Random(time.time())

   anum = int(nums[g.randint(0,19)])

   fuzzy = g.randint(0, 1)

   partname = gen_cname(nameaddto=cnamenum)

   i = 0
   if ( fuzzy == 1 ):
      while ( i < anum ):
         contentname = ''.join([partname, '-', letter[i]])
         blankcontent = build_schema_node.create_content(name=contentname,
                                          addnodeto=addnodesto)
         i += 1
      contentname = ''.join([partname, '-', letter[i]])
      fullcontent = build_schema_node.create_content(name='text',
                                       addnodeto=addnodesto, text=text)
   else:
      contentname = ''.join([partname, '-', letter[i]])
      fullcontent = build_schema_node.create_content(name='text',
                                       addnodeto=addnodesto, text=text)
      while ( i < anum ):
         contentname = ''.join([partname, '-', letter[i + 1]])
         blankcontent = build_schema_node.create_content(name=contentname,
                                          addnodeto=addnodesto)
         i += 1

   return


if __name__ == "__main__":

   startpoint = 0
   letter = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

   docsnode = build_schema_node.create_documents()
   dcollect = gen_docs(doc_count=20)

   i = 0

   for doc in dcollect.docs():
      print "=================================================="
      print doc
      print "=================================================="

      myurl = gen_url(num='%s' % startpoint, letterpart=letter[i])
      print "MYURL:  ", myurl
      adoc = build_schema_node.create_document(url=myurl, addnodeto=docsnode)

      do_content_nodes(addnodesto=adoc, cnamenum='%s' % startpoint, text=doc)

      startpoint += 1
      i += 1

   text = etree.tostring(docsnode)

   crawl_urls = build_schema_node.create_crawl_urls()
   crawl_url = build_schema_node.create_crawl_url(
               status='complete', enqueuetype='reenqueued',
               synchronization='indexed-no-sync', addnodeto=crawl_urls)
   crawl_data = build_schema_node.create_crawl_data(encoding='utf-8',
                contenttype='application/vxml-unnormalized',
                addnodeto=crawl_url,
                text=text)

   print etree.tostring(crawl_urls)

   sys.exit(0)


   
