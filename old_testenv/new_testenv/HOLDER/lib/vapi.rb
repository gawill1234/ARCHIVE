#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'rubygems'
require 'nokogiri'
require 'post'

class VapiException < StandardError
end

class Vapi
  def initialize(velocityURL, username=nil, password=nil)
    @post = Post.new(velocityURL, {'Accept' => 'text/xml,application/xml'})
    @base_parameters = {'v.app' => 'api-rest'}
    @base_parameters['v.username'] = username if username
    @base_parameters['v.password'] = password if password
    @base_parameters.freeze
    @@vvxps = false
  end

  def log_level(level)
    @post.log.level = level
  end

  def twiddle_name(name)
    name.to_s.gsub(/__/, '.').gsub(/_/, '-')
  end

  def prepare(function, args=nil)
    if args
      args_hash = Hash[*args.map {|key,value|
                         [twiddle_name(key), value]}.flatten]
    else
      args_hash = {}
    end
    @base_parameters.merge({'v.function' =>
                             twiddle_name(function)}.merge(args_hash)).
      reject {|n,v| v.nil?}
  end

  def invoke(params)
    @post.post(params).freeze
  end

  def xml(response)
    raise 'Empty response "%s" (expected XML)' % response.body if response.body.length < 5
    doc = Nokogiri::XML(response.body).freeze
    raise doc.errors.first if doc.errors.first
    raise VapiException, response.body if doc.root.name == 'exception'
    doc
  end

  def call(function, args=nil)
    xml(invoke(prepare(function, args)))
  end

  def method_missing(function, args=nil)
    call(function, args)
  end

  # This is a powerful function that we'll add into the target
  # Velocity as needed. It provides chico-like functionality, allowing
  # the evaluation of arbitrary XML through a Vivisimo Object.
  def viv_vivisimo_xml_processed_state(xml, stringout=false)
    myname = 'viv-vivisimo-xml-processed-state'
    unless @@vvxps
      begin
        repository_get_md5(:element => 'function', :name => myname)
      rescue
        repository_add(:node => <<XML)
<function name="viv-vivisimo-xml-processed-state" type="public-api" >
  <prototype>
    <description>Process the input XML through a Vivisimo Object and return the 'processed-state'.</description>
    <declare name="xml" type="nodeset" required="required">
      <description>The XML to process.</description>
    </declare>
    <declare name="stringout" initial-value="false" type="boolean">
      <description>Return a string instead of a nodeset.</description>
    </declare>
  </prototype>
  <declare name="v" />
  <declare name="in" />
  <set-var name="v">
    <value-of select="viv:vivisimo-alloc()" />
  </set-var>
  <set-var name="in">
    <value-of select="viv:vivisimo-input-xml($v, $xml)" />
  </set-var>
  <choose>
    <when test="$stringout">
      <value-of select="viv:vivisimo-xml($v, $stringout, 'processed-state', '')" />
    </when>
    <otherwise>
      <copy-of select="viv:vivisimo-xml($v, $stringout, 'processed-state', '')" />
    </otherwise>
  </choose>
</function>
XML
      end
      @@vvxps = true
    end
    call(myname, :xml => xml, :stringout => stringout)
  end
end

if __FILE__ == $0
  require 'testenv'
  vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
  # Avoid the XML parsing for speed.
  resp = vapi.invoke(vapi.prepare(ARGV[0],
                                  ARGV[1..-1].map {|x| x.split('=', 2)}))
  puts resp.body
end
