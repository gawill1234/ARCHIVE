#!/usr/bin/python

"""Do a simple query test, where PASS/FAIL is determined by the count
of results returned by a series of queries.

Two XML files need to be in place in the current working directory:
collection-name.xml - contains the Velocity collection configuration.
collection-name-results.xml - contains queries and result counts.

When this script finishes up, it writes out another XML file:
collection-name-actual-results.xml
which is the same format as the input results.xml file, but with the
actual counts seen from this run of the test. This output XML file can
be used as the baseline results for future runs of the test.

Example bootstrap: do an initial run with a simple-results.xml file like this:
<bootstrap-results>
  <query>ask</query>
  <query>bing</query>
  <query>clusty</query>
  <query>google</query>
  <query>yahoo</query>
</bootstrap-results>

At the end of the run a file named querywork/simple-actual-results.xml
will be written looking like this (I just made up these numbers):
<actual-results crawler-status--n-output="296598" vse-index-status--n-docs="203616">>
  <query count="20">ask</query>
  <query count="327">bing</query>
  <query count="4">clusty</query>
  <query count="12943">google</query>
  <query count="3474">yahoo</query>
</actual-results>

This file can be used for checking the query result counts for future
runs of the test.
"""

import codecs
import os
import sys
import time
import velocityAPI
from lxml import etree

sys.stderr = codecs.getwriter('utf-8')(sys.stderr)
sys.stdout = codecs.getwriter('utf-8')(sys.stdout)

#### Run time options (should be settable from the command line).

# Compare results from our normal, fast, query with a huge query.
compare_with_big_query = False

test_name = ''                    # Set in 'main'

def msg(text):
    """Just formatted output to stdout."""
    human_time = time.ctime().split()[3]
    print human_time, test_name, str(text)


STATUS_XPATH = 'added-source/parse/@status'
# I think this number is good for comparisons across crawls.
TOTAL_RESULTS_WITH_DUPS_XPATH = 'added-source/@total-results-with-duplicates'
# But, I'm not sure yet. The heavy version also gets these and compares them.
TOTAL_RESULTS_XPATH = 'added-source/@total-results'
SOURCE_RETRIEVED_XPATH = 'added-source/@retrieved'
PARSE_RETRIEVED_XPATH = 'added-source/parse/@retrieved'
LIST_NUM_XPATH = 'list/@num'

def search(sources, query):
    """Do a single query and return the count of results found."""
    # Try a simple search
    resp = velocityAPI.VelocityAPI().query_search(query=query,
                                                  sources=sources)
    # Make sure each source behaved
    if frozenset(resp.xpath(STATUS_XPATH)) \
            != frozenset(['fetched processed parsed']):
        msg('Unexpected status return from simple query: '
            + str(resp.xpath(STATUS_XPATH)))
        return -1
    simple_count = sum([int(i) for i in
                        resp.xpath(TOTAL_RESULTS_WITH_DUPS_XPATH)])

    if compare_with_big_query:
        # To gain confidence in the number gathered above,
        # try really getting all the results and check those counts.
        resp = velocityAPI.VelocityAPI().query_search(query=query,
                                                      sources=sources,
                                                      num=200000,
                                                      num_over_request=1000,
                                                      output_duplicates='true')
        # Make sure each source behaved
        if frozenset(resp.xpath(STATUS_XPATH)) \
                != frozenset(['fetched processed parsed']):
            msg('Unexpected status return from big query: '
                + str(resp.xpath(STATUS_XPATH)))
            return -1
        total_results = sum([int(i) for i in resp.xpath(TOTAL_RESULTS_XPATH)])
        total_results_with_dups \
            = sum([int(i) for i in resp.xpath(TOTAL_RESULTS_WITH_DUPS_XPATH)])
        source_retrieved \
            = sum([int(i) for i in resp.xpath(SOURCE_RETRIEVED_XPATH)])
        parse_retrieved \
            = sum([int(i) for i in resp.xpath(PARSE_RETRIEVED_XPATH)])
        list_num = sum([int(i) for i in resp.xpath(LIST_NUM_XPATH)])
        # Make sure all my counts match each other.
        if frozenset([simple_count,
                      total_results,
                      total_results_with_dups,
                      source_retrieved,
                      parse_retrieved,
                      list_num]) \
                != frozenset([total_results]):
            msg('Unmatched result counts. The simple result count was '
                + str(simple_count))
            msg(TOTAL_RESULTS_XPATH + ' gave ' + str(total_results))
            msg(TOTAL_RESULTS_WITH_DUPS_XPATH + ' gave '
                + str(total_results_with_dups))
            msg(SOURCE_RETRIEVED_XPATH + ' gave ' + str(source_retrieved))
            msg(PARSE_RETRIEVED_XPATH + ' gave ' + str(parse_retrieved))
            msg(LIST_NUM_XPATH + ' gave ' + str(list_num))
    return simple_count


