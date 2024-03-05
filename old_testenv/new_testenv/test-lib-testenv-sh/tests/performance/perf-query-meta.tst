#!/usr/bin/env ruby

require 'cgi'
require 'misc'

def form_urlencode(data)
  return data.map {|key,value|
    [CGI.escape(key.to_s), CGI.escape(value.to_s)].join('=')
  }.join('&')
end

results = TestResults.new('Test query-meta response time for trivial requests.',
                          'This was initially inspired by bug 24730.')
results.need_system_report = false if ENV['VIVVERSION'] < '7.5'

# We should be able to make several hundred trivial requests within time limit.
count = 300
time_limit = 90

args = { 'frontpage'  => 1,
         'v:frame'    => 'form',
         'v:password' => TESTENV.password,
         'v:project'  => 'query-meta',
         'v:username' => TESTENV.user,
         'v:xml'      => 1 }

url = '%s?%s' % [TESTENV.query_meta, form_urlencode(args)]

start = Time.now
results.add(system("ab -n %d '%s'" % [count, url]),
            'ApacheBench ran successfully.',
            'ApacheBench failed!?')
elapsed = Time.now-start
results.add(elapsed < time_limit,
            "#{count} query-meta front pages took less than #{time_limit} seconds.",
            "#{count} query-meta front pages took more than #{time_limit} seconds.")

results.cleanup_and_exit!
