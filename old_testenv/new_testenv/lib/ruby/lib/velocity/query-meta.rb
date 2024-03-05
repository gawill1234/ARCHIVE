#!/usr/bin/env ruby

require 'post'

module Velocity
  class QueryMeta
    def initialize(query_meta, username=nil, password=nil)
      @post = Post.new(query_meta,
                       'Accept' => 'text/xml,text/html,application/xml')
      @base_parameters = {}
      @base_parameters['v:username'] = username if username
      @base_parameters['v:password'] = password if password
      @base_parameters.freeze
    end

    # Different twiddle than vapi !
    def twiddle_name(name)
      name.to_s.gsub(/__/, ':').gsub(/_/, '-')
    end

    def query(args)
      if args
        args_hash = Hash[*args.map {|key,value|
                           [twiddle_name(key), value]}.flatten]
      else
        args_hash = {}
      end
      @post.post(@base_parameters.merge(args_hash)).freeze
    end
  end
end

if __FILE__ == $0
  require 'testenv'
  require 'pmap'
  results = ARGV.pmap {|query|
    qm = Velocity::QueryMeta.new(TESTENV.query_meta,
                                 TESTENV.user,
                                 TESTENV.password)
    html = qm.query(:v__sources => 'example-metadata',
                    :query => query)
    [query, html.body[/<strong>[0-9]*<\/strong> result/]]
  }
  results.each{|q,r| puts "#{q} #{r}"}
end
