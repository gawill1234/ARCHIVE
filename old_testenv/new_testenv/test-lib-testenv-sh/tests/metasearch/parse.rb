def easy_parse(url, options = {})
  parse_xml = <<EOF
<scope>
  <parse />
  <fetch finish="finish" timeout="10000" />
</scope>
EOF

  parse_xml = Nokogiri::XML(parse_xml).root
  parse = parse_xml.xpath('//parse').first
  parse['url'] = url

  if options[:username]
    parse['username'] = options[:username]
  end

  if options[:password]
    parse['password'] = options[:password]
  end

  vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
  return vapi.viv_vivisimo_xml_processed_state(parse_xml)
end

class TestResults
  def add_parse_status(parse_node)
    status = parse_node['status']

    self.add(status.include?('fetched'), 'status contains fetched')
    self.add(status.include?('processed'), 'status contains processed')
    self.add(status.include?('parsed'), 'status contains parsed')
  end
end

def easy_parse_ldap(results, username = nil, password = nil)
  options = {
    :username => username,
    :password => password
  }
  processed = easy_parse('ldap://testbed14.test.vivisimo.com/cn=test1,dc=test,dc=vivisimo,dc=com?cn', options)

  parses = processed.xpath('//parse')
  results.add_number_equals(1, parses.length, 'parse node')

  parse = parses.first
  parse.each{|name, value| msg '%s="%s"' % [name, value]}
  results.add_parse_status(parse)
end
