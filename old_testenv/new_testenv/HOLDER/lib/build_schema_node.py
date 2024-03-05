#!/usr/bin/python

from lxml import etree
import Queue
import os
import sys
import time
import random
import threaded_work
import velocityAPI

def create_completed_crawl(addnodeto=None):

   crawlrpcs = etree.Element('completed-crawl')


   if ( addnodeto is not None ):
      crawlrpcs = etree.SubElement(addnodeto, crawlrpcs.tag, 
                                  crawlrpcs.attrib)

   return crawlrpcs

def create_indexed_crawl(addnodeto=None):

   crawlrpcs = etree.Element('indexed-crawl')


   if ( addnodeto is not None ):
      crawlrpcs = etree.SubElement(addnodeto, crawlrpcs.tag, 
                                  crawlrpcs.attrib)

   return crawlrpcs

def create_crawl_links(addnodeto=None):

   crawlrpcs = etree.Element('crawl-links')


   if ( addnodeto is not None ):
      crawlrpcs = etree.SubElement(addnodeto, crawlrpcs.tag, 
                                  crawlrpcs.attrib)

   return crawlrpcs

def create_crawl_link(addnodeto=None, url=None):

   crawlrpc = etree.Element('crawl-link')

   attributes = crawlrpc.attrib
   if ( url is not None ):
      attributes["url"] = url

   if ( addnodeto is not None ):
      crawlrpc = etree.SubElement(addnodeto, crawlrpc.tag, 
                                  crawlrpc.attrib)

   return crawlrpc

def create_crawler_rpcs(addnodeto=None):

   crawlrpcs = etree.Element('crawler-rpcs')


   if ( addnodeto is not None ):
      crawlrpcs = etree.SubElement(addnodeto, crawlrpcs.tag, 
                                  crawlrpcs.attrib)

   return crawlrpcs

def create_crawler_rpc(addnodeto=None, name=None,
                       id=None, reply=None):

   crawlrpc = etree.Element('crawler-rpc')

   attributes = crawlrpc.attrib
   if ( rpcname is not None ):
      attributes["name"] = rpcname
   if ( rpcid is not None ):
      attributes["id"] = rpcid
   if ( rpcreply is not None ):
      attributes["reply"] = rpcreply

   if ( addnodeto is not None ):
      crawlrpc = etree.SubElement(addnodeto, crawlrpc.tag, 
                                  crawlrpc.attrib)

   return crawlrpc

def create_crawler_rpc_available(addnodeto=None, collection=None,
                                 crawl_id=None, counter=None):

   crawlrpc = etree.Element('crawler-rpc-available')

   attributes = crawlrpc.attrib
   if ( collection is not None ):
      attributes["collection"] = collection
   if ( counter is not None ):
      attributes["counter"] = counter
   if ( crawlid is not None ):
      attributes["crawl-id"] = crawlid

   if ( addnodeto is not None ):
      crawlrpc = etree.SubElement(addnodeto, crawlrpc.tag, 
                                  crawlrpc.attrib)

   return crawlrpc

def create_crawler_rpc_update(addnodeto=None, 
                              collection=None,
                              counter=None,
                              updtime=None, 
                              collection_dependency=None,
                              collection_previous=None,
                              counter_dependency=None,
                              counter_previous=None):

   crawlupd = etree.Element('crawler-rpc-update')

   attributes = crawlupd.attrib
   if ( collection is not None ):
      attributes["collection"] = collection
   if ( counter is not None ):
      attributes["counter"] = counter
   if ( updtime is not None ):
      attributes["time"] = updtime
   if ( collection_dependency is not None ):
      attributes["collection-dependency"] = collection_dependency
   if ( collection_previous is not None ):
      attributes["collection-previous"] = collection_previous
   if ( counter_dependency is not None ):
      attributes["counter-dependency"] = counter_dependency
   if ( counter_previous is not None ):
      attributes["counter-previous"] = counter_previous

   if ( addnodeto is not None ):
      crawlupd = etree.SubElement(addnodeto, crawlupd.tag, 
                                  crawlupd.attrib)

   return crawlupd

