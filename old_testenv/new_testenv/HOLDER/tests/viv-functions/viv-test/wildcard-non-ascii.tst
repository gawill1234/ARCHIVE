#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

$LOAD_PATH << ENV['TEST_ROOT']+'/tests/viv-functions'

require "misc"
require "viv-function-wrapper"

results = TestResults.new('Test that conditional wildcard tests properly support non-ASCII characters')
results.need_system_report = false

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)

params = [
  {:name => 'string', :required => true},
  {:name => 'match', :required => true},
  {:name => 'type', :value => "'wc'"}
]

vapi.create_public_api_wrapper('viv:test', params)

cases = [
  {:str => '¡hasta la próxima!', :wc => '¡*', :expected => true},
  {:str => '¡hasta la próxima!', :wc => '*h*', :expected => true},
  {:str => '¡hasta la próxima!', :wc => '*t*', :expected => true},
  {:str => '¡hasta la próxima!', :wc => '*p*', :expected => true},
  {:str => '¡hasta la próxima!', :wc => '*ó*', :expected => true},
  {:str => '¡hasta la próxima!', :wc => '*!', :expected => true},

  {:str => 'hasta la próxima', :wc => '¡*', :expected => false},
  {:str => 'hasta la próxima', :wc => '*h*', :expected => true},
  {:str => 'hasta la próxima', :wc => '*t*', :expected => true},
  {:str => 'hasta la próxima', :wc => '*p*', :expected => true},
  {:str => 'hasta la próxima', :wc => '*ó*', :expected => true},
  {:str => 'hasta la próxima', :wc => '*!', :expected => false},

  {:str => 'hasta la proxima', :wc => '¡*', :expected => false},
  {:str => 'hasta la proxima', :wc => '*h*', :expected => true},
  {:str => 'hasta la proxima', :wc => '*t*', :expected => true},
  {:str => 'hasta la proxima', :wc => '*p*', :expected => true},
  {:str => 'hasta la proxima', :wc => '*ó*', :expected => false},
  {:str => 'hasta la proxima', :wc => '*!', :expected => false},

  {:str => 'abc¡def', :wc => '*c*e*', :expected => true},
  {:str => 'abc!def', :wc => '*c*e*', :expected => true},

  {:str => 'ウabcd', :wc => '*a*', :expected => true},
  {:str => 'ウabcd', :wc => '*b*', :expected => true},
  {:str => 'ウabcd', :wc => '*c*', :expected => true},
  {:str => 'ウabcd', :wc => '*d*', :expected => true},
]

cases.each do |testcase|
  res = vapi.viv_test(:string => testcase[:str], :match => testcase[:wc])
  actual = res.root.content
  results.add(actual == testcase[:expected].to_s,
              "Testing #{testcase[:str]} with wildcard #{testcase[:wc]} passed",
              "Testing #{testcase[:str]} with wildcard #{testcase[:wc]} should be #{testcase[:expected]}, but was #{actual}")
end

results.cleanup_and_exit!(true)
