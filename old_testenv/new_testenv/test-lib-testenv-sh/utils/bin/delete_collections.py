#!/usr/bin/python

import re
import sys
import vapi_interface
import velocityAPI


def all_collections():
   """Return a list of all collection names."""
   return velocityAPI.VelocityAPI().repository_list_xml().xpath(
      'vse-collection/@name')


def delete_collections_matching(wildcard):
   """Delete every existing collection matching a wildcard."""
   yy = vapi_interface.VAPIINTERFACE()
   for collection_name in filter(re.compile(wildcard).match, all_collections()):
      print 'deleting', collection_name, '...',
      sys.stdout.flush()
      if yy.cleanup_collection(collection_name, delete=True):
         print 'done.'
      sys.stdout.flush()


if __name__ == "__main__":
   if len(sys.argv) > 1:
      for wildcard in sys.argv[1:]:
         delete_collections_matching(wildcard)
   else:
      print 'usage:', sys.argv[0], 'wildcard [wildcard ...]'
