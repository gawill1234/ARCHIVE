#!/usr/bin/env ruby

require 'find'
require 'set'
require 'cgi'
require 'time'
require 'net/http'
require 'rubygems'
require 'nokogiri'

class Build
  include Comparable

  attr_reader :path
  attr_reader :version
  attr_reader :build
  attr_reader :os
  attr_reader :hw
  attr_reader :date
  attr_reader :sha1
  attr_reader :retired

  def initialize(path, version, build, os, hw,
                 date=nil, sha1=nil, retired=false)
    @path = path
    @version = version
    if build == 'Unknown' or build == 'None' or build == 'Pending'
      @build = ''
    else
      @build = build
    end

    @os = os.downcase
    @hw = hw.downcase
    # generic "sparc" is really "sparc32" (Gag)
    @hw = 'sparc32' if @hw == 'sparc'
    @date = date
    @sha1 = sha1
    @retired = retired
  end

  def sha1=(sha1)
    raise "sha1 must not change!" if @sha1 and @sha1 != sha1
    @sha1 = sha1
  end

  def myid
    'vivisimo-velocity-' +
      @version.to_s + '-' +
      @build.to_s + '-' +
      @os.to_s + '-' +
      @hw.to_s # + ' ' + @path.to_s
  end

  # Make this class hashable and sortable.
  # Note that we carry date and sha1, but neither of field counts for equality.
  def hash
    myid.hash
  end

  def <=>(other)
    myid <=> other.myid
  end

  def eql?(other)
    myid == other.myid
  end
end

def all_candidates
  re = /\/candidates(\/velocity)?\/([^\/]*)\/vivisimo-velocity-(.*)-([^-]*)-([^-.]*)\./

  retval = []
  Find.find('/candidates') do |path|
    if not FileTest.directory?(path)
      build1 = path[re, 2]
      build2 = path[re, 3]
      os     = path[re, 4]
      hw     = path[re, 5]
      # Ignore patch releases, since we don't do them anymore.
      if build2 and not build2['patch-']
        if build1 != build2
          # Skip it if the two build ids don't match each other.
          puts "Build mismatch? #{path[12..-1]}"
        elsif build1 and os and hw
          # We have a name that looks good...
          begin
            # Sometimes we can't get to the candidate: sym link to nowhere.
            stat = File::Stat.new(path)
            parts = build1.split('-')
            version = parts[0..1].join('-') # first two bits are the version
            build = parts[2..-1].join('-')  # any remaining is the build
            retval << Build.new(path, version, build, os, hw, stat.mtime)
          rescue
            puts 'Ignoring %s' % path
          end
        end
      end
    end
  end
  retval
end

def form_urlencode(data)
  return data if data.is_a? String
  data.map {|key,value|
    [CGI.escape(key.to_s), CGI.escape(value.to_s)].join('=')
  }.join('&').split('+').join('%20') # 'gronk' doesn't handle "+" as a space.
end

GAUGE_BASE = '/services/builds.svc/'
def call(action, args=nil)
  http = Net::HTTP.new(*GAUGE_HOST_PORT.split(':'))
  req = GAUGE_BASE + action.to_s
  req += '/?' + form_urlencode(args) if args
  puts 'Requesting: %s %s' % [http.inspect, req]
  response = http.request_get(req)
    if response.is_a? Net::HTTPSuccess
      response.body
    else
      response.error!
    end
end

def all_gauge
  xml = Nokogiri::XML(call(:get))
  xml.root.children.map {|node| Build.new(node['Location'],
                                          node['Version'],
                                          node['Number'],
                                          node['TargetOS'],
                                          node['TargetArchitecture'],
                                          node['BuildDate'],
                                          node['SHA1Hash'],
                                          node['IsRetired']) }
end

def all_gauge_stub
  puts 'STUB for "all_gauge"'
  retval = all_candidates
  retval.pop
  retval.pop
  retval.pop
  retval.pop
  retval
end

def add_gauge_build(build)
  args = {
    'Location' => build.path,
    'Version' => build.version,
    'Number' => build.build,
    'TargetOS' => build.os,
    'TargetArchitecture' => build.hw
  }
  if build.date
    args['BuildDate'] = build.date.utc.iso8601
  else
    args['IsRetired'] = true
  end
  args['SHA1Hash'] = build.sha1 if build.sha1

  response = call(:put, args)
  puts 'Put said: %s' % response
end

if __FILE__ == $0
  GAUGE_HOST_PORT = ARGV[0] || 'gauge.vivisimo.com:80'
  candidate_builds = all_candidates
  gauge_builds = all_gauge
  # The database contains a dummy "empty" build record.
  empty_build = Build.new('None', '0.0', 'None',
                          'Unknown', 'Unknown',
                          Time.at(0), 'None')

  cset = Set.new(candidate_builds)
  gset = Set.new(gauge_builds) - Set.new([empty_build])

  dead_builds = gset - cset
  puts '%d dead builds'  %  dead_builds.length

  known_builds = gset & cset
  puts '%d known builds.' %  known_builds.length

  # Which builds do we have that gauge does not?
  new_builds = cset - gset
  puts '%d new builds:' %  new_builds.length
  new_builds.each{|b| puts b.path}
  puts '%d new builds.' %  new_builds.length

  new_builds.each {|build|
    # Get the SHA1 check sum for the build
    build.sha1 = %x{/usr/bin/sha1sum --binary #{build.path}}.split[0]
    add_gauge_build(build) if build.sha1
  }

end
