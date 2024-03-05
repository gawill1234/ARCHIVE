#!/usr/bin/python
# -*- coding: utf-8 -*-

import os, sys, time, cgi_interface, vapi_interface, tc_generic 
import re
import build_schema_node
from lxml import etree

global stemmers, kbs, dumpfile, collection, input_file, segmenters
global test_language, vseidxstr
global current_segmenter, current_stem, current_kb, expected
global current_output, current_collection
global segment_dictionary, text_dictionary, key_list

def removeNonAscii(s): return "".join(i for i in s if ord(i)<128)

def build_query_node(qword=None):

   #partA = '<query><operator logic="and">'
   partA = '<query>'
   partB = '<term field="query" str="' + qword + '" phrase="phrase" input-type="system"/>'
   partC = '</query>'
   #partC = '</operator></query>'

   queryNode = partA + partB + partC

   return queryNode

def get_idem_query(qword=None, qkey=None, expword=None):

   global current_collection

   messylist = []
   fail = False

   qarena = ''.join(['arena', '%s' % qkey])

   if ( qword is None ):
      qword = ''

   try:
      resp = yy.api_qsearch(source=current_collection,
                            query=qword,
                            qarena=qarena)

      for elt in resp.getiterator('content'):
         if ( elt.attrib.has_key('name') ):
            if ( elt.get('name') == 'mydata' ):
               try:
                  zzz = elt.findtext('.', default=None)
                  if ( zzz is not None ):
                     messylist.append(zzz)
               except Exception, e:
                  print "Error, SHIT!!!"
                  print e
                  fail = True
   except:
      print "Query failed on", current_collection, qword
      fail = True

   try:
      if ( len(messylist) > 0 ):
         for item in messylist:
            if ( removeNonAscii(item) != removeNonAscii(expword) ):
               print "Found unexpected content using query", qword
               print "   Returned word: ", item
               fail = True
      else:
         print "IDEM ERROR: No content returned for query of", qword
         fail = True
   except Exception, e:
      print "FUCK!!!:", e

   return fail


def get_query_content(qword=None, qkey=None, expword=None):

   global current_collection

   messylist = []
   fail = False

   qarena = ''.join(['arena', '%s' % qkey])

   if ( qword is None ):
      qword = ''

   queryNode = build_query_node(qword)

   try:
      resp = yy.api_qsearch(source=current_collection,
                            qarena=qarena,
                            qobj=queryNode)

      for elt in resp.getiterator('content'):
         if ( elt.attrib.has_key('name') ):
            if ( elt.get('name') == 'mydata' ):
               try:
                  zzz = elt.findtext('.', default=None)
                  if ( zzz is not None ):
                     messylist.append(zzz)
               except Exception, e:
                  print "Error, SHIT!!!"
                  print e
                  fail = True
   except:
      print "Query failed on", current_collection, qword
      fail = True

   try:
      if ( len(messylist) > 0 ):
         for item in messylist:
            if ( removeNonAscii(item) != removeNonAscii(expword) ):
               print "Found unexpected content using query", qword
               print "   Returned word: ", item
               fail = True
      else:
         print "ERROR: No content returned for query of", qword
         fail = True
   except Exception, e:
      print "FUCK!!!:", e

   return fail

def what_is_this_line(line=None):

   global stemmers, kbs, dumpfile, collection, input_file, segmenters
   global test_language, vseidxstr
   global current_segmenter, current_stem, current_kb, expected

   commands = ['language', 'expected', 'kb', 'stem',
               'collection', 'segmenter']

   turd = line.split('::')

   if ( len(turd) > 1 ):
      if ( turd[0] in commands ):
         if ( turd[0] == 'language' ):
            initall(turd[1].strip('\n'))
            #test_language = turd[1].strip('\n')
            #get_current_vse_idx_data()
         if ( turd[0] == 'expected' ):
            expected = turd[1].strip('\n').split(' ')
            if ( expected[0] == 'NONE' ):
               expected = []
         if ( turd[0] == 'kb' ):
            current_kb = turd[1].strip('\n')
            if ( current_kb == 'NONE' ):
               current_kb = None
         if ( turd[0] == 'stem' ):
            current_stem = turd[1].strip('\n')
            if ( current_stem == 'NONE' ):
               current_stem = None
         if ( turd[0] == 'collection' ):
            current_collection = turd[1].strip('\n')
         if ( turd[0] == 'segmenter' ):
            current_segmenter = turd[1].strip('\n')
            if ( current_segmenter == 'NONE' ):
               current_segmenter = None
         return None
   else:
      return line
   

