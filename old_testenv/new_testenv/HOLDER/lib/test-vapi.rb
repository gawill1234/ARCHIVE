#!/usr/bin/env ruby

require 'vapi'
require 'test/unit'
require 'socket'

class Test_Vapi_twiddle_name < Test::Unit::TestCase

  def setup
    @vapi = Vapi.new('http://localhost/fake/cgi-bin/velocity')
  end

  def test_simple
    for s in ['abc', 'v.indent', 'collection-broker-start', 'based-on']
      assert_equal(s, @vapi.twiddle_name(s))
    end
  end

  def test_string_mutations
    assert_equal('v.indent', @vapi.twiddle_name('v__indent'))
    assert_equal('collection-broker-start', @vapi.twiddle_name('collection_broker_start'))
    assert_equal('based-on', @vapi.twiddle_name('based_on'))
  end

  def test_symbol_mutations
    assert_equal('v.indent', @vapi.twiddle_name(:v__indent))
    assert_equal('collection-broker-start',
                 @vapi.twiddle_name(:collection_broker_start))
    assert_equal('based-on', @vapi.twiddle_name(:based_on))
  end

  def test_weird
    # We don't really indend to care about names this weird.
    assert_equal('x..y...z', @vapi.twiddle_name(:x____y______z))
    assert_equal('a-b.-c', @vapi.twiddle_name(:a_b___c))
  end
end

class Test_Vapi_prepare < Test::Unit::TestCase
  def setup
    @vapi = Vapi.new('http://nowhere/', 'user', 'password')
  end

  def test_no_args
    assert_equal({"v.app"=>"api-rest",
                   "v.username"=>"user",
                   "v.password"=>"password",
                   "v.function"=>"no-args"},
                 @vapi.prepare(:no_args))
  end

  def test_one_args
    assert_equal({"v.app"=>"api-rest",
                   "v.username"=>"user",
                   "v.password"=>"password",
                   "v.function"=>"one-arg",
                   "name"=>:value},
                 @vapi.prepare(:one_arg, :name=>:value))
  end

  def test_two_args
    assert_equal({"v.app"=>"api-rest",
                   "v.username"=>"user",
                   "v.password"=>"password",
                   "v.function"=>"two-args",
                   "name1"=>:value1,
                   "name2"=>"value2"},
                 @vapi.prepare(:two_args, :name1=>:value1, :name2=>"value2"))
  end

  def test_nil_arg
    assert_equal({"v.app"=>"api-rest",
                   "v.username"=>"user",
                   "v.password"=>"password",
                   "v.function"=>"two-args",
                   "name1"=>:value1},
                 @vapi.prepare(:two_args, :name1=>:value1, :name2=>nil))
  end
end

class Test_Vapi_call < Test::Unit::TestCase
  def dumb_server(request, response)
  end

  def test_bad_xml
    vapi = Vapi.new('http://vivisimo.com/robots.txt')
    assert_raise Nokogiri::XML::SyntaxError do
      vapi.query_service_status
    end
  end

  def test_HTTP_error
    vapi = Vapi.new('http://google.com/')
    assert_raise Net::HTTPServerException do
      vapi.nothing
    end
  end
end