def create_crawler_rpc_request(addnodeto=None, collection=None):

   crawlrpc = etree.Element('crawler-rpc-request')

   attributes = crawlrpc.attrib
   if ( collection is not None ):
      attributes["collection"] = collection

   if ( addnodeto is not None ):
      crawlrpc = etree.SubElement(addnodeto, crawlrpc.tag, 
                                  crawlrpc.attrib)

   return crawlrpc

def create_crawler_rpc_applied(addnodeto=None, collection=None):

   crawlrpc = etree.Element('crawler-rpc-applied')

   attributes = crawlrpc.attrib
   if ( collection is not None ):
      attributes["collection"] = collection

   if ( addnodeto is not None ):
      crawlrpc = etree.SubElement(addnodeto, crawlrpc.tag, 
                                  crawlrpc.attrib)

   return crawlrpc

def create_crawler_rpc_range(addnodeto=None, crfrom=None, crto=None):

   crawlrpc = etree.Element('crawler-rpc-range')

   attributes = crawlrpc.attrib
   if ( crfrom is not None ):
      attributes["from"] = crfrom
   if ( crto is not None ):
      attributes["to"] = crto

   if ( addnodeto is not None ):
      crawlrpc = etree.SubElement(addnodeto, crawlrpc.tag, 
                                  crawlrpc.attrib)

   return crawlrpc

def create_cb_element(addnodeto=None, elemname=None, value=None):

   if ( elemname is None ):
      return

   cbm = etree.Element(elemname)

   if ( addnodeto is not None ):
      cbm = etree.SubElement(addnodeto, cbm.tag, 
                             cbm.attrib)

   if ( value is not None ):
      cbm.text = value.decode('utf-8', 'replace')

   return cbm

def isInList(checkfor, thelist):

   for item in thelist:
      if ( item == checkfor ):
         return 1

   return 0

def schema_twiddle_elem_name(name):

   return name.replace('__', '.').replace('_', '-')


def create_cb_config(**myparams):

    valid_list = ['maximum-collections', 'prefer-requests',
                  'minimum-free-memory', 'overcommit-factor',
                  'indexer-overhead', 'crawler-overhead',
                  'indexer-minimum', 'crawler-minimum',
                  'memory-granularity', 'check-online-time',
                  'current-status-time', 'start-offline-time',
                  'find-new-collections-time', 'check-memory-usage-time',
                  'persistent-save-time', 'live-ping-probability',
                  'always-allow-one-collection']

    cbconf = etree.Element('collection-broker-configuration')

    attributes = cbconf.attrib
    attributes["name"] = 'global'

    for key, value in myparams.items():
       if ( value is not None ):
          myelement = schema_twiddle_elem_name(key)
          if ( isInList(myelement, valid_list) ):
             create_cb_element(addnodeto=cbconf,
                               elemname=myelement,
                               value=value)
          else:
             print "create_cb_config:  ignoring illegal config element:", myelement

    return cbconf


def create_vse_config(addnodeto=None):

    vseconf = etree.Element('vse-config')

    attributes = vseconf.attrib

    if ( addnodeto is not None ):
       vseconf = etree.SubElement(addnodeto, vseconf.tag, 
                                  vseconf.attrib)

    return vseconf

def create_vse_collection(name=None, addnodeto=None):

    vsecoll = etree.Element('vse-collection')

    attributes = vsecoll.attrib

    if ( name is not None ):
       attributes["name"] = name

    if ( addnodeto is not None ):
       vsecoll = etree.SubElement(addnodeto, vsecoll.tag, 
                                  vsecoll.attrib)

    return vsecoll

def create_crawler(addnodeto=None):

    crawler = etree.Element('crawler')

    attributes = crawler.attrib

    if ( addnodeto is not None ):
       crawler = etree.SubElement(addnodeto, crawler.tag, 
                                  crawler.attrib)

    return crawler


def create_crawl_options(addnodeto=None):

   crawlopts = etree.Element('crawl-options')

   if ( addnodeto is not None ):
      crawlopts = etree.SubElement(addnodeto, crawlopts.tag, 
                                  crawlopts.attrib)

   return crawlopts

