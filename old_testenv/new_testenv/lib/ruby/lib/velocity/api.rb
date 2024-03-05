require 'simple_http'

module Velocity
  class APIException < StandardError
  end

  class API
    attr_reader :response, :doc

    def initialize(velocity_url, username=nil, password=nil)
      @post = SimpleHTTP.new(velocity_url, {'Accept' => 'text/xml,application/xml'})
      @base_parameters = {'v.app' => 'api-rest'}
      @base_parameters['v.username'] = username if username
      @base_parameters['v.password'] = password if password
      @base_parameters.freeze
    end

    def twiddle_name(name)
      name.to_s.gsub(/__/, '.').gsub(/_/, '-')
    end

    def call(function, args=nil)
      if args
        args_hash = Hash[*args.map {|key, value|
                           [twiddle_name(key), value]}.flatten]
      else
        args_hash = {}
      end
      params = @base_parameters.merge(
                 {'v.function' => twiddle_name(function)}.merge(args_hash))
      @response = @post.post(params).freeze
      @doc = Nokogiri::XML(@response.body).freeze
      raise Velocity::APIException, @response.body if @doc.root.name == 'exception'
      @doc

    end

    def method_missing(function, args=nil)
      call(function, args)
    end
  end

  if __FILE__ == $0
    # Pick up target info from environment, with reasonable defaults
    url = ENV['VIVURL'] || "http://" \
                           "#{ENV['VIVHOST'] || 'localhost'}:" \
                           "#{ENV['VIVHTTPPORT'] || '80'}/" \
                           "#{ENV['VIVVIRTUALDIR'] || 'vivisimo'}/" \
                           "cgi-bin/velocity" \
                           + ( ENV['VIVTARGETOS'] == 'windows' ? '.exe' : '' )
    user = ENV['VIVUSER'] || 'test-all'
    pswd = ENV['VIVPW'] || 'P@$$word#1?'

    vapi = API.new(url, user, pswd)
    xml = vapi.call(ARGV[0], ARGV[1..-1].map {|x| x.split('=', 2)})
    puts xml
  end
end