#
#   I know this could have been done smaller and maybe even a bit
#   more efficiently.  But, doing it this way puts the data that is
#   being used to index each language right in the test to readily
#   be reviewed and/or updated.
#
def get_current_vse_idx_data():

   global stemmers, kbs, dumpfile, collection, input_file, segmenters
   global test_language, vseidxstr
   global current_segmenter, current_stem, current_kb

   if ( test_language is None ):
      print "No test language set, exiting"
      sys.exit(1)

   if ( current_segmenter is None ):
      try:
         current_segmenter = segmenters[test_language]
      except KeyError:
         current_segmenter = None

   if ( current_stem is None ):
      try:
         current_stem = stemmers[test_language]
      except KeyError:
         current_stem = None

   if ( current_kb is None ):
      try:
         current_kb = kbs[test_language]
      except KeyError:
         current_kb = None

   #try:
   #   vseidxstr = vseidxstr + ' kb="' + stoplists[test_language] +'"'
   #except KeyError:
   #   print "No kb for", test_language

   return


def set_vse_index_stream():

   global stemmers, kbs, dumpfile, collection, input_file, segmenters
   global test_language, vseidxstr
   global current_segmenter, current_stem, current_kb

   #
   #   Since the vse-index-stream node is always the same, do it here.
   #
   vseidxstr = '<vse-index-stream'

   if ( current_segmenter is not None ):
      vseidxstr = vseidxstr + ' segmenter="' + current_segmenter +'"'
   else:
      print "No segmenter for", test_language

   if ( current_stem is not None ):
      vseidxstr = vseidxstr + ' stem="' + current_stem +'"'
   else:
      print "No stemmers for", test_language

   if ( current_kb is not None ):
      vseidxstr = vseidxstr + ' kb="' + current_kb +'"'
   else:
      print "No kb for", test_language

   #try:
   #   vseidxstr = vseidxstr + ' kb="' + stoplists[test_language] +'"'
   #except KeyError:
   #   print "No kb for", test_language

   vseidxstr = vseidxstr + '/>'

   print vseidxstr

def initall(mylang=None):

   global stemmers, kbs, dumpfile, collection, input_file, segmenters
   global test_language, vseidxstr
   global current_segmenter, current_stem, current_kb, expected
   global current_output, current_collection

   #
   #   Default test language is english
   #
   if ( mylang is None ):
      test_language = "english"
   else:
      test_language = mylang

   current_segmenter = None
   current_stem = None
   current_kb = None
   current_output = 'language_stemming'
   current_collection = 'language_stemming'
   expected = []

   stemmers = {}
   kbs = {}
   segmenters = {}
   stoplists = {}
   dumpfile = {}
   collection = {}
   input_file = {}

   vseidxstr = None

   stemmers["spanish"] = "delanguage+spanish+spanish-depluralize"
   kbs["spanish"] = "spanish"
   dumpfile["spanish"] = "es_lang_data"
   collection["spanish"] = "spanish-lng"
   input_file["spanish"] = "spanish_words"

   stemmers["french"] = "delanguage+french"
   kbs["french"] = "french"
   dumpfile["french"] = "fr_lang_data"
   collection["french"] = "french-lng"
   input_file["french"] = "french_words"

   stemmers["english"] = "delanguage+english+depluralize"
   kbs["english"] = "english"
   dumpfile["english"] = "en_lang_data"
   collection["english"] = "english-lng"
   input_file["english"] = "english_words"

   stemmers["italian"] = "delanguage+italian"
   kbs["italian"] = "italian"
   dumpfile["italian"] = "it_lang_data"
   collection["italian"] = "italian-lng"
   input_file["italian"] = "italian_words"

   stemmers["german"] = "delanguage+german"
   kbs["german"] = "german"
   dumpfile["german"] = "de_lang_data"
   collection["german"] = "german-lng"
   input_file["german"] = "german_words"

   segmenters["japanese"] = "japanese"
   stemmers["japanese"] = "delanguage"
   kbs["japanese"] = "japanese-indexing+japanese-letters+japanese-proper"
   dumpfile["japanese"] = "jp_lang_data"
   collection["japanese"] = "japanese-lng"
   input_file["japanese"] = "japanese_words"

   get_current_vse_idx_data()

   return

