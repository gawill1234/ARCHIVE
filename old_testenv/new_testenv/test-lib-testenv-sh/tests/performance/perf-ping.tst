#!/usr/bin/env ruby

require 'misc'

results = TestResults.new('Test Velocity API ping response time.',
                          'This was initially inspired by bug 26482.')
results.need_system_report = false if ENV['VIVVERSION'] < '7.5'

# We should be able to make several hundred trivial requests in a minute.
count = 600

url = '%s?%s' % [TESTENV.velocity, 'v.app=api-rest&v.function=ping']

start = Time.now
results.add(system("ab -n %d '%s'" % [count, url]),
            'ApacheBench ran successfully.',
            'ApacheBench failed!?')
elapsed = Time.now-start
results.add(elapsed < 60,
            '%d Velocity API pings took less than one minute.' % count,
            '%d Velocity API pings took more than one minute.' % count)

results.cleanup_and_exit!
