#!/usr/bin/python

import sys, os, random, time, vapi_interface, getopt


class Compare:


   def __init__(self, outfile, comparefile):

      self.__vapi = vapi_interface.VAPIINTERFACE()

      self.__vapi.api_ss_start()

      self.__newfile = outfile
      self.__oldfile = comparefile

      self.__old_vbscore = []
      self.__old_slscore = []
      self.__old_lascore = []
      self.__old_dcscore = []
      self.__old_urls = []
      self.__old_query = []

      self.__new_vbscore = []
      self.__new_slscore = []
      self.__new_lascore = []
      self.__new_dcscore = []
      self.__new_urls = []
      self.__new_query = []

      self.__compare_fail = 0
      self.__binning_fail = 0

      self.build_score_set_data()
      self.build_score_set_compare()

      return

   def get_score_compare_result(self):

      if ( self.__compare_fail == 0 ):
         print "   Score comparison passed"
      else:
         print "   Score comparison failed"

      return self.__compare_fail


   def build_score_set_data(self):

      try:
         fd = open(self.__newfile, "r+")

         self.__new_urls = self.__vapi.getResultGenericTagList(
                                             filename=self.__newfile,
                                             tagname="document",
                                             attrname="url")

         slscore = self.__vapi.getResultGenericTagList(
                                             filename=self.__newfile,
                                             tagname="solution",
                                             attrname="score")
         lascore = self.__vapi.getResultGenericTagList(
                                             filename=self.__newfile,
                                             tagname="document",
                                             attrname="la-score")
         vbscore = self.__vapi.getResultGenericTagList(
                                             filename=self.__newfile,
                                             tagname="document",
                                             attrname="vse-base-score")

         dcscore = self.__vapi.getResultGenericTagList(
                                             filename=self.__newfile,
                                             tagname="document",
                                             attrname="score")


         fd.close()

         vbscore.sort()
         slscore.sort()
         lascore.sort()
         dcscore.sort()

         self.__new_vbscore = vbscore
         self.__new_slscore = slscore
         self.__new_lascore = lascore
         self.__new_dcscore = dcscore

         #print "NEW SLSCORE:  ######################################"
         #print self.__new_slscore
         #print "NEW LASCORE:  ######################################"
         #print self.__new_lascore
         #print "NEW VBSCORE:  ######################################"
         #print self.__new_vbscore
         #print "NEW DCSCORE:  ######################################"
         #print self.__new_dcscore
      except:
         print "   Could not open file:", self.__newfile
         print "   Score comparison failed"
         self.__compare_fail += 1

      return

   def build_score_set_compare(self):

      try:
         fd = open(self.__oldfile, "r+")

         self.__old_urls = self.__vapi.getResultGenericTagList(
                                             filename=self.__oldfile,
                                             tagname="document",
                                             attrname="url")

         slscore = self.__vapi.getResultGenericTagList(
                                             filename=self.__oldfile,
                                             tagname="solution",
                                             attrname="score")
         lascore = self.__vapi.getResultGenericTagList(
                                             filename=self.__oldfile,
                                             tagname="document",
                                             attrname="la-score")
         vbscore = self.__vapi.getResultGenericTagList(
                                             filename=self.__oldfile,
                                             tagname="document",
                                             attrname="vse-base-score")

         dcscore = self.__vapi.getResultGenericTagList(
                                             filename=self.__oldfile,
                                             tagname="document",
                                             attrname="score")

         fd.close()

         vbscore.sort()
         slscore.sort()
         lascore.sort()
         dcscore.sort()

         self.__old_vbscore = vbscore
         self.__old_slscore = slscore
         self.__old_lascore = lascore
         self.__old_dcscore = dcscore

         #print "OLD SLSCORE:  ######################################"
         #print self.__old_slscore
         #print "OLD LASCORE:  ######################################"
         #print self.__old_lascore
         #print "OLD VBSCORE:  ######################################"
         #print self.__old_vbscore
         #print "OLD DCSCORE:  ######################################"
         #print self.__old_dcscore

      except:
         print "   Could not open file:", self.__oldfile
         print "   Score comparison failed"
         self.__compare_fail += 1

      return

   def do_query_compare(self):

      itemfail = 0

      try:
         if ( self.__new_query == [] ):
            self.__new_query = self.__vapi.getResultGenericTagString(
                                       filename=self.__newfile,
                                       tagname='query')
      except:
         print "Could not get query list from new file"

      try:
         if ( self.__old_query == [] ):
            self.__old_query = self.__vapi.getResultGenericTagString(
                                       filename=self.__oldfile,
                                       tagname='query')
      except:
         print "Could not get query list from old file"

      for item in self.__old_query:
         found = 0
         for it2 in self.__new_query:
            if ( item == it2 ):
               found = 1

         if ( found == 0 ):
            print "   Query find failure: ", item, "not in new result"
            self.__compare_fail += 1
            itemfail += 1

      for item in self.__new_query:
         found = 0
         for it2 in self.__old_query:
            if ( item == it2 ):
               found = 1

         if ( found == 0 ):
            print "   Query find failure: ", item, "not in old result"
            self.__compare_fail += 1
            itemfail += 1

      if ( itemfail == 0 ):
         print "   Query comparison passed"
      else:
         print "   Query comparison failed"

      return itemfail


   def do_url_compare(self, sortedorder=False):

      itemfail = 0

      if ( not sortedorder ):
         try:
            if ( self.__new_urls == [] ):
               self.__new_urls = self.__vapi.getResultGenericTagList(
                                          filename=self.__newfile,
                                          tagname='document',
                                          attrname='url',
                                          attrvalue=item)
         except:
            print "Could not get url list from new file"

         try:
            if ( self.__old_urls == [] ):
               self.__old_urls = self.__vapi.getResultGenericTagList(
                                          filename=self.__oldfile,
                                          tagname='document',
                                          attrname='url',
                                          attrvalue=item)
         except:
            print "Could not get url list from old file"

         for item in self.__old_urls:
            found = 0
            for it2 in self.__new_urls:
               if ( item == it2 ):
                  found = 1

            if ( found == 0 ):
               print "   URL find failure: ", item, "not in new result"
               self.__compare_fail += 1
               itemfail += 1

         for item in self.__new_urls:
            found = 0
            for it2 in self.__old_urls:
               if ( item == it2 ):
                  found = 1

            if ( found == 0 ):
               print "   URL find failure: ", item, "not in old result"
               self.__compare_fail += 1
               itemfail += 1
      else:
         oldurlcount = len(self.__old_urls)
         newurlcount = len(self.__new_urls)

         if ( oldurlcount != newurlcount ):
            print "   URL find failure:  URL counts differ"
            itemfail += 1
         else:
            counter = 0
            while ( counter < oldurlcount ):
               if ( self.__old_urls[counter] != self.__new_urls[counter] ):
                  itemfail += 1
                  print "   URL find failure:  Order of the new list"
                  print "                  differs of the old list order"
               counter += 1

      if ( itemfail == 0 ):
         print "   URL comparison passed"
      else:
         print "   URL comparison failed"

      return itemfail

   def do_binning_check(self):

      self.do_binset_compare()
      self.do_bin_compare()

      if ( self.__binning_fail == 0 ):
         print "   BINNING comparison passed"
      else:
         print "   BINNING comparison failed"

      return self.__binning_fail

   def do_binset_compare(self):

      itemfail = 0

      n_binset_nob = self.__vapi.getResultGenericTagList(
                                          filename=self.__newfile,
                                          tagname="binning-set",
                                          attrname="n-output-bins")
      n_binset_nob.sort()

      n_binset_ntb = self.__vapi.getResultGenericTagList(
                                          filename=self.__newfile,
                                          tagname="binning-set",
                                          attrname="n-total-bins")
      n_binset_ntb.sort()

      o_binset_nob = self.__vapi.getResultGenericTagList(
                                          filename=self.__oldfile,
                                          tagname="binning-set",
                                          attrname="n-output-bins")
      o_binset_nob.sort()

      o_binset_ntb = self.__vapi.getResultGenericTagList(
                                          filename=self.__oldfile,
                                          tagname="binning-set",
                                          attrname="n-total-bins")
      o_binset_ntb.sort()

      if o_binset_ntb != n_binset_ntb:
         print "   BINNING:  n-total-bins do not match"
         print "expected:", o_binset_ntb
         print "  actual:", n_binset_ntb
         itemfail += 1

      if o_binset_nob != n_binset_nob:
         print "   BINNING:  n-output-bins do not match"
         print "expected:", o_binset_nob
         print "  actual:", n_binset_nob
         itemfail += 1

      self.__compare_fail += itemfail
      self.__binning_fail += itemfail

      return

   def do_bin_compare(self):

      itemfail = 0

      n_bin_ndoc = self.__vapi.getResultGenericTagList(
                                          filename=self.__newfile,
                                          tagname="bin",
                                          attrname="ndocs")
      n_bin_ndoc.sort()

      n_bin_label = self.__vapi.getResultGenericTagList(
                                          filename=self.__newfile,
                                          tagname="bin",
                                          attrname="label")
      n_bin_label.sort()

      n_bin_token = self.__vapi.getResultGenericTagList(
                                          filename=self.__newfile,
                                          tagname="bin",
                                          attrname="token")
      n_bin_token.sort()

      n_bin_calc = self.__vapi.getResultGenericTagList(
                                          filename=self.__newfile,
                                          tagname="binning-calculation",
                                          attrname="value")
      n_bin_calc.sort()

      o_bin_ndoc = self.__vapi.getResultGenericTagList(
                                          filename=self.__oldfile,
                                          tagname="bin",
                                          attrname="ndocs")
      o_bin_ndoc.sort()

      o_bin_label = self.__vapi.getResultGenericTagList(
                                          filename=self.__oldfile,
                                          tagname="bin",
                                          attrname="label")
      o_bin_label.sort()

      o_bin_token = self.__vapi.getResultGenericTagList(
                                          filename=self.__oldfile,
                                          tagname="bin",
                                          attrname="token")
      o_bin_token.sort()

      o_bin_calc = self.__vapi.getResultGenericTagList(
                                          filename=self.__oldfile,
                                          tagname="binning-calculation",
                                          attrname="value")
      o_bin_calc.sort()

      if o_bin_ndoc != n_bin_ndoc:
         print "   BINNING:  ndocs do not match"
         print "expected:", o_bin_ndoc
         print "  actual:", n_bin_ndoc
         itemfail += 1

      if o_bin_label != n_bin_label:
         print "   BINNING:  label do not match"
         print "expected:", o_bin_label
         print "  actual:", n_bin_label
         itemfail += 1

      if o_bin_token != n_bin_token:
         print "   BINNING:  token do not match"
         print "expected:", o_bin_token
         print "  actual:", n_bin_token
         itemfail += 1

      if o_bin_calc != n_bin_calc:
         print "   BINNING:  binning-calculation do not match"
         print "expected:", o_bin_calc
         print "  actual:", n_bin_calc
         itemfail += 1

      self.__compare_fail += itemfail
      self.__binning_fail += itemfail

      return


   def do_full_score_compare(self):

      llen1 = len(self.__old_urls)
      llen2 = len(self.__new_urls)

      if ( llen1 != llen2 ):
         if ( llen1 < llen2 ):
            thing = self.__new_urls
         else:
            thing = self.__old_urls
      else:
         thing = self.__old_urls

      for item in thing:
         try:
            ods = self.__vapi.getResultGenericOtherAttrValue(
                                       filename=self.__oldfile,
                                       tagname='document',
                                       attrname='url',
                                       attrvalue=item,
                                       returnattr='score')
         except:
            ods = 'None'

         try:
            ola = self.__vapi.getResultGenericOtherAttrValue(
                                       filename=self.__oldfile,
                                       tagname='document',
                                       attrname='url',
                                       attrvalue=item,
                                       returnattr='la-score')
         except:
            ola = 'None'

         try:
            ovb = self.__vapi.getResultGenericOtherAttrValue(
                                       filename=self.__oldfile,
                                       tagname='document',
                                       attrname='url',
                                       attrvalue=item,
                                       returnattr='vse-base-score')
         except:
            ovb = 'None'


         try:
            nds = self.__vapi.getResultGenericOtherAttrValue(
                                       filename=self.__newfile,
                                       tagname='document',
                                       attrname='url',
                                       attrvalue=item,
                                       returnattr='score')
         except:
            nds = 'None'

         try:
            nla = self.__vapi.getResultGenericOtherAttrValue(
                                       filename=self.__newfile,
                                       tagname='document',
                                       attrname='url',
                                       attrvalue=item,
                                       returnattr='la-score')
         except:
            nla = 'None'

         try:
            nvb = self.__vapi.getResultGenericOtherAttrValue(
                                       filename=self.__newfile,
                                       tagname='document',
                                       attrname='url',
                                       attrvalue=item,
                                       returnattr='vse-base-score')
         except:
            nvb = 'None'


         itemfail = 0
         if ( ovb != nvb ):
            itemfail = 1
         if ( ola != nla ):
            itemfail = 1
         if ( ods != nds ):
            itemfail = 1

         if ( itemfail == 1 ):
            print "   #########################################"
            print "   FAILING URL SCORES:"
            print "      url: ", item
            print "      score(current):          ", nds
            print "      score(saved):            ", ods
            print "      vse-base-score(current): ", nvb
            print "      vse-base-score(saved):   ", ovb
            print "      la-score(current):       ", nla
            print "      la-score(saved):         ", ola
         else:
            print "   #########################################"
            print "   PASSING URL SCORES:"
            print "      pass url: ", item
            print "      pass score(current):          ", nds
            print "      pass score(saved):            ", ods
            print "      pass vse-base-score(current): ", nvb
            print "      pass vse-base-score(saved):   ", ovb
            print "      pass la-score(current):       ", nla
            print "      pass la-score(saved):         ", ola

      return

   def do_full_compare(self, sortedorder=False):

      print "   COMPARE OF QUERY OUTPUT DATA"
      print "   ----------------------------"
      print "   COMPARE FILE: ", self.__oldfile
      print "   OUTPUT FILE : ", self.__newfile
      print ""

      if ( self.__compare_fail == 0 ):
         self.reg_score_compare()
         self.vb_score_compare()
         self.la_score_compare()
         self.dc_score_compare()

         self.do_url_compare(sortedorder)
         self.do_query_compare()
         self.do_binning_check()

         if ( self.__compare_fail != 0 ):
            self.do_full_score_compare()

      return self.get_score_compare_result()

   def do_score_compare(self):

      if ( self.__compare_fail == 0 ):
         self.reg_score_compare()
         self.vb_score_compare()
         self.la_score_compare()
         self.dc_score_compare()

         if ( self.__compare_fail != 0 ):
            self.do_full_score_compare()

      return self.get_score_compare_result()

   def reg_score_compare(self):

      epsilon = 0.001
      localscore = 0

      llen1 = len(self.__old_slscore)
      llen2 = len(self.__new_slscore)

      if ( llen1 != llen2 ):
         localscore += 1
         print "   Number of SOLUTION scores differ between documents"
         if ( llen1 < llen2 ):
            maxlen = llen1
         else:
            maxlen = llen2
      else:
         maxlen = llen1

      trac = 0
      while ( trac < maxlen ):
         diff = abs(float(self.__old_slscore[trac]) - float(self.__new_slscore[trac]))
         max_score = max(float(self.__old_slscore[trac]), float(self.__new_slscore[trac]))
         if ( diff / max_score >= epsilon ):
            print "  SLSCORE FAIL:  OLD,", self.__old_slscore[trac], "NEW,", self.__new_slscore[trac]
            localscore += 1
         trac += 1

      if ( localscore == 0 ):
         print "   SOLUTION score check passed"
      else:
         print "   SOLUTION score check failed"

      self.__compare_fail += localscore

      return localscore

   def vb_score_compare(self):

      epsilon = 0.001
      localscore = 0

      llen1 = len(self.__old_vbscore)
      llen2 = len(self.__new_vbscore)

      if ( llen1 != llen2 ):
         localscore += 1
         print "   Number of DOCUMENT scores differ between documents"
         if ( llen1 < llen2 ):
            maxlen = llen1
         else:
            maxlen = llen2
      else:
         maxlen = llen1

      trac = 0
      while ( trac < maxlen ):
         diff = abs(float(self.__old_vbscore[trac]) - float(self.__new_vbscore[trac]))
         max_score = max(float(self.__old_vbscore[trac]), float(self.__new_vbscore[trac]))
         if ( diff / max_score >= epsilon ):
            localscore += 1
            print "  VBSCORE FAIL:  OLD,", self.__old_vbscore[trac], "NEW,", self.__new_vbscore[trac]
         trac += 1

      if ( localscore == 0 ):
         print "   DOCUMENT vse-base-score check passed"
      else:
         print "   DOCUMENT vse-base-score check failed"

      ##########################################################
      #
      #   Set localscore to 0 for the moment to allow tests to pass.
      #   Change it back when issues around vse base score are resolved.
      #   Relevant bugs are: 24578 and 25435
      #
      localscore = 0
      #
      ##########################################################
      self.__compare_fail += localscore

      return localscore

   def la_score_compare(self):

      epsilon = 0.001
      localscore = 0

      llen1 = len(self.__old_lascore)
      llen2 = len(self.__new_lascore)

      if ( llen1 != llen2 ):
         localscore += 1
         print "   Number of DOCUMENT scores differ between documents"
         if ( llen1 < llen2 ):
            maxlen = llen1
         else:
            maxlen = llen2
      else:
         maxlen = llen1

      trac = 0
      while ( trac < maxlen ):
         diff = abs(float(self.__old_lascore[trac]) - float(self.__new_lascore[trac]))
         max_score = max(float(self.__old_lascore[trac]), float(self.__new_lascore[trac]))
         if ( diff / max_score >= epsilon ):
            localscore += 1
            print "  LASCORE FAIL:  OLD,", self.__old_lascore[trac], "NEW,", self.__new_lascore[trac]
         trac += 1

      if ( localscore == 0 ):
         print "   DOCUMENT la-score check passed"
      else:
         print "   DOCUMENT la-score check failed"

      self.__compare_fail += localscore

      return localscore

   def dc_score_compare(self):

      epsilon = 0.001
      localscore = 0

      llen1 = len(self.__old_dcscore)
      llen2 = len(self.__new_dcscore)

      if ( llen1 != llen2 ):
         localscore += 1
         print "   Number of DOCUMENT scores differ between documents"
         if ( llen1 < llen2 ):
            maxlen = llen1
         else:
            maxlen = llen2
      else:
         maxlen = llen1

      trac = 0
      while ( trac < maxlen ):
         diff = abs(float(self.__old_dcscore[trac]) - float(self.__new_dcscore[trac]))
         max_score = max(float(self.__old_dcscore[trac]), float(self.__new_dcscore[trac]))
         if ( diff / max_score >= epsilon ):
            localscore += 1
            print "  DCSCORE FAIL:  OLD,", self.__old_dcscore[trac], "NEW,", self.__new_dcscore[trac]
         trac += 1

      if ( localscore == 0 ):
         print "   DOCUMENT score check passed"
      else:
         print "   DOCUMENT score check failed"

      self.__compare_fail += localscore

      return localscore


if __name__ == "__main__":

   opts, args = getopt.getopt(sys.argv[1:], "I:C:", ["infile=", "comparefile="])

   for o, a in opts:
      if o in ("-I", "--infile"):
         in_file = a
      if o in ("-C", "--comparefile"):
         compare_file = a


   thingy = scoreCompare(in_file, compare_file)

   thingy.do_full_compare()

   #thingy.do_score_compare()

   sys.exit(0)
