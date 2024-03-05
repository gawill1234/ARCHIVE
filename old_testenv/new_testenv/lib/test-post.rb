#!/usr/bin/env ruby

require 'post'
require 'test/unit'
require 'net/http'
require 'socket'

class Test_Post_form_urlencode < Test::Unit::TestCase

  def setup
    @post = Post.new('http://nowhere/')
  end

  def test_strings
    # Strings should pass through without change.
    for s in ['abc', 'arg=value', 'n=%10&r=%13', '', " line one \n line two \n"]
      assert_equal(s, @post.form_urlencode(s))
    end
  end

  def test_simple_text_hash
    h = {:a=>:alpha, 'b'=>'beta', "z"=>"zeta"}
    f = @post.form_urlencode(h)
    # These can be in any order.
    assert_match(/a=alpha/, f)
    assert_match(/b=beta/, f)
    assert_match(/z=zeta/, f)
  end

  def test_simple_text_assoc
    h = [[:a, :alpha], ['b', 'beta'], ["z", "zeta"]]
    assert_equal('a=alpha&b=beta&z=zeta', @post.form_urlencode(h))
  end

  def test_complex_assoc
    h = [[:a, 'a-b_c.d&e'], [:b, '!@#$'], [:c, "<html>text</html>"]]
    assert_equal('a=a-b_c.d%26e&b=%21%40%23%24&c=%3Chtml%3Etext%3C%2Fhtml%3E',
                 @post.form_urlencode(h))
  end
end

class Test_Post_post < Test::Unit::TestCase

  # def setup
  # def teardown

  def read_post_request(conn)
    # This is making the bold assumption that the POST request is well
    # formed. If content length is screwed up, we may hang--not the
    # nicest test failure mode.
    request = ''
    while header = conn.gets and header != "\r\n"
      request += header
      content_length = $1.to_i if header.match(/Content-Length: ([0-9]+)/)
    end
    if header
      request += header
      data = conn.read(content_length)
      request += data if data
    end
    request
  end

  def server_trivial_with_close(port, requests)
    Thread.new do
      server = TCPServer.open(port)
      requests.times do |i|
        conn = server.accept
        read_post_request(conn)
        trivial_xml = "<document>Hi number #{i}</document>"
        conn.write "HTTP/1.1 200 OK\r\n" \
                   "Content-Length: #{trivial_xml.length}\r\n" \
                   "\r\n" + trivial_xml
        conn.close()
      end
    end
  end

  def server_trivial_no_close(port, requests)
    Thread.new do
      server = TCPServer.open(port)
      conn = server.accept
      requests.times do |i|
        read_post_request(conn)
        trivial_xml = "<document>Hi number #{i}</document>"
        conn.write "HTTP/1.1 200 OK\r\n" \
                   "Content-Length: #{trivial_xml.length}\r\n" \
                   "\r\n" + trivial_xml
      end
    end
  end

  def server_trivial_keep_alive(port, requests)
    Thread.new do
      server = TCPServer.open(port)
      conn = server.accept
      requests.times do |i|
        read_post_request(conn)
        trivial_xml = "<document>Hi number #{i}</document>"
        conn.write "HTTP/1.1 200 OK\r\n" \
                   "Connection: Keep-Alive\r\n" \
                   "Content-Length: #{trivial_xml.length}\r\n" \
                   "\r\n" + trivial_xml
      end
    end
  end

  def test_keep_alive
    port = 2004
    loop = 5
    server_trivial_keep_alive(port, loop)
    post = Post.new("http://LocalHost:#{port}")
    loop.times do |i|
      assert_match(/Hi number #{i}/, post.post('argument=should+work').body)
    end
  end

  def test_keep_alive_one
    port = 2014
    loop = 1
    server_trivial_keep_alive(port, loop)
    post = Post.new("http://LocalHost:#{port}")
    loop.times do |i|
      assert_match(/Hi number #{i}/, post.post('argument=should+work').body)
    end
  end

  def test_no_close_one
    port = 2013
    loop = 1
    server_trivial_no_close(port, loop)
    post = Post.new("http://LocalHost:#{port}")
    loop.times do |i|
      assert_match(/Hi number #{i}/, post.post('argument=should+work').body)
    end
  end

  def test_no_close
    port = 2003
    loop = 5
    server_trivial_no_close(port, loop)
    post = Post.new("http://LocalHost:#{port}")
    loop.times do |i|
      assert_match(/Hi number #{i}/, post.post('argument=should+work').body)
    end
  end

  def test_premature_close
    # This is a little weird, demonstrating an uncomfortable side
    # effect of the keep-alive retry handling in Post.post
    trivial_xml = "<document>Response after first close.</document>"
    Thread.new do
      server = TCPServer.open(2002)
      conn = server.accept
      read_post_request(conn)
      conn.close()
      conn = server.accept
      read_post_request(conn)
      conn.write "HTTP/1.1 200 OK\r\n" \
                 "Content-Length: #{trivial_xml.length}\r\n" \
                 "\r\n" + trivial_xml
      conn.close()
    end
    post = Post.new('http://LocalHost:2002')
    resp = post.post('argument=should+work')
    assert_equal(trivial_xml, resp.body)
  end

  def dont_test_no_timeout
    trivial_xml = "<document>After a long time...</document>"
    Thread.new do
      server = TCPServer.open(2005)
      conn = server.accept
      read_post_request(conn)
      sleep 20*60
      conn.write "HTTP/1.1 200 OK\r\n" \
                 "Connection: Keep-Alive\r\n" \
                 "Content-Length: #{trivial_xml.length}\r\n" \
                 "\r\n" + trivial_xml
    end
    post = Post.new('http://LocalHost:2005')
    resp = post.post('argument=should+work+after+long+sleep')
    assert_equal(trivial_xml, resp.body)
  end

  def test_nasty_server
    Thread.new do
      server = TCPServer.open(2000)
      conn = server.accept
      read_post_request(conn)
      conn.close()
      conn = server.accept
      read_post_request(conn)
      conn.close()
    end
    post = Post.new('http://LocalHost:2000')
    assert_raise EOFError do
      # What is not obvious here is that two requests are made...
      post.post('argument=expect+end+of+file')
    end
  end

  def test_trivial_server
    port = 2001
    loop = 5
    server_trivial_with_close(port, 5)
    post = Post.new("http://LocalHost:#{port}")
    loop.times do |i|
      assert_match(/Hi number #{i}/, post.post('argument=should+work').body)
    end
  end

  def test_no_path
    # Make sure paths are normalized.
    post = Post.new('http://Vivisimo.com')
    post.post('')
  end

  def test_with_path
    # Make sure we get back some reasonable data.
    post = Post.new('http://Vivisimo.com/robots.txt')
    assert_match(/^User-agent:/, post.post('').body)
  end

  def test_connection_refused
    post = Post.new('http://localhost:10')
    assert_raise Errno::ECONNREFUSED do
      post.post('')
    end
  end

  def test_no_route_to_host
    post = Post.new('http://172.16.10.252')
    assert_raise Errno::EHOSTUNREACH do
      post.post('')
    end
  end

  def test_unknown_host
    post = Post.new('http://unknown-gronk.Vivisimo.com')
    assert_raise SocketError do
      post.post('')
    end
  end

  def test_405_method_not_allowed
    # Google (appropriately) tells us POST is inappropriate
    post = Post.new('http://Google.com/')
    assert_raise Net::HTTPServerException do
      post.post('')
    end
  end
end