def create_crawl_option(name=None, text=None, addnodeto=None):

    crawlopt = etree.Element('crawl-option')

    attributes = crawlopt.attrib

    if ( name is not None ):
       attributes["name"] = name

    if ( addnodeto is not None ):
       crawlopt = etree.SubElement(addnodeto, crawlopt.tag, 
                                  crawlopt.attrib)

    if ( text is not None ):
       crawlopt.text = text.decode('utf-8', 'replace')

    return crawlopt

def create_curl_options(addnodeto=None):

   curlopts = etree.Element('curl-options')

   if ( addnodeto is not None ):
      curlopts = etree.SubElement(addnodeto, curlopts.tag, 
                                  curlopts.attrib)

   return curlopts

def create_curl_option(name=None, added=None, text=None, addnodeto=None):

    curlopt = etree.Element('curl-option')

    attributes = curlopt.attrib

    if ( name is not None ):
       attributes["name"] = name
    if ( added is not None ):
       attributes["added"] = added

    if ( addnodeto is not None ):
       curlopt = etree.SubElement(addnodeto, curlopt.tag, 
                                  curlopt.attrib)

    if ( text is not None ):
       curlopt.text = text.decode('utf-8', 'replace')

    return curlopt

def create_vce(addnodeto=None):

   vcenode = etree.Element('vce')

   if ( addnodeto is not None ):
      vcenode = etree.SubElement(addnodeto, vcenode.tag, 
                                  vcenode.attrib)

   return vcenode

def create_documents(async=None, addnodeto=None):

    docsnode = etree.Element('documents')

    attributes = docsnode.attrib

    if ( async is not None ):
       attributes["async"] = async

    if ( addnodeto is not None ):
       docsnode = etree.SubElement(addnodeto, docsnode.tag, 
                                  docsnode.attrib)

    return docsnode

def create_vxml(addnodeto=None):

    docsnode = etree.Element('vxml')

    if ( addnodeto is not None ):
       docsnode = etree.SubElement(addnodeto, docsnode.tag, 
                                  docsnode.attrib)

    return docsnode

def create_document(url=None, source=None, vsekey=None,
                    vsekeynormalized=None, addnodeto=None):

    docnode = etree.Element('document')

    attributes = docnode.attrib

    if ( url is not None ):
       attributes["url"] = url
    if ( source is not None ):
       attributes["source"] = source
    if ( vsekeynormalized is not None ):
       attributes["vse-key-normalized"] = "vse-key-normalized"
    if ( vsekey is not None ):
       attributes["vse-key"] = vsekey

    if ( addnodeto is not None ):
       docnode = etree.SubElement(addnodeto, docnode.tag, 
                                  docnode.attrib)

    return docnode

def create_content(name=None, text=None, acl=None, 
                   addto=None, vseaddtonorm=None,
                   filename=None, addnodeto=None):

    contentnode = etree.Element('content')

    attributes = contentnode.attrib

    if ( name is not None ):
       attributes["name"] = name
    if ( acl is not None ):
       attributes["acl"] = acl
    if ( addto is not None ):
       attributes["add-to"] = addto
    if ( vseaddtonorm is not None ):
       attributes["vse-add-to-normalized"] = "vse-add-to-normalized"

    if ( addnodeto is not None ):
       contentnode = etree.SubElement(addnodeto, contentnode.tag, 
                                     contentnode.attrib)

    if ( filename is not None ):
       f =  open(os.path.join(filename))
       contentnode.text = ''.join([line.decode('utf-8', 'replace')
                                  for line in f.readlines()])
       f.close()
    else:
       if ( text is not None ):
          contentnode.text = text.decode('utf-8', 'replace')

    return contentnode


def create_crawl_urls(synchronization=None):

    crawl_urls = etree.Element('crawl-urls')

    attributes = crawl_urls.attrib

    if ( synchronization is not None ):
       attributes["synchronization"] = synchronization

    return crawl_urls

def create_index_atomic(addnodeto=None, originator=None,
                        enqueueid=None, partial=None,
                        abortonerror=None, synchronization=None):

    index_atomic = etree.Element('index-atomic')

    attributes = index_atomic.attrib

    if ( originator is not None ):
       attributes["originator"] = originator
    if ( enqueueid is not None ):
       attributes["enqueue-id"] = '%s' % enqueueid
    if ( partial is not None ):
       attributes["partial"] = "partial"
    if ( abortonerror is not None ):
       attributes["abort-batch-on-error"] = "abort-batch-on-error"
    if ( synchronization is not None ):
       attributes["synchronization"] = synchronization

    if ( addnodeto is not None ):
       index_atomic = etree.SubElement(addnodeto, index_atomic.tag, 
                                     index_atomic.attrib)

    return index_atomic

