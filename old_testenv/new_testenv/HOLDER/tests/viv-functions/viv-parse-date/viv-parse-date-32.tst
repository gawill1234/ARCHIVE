#!/usr/bin/env ruby

require 'misc'
require 'pmap'
require './viv-parse-date'

# Just mess with specific times. Don't tickle date parsing or daylight
# savings time issues (which are, at least in theory, tested elsewhere).
PARSE_DATE_CASES = [['1776-07-04T00:00:00Z', 0],
                    ['1901-12-13T00:00:00Z', 0],
                    ['1901-12-13T20:45:51Z', 0],
                    ['1901-12-13T20:45:52Z', -2147483648],
                    ['1901-12-13T20:46:00Z', -2147483640],
                    ['1960-01-01T00:00:00Z', -315619200],
                    ['1969-12-31T23:59:00Z', -60],
                    ['1969-12-31T23:59:58Z', -2],
                  # ['1969-12-31T23:59:59Z', -1], fails; added to other test.
                    ['1970-01-01T00:00:00Z', 0],
                    ['1970-01-01T00:00:01Z', 1],
                    ['1970-01-01T00:01:00Z', 60],
                    ['2000-06-21T00:00:00Z', 961545600],
                    ['2038-01-18T22:14:07Z', 2147465647],
                    ['2038-01-18T22:14:08Z', 2147465648],
                    ['2038-01-19T03:14:00Z', 2147483640],
                    ['2038-01-19T03:14:07Z', 2147483647],
                    ['2038-01-19T03:14:08Z', 0],
                    ['2040-01-01T00:00:00Z', 0],
                    ['2100-01-01T00:00:00Z', 0],
                    ['2999-01-01T00:00:00Z', 0]]

results = TestResults.new
public_viv_parse_date_range(Vapi.new(TESTENV.velocity,
                                     TESTENV.user,
                                     TESTENV.password))

viv = PARSE_DATE_CASES.pmap {|given, expect|
  date = given
  vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
  vapi.viv_parse_date_range(:date => date).root.text.to_f.to_i
}

PARSE_DATE_CASES.zip(viv).each {|test, zulu|
  date = test.first
  expect = test.last
  results.add(zulu == expect,
              "#{date} matched #{simple_time(zulu)}.",
              "#{date} mis-match #{simple_time(zulu)} (off by #{format_elapsed_time(zulu-expect)}).")
}

results.cleanup_and_exit!
