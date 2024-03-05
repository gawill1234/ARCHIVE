require 'rubygems'
require 'simple_http'
require 'velocity/api'
require 'nokogiri'

def pretty_print(xml)
  style = Nokogiri::XSLT(File.read("pretty_print.xsl"))
  xml = Nokogiri::XML(xml)
  style.apply_to(xml)
end

crawl_url_status = <<HERE
<crawl-url-status>
  <crawl-url-status-filter-operation name="and">
    <crawl-url-status-filter name="url" comparison="eq" value="file:///no-such-file" />
  </crawl-url-status-filter-operation>
</crawl-url-status>
HERE
req = SimpleHTTP.new('http://ux-qa-7.5b.apps2.vivisimo.com/vivisimo/cgi-bin/velocity')
resp = req.post('v.app' => 'api-rest',
                'v.function' => 'search-collection-url-status-query',
                'v.username' => 'test-all',
                'v.password' => 'P@$$word#1?',
                'collection' => 'test-light-crawler',
                'crawl-url-status' => crawl_url_status)
# pretty_print(resp.body)

# style = Nokogiri::XSLT(File.read("pretty_print.xsl"))
style = Nokogiri::XSLT(File.read("simple.xsl"))
xml = Nokogiri::XML(xml)
style.apply_to(xml)