def modify_index_atomic(index_atomic=None, originator=None,
                        enqueueid=None, partial=None,
                        abortonerror=None, synchronization=None):

    if ( index_atomic is None ):
       return None

    attributes = index_atomic.attrib

    if ( originator is not None ):
       attributes["originator"] = originator
    if ( enqueueid is not None ):
       attributes["enqueue-id"] = '%s' % enqueueid
    if ( partial is not None ):
       attributes["partial"] = "partial"
    if ( abortonerror is not None ):
       attributes["abort-batch-on-error"] = "abort-batch-on-error"
    if ( synchronization is not None ):
       attributes["synchronization"] = synchronization

    return index_atomic

def create_crawl_data(encoding=None, contenttype=None, text=None,
                      addnodeto=None, filename=None):

    crawl_data = etree.Element('crawl-data')

    attributes = crawl_data.attrib

    if ( encoding is not None ):
       attributes["encoding"] = encoding
    if ( contenttype is not None ):
       attributes["content-type"] = contenttype

    if ( addnodeto is not None ):
       crawl_data = etree.SubElement(addnodeto, crawl_data.tag, 
                                     crawl_data.attrib)

    if ( filename is not None ):
       f =  open(os.path.join(filename))
       crawl_data.text = ''.join([line.decode('utf-8', 'replace')
                                  for line in f.readlines()])
       f.close()
    else:
       if ( text is not None ):
          crawl_data.text = text.decode('utf-8', 'replace')

    #print etree.tostring(crawl_data)

    return crawl_data

def create_crawl_url(url=None, status=None, enqueuetype=None,
                     synchronization=None,  addnodeto=None,
                     forcevsekeynorm=None, arena=None,
                     originator=None, enqueueid=None,
                     parenturl=None, parenturlnorm=None):

    crawl_url = etree.Element('crawl-url')

    attributes = crawl_url.attrib

    if ( url is not None ):
       attributes["url"] = url.decode('utf-8', 'replace')
    if ( parenturl is not None ):
       attributes["parent-url"] = parenturl
    if ( parenturlnorm is not None ):
       attributes["parent-url-normalized"] = 'parent-url-normalized'
    if ( synchronization is not None ):
       attributes["synchronization"] = synchronization
    if ( status is not None ):
       attributes["status"] = status
    if ( arena is not None ):
       attributes["arena"] = arena
    if ( enqueuetype is not None ):
       attributes["enqueue-type"] = enqueuetype
    if ( originator is not None ):
       attributes["originator"] = originator
    if ( enqueueid is not None ):
       attributes["enqueue-id"] = '%s' % enqueueid
    if ( forcevsekeynorm is not None ):
       attributes["forced-vse-key-normalized"] = "forced-vse-key-normalized"

    if ( addnodeto is not None ):
       crawl_url = etree.SubElement(addnodeto, crawl_url.tag, crawl_url.attrib)

    #print etree.tostring(crawl_url)

    return crawl_url

def create_crawl_delete(url=None, addnodeto=None, originator=None,
                        vsekey=None, synchronization=None,
                        enqueueid=None, recursive=None):

    crawl_delete = etree.Element('crawl-delete')

    attributes = crawl_delete.attrib

    if ( url is not None ):
       attributes["url"] = url.decode('utf-8', 'replace')
    if ( vsekey is not None ):
       attributes["vse-key"] = vsekey.decode('utf-8', 'replace')
    if ( recursive is not None ):
       attributes["recursive"] = 'recursive'
    if ( originator is not None ):
       attributes["originator"] = originator
    if ( enqueueid is not None ):
       attributes["enqueue-id"] = '%s' % enqueueid
    if ( synchronization is not None ):
       attributes["synchronization"] = synchronization

    if ( addnodeto is not None ):
       crawl_delete = etree.SubElement(addnodeto, crawl_delete.tag,
                                       crawl_delete.attrib)

    #print etree.tostring(crawl_delete)

    return crawl_delete

