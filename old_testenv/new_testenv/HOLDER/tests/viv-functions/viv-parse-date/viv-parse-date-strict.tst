#!/usr/bin/env ruby

require 'misc'
require 'pmap'
require './viv-parse-date'
require './parse-date-cases'

results = TestResults.new
public_viv_parse_date(Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password))

viv = PARSE_DATE_CASES.pmap {|given, expect|
  date = given.first
  format = given[1]
  vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
  vapi.viv_parse_date(:date => date, :format => format).root.text.to_f.to_i
}

PARSE_DATE_CASES.zip(viv).each {|test, zulu|
  date = test.first.first
  expect = test.last.first
  results.add(zulu == expect,
              "#{date} matched #{simple_time(zulu)}.",
              "#{date} mis-match #{simple_time(zulu)} (off by #{format_elapsed_time(zulu-expect)}).")
}

results.cleanup_and_exit!