def initialize_actual_results(collection_name):
    actual_results = etree.Element('actual-results')
    scs = velocityAPI.VelocityAPI().search_collection_status(
        collection=collection_name)
    if scs.tag == 'vse-status':
        check_list = ['crawler-status/@n-output',
                      'vse-index-status/@n-docs']
        for check in check_list:
            basename = check.replace('/', '-').replace('@', '-')
            if len(scs.xpath(check)) > 0:
                actual_results.set(basename, scs.xpath(check)[0])
    return actual_results


def check_results(collection_name):
    """Run each query and check the number of results returned
    (with duplicates) against expected.

    We save the actual results under 'querywork'.
    This makes it easy to bootstrap a new test, just create a
    collection-results.xml file with each query in it and no counts."""
    success = True
    expected_results = etree.parse(collection_name + '-results.xml').getroot()
    actual_results = initialize_actual_results(collection_name)
    for i, query in enumerate(expected_results.xpath('query')):
        n = search(collection_name, query.text)
        arq = etree.SubElement(actual_results, 'query', count=str(n))
        arq.text = query.text
        if n == int(query.get('count', -1)):
            print i,
            sys.stdout.flush()
        else:
            print
            print '%d - expected: %s, found %d for:' \
                % (i, query.get('count'), n), query.text
            success = False
    print
    f = open('querywork/%s-actual-results.xml' % collection_name, 'w')
    try:
        f.write(etree.tostring(actual_results,
                               encoding='utf-8',
                               xml_declaration=True,
                               pretty_print=True))
    finally:
        f.close()
    return success


def shutdown_collection(collection_name, kill=None):
    """Stop the crawler and indexer for a collection."""
    vapi = velocityAPI.VelocityAPI()
    vapi.search_collection_crawler_stop(collection=collection_name, kill=kill)
    vapi.search_collection_indexer_stop(collection=collection_name, kill=kill)


def create_collection(collection_name):
    """Create a collection.
    If the collection already exists, stop, delete, then create it."""
    vapi = velocityAPI.VelocityAPI()
    retry = True
    while retry:
        try:
            resp = vapi.search_collection_create(collection=collection_name,
                                                 based_on='default')
            retry = False
        except velocityAPI.VelocityAPIexception:
            exception = sys.exc_info()[1][0]
            if exception.get('name') != 'search-collection-already-exists':
                raise
            msg('Removing the existing collection "%s".' % collection_name)
            shutdown_collection(collection_name, 'kill')
            try:
                vapi.search_collection_delete(collection=collection_name)
            except velocityAPI.VelocityAPIexception:
                pass
    xml = etree.parse(collection_name + '.xml')

    # Do the magic index options.
    if os.environ.has_key('INDEX_OPTIONS'):
       # I'm probably assuming too much here; may lead to crashes.
       vse_index = xml.xpath('/vse-collection/vse-config/vse-index')[0]
       opts = dict([nv.split('=') for nv in
                    os.environ['INDEX_OPTIONS'].split(',')])
       for name, value in opts.iteritems():
          index_option = vse_index.xpath('vse-index-option[@name="%s"]'%name)
          if index_option:
             # Grab the last one (should be the only one).
             index_option = index_option[-1]
          else:
             # Create a new index option element.
             index_option = etree.SubElement(vse_index,
                                             'vse-index-option',
                                             name=name)
          index_option.text = value

    resp = vapi.search_collection_set_xml(collection=collection_name,
                                          xml=etree.tostring(xml))
    assert resp.tag == '__CONTAINER__', etree.tostring(resp)
    msg('Collection "%s" created.' % collection_name)
    return True


