#!/usr/bin/python

import httplib, urllib, os, sys, time, string
import base64, mimetypes
import cba_auth
from toolenv import VIVTENV

class HTTPINTERFACE(object):

   ticket = None
   cba_cookie = None
   postit1 = None
   postit2 = None
   user = None
   password = None
   user_cookie = None
   port = None
   site = None
   host = None
   use_cba = False
   defheaders = {"Content-type": "text/html",
                 "Accept": "text/*"}

   USER_AGENT = "test-infrastructure"

   def __init__(self, site=None, port=None, env=None, use_cba=False):

      if ( env == None ):
         self.TENV = VIVTENV(envlist=[])
      else:
         self.TENV = env

      self.user = self.TENV.user
      self.password = self.TENV.pswd

      self.setsite(site)
      self.setport(port)
      self.host = ''.join([self.site, ':', "%s" % self.port])

      self.use_cba = use_cba
      if use_cba:
        self.get_cba_cookie()

      self.get_ticket()
      self.connected = 0

      return

   def split_cookies(self, cookiestring=None):

      if ( cookiestring == None ):
         return

      xx = cookiestring.split(';')
      cookielist = []

      for item in xx:
         zz = item.replace(',', '').split('=')
         try:
            zz[0] = zz[0].replace(' ', '')
            cookielist.append(zz)
         except:
            break

      for item in cookielist:
         try:
            if ( self.TENV.vivfloatversion < 7.5 ):
               if ( item[0] == 'vivisimo-ticket' ):
                  self.ticket = item[1]
            else:
               if ( item[0] == 'velocity-ticket' ):
                  self.ticket = item[1]
         except:
            break

      #print "USER:", self.user
      #print "TICKET:", self.ticket
      return

   def new_ticket_file_is_needed(self):
      ticketfile = ''.join([self.TENV.testroot, '/tmp/ticket.', self.site])
      try:
         xx = os.stat(ticketfile)
         q = time.time()
         age = q - xx.st_ctime
         if ( xx.st_size > 0 ):
            if ( age > 7200 ):
               os.remove(ticketfile)
               return True
         else:
            os.remove(ticketfile)
            return True
      except:
        return True

      #If we get here, then a new file is not required
      return False

   def get_admin_cgi_path(self):
         if ( self.TENV.targetos == "windows" ):
            return ''.join(['/', self.TENV.virtualdir, '/cgi-bin/admin.exe'])
         else:
            return ''.join(['/', self.TENV.virtualdir, '/cgi-bin/admin'])

   def get_cba_cookie(self):
     if ( self.new_ticket_file_is_needed() ):
         target_url = "https://" + self.host + self.get_admin_cgi_path()
         self.cba_cookie = cba_auth.fetch_cba_auth_cookie(target_url, self.user, self.password)

   def get_ticket(self, content=None):
      if ( content == None ):
         content_type = 'application/x-www-form-urlencoded'
      else:
         content_type = content

      ticketfile = ''.join([self.TENV.testroot, '/tmp/ticket.', self.site])

      if ( self.new_ticket_file_is_needed() ):
         blah = self.get_admin_cgi_path()
         headers = {"Content-type": "application/x-www-form-urlencoded"}
         # If we are using CBA, we have to use the CBA cookie to get the Velocity "ticket"
         if self.cba_cookie != None:
           headers["Cookie"] = self.cba_cookie

         body = {'id': 'login.logged', 'username': self.user, 'password': self.password}
         self.setconnection()
         if ( self.connected ):
            localconn = self.conn
            try:
               localconn.request( "POST", blah, urllib.urlencode(body), headers)
               resp = localconn.getresponse()
               cookie = resp.getheader( "set-cookie" )
               localconn.close()
            except:
               print "Get ticket failed"
               return

            if ( cookie != None ):
               self.split_cookies(cookie)

               if ( self.ticket != None ):
                  if ( self.TENV.vivfloatversion < 7.5 ):
                     thiscookie = ''.join(['vivisimo-username=', self.user, ';vivisimo-ticket=', self.ticket])
                  else:
                     thiscookie = ''.join(['vivisimo-username=', self.user, ';velocity-ticket=', self.ticket])

                  #print "Cookies before adding CBA: ", thiscookie
                  # If CBA was used, append the CBA Authentication Cookie
                  if self.cba_cookie != None:
                    thiscookie = thiscookie + ";" + self.cba_cookie

                  fd = open(ticketfile, 'a+')
                  fd.write(thiscookie)
                  fd.close()
               else:
                  print "No ticket.  Cookie =", cookie

               self.user_cookie = { 'Cookie' : thiscookie }
               self.postit1 = {'Content-Type':content_type, 'Content-Length':0, 'Cookie' : thiscookie }
               self.postit2 = {'Content-Type':content_type, 'Cookie' : thiscookie }
            else:
               print "Cookie get failed"
      else:
         fd = open(ticketfile, 'r')
         thiscookie = fd.read()
         fd.close()
         self.user_cookie = { 'Cookie' : thiscookie }
         self.postit1 = {'Content-Type':content_type, 'Content-Length':0, 'Cookie' : thiscookie }
         self.postit2 = {'Content-Type':content_type, 'Cookie' : thiscookie }
 
      return


   def uriit(self, string):

      #z = unicode(string, 'utf8')
      #return urllib.quote(z)
      return urllib.quote(string)


   def setsite(self, site=None):

      self.site = site

      if ( self.site == None ):
         print "You need a site to link to.  Required.  Exiting."
         sys.exit(99)

      return

   def setport(self, port=None):

      self.port = port

      if ( self.port == None ):
         self.port = 80

      return

   def doget(self, tocmd=None, argstring=None, dumpfile=None, binary=0):
      if ( tocmd != None ):
         myargs = ''.join([tocmd, '?', argstring])
      else:
         myargs = argstring

      basecmd = os.path.basename(tocmd)

      self.get_ticket()

      #print "CMD:"
      #print tocmd
      #print "MYARGS:"
      #print myargs

      err = 1
      self.setconnection()
      if ( self.connected ):
         try:
            if ( self.user_cookie != None ):
               self.conn.request("GET", myargs, None, self.user_cookie)
            else:
               self.conn.request("GET", myargs)

            r1 = None
            try:
               r1 = self.conn.getresponse()

               if ( (r1.status == 200) or (r1.status == 302) ):
                  err = 0
                  if ( dumpfile != None ):
                     if ( dumpfile != "/dev/null" ):
                        if (os.access(dumpfile, os.F_OK) == 0 ):
                           os.mknod(dumpfile, 0644)
                        try:
                           fd = open(dumpfile, 'w+')
                           try:
                              if ( binary == 0 ):
                                 fd.write(r1.read().replace('\r\n', '\n'))
                              else:
                                 fd.write(r1.read())
                              fd.close()
                           except OSError, e:
                              print "Could not write", dumpfile
                              print "Error:", e
                        except OSError, e:
                           print "Could not open", dumpfile
                           print "Error:", e
                  else:
                     err = r1.read()
               else:
                  print "http get request failed (", r1.status, r1.reason, ") for:"
                  print "  ", myargs
            except:
               print "No response from", tocmd
               if ( r1 == None ):
                  if ( ( basecmd == "velocity" ) or
                       ( basecmd == "velocity.exe" ) ):
                     err = 0
         except Exception, e:
            self.closeconnection()
            print "http_interface.doget() connection error"
            print "   using: ", myargs
            print "ERROR: ", e
            sys.exit(99)

         self.closeconnection()

      return err

   def vapipost(self, tocmd=None, argstring=None,
                argstring2='',
                datasize=0, outfile=None):

      self.get_ticket()

      err = 1
      ofd = None
      if ( argstring == None ):
         #uri = ''.join([tocmd, '?'])
         uri = tocmd
      else:
         uri = ''.join([tocmd, '?', argstring])
         #print uri
      basecmd = os.path.basename(tocmd)
      #print argstring2

      if ( outfile != None ):
         if (os.access(outfile, os.F_OK) == 0 ):
            os.mknod(outfile, 0644)
         ofd = open(outfile, 'w+')
      else:
         postbase = os.path.basename(postfile)
         outfile = ''.join(["querywork", "/", postbase, ".postres"])
         if (os.access(outfile, os.F_OK) == 0 ):
            os.mknod(outfile, 0644)
         ofd = open(outfile, 'w+')
     
      content_type = 'text/xml'
      if ( datasize == 0 ):
         if ( self.postit1 != None ):
            pt = self.postit1
         else:
            pt = {'Content-Type':content_type, 'Content-Length':0}
      else:
         if ( self.postit2 != None ):
            pt = self.postit2
         else:
            pt = {'Content-Type':content_type}

      #print pt
      r1 = None
      self.setconnection()
      if ( self.connected ):
         #print "URI:", uri
         #print "AS2:", argstring2
         self.conn.request("POST", uri, argstring2, pt)
         try:
            r1 = self.conn.getresponse()
            if ( r1.status == 200 ):
               err = 0
         except:
            print "No response from", tocmd
            if ( r1 == None ):
               if ( ( basecmd == "velocity" ) or
                    ( basecmd == "velocity.exe" ) ):
                  err = 0

      if ( r1 != None ):
         if ( err != 0 ):
            self.closeconnection()
            print "STATUS: ", r1.status
            print "Post failed"
            sys.exit(99)

         if (ofd != None ):
            ofd.write(r1.read())
            ofd.close()

         #print "STATUS: ", r1.status
      else:
         print "HTTP response returned nothing(None)"

      self.closeconnection()

      return err

   def dopost(self, tocmd=None, argstring=None, type=None, postfile=None, outfile=None):
      err = 1
      fd = None
      ofd = None
      uri = ''.join([tocmd, '?', argstring])
      basecmd = os.path.basename(tocmd)

      if ( outfile != None ):
         if (os.access(outfile, os.F_OK) == 0 ):
            os.mknod(outfile, 0644)
         ofd = open(outfile, 'w+')
      else:
         postbase = os.path.basename(postfile)
         outfile = ''.join(["querywork", "/", postbase, ".postres"])
         if (os.access(outfile, os.F_OK) == 0 ):
            os.mknod(outfile, 0644)
         ofd = open(outfile, 'w+')

      if ( postfile != None ):
         if (os.access(postfile, os.R_OK) == 1 ):
            datasize = os.stat(postfile).st_size
            fd = file(postfile, 'rb', datasize)

      if (fd == None):
         return
     
      content_type = 'application/x-www-form-urlencoded'
      if ( datasize == 0 ):
         if ( self.postit1 != None ):
            pt = self.postit1
         else:
            pt = {'Content-Type':content_type, 'Content-Length':0}
      else:
         if ( self.postit2 != None ):
            pt = self.postit2
         else:
            pt = {'Content-Type':content_type}

      self.setconnection()
      if ( self.connected ):
         self.conn.request("POST", uri, urllib.quote(fd.read()), pt)
         try:
            r1 = self.conn.getresponse()
            if ( r1.status == 200 ):
               err = 0
         except:
            print "No response from", tocmd
            if ( r1 == None ):
               if ( ( basecmd == "velocity" ) or
                    ( basecmd == "velocity.exe" ) ):
                  err = 0

      if ( err != 0 ):
         self.closeconnection()
         fd.close()
         print "STATUS: ", r1.status
         print "Post failed"
         sys.exit(99)

      if (ofd != None ):
         ofd.write(r1.read())
         ofd.close()

      self.closeconnection()

      fd.close()

      return err
   
   def get_content_type(self, filename):
       return mimetypes.guess_type(filename)[0] or 'application/octet-stream'


   def setconnection(self):

      self.connected = 0

      try:
         if self.use_cba:
             # CBA Authentication requires that Velocity is using SSL
             self.conn = httplib.HTTPSConnection(self.site, self.port)
         else:
             self.conn = httplib.HTTPConnection(self.site, self.port)

         self.connected = 1
      except:
         print "Barf on connect: ", self.site,":",self.port
         sys.exit(99)

      return

   def closeconnection(self):

      self.conn.close()

      return

if __name__ == "__main__":
   junk = HTTPINTERFACE("testbed4")

   junk.doget(argstring="/index.html")
   junk.doget(tocmd="/vivisimo/cgi-bin/gronk", argstring="action=get-collection&collection=oracle-1&type=binary", dumpfile='wazzat')
   #junk.dopost(getfile='junk.py', tocmd="/vivisimo/cgi-bin/gronk", argstring="action=send-file&file=/tmp/dumb", type="text/html")