def do_crawl_urls(genstring=None, urlnum=3):

   global stemmers, kbs, dumpfile, collection, input_file, segmenters
   global test_language, vseidxstr

   set_vse_index_stream()

   vxmlstr1 = '<?xml version="1.0" encoding="UTF-8"?><vce><document vse-key="document://generic' + '%s' % urlnum + '/doc_segment_it">' + vseidxstr + '<content name="mydata">'
   vxmlstr2 = '</content></document></vce>'

   nodestr = ''.join([vxmlstr1, genstring, vxmlstr2])

   #print nodestr

   myurl = 'http://vivisimo_' + '%s' % urlnum + '.com'
   crawl_urls = build_schema_node.create_crawl_urls()
   crawl_url = build_schema_node.create_crawl_url(url=myurl,
               status='complete', enqueuetype='reenqueued',
               arena="arena" + '%s' % urlnum,
               synchronization='indexed-no-sync', addnodeto=crawl_urls)
   curlopts = build_schema_node.create_curl_options(addnodeto=crawl_url)
   curlopt = build_schema_node.create_curl_option(addnodeto=curlopts,
                                name='default-allow',
                                added='added',
                                text='allow')
   curlopt = build_schema_node.create_curl_option(addnodeto=curlopts,
                                name='max-hops',
                                added='added',
                                text='1')
   crawl_data = build_schema_node.create_crawl_data(encoding='utf-8',
                contenttype='application/vxml-unnormalized',
                addnodeto=crawl_url, text=nodestr)

   return crawl_urls

def do_enqueues(collection_name2=None, genstring=None, urlnum=3):

    #print tname, ": ============================= "
    #print tname, ": Enqueuing: ", genstring
    word_list = genstring.strip('\n').split(';;')
    if ( len(word_list) < 2 ):
       word_list = genstring.strip('\n').split(' ')
    newgenstring = None
    urlnum = 3
    numwords = len(word_list)
    for item in word_list:
       print "ENQUEUE", urlnum - 2, "of", numwords, ": ", item
       crawl_urls = do_crawl_urls(genstring=item, urlnum=urlnum)
       #print etree.tostring(crawl_urls)
       #print tname, ": ============================="
       resp = yy.api_sc_enqueue_xml(
                        collection=collection_name2,
                        subc='live',
                        crawl_nodes=etree.tostring(crawl_urls))
       urlnum += 1

    return word_list

def update_segment_dictionary(word_to_add, word_arena, word_address):

   global segment_dictionary, text_dictionary, key_list

   if ( not word_arena in key_list ):
      key_list.append(word_arena)

   try:
      segment_dictionary[word_arena].append([word_to_add, word_address])
   except KeyError:
      segment_dictionary[word_arena] = []
      segment_dictionary[word_arena].append([word_to_add, word_address])

   return

def update_text_dictionary(word_to_add, word_address):

   global segment_dictionary, text_dictionary

   try:
      text_dictionary[word_address].append(word_to_add)
   except KeyError:
      text_dictionary[word_address] = []
      text_dictionary[word_address].append(word_to_add)

   return

def word_i_care_about(idxelem=[], expected=[],
                      found_segment=[], word_count=0):

   exclude_list = ['com', 'http', 'vivisim', 'vivisimo']

   gribble = idxelem[1].split('_')
   myarena = gribble[0].strip(' ')
   myword = gribble[1].strip(')')
   myaddr = idxelem[3].strip(' ')

   if ( expected != [] ):
      if ( myword in expected ):
         wordnorm = ''.join(["      word/normalized:  ", myword, "\n"])
         update_segment_dictionary(myword, myarena, myaddr)
         if ( not myword in found_segment ):
            found_segment.append(myword)
         word_count += 1
      else:
         if ( not myword in exclude_list ):
            if ( not re.match('[0-9]+', myword) ):
               print "Word found that is not expected:", myword 
               update_segment_dictionary(myword, myarena, myaddr)
               if ( not myword in found_segment ):
                  found_segment.append(myword)
         wordnorm = None
   else:
      wordnorm = None
      if ( not myword in exclude_list ):
         if ( not re.match('[0-9]+', myword) ):
            wordnorm = ''.join(["      word/normalized:  ", myword, "\n"])
            update_segment_dictionary(myword, myarena, myaddr)
            if ( not myword in found_segment ):
               found_segment.append(myword)
            word_count += 1

   return wordnorm, found_segment, word_count

