#!/usr/bin/python

import sys, time, myutils

class RABOS(object):

   def __init__ (self, filename=None, filetype=None):

      self.filename = filename
      self.filetype = "url"

      if ( filetype != None ):
         self.filetype = filetype

      self.ofd = open(self.filename, 'r')

      return

   def urlread(self):

      data = self.ofd.readline()

      if ( data == '' or data == None ):
         return None

      data = data.replace('\n', '')

      return data


   def doTheRead(self):

      if ( self.filetype == "url" ):
         return self.urlread()

class BASICJUNK(object):

   def __init__(self):

      return

   def stdin_read(self, prompt=None, default=None):

      spaces = "  "

      sys.stdout.write(prompt)
      if ( default != None ):
         sys.stdout.write("(Default=")
         sys.stdout.write(default)
         sys.stdout.write(")")
         sys.stdout.write(":")
      else:
         sys.stdout.write(":")
         
      sys.stdout.write(spaces)

      data = sys.stdin.readline()

      if ( ( data != '\n' ) and ( data != '' ) and ( data != None ) ):
         data = data.rstrip()
      else:
         data = default

      return data

   def today(self):

      thedate = time.strftime("%Y-%m-%d")

      return thedate

   def leap_year(self, year=None):
      
      if ( year == None ):
         year = int(time.strftime("%Y"))
      
      a = year % 4
      b = year % 100
      c = year % 400

      if ( a == 0 ):
         if ( b == 0 ):
            if ( c == 0 ):
               return 1
         else:
            return 1

      return 0

   def get_day_max(self, year=None, month=None):

      if ( year == None ):
         year = time.strftime("%Y")

      if ( year == None ):
         year = time.strftime("%m")

      #     j  f  m  a  m  j  j  a  s  o  n  d
      a = [31,28,31,30,31,30,31,31,30,31,30,31]

      daymax = a[month - 1]

      if ( month == 2 ):
         if ( self.leap_year(year) ):
            daymax = 29

      return daymax
            

   def get_date_for_idiots(self):
      
      year = time.strftime("%Y")
      month = time.strftime("%m")
      day = time.strftime("%d")

      print "Enter year data (3 questions: year, month, day)"
      year = self.stdin_read(prompt="   Enter year", default=year)

      month = self.stdin_read(prompt="   Enter month(as month of year, 1-12)", default=month)
      try:
         imonth = int(month)
      except:
         imonth = 0
      while ( imonth > 12 or imonth < 1 ):
         print "Come on, enter a proper month"
         month = self.stdin_read(prompt="   Enter month(as month of year, 1-12)", default=month)
         try:
            imonth = int(month)
         except:
            imonth = 0

      daymax = self.get_day_max(int(year), int(month))
      pstr = ''.join(['   Enter day (as day of month, 1 - ', str(daymax), ')'])
      day = self.stdin_read(prompt=pstr, default=day)

      try:
         iday = int(day)
      except:
         iday = 0
      while ( iday > daymax or iday < 1 ):
         day = str(daymax)
         print "Doh!  Enter a proper day"
         day = self.stdin_read(prompt=pstr, default=day)
         try:
            iday = int(day)
         except:
            iday = 0

      datestring = ''.join([year, '-', month, '-', day])

      return datestring

