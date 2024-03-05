#!/usr/local/bin/ruby

#
#   Bug 26888 for more info
#
#   * put ruby-connector.rb in the Velocity bin/ on a system that can run ruby.
#   * modify the #!/ path on the first line to point at my ruby install
#   * add the following the the <crawler> configuration:
#       <call-function name="vse-crawler-seed-urls" type="crawl-seed">
#         <with name="urls">rc:///foo</with>
#       </call-function>
#       <crawl-extender protocol="rc" exec="%bin/ruby %bin/ruby-connector.rb" />
#   * hit start crawl
#
#It should crawl 2 URLs.
#

require 'thread'
require 'socket'
require 'rexml/document'

include REXML

class RubyConnector

    def initialize(port, token)
	@lock = Mutex.new
        @socket = TCPSocket.new('127.0.0.1', port)

	send_xml("<crawl-extender-token token='#{token}'/>")

	@config = read_xml


	rescue
    end

    def get_config
	@config
    end

    def read_xml
	n = 0
	while (byte = @socket.sysread(1)) != "\n"
	    n = n * 10 + byte.to_i()
	end
	str = @socket.sysread(n)
        File.open('scrubby_rat', 'a') {|f| f.write(str + "\n") }
	(Document.new str).root
    end

    def send_xml(xml)
	str = xml.to_s
	if str[0,2] != "<?"
	    str = "<?xml version='1.0' ?>" + str
	end
	@lock.lock
	@socket.syswrite("#{str.length}\n")
	@socket.syswrite(str)
	@lock.unlock
    end

    def enqueue(crawl_enqueues, xml = nil)
	ce = Element.new "crawl-extender-enqueue"
	if ! xml.nil?
	    ce.attributes["url"] = xml.attributes["url"]
	end
	ce.elements << crawl_enqueues

	send_xml ce
    end

    def enqueue_url(url, xml = nil)
	ce = Element.new "crawl-url"
	ce.attributes["url"] = url
	enqueue(ce, xml)
    end

    def add_crawl_data(xml, encoding = "xml", content_type = "application/vxml")
	xml.add_element "crawl-data", { "encoding" => encoding, "content-type" => content_type }
    end

    def handle_incoming(xml)
	# You will want to override this function!
    end

    def process_requests
	while xml = read_xml do
	    Thread.new do
		begin
		    xml = handle_incoming(xml)
		rescue
		    xml.attributes["status"] = "error"
		    xml.attributes["error"] = $!
		end
		complete = Element.new "crawl-extender-complete"
		complete.elements << xml
		if xml.attributes["status"].nil?
		    xml.attributes["status"] = "complete"
		end
		send_xml complete
	    end
	end
    end
end

class MyConnector < RubyConnector
    def initialize(port, token)
	super(port, token)
    end

    def handle_incoming(xml)
        cd = add_crawl_data(xml)
        doc = cd.add_element "document"
        content = doc.add_element "content", { "name" => "title" }
        content.text = "Hi there: #{xml.attributes['url']}"
        enqueue_url("rc:///bar", xml)
	xml
    end
end

rc = MyConnector.new ARGV[0], ARGV[1]
rc.process_requests


