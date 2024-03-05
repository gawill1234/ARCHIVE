#!/usr/bin/python

import os, re, sys, string, shutil
from lxml import etree

import vapi_interface, cgi_interface

def build_http_string():

   target = os.getenv('VIVHOST')
   if ( target is None or target == '' ):
      return None

   vdir = os.getenv('VIVVIRTUALDIR')
   if ( vdir is None or vdir == '' ):
      return None

   targetos = os.getenv('VIVTARGETOS')
   if ( targetos is None or targetos == '' ):
      return None

   myvelo = 'velocity'
   if ( targetos == 'windows' ):
      myvelo = 'velocity.exe'

   httpstring = ''.join(['http://', target, '/', vdir, '/cgi-bin/', myvelo, '?v.app=api-soap&use-types=true&wsdl=1'])

   return httpstring

def get_build_xml_dir():

   global xx, yy

   basedir = xx.vivisimo_dir(which="base")
   filename = 'build.xml'

   # /var/apache2/htdocs/vivisimo/examples/java/API/build.xml
   fullfile = ''.join([basedir, "/examples/java/API/build.xml"])

   err = xx.get_file(getfile=fullfile)

   if ( err == 0 ):
      return filename
   
   return None

def do_import_replacement(filename=None):

   tagname = 'wsimport'
   attrname = 'binding'

   if ( filename is not None ):
      fd = open(filename, 'r+')

      xmltext = fd.read()

      mytree = etree.fromstring(xmltext)

      for elt in mytree.getiterator( tagname ):
         if ( elt.attrib.has_key( attrname ) ):
            del elt.attrib["binding"]
            break

      fd.close()

      fd = open(filename, 'w+')
      fd.write(etree.tostring(mytree))
      fd.close()

   return

def do_node_replacement(filename=None, httpstring=None):

   tagname = 'property'
   attrname = 'name'

   if ( filename is not None ):
      fd = open(filename, 'r+')

      xmltext = fd.read()

      mytree = etree.fromstring(xmltext)

      for elt in mytree.getiterator( tagname ):
         if ( elt.attrib.has_key( attrname ) ):
            if ( elt.get( attrname ) == 'wsdl.uri' ):
               elt.attrib["value"] = httpstring
               break

      tagname = 'target'
      attrname = 'name'
      for elt in mytree.getiterator( tagname ):
         if ( elt.attrib.has_key( attrname ) ):
            if ( elt.get( attrname ) == 'all' ):
               elt.attrib["depends"] ="${target.jar}" 
               break

      fd.close()

      fd = open(filename, 'w+')
      fd.write(etree.tostring(mytree))
      fd.close()

   return

def build_java_lib():

   try:
      os.mkdir('soapfault')
   except:
      pass

   print "Building SOAPFaultExceptionUtils.class"
   xx.exec_command_stdout('javac', 'SOAPFaultExceptionUtils.java', None)
   print "Done"

   try:
      shutil.move('SOAPFaultExceptionUtils.class', 'soapfault')
   except:
      pass

   print "Building API.class"
   xx.exec_command_stdout('javac', 'API.java', None)
   print "Done"

   return

if __name__ == "__main__":

   global xx, yy

   filename = "build.xml"

   xx = cgi_interface.CGIINTERFACE()

   thisdir = os.path.join(os.getenv('TEST_ROOT', None), 'lib')

   if ( os.access('jaxws-ri/build.xml', os.F_OK) == 0 ):
      print "You need to unpack JAXWS"
      print "To do that, in", thisdir, "do"
      print "java -jar JAXWS2.1.7-20090419.jar"
      print "Accept the license"
      sys.exit(1)

   httpstring = build_http_string()
   if ( httpstring is not None ):
      print "Set http string"
   else:
      print "Could not set http string"
      sys.exit(1)

   print "Getting build.xml"
   #shutil.copyfile('holdbuildxml', 'build.xml')
   filename = get_build_xml_dir()
   if ( filename is not None ):
      print "Got build.xml"
   else:
      print "Could not get build.xml"
      sys.exit(1)

   print "Setting target in build.xml"
   do_node_replacement(filename=filename, httpstring=httpstring)
   do_import_replacement(filename=filename)
   print "Done"

   cmdopts = ''.join(['-f ', filename])

   print "CMDOPTS:", cmdopts

   print "Building velocity.jar"
   xx.exec_command_stdout("ant", cmdopts, None)
   print "Done"

   build_java_lib()

   sys.exit(0)