def text_i_care_about(idxelem=[], valid_words=[], current_count=0):

   exclude_list = ['http://', 'vivisimo_', 'com', 'http://vivisimo_1.com']

   lenoflist = len(idxelem)
   textiwant = idxelem[lenoflist - 1].strip(' ')
   textiwant = textiwant.strip('\n')
   textiwant = textiwant.strip(')')
   textiwant = textiwant.rstrip(' ')

   addriwant = idxelem[lenoflist - 2].strip(' ')

   #if ( not textiwant.isalnum() ):
   if ( textiwant in valid_words ):
      segment = ''.join(["      text/segment:     ", textiwant, "\n"])
      update_text_dictionary(textiwant, addriwant)
      current_count += 1
   else:
      segment = None
      if ( not textiwant in exclude_list ):
         if ( not re.match('http://vivisimo.*', textiwant) ):
            if ( not re.match('[0-9]+', textiwant) ):
               if ( not re.match('<document.*>', textiwant) ):
                  print "Text found that is not expected:", textiwant
                  segment = ''.join(["      text/segment:     ", textiwant, "\n"])
                  update_text_dictionary(textiwant, addriwant)

   return segment, current_count

def do_summary_dump(summary, cntr, text_list, found_segment, tfail, tpass, arena_count):

   global stemmers, kbs, dumpfile, collection, input_file, segmenters
   global test_language, vseidxstr
   global current_segmenter, current_stem, current_kb, expected
   global current_output, current_collection
   global segment_dictionary, text_dictionary, key_list

   print "======================="
   print "======================="
   print "======================="
   print "======================="
   ostrng = ''.join(['= CASE SUMMARY DATA: ', '%s' % cntr])
   print ostrng
   print ostrng
   stupid = ''.join(['<h3>CASE SUMMARY DATA: ', '%s' % cntr, '</h3>'])
   summary.write(stupid)
   summary.write("\n")

   print "======================="
   #
   #   A kludge so that printing the word will not turn it into
   #   a mess.  Printing the actual list seems to cause issues
   #   with utf8 processing.  Turning the elements into a string
   #   allows the items to print correctly.
   #
   summary.write('<br/><br/>\n')
   stupid = '<table border="1" cellpadding="10" align="center">'
   summary.write(stupid)
   summary.write('\n')
   stupid = '<caption><b>Word and Stem Summary Table</b></caption>'
   summary.write(stupid)
   summary.write('\n')

   stupid = '<tr><th><center>vse-index-stream</center></th>'
   summary.write(stupid)
   summary.write('\n')
   stupid = '<th colspan="2"><center>' + \
             vseidxstr.replace('<', '&lt;').replace('>', '&gt;') + \
            '</center></th></tr>'
   summary.write(stupid)
   summary.write('\n')

   stupid = '<tr><th><center>Word Summary</center>'
   summary.write(stupid)
   summary.write('\n')
   stupid = '<center>(Input)</center></th>'
   summary.write(stupid)
   summary.write('\n')
   stupid = '<td>'
   summary.write(stupid)
   summary.write('\n')

   goober = "=   WORDS INDEXED:"
   for item in text_list:
      mydumper = '<center>' + item + '</center>'
      summary.write(mydumper)
      summary.write('\n')
      goober = goober + ' ' + '-' + item + '-'

   summary.write('</td>\n')
   #
   #   End kludge
   #
   stupid = '<td><center><b>'+ \
            '%s' % len(text_list) + \
            '</b></center></td></tr>'
   summary.write(stupid)
   summary.write('\n')

   print goober
   ostrng = '=   Indexed word count: ' + '%s' % len(text_list)
   print ostrng
   print "=   -------"

   ostrng = ''.join(['=   VSE-INDEX-STREAM of: ', vseidxstr])
   print ostrng
   print "=   -------"

   stupid = '<tr><th><center>Stem Class Summary</center>'
   summary.write(stupid)
   summary.write('\n')
   stupid = '<center>(Output)</center></th>'
   summary.write(stupid)
   summary.write('\n')
   stupid = '<td>'
   summary.write(stupid)
   summary.write('\n')

   ostrng = '=   List of stem classes found/created:'
   for item in found_segment:
      mydumper = '<center>' + item + '</center>'
      summary.write(mydumper)
      summary.write('\n')
      ostrng = ostrng + ' ' + '-' + item + '-'

   summary.write('</td>\n')

   print ostrng
   stupid = '<td><center><b>'+ \
            '%s' % len(found_segment) + \
            '</b></center></td></tr>'
   summary.write(stupid)
   summary.write('\n')

   ostrng = '=   Stem class count: ' + '%s' % len(found_segment)
   print ostrng
   print "=   -------"

   if ( expected != [] ):
      ostrng = '=   List of expected stem classes:'
      for item in expected:
         ostrng = ostrng + ' ' + item
      summary.write(ostrng)
      summary.write('\n')
      print ostrng
      print "=   -------"
      summary.write("=   -------")
      summary.write('\n')

   summary.write('<tr align="center">\n')
   summary.write('<th colspan="3"><center>Stem Class Count Test:  ')

   if ( expected == [] ):
      if ( len(found_segment) > 1 ):
         summary.write('<font color="red">Failed</font> (1 expected)')
         #summary.write('<i>NOT APPLICABLE</i>')
         summary.write('</center></th></tr>\n')
         print "=   More than one stem class was found, only one expected(fail)"
         tfail += 1
      else:
         summary.write('<font color="green">Passed</font>')
         #summary.write('<i>NOT APPLICABLE</i>')
         summary.write('</center></th></tr>\n')
   else:
      for item in found_segment:
         if ( not item in expected ):
            ostrng = ''.join(['=   Segment not expected(fail): ', item])
            summary.write(ostrng)
            summary.write('\n')
            print ostrng
            tfail += 1
         else:
            ostrng = ''.join(['=   Expected stem class found(pass): ', item])
            summary.write(ostrng)
            summary.write('\n')
            print ostrng
            tpass += 1

   summary.write('</table>\n')
   summary.write('<br/><br/>\n')

   #if ( word_count == text_count ):
   #   summary.write("=   Normalized word and text counts match(pass)")
   #   summary.write('\n')
   #   print "=   Normalized word and text counts match(pass)"
   #   tpass += 1
   #else:
   #   summary.write("=   words and text do not match(fail)")
   #   summary.write('\n')
   #   print "=   words and text do not match(fail)"
   #   tfail += 1

   print "======================"
   print "======================"

   #
   #   global segment_dictionary, text_dictionary
   #   Put query stuff somewhere in here.
   #
   for key in key_list:
      #word_idx = int(key) - 3
      word_idx = int(key) - 3
      try:
         print "a======================"
         current_word = text_list[word_idx]
         ostrng = ''.join([key, 'b=   WORD: ', text_list[word_idx]])
         print ostrng

         summary.write('<table border="1" cellpadding="10" align="center">\n')
         stupid = '<caption><b>WORD:  ' + \
                  text_list[word_idx] + \
                  '</b></caption>'
         summary.write(stupid)
         summary.write('\n')
         summary.write('<tr  bgcolor="#0099FF"><th>Normalized Word</th>')
         summary.write('<th>Associated Text</th>')
         summary.write('<th>Normalization 1 Query</th>')
         summary.write('<th>Normalization 2 Query</th>')
         summary.write('<th>Idempotence Query</th></tr>\n')

         try:
            for item in segment_dictionary[key]:
               summary.write('<tr>\n')
               ostrng = ''.join([key, 'c=   normalized word: ', item[0]])
               print ostrng
               stupid = '<td><center>' + item[0] + '</center></td>'
               summary.write(stupid)
               summary.write('\n')
               summary.write('<td>\n')
               try:
                  for thing in text_dictionary[item[1]]:
                     ostrng = ''.join([key, 'd=   associated text: ', thing])
                     print ostrng
                     stupid = '<center>' + thing + '</center>'
                     summary.write(stupid)
                     summary.write('\n')
               except KeyError:
                  summary.write('<center>&lt;BAD LOCATION&gt;</center>\n')
                  ostrng = ''.join([key, 'd=   Bad text location address: ', item[1]])
                  print ostrng
               summary.write('</td>\n')
               #
               #   A query using the normalize word and the arena for the query
               #
               try:
                  queryfail = get_query_content(qword=item[0], qkey=int(key),
                                    expword=current_word)
               except:
                  print "QUERY FAILED, word and arena"
                  queryfail = True

               if ( queryfail ):
                  try:
                     ostrng = ''.join([key, ' =      Normalized word query did not return the expected content\n', key, ' =      Possible indexing or query problem'])
                     print ostrng
                     summary.write('<td><center><font color="red">FAIL</font></center></td>\n')
                     tfail += 1
                  except:
                     print "TOP CONDITIONAL FAIL, word and arena"
               else:
                  try:
                     ostrng = ''.join([key, ' =      Normalized word query was correct'])
                     print ostrng
                     summary.write('<td><center><font color="green">PASSED</font></center></td>\n')
                     tpass += 1
                  except:
                     print "BOTTOM CONDITIONAL FAIL, word and arena"

               try:
                  queryfail = get_idem_query(qword=item[0], qkey=int(key),
                                             expword=current_word)
               except:
                  print "Norm 2 QUERY FAILED, word and arena"
                  queryfail = True

               if ( queryfail ):
                  try:
                     ostrng = ''.join([key, ' =      Normalization 2 query did not return the expected content\n', key, ' =      Possible normalization or query problem'])
                     print ostrng
                     summary.write('<td><center><font color="red">FAIL</font></center></td>\n')
                     tfail += 1
                  except:
                     print "Norm 2 TOP CONDITIONAL FAIL, word and arena"
               else:
                  try:
                     ostrng = ''.join([key, ' =      Normalization 2 query was correct'])
                     print ostrng
                     summary.write('<td><center><font color="green">PASSED</font></center></td>\n')
                     tpass += 1
                  except:
                     print "Norm 2 BOTTOM CONDITIONAL FAIL, word and arena"

               try:
                  summary.write('<td>\n')
                  try:
                     for thing in text_dictionary[item[1]]:
                        queryfail = get_idem_query(qword=thing, qkey=int(key),
                                                   expword=current_word)
                        if ( queryfail ):
                           try:
                              ostrng = ''.join([key, ' =      Idempotence query did not return the expected content\n', key, ' =      Possible normalization or query problem'])
                              print ostrng
                              summary.write('<center><font color="red">FAIL</font></center>\n')
                              tfail += 1
                           except:
                              print "IDEM TOP CONDITIONAL FAIL, word and arena"
                        else:
                           try:
                              ostrng = ''.join([key, ' =      Idempotence query was correct'])
                              print ostrng
                              summary.write('<center><font color="green">PASSED</font></center>\n')
                              tpass += 1
                           except:
                              print "IDEM BOTTOM CONDITIONAL FAIL, word and arena"
                  except KeyError:
                     summary.write('<center>&lt;BAD LOCATION&gt;</center>\n')
                     ostrng = ''.join([key, 'd=   Bad text location address: ', item[1]])
                     print ostrng
                  summary.write('</td>\n')
               except:
                  print "IDEM QUERY FAILED, word and arena"
                  queryfail = True

               summary.write('</tr>\n')

         except KeyError:
            ostrng = ''.join([key, 'c=   Bad segment arena id: ', key])
            print ostrng
            summary.write(ostrng)
            summary.write('\n')
         #
         #   A query using the arena only
         #
         summary.write('<tr align="center">\n')
         summary.write('<th colspan="5"><center>Arena Query:  ')
         try:
            queryfail = get_query_content(qword=None, qkey=int(key),
                           expword=current_word)
         except:
            print "QUERY FAILED, arena only"
            queryfail = True

         if ( queryfail ):
            try:
               ostrng = ''.join([key, ' =   Arena query did not return the expected content\n', key, ' =   Possible indexing problem'])
               print ostrng
               summary.write('<font color="red">Failed</font>(indexing?)</center>')
               tfail += 1
            except:
               summary.write('<font color="red">Failed</font>(exception 1)</center>')
               print "TOP FAIL, arena only"
         else:
            try:
               ostrng = ''.join([key, ' =   Arena query was correct'])
               print ostrng
               summary.write('<font color="green">Passed</font></center>')
               tpass += 1
            except:
               summary.write('<font color="red">Failed</font>(exception 2)</center>')
               print "BOTTOM FAIL, arena only"
         summary.write('</th>\n</tr>\n')
         print "e======================"
         summary.write('</table>\n')
         summary.write('<br/><br/>\n')
      except:
         print "Probable index range error"
   print "======================"
   print "======================"
   print "======================"
   print "======================"

   return tfail, tpass


