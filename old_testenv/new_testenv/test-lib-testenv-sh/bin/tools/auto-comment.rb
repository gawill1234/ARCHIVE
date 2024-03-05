#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# When run as a script, command line arguments are log file names to check.
# The filename paths need to exactly match LogFilePath in the Gauge database.

# A typical run is something like this:
# find /home/adams/testrun -name '*.std???' -mtime -1 | xargs auto-comment.rb

require 'comment-fail'

# List of matchers. Each matcher is a simple hash.
# - bug: A Bugzilla bug number for what got matched. Optional.
# - comment: The comment for what got matched.
# - filenames: list of regular expressions that all must match the log filename
# - logs: list of regular expressions that all must match the log file contents

# These guys are a bit too loose to run all the time.
# They might match things they should not.
DISABLED_MATCHERS =
  [
   {
     comment: 'Passed. False failure due to a system reporting message from an earlier test.',
     filenames: [/\.stdout$/],
     logs: [/ 0 of [0-9]* cases failed/]
   },
   ###########################################################################
  ]

# These are the real matchers.
MATCHERS =
  [
   ###########################################################################
   {
     bug: 27229,
     comment: 'enhance regression test automation to support JP builds',
     filenames: [/\.stderr$/],
     logs: ['ValueError: invalid literal for float(): JP']
   },
   ###########################################################################
   { bug: 24557,
     comment: 'Collection size is wrong; Expected: 702; Actual: 0',
     filenames: [/\/api-sc-read-only-p6\.stdout$/],
     logs: [
            # The test failed (mostly means: it did not crash)
            '
api_sc_read_only_p6 :  Test Failed
',
            # Only the expected "Section five failed", no others
            '
api_sc_read_only_p6 :   Section one result, enable read only mode
api_sc_read_only_p6 :      Section one passed
api_sc_read_only_p6 :   Section two result, initial query results correct
api_sc_read_only_p6 :      Section two passed
api_sc_read_only_p6 :   Section three result, interim query results correct
api_sc_read_only_p6 :      Section three passed
api_sc_read_only_p6 :   Section four result, disable read only mode
api_sc_read_only_p6 :      Section four passed
api_sc_read_only_p6 :   Section five result, final query results correct
api_sc_read_only_p6 :      Section five failed
',
            # At least one detail issue looks like this
            '
api_sc_read_only_p6 :      Expected,  702
api_sc_read_only_p6 :      Actual,    0
api_sc_read_only_p6 :      Collection size is wrong
']
   },
   ###########################################################################
   ###########################################################################
   { bug: 25633,
     comment: 'index-atomic siphoning is inconsistent',
     filenames: [/\/api-sc-index-atomic-13\.stdout$/],
     logs: ['
api-sc-index-atomic-13 :  transaction count and entrycount do not match
api-sc-index-atomic-13 :  transaction count and successcount do not match
api-sc-index-atomic-13 :  ##################
api-sc-index-atomic-13 :  Test Failed
']
   },
   ###########################################################################
   { bug: 26850,
     comment: 'Invalid expression while evaluating XPath file:create-directory($dir-md5, true())',
     filenames: [/\.stderr$/],
     logs: ['Error <string name="error">Invalid expression</string> while evaluating XPath <string name="xpath">file:create-directory($dir-md5, true())</string> ']
   },
   ###########################################################################
   { bug: 24113,
     comment: 'The exception [collection-broker-terminating] was thrown.',
     filenames: [/\.stderr$/],
     logs: ['<exception name="collection-broker-terminating" ']
   },
   ###########################################################################
   { bug: 24113,
     comment: 'The exception [collection-broker-terminating] was thrown.',
     filenames: [/\.stderr$/],
     logs: [/<exception date="[0-9]*" id="COLLECTION_BROKER_TERMINATING" name="collection-broker-terminating" /]
   },
   ###########################################################################
   { bug: 24113,
     comment: 'The exception [collection-broker-terminating] was thrown.',
     filenames: [],
     logs: [
            # The test failed with a single error.
/Tests run: [0-9]*, Errors: 1, Failures: 0, Inconclusive: 0, Time: [0-9]*.[0-9]* seconds/,
            # The error signature looks like this:
            '
   System.Web.Services.Protocols.SoapException : The exception [collection-broker-terminating] was thrown.']
   },
   ###########################################################################
   { bug: 24113,
     comment: 'The exception [collection-broker-terminating] was thrown.',
     filenames: [],
     logs: [
            # The test failed with a single failure.
/Tests run: [0-9]*, Errors: 0, Failures: 1, Inconclusive: 0, Time: [0-9]*.[0-9]* seconds/,
            # The error signature looks like this:
            '
   SoapException caught: The exception [collection-broker-terminating] was thrown.']
   },
   ###########################################################################
   { bug: 23589,
     comment: 'The exception [file-lock-error] was thrown.',
     filenames: [],
     logs: [
            # The test failed with a single error.
/Tests run: [0-9]*, Errors: 1, Failures: 0, Inconclusive: 0, Time: [0-9]*.[0-9]* seconds/,
            # The error signature looks like this:
            '
   System.Web.Services.Protocols.SoapException : The exception [file-lock-error] was thrown.']
   },
   ###########################################################################
   { bug: 23589,
     comment: 'The exception [file-lock-error] was thrown.',
     filenames: [],
     logs: [
            # The test failed with a single error.
/Tests run: [0-9]*, Errors: 0, Failures: 1, Inconclusive: 0, Time: [0-9]*.[0-9]* seconds/,
            # The error signature looks like this:
            '
   SoapException caught: The exception [file-lock-error] was thrown.']
   },
   ###########################################################################
   { bug: 23589,
     comment: 'The exception [file-lock-error] was thrown.',
     filenames: [/\.stderr$/],
     logs: [/<exception time="[0-9]*" date="[0-9]*" id="FILE_LOCK" function=/]
   },
   ###########################################################################
   { bug: 25673,
     comment: 'The exception [search-collection-crawler-start] was thrown.',
     filenames: [],
     # The Java tests have ugly failure modes. Not a lot to cross check here.
     logs: ['
Exception in thread "main" javax.xml.ws.soap.SOAPFaultException: The exception [search-collection-crawler-start] was thrown.
']
   },
   ###########################################################################
   { bug: 24082,
     comment: 'maximum time on 32 bit Linux is five hours early',
     filenames: [/\/testbed10\/.*\/viv-parse-date-32\/viv-parse-date-32.stdout$/],
     logs: ['Test failed. 3 steps failed (out of 21):
step 14 fail: 2038-01-18T22:14:08Z mis-match 1970-01-01 00:00:00 UTC (off by -24854d 22:14:08).
step 15 fail: 2038-01-19T03:14:00Z mis-match 1970-01-01 00:00:00 UTC (off by -24855d 3:14:00).
step 16 fail: 2038-01-19T03:14:07Z mis-match 1970-01-01 00:00:00 UTC (off by -24855d 3:14:07).
']
   },
   ###########################################################################
   { bug: 24083,
     comment: 'viv:parse-date is 32bit only on 32bit Linux',
     filenames: [/\/testbed10\/.*\/viv-parse-date-tolerant\/viv-parse-date-tolerant.stdout$/],
     logs: ['Test failed. 15 steps failed (out of 138):
step 36 fail: 1901-12-13T20:45:51Z mis-match 1970-01-01 00:00:00 UTC (off by 24855d 3:14:09).
step 42 fail: 2038-01-19T03:14:00Z mis-match 1970-01-01 00:00:00 UTC (off by -24855d 3:14:00).
step 43 fail: 2038-01-19T03:14:07Z mis-match 1970-01-01 00:00:00 UTC (off by -24855d 3:14:07).
step 44 fail: 2038-01-19T03:14:08Z mis-match 1970-01-01 00:00:00 UTC (off by -24855d 3:14:08).
step 47 fail: 19-Jan-2038 03:14:07 GMT mis-match 1970-01-01 00:00:00 UTC (off by -24855d 3:14:07).
step 48 fail: 19-Jan-2038 03:14:06 GMT mis-match 1970-01-01 00:00:00 UTC (off by -24855d 3:14:06).
step 51 fail: 20380119 03:14:07 GMT mis-match 1970-01-01 00:00:00 UTC (off by -24855d 3:14:07).
step 52 fail: January 19, 2038 03:14:07 GMT mis-match 1970-01-01 00:00:00 UTC (off by -24855d 3:14:07).
step 53 fail: January 19, 2038 03:14:08 GMT mis-match 1970-01-01 00:00:00 UTC (off by -24855d 3:14:08).
step 54 fail: 19-Jan-2038 03:14:07 GMT mis-match 1970-01-01 00:00:00 UTC (off by -24855d 3:14:07).
step 55 fail: 07-Feb-2106 06:28:15 GMT mis-match 1970-01-01 00:00:00 UTC (off by -49710d 6:28:15).
step 56 fail: February 7, 2106 06:28:15 GMT mis-match 1970-01-01 00:00:00 UTC (off by -49710d 6:28:15).
step 130 fail: Dec 30, 2060 mis-match 1970-01-01 00:00:00 UTC (off by -33236d 5:00:00).
step 131 fail: July 4, 1776 mis-match 1970-01-01 00:00:00 UTC (off by 70671d 19:00:00).
step 132 fail: 1776-07-04T00:00:00Z mis-match 1970-01-01 00:00:00 UTC (off by 70672d 0:00:00).
']
   },
   ###########################################################################
   { bug: 20618,
     comment: 'wildcard dictionary creation differences',
     filenames: [/\/testbed10\/.*\/wc-(create-1|create-2|destroy)\/wc-(create-1|create-2|destroy).stdout$/],
     logs: [/\nwc-(create-1|create-2|destroy) :  Dictionary file does not match known good \n/]
   },
   ###########################################################################
   { bug: 25846,
     comment: 'Too many open files',
     filenames: [/\/(broker|cb)-.*\.std...$/],
     logs: ['Too many open files']
   },
   ###########################################################################
   { bug: 25867,                # Linux specific bug
     comment: 'The exception [xml-unset-var-error] was thrown.',
     filenames: [/\/testbed(1|4|6|10|14)\//],
     logs: [# The test failed with a single error.
/Tests run: [0-9]*, Errors: 1, Failures: 0, Inconclusive: 0, Time: [0-9]*.[0-9]* seconds/,
            # The error signature looks like this:
            '
   System.Web.Services.Protocols.SoapException : The exception [xml-unset-var-error] was thrown.']
   },
   ###########################################################################
   { bug: 25867,                # Windows specific bug
     comment: 'The exception [xml-unset-var-error] was thrown.',
     filenames: [/\/testbed(2|8|9|11|15|17)\//],
     logs: [# The test failed with a single error.
/Tests run: [0-9]*, Errors: 1, Failures: 0, Inconclusive: 0, Time: [0-9]*.[0-9]* seconds/,
            # The error signature looks like this:
            '
   System.Web.Services.Protocols.SoapException : The exception [xml-unset-var-error] was thrown.']
   },
   ###########################################################################
   { bug: 25867,                # Linux specific bug
     comment: 'The exception [xml-unset-var-error] was thrown.',
     filenames: [/\/testbed(1|4|6|10|14)\/.*\.stderr$/],
     logs: [/<exception time="[0-9]*" date="[0-9]*" id="XML_UNSET_VAR" function=/]
   },
   ###########################################################################
   { bug: 25867,                # Windows specific bug
     comment: 'The exception [xml-unset-var-error] was thrown.',
     filenames: [/\/testbed(2|8|9|11|15|17)\/.*\.stderr$/],
     logs: [/<exception time="[0-9]*" date="[0-9]*" id="XML_UNSET_VAR" function=/]
   },
   { bug: 25846,                # Linux specific bug
     comment: 'The exception [xml-unset-var-error] was thrown.',
     filenames: [/\/testbed(1|4|6|10|14)\/.*\/broker-race-online-offline\.stdout$/],
     logs: [/<exception time=\\\"[0-9]*\\\" date=\\\"[0-9]*\\\" id=\\\"XML_UNSET_VAR\\\" function=/]
   },
   ###########################################################################
   { bug: 25867,                # Windows specific bug
     comment: 'The exception [xml-unset-var-error] was thrown.',
     filenames: [/\/testbed(2|8|9|11|15|17)\/.*\/broker-race-online-offline\.stdout$/],
     logs: [/<exception time=\\\"[0-9]*\\\" date=\\\"[0-9]*\\\" id=\\\"XML_UNSET_VAR\\\" function=/]
   },
   ###########################################################################
   { bug: 27050,
     comment: 'Test infrastructure issue: "system is currently in maintenance mode"',
     filenames: [],
     logs: [/system is currently in maintenance mode: .*System Administrator requested shutdown/]
   },
   ###########################################################################
   { bug: 27050,
     comment: 'Test infrastructure issue: "system is currently in maintenance mode"',
     filenames: [/\.stderr$/],
     logs: ['The Vivisimo installation is currently in maintenance mode'],
   },
   ###########################################################################
   { bug: 26409,
     comment: 'Test Failed: 3 collection-services, should be 1',
     filenames: [/\/testbed(7|12)\/.*\/csrv_mess\.stdout$/],
     logs: ['
Test Failed: 3 collection-services, should be 1
']
   },
   ###########################################################################
   { bug: 26201,
     comment: 'fails consistently on testbed12, while passing on testbed7',
     filenames: [/\/testbed12\/.*\/gate-1\.stdout$/],
     logs: ['
crawl check:  index documents disagree. Saw: 0, expected: 1
',
'
TEST RESULT FOR gate-1:  Test Failed
gate-1:  1 of 6 cases failed
'
]
   },
   ###########################################################################
   { bug: 23233,
     comment: 'Test infrastructure issue: collection restore timeout',
     filenames: [/\/testbed2\/.*\/qs-.*-large.stderr$/],
     logs: [':in `execute\': execute failure: <?xml version="1.0"?> (RuntimeError)
<REMOP>
   <OP>Execute</OP>
   <TARGET>Command</TARGET>
']
   },
   ###########################################################################
   { bug: 23233,
     comment: "Collection restore didn't work on testbed2.",
     filenames: [/\/testbed2\/.*\/query-(expansion|syntax-doc-condition).stdout$/],
     logs: []
   },
   ###########################################################################
   { bug: 26838,
     comment: "OSError: [Errno 17] File exists: '/testenv/samba_test_data/samba-dist-idx/doc-",
     filenames: [/\/dstidx-proxy-[1-9]\.stderr$/],
     logs: ["
OSError: [Errno 17] File exists: '/testenv/samba_test_data/samba-dist-idx/doc-"]
   },
   ###########################################################################
   { bug: 26599,
     comment: "Expected Annotation: tagsPushpa, value: newTag1, for doc: ... was not added",
     filenames: [/\/annotations\.stdout$/],
     logs: [/ message="Expected Annotation: tagsPushpa, value: newTag1, for doc: .*was not added" /]
   },
   ###########################################################################
   { bug: 24114,
     comment: 'Enhance tests to tolerate "search-collection-service-communication-terminating"',
     filenames: [],
     logs: ['exception name="search-collection-service-communication-terminating" ']
   },
   ###########################################################################
   { bug: 24115,
     comment: 'Enhance tests to deal with "no more collections are available to stop"',
     filenames: [],
     logs: [' requires more resources, but no more collections are available to stop. ']
   },
   ###########################################################################
   { bug: 23053,
     comment: 'Fewer URLs than there were before. Not suppose to be possible.',
     filenames: [/\/crawlandquery\.stdout$/],
     logs: ['
Fewer URLs than there were before.  Not suppose to be possible
crawlandquery:  Test Failed
']
     },
   { comment: 'Passed. False failure due to system reporting messages from previous test.',
     filenames: [/\/cb-(overlapping-online|repeated)-enqueues\.stdout$/],
     logs: [/ System Report from ([-0-9]+)T([-:0-9]+) to [-0-9]+T[-:0-9]+
(\1 \2  error    errors-high   COLLECTION_SERVICE_SERVICE_TERMINATED  The \[live\] \[[ci][rn][ad][we][lx]er\] for collection \[cb-tunable-0\] terminated unexpectedly: \[Unknown reason\]. *
)+[:0-9]+ End of System Report
[:0-9]+ Test failed (true )+false
/]
   },
   ###########################################################################
   { bug: 24115,
     comment: 'Enhance tests to deal with "no more collections are available to stop"',
     filenames: [/\.stderr$/],
     logs: ['<error id="COLLECTION_BROKER_SEARCH_STARTED_AND_STOPPED" ']
   },
   ###########################################################################
   { bug: 27553,
     comment: 'New Value = 0 for third test case',
     filenames: [/\/error-expire-1\.stdout$/],
     logs: ['
error-expire-1 :  ##################
error-expire-1 :  Get case data
error-expire-1 :  Query to check data, pass = 1
error-expire-1 :      Document counts, Expected = 20441
error-expire-1 :                         Actual = 0
error-expire-1 :  Query to check data, pass = 2
error-expire-1 :      Document counts, Expected = 20441
error-expire-1 :                         Actual = 0
error-expire-1 :  Query to check data, pass = 3
error-expire-1 :      Document counts, Expected = 20441
error-expire-1 :                         Actual = 0
error-expire-1 :  Query to check data, pass = 4
error-expire-1 :      Document counts, Expected = 20441
error-expire-1 :                         Actual = 0
error-expire-1 :  Query to check data, pass = 5
error-expire-1 :      Document counts, Expected = 20441
error-expire-1 :                         Actual = 0
error-expire-1 :  Query to check data, pass = 6
error-expire-1 :      Document counts, Expected = 20441
error-expire-1 :                         Actual = 0
error-expire-1 :  Query to check data, pass = 7
error-expire-1 :      Document counts, Expected = 20441
error-expire-1 :                         Actual = 0
error-expire-1 :  Query to check data, pass = 8
error-expire-1 :      Document counts, Expected = 20441
error-expire-1 :                         Actual = 0
error-expire-1 :  Query to check data, pass = 9
error-expire-1 :      Document counts, Expected = 20441
error-expire-1 :                         Actual = 0
error-expire-1 :  Query to check data, pass = 10
error-expire-1 :      Document counts, Expected = 20441
error-expire-1 :                         Actual = 0
error-expire-1    Case Failed
##########################################################
##########################################################
error-expire-1 :  Option settings
error-expire-1 :     filter-exact-duplicates - false
error-expire-1 :     error-expires           - 1
error-expire-1 :     uncrawled-expires       - unset
error-expire-1 :     connect-timeout         - 1
error-expire-1 :     timeout                 - 1
error-expire-1 :     max-bytes               - 1
##########################################################
']
   },
   ###########################################################################
   { bug: 24148,
     comment: 'query-search does not properly handle passed-in empty rights (known not fixed in 7.5)',
     filenames: [/\/APITests\.QuerySearchTests\.stdout$/],
     logs: [
            /Tests run: [0-9]*, Errors: 0, Failures: 1, Inconclusive: 0, Time: [0-9]*.[0-9]* seconds/,
            '1) Test Failure : APITests.QuerySearchTests.QuerySearch_Bug24148']
   },
   ###########################################################################
   { bug: 26512,
     comment: '"a required shared library was not found"',
     filenames: [/\/parse-ldap.+stdout$/],
     logs: [/ message="a required shared library was not found \(Error #40 in LDAP processing\): The liblber.+so.* LDAP library\/libraries couldn't be opened"/]
   },
   ###########################################################################
   { bug: 23000,
     comment: 'The test, or maybe Velocity, is flaky.',
     filenames: [/\/always-allow-one-collection\.stdout$/],
     logs: [' Test failed. 4 steps failed (out of 9):
step 3 fail: crawler/service-status [nil, nil]
step 4 fail: indexer/service-status [nil, nil]
step 5 fail: crawler/service-status [nil, nil]
step 6 fail: indexer/service-status [nil, nil]
']
   },
   ###########################################################################
   { bug: 23918,
     comment: 'COLLECTION_BROKER_COLLECTION_IS_NO_LONGER_RESPONSIVE',
     filenames: [/\/read-only-push-4\.stdout$/],
     logs: [' COLLECTION_BROKER_COLLECTION_IS_NO_LONGER_RESPONSIVE  The collection [read-only-push-0] is no longer responsive and will be terminated.',
            ' Test failed. 1 steps failed (out of 39):
step 39 fail: End of System Report
']
   },
   ###########################################################################
   { bug: 26069,
     comment: '"An error happened during one of the crawls."',
     filenames: [/\/samba-multi-hit\.stdout$/],
     logs: ['
An error happened during one of the crawls.
']
   },
   ###########################################################################
   { bug: 27303,
     comment: 'XML function "vse-converter-enterprise-vault" is not defined',
     filenames: [],
     logs: [/XML_FUNCTION_NOT_DEFINED.*vse-converter-enterprise-vault/]
   },
   ###########################################################################
   { bug: 27317,
     comment: '"No response from /search"',
     filenames: [/\.stdout$/],
     logs: ['
No response from /search
']
   },
   ###########################################################################
   { bug: 27318,
     comment: '"Connection reset by peer" from query-service axl request',
     filenames: [/\.stderr$/],
     logs: [' Connection reset by peer (Errno::ECONNRESET)
']
   },
   ###########################################################################
   { bug: 27238,
     comment: 'FATAL_ERROR An attempt was made to write to a persistent storage object when the service is in read-only mode.',
     filenames: [/read-only-push-.\.stdout$/],
     logs: [/ FATAL_ERROR_OCCURRED .*An attempt was made to write to a persistent storage object when the service is in read-only mode/]
   },
   ###########################################################################
   { bug: 27238,
     comment: 'FATAL_ERROR An attempt was made to write to a persistent storage object when the service is in read-only mode.',
     filenames: [/read-only-push-.\.stderr$/],
     logs: [/ id="SERVICE_STARTUP_RECEIVE">Failed to receive startup confirmation from the service &lt;string name="command">.*crawler-service/]
   },
   ###########################################################################
   { bug: 27239,
     comment: 'dictionary-language failing on Windows for recent JP builds',
     filenames: [/\/dictionary-language\.stdout$/],
     logs: [' Test failed. 2 steps failed (out of 180):
step 127 fail: Found 0 suggestions, expected 1
step 128 fail: Returned 0 suggestions, expected 1
']
   },
   ###########################################################################
   { comment: 'Test infrastructure issue: incorrect "velocity.jar" build.',
     filenames: [],
     logs: ['java.lang.Error: Undefined operation name VivTest']
   },
   ###########################################################################
   { bug: 27383,
     comment: 'Search_StartMax step failing for recent JP builds',
     filenames: [/\.stdout$/],
     logs: [ /Tests run: [0-9]*, Errors: 0, Failures: 1, Inconclusive: 0, Time: [0-9]*.[0-9]* seconds/,
             /Search_StartMax\r\n *Incorrect results returned.\r\n *Expected: null\r\n *But was: *<list>\r\n\r\nat APITests./]
   },
   ###########################################################################
   { bug: 27384,
     comment: 'api-query-search-8 fails with efficient-paging=true',
     filenames: [/\.stdout$/],
     logs: ['
api-query-search-8 :  Basic query of aggregated collections
api-query-search-8 :     Expected 398
api-query-search-8 :     Actual(1), 400
api-query-search-8 :     Actual(2), 400
api-query-search-8 :  Aggregation failed
']
   },
   ###########################################################################
   { bug: 27408,
     comment: 'Failed to load the dynamic library [...\lib\libvivisimochasen.dll]',
     filenames: [/\.stderr$/],
     logs: ['
The specified module could not be found.].   (ID: CHASEN_COULD_NOT_LOAD_LIBRARY)
']
   },
   ###########################################################################
   { bug: 27409,
     comment: 'Two cases failing for JP builds',
     filenames: [/wildcard-jpn\.stdout$/],
     logs: ['
Case 1:  Test Passed
',
'
Case 2:  Test Passed
',
'
Case 3:  Test Failed
',
'
Case 4:  Test Passed
',
'
Case 5:  Test Passed
',
'
Case 6:  Test Passed
',
'
Case 7:  Test Failed
',
'
Case 8:  Test Passed
',
'
Case 9:  Test Passed
',
'
TEST RESULT FOR wildcard-jpn:  Test Failed
wildcard-jpn:  2 of 4 cases failed
'
]
   },
   ###########################################################################
   { bug: 27410,
     comment: 'Empty conversion of one Japanese PDF',
     filenames: [/language-1\.stdout$/],
     logs: ['
japanese file checks failed
',
'
unknown file checks failed
',
'
TEST RESULT FOR language-1:  Test Failed
language-1:  2 of 19 cases failed
']
   },
   ###########################################################################
   # This check is a little too loose...
   { bug: 27413,
     comment: 'literal-search tests failing: expecting fewer than "num" results',
     filenames: [/literal-search-[0-9]*\.stdout$/],
     logs: [/
literal-search-[0-9]* : *URLs:
literal-search-[0-9]* : *Expected: *[0-9]*
literal-search-[0-9]* : *Actual: *200
literal-search-[0-9]* : *Check Failed
/]
   },
   ###########################################################################
   { bug: 27415,
     comment: 'crawl-delete by vse-key not appearing in client audit logs',
     filenames: [/replicated-synch-finished.*\.stdout$/],
     logs: [/ Test failed\. 3 steps failed \(out of 29\):
step 21 fail: .*
step 23 fail: .*
step 24 fail: /]
   },
   ###########################################################################
   { bug: 27416,
     comment: 'Unexpected query results on Windows only',
     filenames: [/literal-search-5.stdout$/],
     # This might be excessively specific.
     logs: ['
literal-search-5 :     QUERY 1 FAILED
lists do not match
    http://vivisimo.com?email2 new item not found in expected values
lists do not match
    http://vivisimo.com?email1 expected item not found in new items
lists do not match
    http://vivisimo.com?email4 expected item not found in new items
literal-search-5 :     Expected URLs do not match
',
'
literal-search-5 :     QUERY 2 PASSED
lists do not match
    http://vivisimo.com?email2 new item not found in expected values
lists do not match
    http://vivisimo.com?email3 expected item not found in new items
literal-search-5 :     Expected URLs do not match
',
'
literal-search-5 :     QUERY 3 FAILED
lists do not match
    http://vivisimo.com?email2 new item not found in expected values
lists do not match
    http://vivisimo.com?email1 expected item not found in new items
lists do not match
    http://vivisimo.com?email3 expected item not found in new items
literal-search-5 :     Expected URLs do not match
',
'
literal-search-5 :     QUERY 4 FAILED
lists do not match
    http://vivisimo.com?email2 new item not found in expected values
lists do not match
    http://vivisimo.com?email1 expected item not found in new items
lists do not match
    http://vivisimo.com?email3 expected item not found in new items
literal-search-5 :     Expected URLs do not match
',
'
literal-search-5 :     QUERY 7 FAILED
lists do not match
    http://vivisimo.com?fizz1 expected item not found in new items
lists do not match
    http://vivisimo.com?gl1 expected item not found in new items
lists do not match
    http://vivisimo.com?lp1 expected item not found in new items
literal-search-5 :     Expected URLs do not match
',
'
literal-search-5 :     QUERY 8 FAILED
lists do not match
    http://vivisimo.com?email1 expected item not found in new items
literal-search-5 :     Expected URLs do not match
',
'
literal-search-5 :     QUERY 10 FAILED
lists do not match
    http://vivisimo.com?ssn1 expected item not found in new items
literal-search-5 :     Expected URLs do not match
',
'
literal-search-5 :     QUERY 12 FAILED
lists do not match
    http://vivisimo.com?lp2 expected item not found in new items
literal-search-5 :     Expected URLs do not match
',
'
literal-search-5 :     QUERY 16 FAILED
lists do not match
    http://vivisimo.com?halffullmix expected item not found in new items
literal-search-5 :     Expected URLs do not match
',
'
literal-search-5 :     QUERY 17 FAILED
lists do not match
    http://vivisimo.com?halffullmix expected item not found in new items
literal-search-5 :     Expected URLs do not match
']
   },
   ###########################################################################
   { bug: 27419,
     comment: '50% failure rate on JP with identical failure modes',
     filenames: [/api-sc-index-atomic-10\.stdout$/],
     logs: ['
api-sc-index-atomic-10 :  total results and current count differ
api-sc-index-atomic-10 :  total results =  5
api-sc-index-atomic-10 :  current count     =  3
',
'
api-sc-index-atomic-10 :  total results and current count differ
api-sc-index-atomic-10 :  total results =  102
api-sc-index-atomic-10 :  current count     =  100
',
'
api-sc-index-atomic-10 :  total results and current count differ
api-sc-index-atomic-10 :  total results =  99
api-sc-index-atomic-10 :  current count     =  97
']
   },
   ###########################################################################
   { bug: 25660,
     comment: 'audit log entries corresponding to remote updates may be written multiple times',
     filenames: [/replicated-synch-ia-indexer-bounce\.stdout$/],
     logs: [' Test failed. 1 steps failed (out of 5):
step 5 fail: Number of entries differs between nodes:
']
   },
   ###########################################################################
   { bug: 27420,
     comment: 'fewer duplicates eliminated than the test expects',
     filenames: [/17296\.stdout$/],
     logs: ['
17296 :     URLs:
17296 :        Expected: 1992
17296 :        Actual:   2028
17296 :        Check Failed
17296 :     Retrieved:
17296 :        Expected:        1992
17296 :        Actual:          2028
17296 :        Total Results:   2032
17296 :        Total Results(exp):   2032
17296 :        Check Failed
']
   },
   ###########################################################################
   { bug: 25947,
     comment: 'Valid index value is ??, expected 34 or 54',
     filenames: [/query-1\.stdout$/],
     logs: [/Valid index value is [0-9]*, expected 34 or 54/]
   },
   ###########################################################################
   { bug: 24730,
     comment: 'Worse response time for 8.0 on Windows.',
     filenames: [/perf-query-meta\.stdout$/],
     logs: [' Test failed. 1 steps failed (out of 3):
step 2 fail: 300 query-meta front pages took more than one minute.
']
   },
   ###########################################################################
   { bug: 24730,
     comment: 'Much worse response time for 8.0 on Windows.',
     filenames: [/perf-ping\.stdout$/],
     logs: [' Test failed. 1 steps failed (out of 3):
step 2 fail: 600 Velocity API pings took more than one minute.
']
   },
   ###########################################################################
   { bug: 27452,
     comment: 'vlib-js external not integrated with Velocity',
     filenames: [/\/annotations\.stdout$/],
     logs: ['
result/TEST-apiTests.Annotation_express_update_doc_list_Tests.xml:    <error message="Couldn&apos;t create SOAP message due to exception: XML reader error: javax.xml.stream.XMLStreamException: ParseError at [row,col]:[1,1]
result/TEST-apiTests.AnnotationsAddDocList_API_Tests.xml:    <error message="Couldn&apos;t create SOAP message due to exception: XML reader error: javax.xml.stream.XMLStreamException: ParseError at [row,col]:[1,1]
result/TESTS-TestSuites.xml:          <error message="Couldn&apos;t create SOAP message due to exception: XML reader error: javax.xml.stream.XMLStreamException: ParseError at [row,col]:[1,1] Message: Content is not allowed in prolog." type="com.sun.xml.internal.ws.protocol.soap.MessageCreationException">com.sun.xml.internal.ws.protocol.soap.MessageCreationException: Couldn&apos;t create SOAP message due to exception: XML reader error: javax.xml.stream.XMLStreamException: ParseError at [row,col]:[1,1]
result/TESTS-TestSuites.xml:          <error message="Couldn&apos;t create SOAP message due to exception: XML reader error: javax.xml.stream.XMLStreamException: ParseError at [row,col]:[1,1] Message: Content is not allowed in prolog." type="com.sun.xml.internal.ws.protocol.soap.MessageCreationException">com.sun.xml.internal.ws.protocol.soap.MessageCreationException: Couldn&apos;t create SOAP message due to exception: XML reader error: javax.xml.stream.XMLStreamException: ParseError at [row,col]:[1,1]
2 JUnit tests failed.
']
   },
   ###########################################################################
   { bug: 27493,
     comment: 'The test script crashed before it even got started.',
     filenames: [/\/cr_.*\.stderr$/],
     logs: ["
velocityAPI.VelocityAPIexception: <?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?><exception name=\"search-collection-invalid-name\" stack-trace=\"//scope/print/xml-to-text/function[@name='api-rest']/scope/set-var[@name='result']/scope/scope/function[@name='search-collection-crawler-stop']/scope/function[@name='search-collection-service-command']/scope/set-var[@name='run']/function[@name='search-collection-service-run-node']/scope/set-var[@name='base-filename']/function[@name='search-collection-filebase']/scope/scope/scope///exception[@name='search-collection-invalid-name']\">The collection <string name=\"collection\">crawl-stop-start</string> does not exist.</exception>
"]
   },
   ###########################################################################
   { bug: 27384,
     comment: 'api-query-search-8.tst fails with efficient-paging=true',
     filenames: [/\/api-query-search-8\.stdout$/],
     logs: ['
api-query-search-8 :  CRAWLS COMPLETE
api-query-search-8 :  ##################
api-query-search-8 :  TEST CASES BEGIN
api-query-search-8 :  ##################
api-query-search-8 :  CASE 1, DEFAULTS
api-query-search-8 :     output-contents-mode = defaults
api-query-search-8 :     output-contents = <empty>
api-query-search-8 :  Basic query of multiple collections
api-query-search-8 :     Expected 444
api-query-search-8 :     Actual(1), 444
api-query-search-8 :     Actual(2), 444
api-query-search-8 :  Basic query succeeded
api-query-search-8 :  Basic query of aggregated collections
api-query-search-8 :     Expected 398
api-query-search-8 :     Actual(1), 400
api-query-search-8 :     Actual(2), 400
Data differences:
api-query-search-8 :  Aggregation failed
api-query-search-8 :  Basic query of multiple collections with dups
api-query-search-8 :     Expected 446
api-query-search-8 :     Actual, 446
api-query-search-8 :  Dups properly accounted for
api-query-search-8 :  ##################
api-query-search-8 :  Test Failed
']
   },
   ###########################################################################
   { bug: 27494,
     comment: 'crashed due to failure to delete its collection',
     filenames: [/\/files-2.*\.stderr$/],
     logs: ["
velocityAPI.VelocityAPIexception: <?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?><exception name=\"search-collection-update-failed\" stack-trace=\"//scope/print/xml-to-text/function[@name='api-rest']/scope/set-var[@name='result']/scope/scope/function[@name='search-collection-set-xml']/scope/scope/scope///exception[@name='search-collection-update-failed']\">Could not update the repository configuration for collection <string name=\"collection\">files-2"]
   },
   ###########################################################################
   { bug: 27494,
     comment: 'crashed due to failure to delete its collection',
     filenames: [/\/files-2.*\.stderr$/],
     logs: [" id=\"LIBXML_XPATH\" function=\"vivisimo_load\" fid=\"1\" process=\"*\" name=\"libxml-xpath-error\" stack-trace=\"//scope/print/xml-to-text/function[@name='api-rest']/scope/set-var[@name='result']/scope/scope/function[@name='repository-update']/scope/exception[@id='LIBXML_XPATH']\">Error <string name=\"error\">Invalid expression</string> while evaluating XPath <string name=\"xpath\">viv:repository-update($node, $md5)</string> in scope <xmlnode name=\"scope\" xpath=\"//scope/print/xml-to-text/function[@name='api-rest']/scope/set-var[@name='result']/scope/scope/function[@name='repository-update']/scope\" />  </exception></xmlnode> </exception>
"]
   },
   ###########################################################################
   { bug: 27495,
     comment: 'search-collection-crawler-start failed: "Could not delete ...\tmp\...\ehcache-core-2.3.2.jar"',
     filenames: [/\/cr_.*\.stderr$/],
     logs: [/id="FILE_DELETE">.*ehcache-core-2\.3\.2\.jar.*The process cannot access the file because it is being used by another process/]
   },
   ###########################################################################
   { bug: 27495,
     comment: 'search-collection-crawler-start failed: "Could not delete ...\tmp\...\jcifs-1.3.15.jar"',
     filenames: [/\/cr_.*\.stderr$/],
     logs: [/id="FILE_DELETE">.*jcifs-1\.3\.15\.jar.*The process cannot access the file because it is being used by another process/]
   },
   ###########################################################################
   { bug: 27465,
     comment: 'client results = 0; server results = 2151',
     filenames: [/\/dstidx-conflict-.\.stdout$/],
     logs: [/
dstidx-conflict-. :  total results differ between client and server
dstidx-conflict-. :  client results =  0
dstidx-conflict-. :  server results =  2151
/]
   },
   ###########################################################################
   { bug: 26613,
     comment: 'client results = 0; server results = 7143',
     filenames: [/\/dstidx-ia-[0-9]*\.stdout$/],
     logs: [/
dstidx-ia-[0-9]* :  total results differ between client and server
dstidx-ia-[0-9]* :  client results =  0
dstidx-ia-[0-9]* :  server results =  7143
/]
   },
   ###########################################################################
   { bug: 26613,
     comment: 'client results = 0; server results = 7099',
     filenames: [/\/dstidx-ia-8\.stdout$/],
     logs: ['
dstidx-ia-8 :  total results differ between client and server
dstidx-ia-8 :  client results =  0
dstidx-ia-8 :  server results =  7099
']
   },
   ###########################################################################
   { bug: 27486,
     comment: 'pure client results = 0; expected results = 406',
     filenames: [/\/dstidx-basic-29\.stdout$/],
     logs: ['
dstidx-basic-29 :  ##################
dstidx-basic-29 :  TEST CASES BEGIN
dstidx-basic-29 :  ##################
dstidx-basic-29 :  total results differ between client and server
dstidx-basic-29 :  client results =  406
dstidx-basic-29 :  server results =  406
dstidx-basic-29 :  pure client results =  0
dstidx-basic-29 :  expected results =  406
dstidx-basic-29 :  ##################
dstidx-basic-29 :  total url results differ between client and server
dstidx-basic-29 :  client results =  406
dstidx-basic-29 :  server results =  406
dstidx-basic-29 :  pure client results =  0
dstidx-basic-29 :  ##################
']
   },
   ###########################################################################
   { bug: 23199,
     comment: 'Collection stuck with read-only mode="pending"',
     filenames: [/\/read-only-race-1\.stdout$/],
     logs: [" fail: read-only never 'acquired'
"]
   },
   ###########################################################################
   { comment: 'Java test failures due to testenv being builds with an 8.0 "velocity.jar"',
     filenames: [/\.stderr$/],
     logs: ['
Exception in thread "main" java.lang.Error: Undefined operation name AutocompleteSuggest
']
   },
   ###########################################################################
   { bug: 27579,
     comment: 'bad urls from url_parse',
     filenames: [/\/imaps-1\.stdout$/],
     logs: ['
TEST RESULT FOR imaps-1:  Test Failed
imaps-1:  5 of 10 cases failed
']
   },
   ###########################################################################
   { bug: 27579,
     comment: 'bad urls from url_parse',
     filenames: [/\/imaps-2\.stdout$/],
     logs: ['
TEST RESULT FOR imaps-2:  Test Failed
imaps-2:  4 of 8 cases failed
']
   },
   ###########################################################################
   { bug: 27668,
     comment: 'ssh: connect to host testbed8.test.vivisimo.com port 22: No route to host',
     filenames: [/\/APITests\..*\.stderr$/],
     logs: ['ssh: connect to host testbed8.test.vivisimo.com port 22: No route to host']
   },
   ###########################################################################
   { bug: 27779,
     comment: 'Function "dictionary-read-from-collection" is not defined in the repository.',
     filenames: [/\.stderr$/],
     logs: ['Function <string name="function">dictionary-read-from-collection</string> is not defined in the repository.']
   },
   ###########################################################################
   { bug: 28017,
     comment: 'SharePoint Connector not installed by default after 8.1-2',
     filenames: [/\.stdout$/],
     logs: [
'Version 8.1',
/Creating the collection \S+ from VAPIINTERFACE api_sc_create/,
/crawl check:  crawl errors disagree. Saw: -1, expected: \d+/,
/crawl check:  crawl duplicates disagree. Saw: -1, expected: \d+/,
/ERROR MESSAGE\:         Could not start the \[live\] \[indexer\] for collection \[.+\] because an error occurred while processing the configuration./,
'ERROR MESSAGE ID:      COLLECTION_SERVICE_CONFIGURATION_PROCESSING_FAILED
ERROR MODULE:          collection-service
ERROR SERVICE:         indexer'
]
   },
   ###########################################################################
  { bug: 28017,
    comment: 'SharePoint Connector not installed by default after 8.1-2',
    filenames: [/\.stderr$/],
    logs: [/XML_FUNCTION_NOT_DEFINED.+function.+vse-crawler-seed-sharepoint/]
  }

  ]

def auto_comment(filename, options)
  open(filename, external_encoding: Encoding::UTF_8) {|f|
    log = f.read                # read the whole file
    MATCHERS.each {|match|      # try each matcher
      if match[:filenames].all? {|fm| filename[fm]}
        puts 'bug: %s matched in %s' % [match[:bug], filename] if options[:verbose]
        begin
          if match[:logs].all? {|lm| log[lm]}
            begin
              add_comment(File.dirname(filename),
                          match[:comment],
                          options.merge(bug: match[:bug]))
            rescue => ex
              puts ex
            end
          end
        rescue => ex
          # We can't deal with non-UTF-8 log files. Punt silently. :-(
          puts ex if options[:verbose]
        end
      end
    }
  }
end

if __FILE__ == $0
  require 'trollop'
  opts = Trollop::options do
    opt(:verbose, 'Verbose output')
  end

  require 'mysql2'
  db = Mysql2::Client.new(:database => 'gauge',
                          :host => 'eng-db.vivisimo.com',
                          :password => 'aTZp6wmymVcsuCmz',
                          :sslkey => '/dev/null',
                          :username => 'gauge')

  sql = %w{
    select d.TestName, d.LogFilePath
      from tblTestRunSummary s, tblTestRunDetails d
      where s.ReviewStatus = 'Pending'
        and d.TestRunID = s.id
        and d.Result <> 'Passed' and d.Result <> 'Pending'
        and ( d.Notes = '' or d.Notes = 'None' )
  }.join(' ')
  review_list = db.query(sql)
  result_count = review_list.count
  good = 0
  review_list.each{|row|
    test, path = row.values_at('TestName', 'LogFilePath')

    if path.length < 9
      puts 'Bad path %s for %s' % [path, test] if opts[:verbose]
    else
      good += 1
      puts path if opts[:verbose]
      stdout = '%s/%s.stdout' % [path, test]
      stderr = '%s/%s.stderr' % [path, test]
      [stdout, stderr].each{|filename|
        begin
          auto_comment(filename, verbose: opts[:verbose])
        rescue Errno::ENOENT => enoent
          puts enoent if opts[:verbose]
        end
      }
    end
  }
  puts 'Looked at %d test failures with %d matchers.' %
    [good, MATCHERS.length] if opts[:verbose]
  puts 'Ignored %d bad paths' % (result_count-good) if
    opts[:verbose] and result_count > 0
end
