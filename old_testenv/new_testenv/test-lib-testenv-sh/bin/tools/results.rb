#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'set'

KNOWN_RESULTS = Set.new([ :aborted,
                          :absent,
                          :ambiguous,
                          :crashed,
                          :failed,
                          :passed,
                          :timedout,
                          :unknown ])

class TestResult
  include Comparable
  attr_reader :start
  attr_reader :finish
  attr_reader :name
  attr_reader :info
  attr_reader :target
  attr_reader :run
  attr_reader :loc
  attr_reader :result

  def initialize(target, run, node)
    @start   = Time.at(node.xpath('stime').first.content.to_i)
    @finish  = Time.at(node.xpath('etime').first.content.to_i)
    @name    = node.xpath('name').first.content
    @loc     = node.xpath('loc' ).first.content
    @info    = node.xpath('info').first.content
    @target  = target
    @run     = run
    @result  = node.xpath('result').first.content.split(' ')[-1].downcase.to_sym
    # Fix an alternate spelling
    @result = :timedout if @result == :timeout
    # Kill off any result we don't know about.
    unless KNOWN_RESULTS.include?(@result)
      puts 'Squashing an unrecognized result %s' % @result
      @result  = :unknown
    end
  end

  def passed
    @result == :passed
  end

  def <=>(other)
    [:start, :finish, :name, :info, :target, :run, :loc, :result].each {|field|
      retval = (self.send(field) <=> other.send(field))
      return retval unless retval == 0
    }
    return 0                    # Every field matched.
  end
end

class TestRunResults
  BASE_DIR = '/testenv/NEW_RESULTS'
  attr_reader :results
  attr_reader :runs
  attr_reader :targets

  def initialize
    @targets = Dir.entries(BASE_DIR).
      select {|d| d =~ /linux|solaris|windows/}.
      sort
    @runs = {}
    targets.each do |target|
      @runs[target] = Dir.entries('%s/%s'%[BASE_DIR,target]).
        reject {|f| f[0,1] == '.'}
    end
    @results = {}
    @targets.each do |target|
      @runs[target].each do |run|
        filename = '%s/%s'%[BASE_DIR, target_run(target, run)]
        @results[target_run(target, run)] =
          list_of_results(target, run, filename)
      end
    end
  end

  def target_run(target, run)
    '%s/%s'%[target, run]
  end

  def result(target, run)
    @results[target_run(target, run)]
  end

  def fraction_pass(target, run)
    myrun = result(target, run)
    passes = myrun.count {|r| r.passed}
    passes.to_f/myrun.length
  end

  def flat_results
    flat = []
    @results.each {|n,v| flat += v.map{|r| r}}
    flat.sort
  end

  protected
  def list_of_results(target, run, filename)
    contents = File.open(filename) {|f| f.read}
    stuff = Nokogiri::XML('<wrapper>%s</wrapper>'%contents)
    stuff.root.children.xpath('//test').map {|node|
      TestResult.new(target, run, node)
    }
  end
end

if __FILE__ == $0
  require 'set'

  trr = TestRunResults.new()
  puts "targets are #{trr.targets.inspect}"
  run_set = Set.new(trr.runs.values.flatten)
  puts "#{run_set.length} runs are: #{run_set.sort.inspect}"
  trr.results.each do |n,v|
    x = v.select {|r| r.name == 'data-export-race-1'}
    puts "%s %s" % [n,x.first.passed] unless x.empty?
  end
end