if __name__ == "__main__":

   global stemmers, kbs, dumpfile, collection, input_file, segmenters
   global test_language, vseidxstr
   global current_segmenter, current_stem, current_kb, expected
   global current_output, current_collection
   global segment_dictionary, text_dictionary, key_list

   verbose = False

   initall()

   tfail = 0
   tpass = 0

   infile = sys.argv[1]

   #collection_name2 = collection[test_language]

   tname = "language_stem_class"

   datadir = 'vxml_data'
   filename = "vxml_data/" + infile
   summaryfile = "language_data_summary"

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  content schema node test 1"

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   zz = tc_generic.TCINTERFACE()

   if ( xx.TENV.vivfloatversion < 7.5 ):
      print tname, ":  Unsupported release for these features"
      sys.exit(0)

   divider = ''.join([tname, ": =============================\n"])
   f =  open(filename)
   output = open(current_output, 'w+', 0)
   summary = open(summaryfile, 'w+', 0)
   summary.write('<html>\n<head>\n')
   summary.write('<meta http-equiv="Content-Language" content="en-us">\n')
   summary.write('<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">\n')
   summary.write('<title>Language OEM Evaluation Results</title>\n')
   summary.write('</head>\n<body>\n')
   cntr = 1
   for line in f.readlines():

      line = what_is_this_line(line=line)
      if ( line is not None ):
         collection_name2 = current_collection
         idxfile = collection_name2 + ".index"
         xfile = collection_name2 + ".xml"
         text_count = 0
         word_count = 0
         found_segment = []
         key_list = []
         segment_dictionary = {}
         text_dictionary = {}
         #
         #   Empty collection to be filled using crawl-urls
         #
         cex = xx.collection_exists(collection=collection_name2)
         if ( cex == 1 ):
            xx.delete_collection(collection=collection_name2)

         print tname, ":  PERFORM CRAWLS"
         print tname, ":     Create empty collection", collection_name2

         yy.api_sc_create(collection=collection_name2, based_on='default-push')
         yy.api_repository_update(xmlfile=xfile)

         thebeginning = time.time()

         text_list = do_enqueues(collection_name2=collection_name2,
                                 genstring=line, urlnum=3)

         arena_count = len(text_list)

         xx.wait_for_idle(collection=collection_name2)
   
         xx.dump_indices(collectionname=collection_name2)

         indexfp = open(idxfile)

         output.write(divider)
         if ( verbose ):
            print divider
            print "Word number:", cntr

         fullstring = ''.join(["   full string:  ", line, "\n"])
         output.write(fullstring)
         if ( verbose ):
            print fullstring

         for thing in indexfp.readlines():
            idxelem = thing.split(',')
            if ( idxelem is not None ):
               if ( idxelem[0] == '(text' ):
                  segment, text_count = text_i_care_about(idxelem,
                                                   text_list, text_count)
                  if ( segment is not None ):
                     output.write(segment)
                     if ( verbose ):
                        print segment
               if ( idxelem[0] == '(word' ):
                  wordnorm, found_segment, word_count = word_i_care_about(
                                                    idxelem, expected,
                                                    found_segment, word_count)
                  if ( wordnorm is not None ):
                     output.write(wordnorm)
                     if ( verbose ):
                        print wordnorm

         output.write(divider)
         if ( verbose ):
            print divider

         tfail, tpass = do_summary_dump(summary, cntr, text_list, 
                                        found_segment, tfail, tpass, arena_count)
         cntr += 1

   summary.write('</body>\n</html>\n')
   summary.close()
   output.close()
   f.close()

   ##############################################################
   #
   print tname, ":  Get rid of the collection to save space and"
   print tname, ":  remove side effects."
   #
   #xx.delete_collection(collection=collection_name2)

   print tname, ": #############################################"
   print tname, ":  Final Result"

   if ( tfail == 0 ) and ( tpass > 0 ):
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