def wait_for_crawl(collection_name, verbose=True):
    """Wait for a crawl and index to complete.
    With 'verbose=True', prints crawl progress messages while waiting."""
    vapi = velocityAPI.VelocityAPI()

    # Wait for the crawler to do its work.
    sleep_time = 1     # Start with a few short sleeps, then on the five minute
    while True:
        sleep_time = min(8*sleep_time, 300-time.time()%300)
        time.sleep(sleep_time)
        scs = vapi.search_collection_status(collection=collection_name)
        if scs.xpath('crawler-status/@service-status') == ['stopped']:
            msg('Crawl complete.')
            break
        elif verbose:
            n_input  = int(scs.xpath('crawler-status/@n-input')[0])
            n_output = int(scs.xpath('crawler-status/@n-output')[0])
            percent = int(100.0*n_output/max(1,n_input))
            msg('Crawling: %d/%d - %d%%' % (n_output, n_input, percent))

    # Wait for the indexer to go idle--expect it to be quick.
    while scs.xpath('vse-index-status/@idle') != ['idle'] \
            and scs.xpath('vse-index-status/@service-status') != ['stopped']:
        time.sleep(2)
        scs = vapi.search_collection_status(collection=collection_name)

    if verbose:
        msg('Indexer status: %s and idle: %s'
            % (scs.xpath('vse-index-status/@service-status'),
               scs.xpath('vse-index-status/@idle')))


MISMATCH = 0
COMPLETE = 1
CRAWLING = 2

def check_crawl(collection_name, verbose=False):
    """Check the results of a crawl.
    Returns one of three statuses: MISMATCH, COMPLETE or CRAWLING.
    With 'verbose=True', also prints messages about the status."""
    vapi = velocityAPI.VelocityAPI()
    try:
        scs = vapi.search_collection_status(collection=collection_name)
    except velocityAPI.VelocityAPIexception:
        if verbose:
            msg('Collection %s does not exist.' % collection_name)
        return MISMATCH
    expected_results = etree.parse(collection_name + '-results.xml').getroot()
    check = 'crawler-status/@service-status'
    if scs.xpath(check) == ['running']:
        if verbose:
            msg('Crawler running for collection %s.' % collection_name)
        return CRAWLING
    return_status = COMPLETE    # Assume success, then check it...
    check_list = ['crawler-status/@n-output',
                  'vse-index-status/@n-docs']
    for check in check_list:
        baseline = check.replace('/', '-').replace('@', '-')
        if scs.xpath(check) == [expected_results.get(baseline)]:
            if verbose:
                msg('%s="%s", as expected.' % (check,
                                               expected_results.get(baseline)))
        else:
            if verbose:
                msg('Expected %s="%s", found %s.'
                    % (check,
                       expected_results.get(baseline),
                       scs.xpath(check)))
            return_status = MISMATCH
    return return_status


def create_and_crawl(collection_name):
    """Create and crawl a collection (if needed)."""
    vapi = velocityAPI.VelocityAPI()
    resp = vapi.search_service_start()
    index_status = check_crawl(collection_name)
    # If the crawl and index are already the right sizes, just use it.
    if index_status == COMPLETE:
        resp = vapi.search_collection_indexer_start(collection=collection_name)
        msg('Using existing index for %s' % collection_name)
    else:
        # Assume a running crawl is the right thing for us.
        if index_status == CRAWLING:
            msg('Continuing with pre-existing crawl for %s' % collection_name)
        else:
            create_collection(collection_name)
            resp = vapi.search_collection_crawler_start(
                collection=collection_name)
        wait_for_crawl(collection_name)
    # Tell the user about the crawl stats (and proceed in any case).
    check_crawl(collection_name, verbose=True)
    return


def main(test_script, test_description, collection_name_list):
    """Run the test."""
    global test_name
    test_name = os.path.basename(test_script).replace('.tst', ':')
    msg('Initialize: ' + test_script)
    msg(test_description)
    failed = False
    for collection_name in collection_name_list:
        create_and_crawl(collection_name)
        msg('Collection "%s" setup, running queries ...' % collection_name)
        if check_results(collection_name):
            msg('Collection "%s" passed.' % collection_name)
        else:
            msg('Collection "%s" failed.' % collection_name)
            failed = True
    if failed:
        msg('TEST FAILED.')
        return 1                # Unix-style status code
    shutdown_collection(collection_name)
    msg('TEST PASSED.')
    return 0                    # Unix-style status code


if __name__ == "__main__":
    if len(sys.argv) < 4:
        print 'usage:', sys.argv[0],\
            'test_script test_description collection_name [collection_name ...]'
        sys.exit(2)
    sys.exit(main(sys.argv[1], sys.argv[2], sys.argv[3:]))
