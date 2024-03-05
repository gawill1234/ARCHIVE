#!/usr/bin/env ruby

# ------------ Option-level methods ------------------ #

def configure_audit_log(c, how)
  xml = c.xml
  set_option(xml, 'crawl-options', 'crawl-option', 'audit-log', 'all')
  set_option(xml, 'crawl-options', 'crawl-option', 'audit-log-detail', 'full')
  set_option(xml, 'crawl-options', 'crawl-option', 'audit-log-when', how)
  c.set_xml(xml)
end

def configure_remote_common(c)
  xml = c.xml
  crawler_conf = xml.xpath('//vse-config/crawler').first
  opt = crawler_conf.document.create_element('call-function')
  opt['name'] = 'vse-crawler-remote-common'
  opt['sub-type'] = 'common'
  opt['type'] = 'crawl-condition-remote'

  # Create the function parameters XML
  server = opt.document.create_element('with')
  server['name'] = 'remote-name'
  server.content = c.name
  opt << server

  crawler_conf << opt
  c.set_xml(xml)
end

def configure_remote_client(c, requested, addr, rebase_addr = nil)
  xml = c.xml
  crawler_conf = xml.xpath('//vse-config/crawler').first
  opt = crawler_conf.document.create_element('call-function')
  opt['name'] = 'vse-crawler-remote-client'
  opt['sub-type'] = 'client'
  opt['type'] = 'crawl-condition-remote'

  # Create the function parameters XML
  server = opt.document.create_element('with')
  server['name'] = 'remote-servers'
  server.content = addr
  opt << server

  collection_requested = opt.document.create_element('with')
  collection_requested['name'] = 'remote-requested'
  collection_requested.content = requested
  opt << collection_requested

  if rebase_addr
    rebase = opt.document.create_element('with')
    rebase['name'] = 'remote-rebase-server'
    rebase.content = rebase_addr
    opt << rebase
  end

  crawler_conf << opt
  c.set_xml(xml)
end

def configure_remote_server(c, clients, port, proxied=nil)
  xml = c.xml
  crawler_conf = xml.xpath('//vse-config/crawler').first

  opt = crawler_conf.document.create_element('call-function')
  opt['name'] = 'vse-crawler-remote-server'
  opt['sub-type'] = 'server'
  opt['type'] = 'crawl-condition-remote'

  port_node = opt.document.create_element('with')
  port_node['name'] = 'remote-listener-port'
  port_node.content = port
  opt << port_node

  serve_self = opt.document.create_element('with')
  serve_self['name'] = 'remote-serve-self'
  serve_self.content = 'true'
  opt << serve_self

  clients_node = opt.document.create_element('with')
  clients_node['name'] = 'remote-clients'
  clients_node.content = clients
  opt << clients_node

  if proxied
    proxied_node = opt.document.create_element('with')
    proxied_node['name'] = 'remote-served'
    proxied_node.content = proxied
    opt<< proxied_node
  end

  crawler_conf << opt
  c.set_xml(xml)
end

def remove_light_crawler(c)
  xml = c.xml
  child = xml.xpath("//vse-config/crawler/call-function[@name='vse-crawler-light-crawler']")
  if child.empty?
    msg "Light crawler component not found"
  else
    msg "Removing light crawler component"
    xml.xpath("//vse-config/crawler/call-function[@name='vse-crawler-light-crawler']").remove
  end
  c.set_xml(xml)
end

# --------------- Setups ------------------- #

def setup_new_collection_as_remote(collection_alias, collection_name,
                                   audit_log_mode)
  msg "Creating empty collection for #{collection_alias} (#{collection_name})"
  collection = Collection.new(collection_name)
  collection.delete
  collection.create
  configure_audit_log(collection, audit_log_mode)
  configure_remote_common(collection)
  collection
end

def setup_two_independent_servers_and_a_client(server1_name,
                server2_name, client_name,
                port1, port2, audit_log_mode)

  server1 = setup_new_collection_as_remote("server1", server1_name,
               audit_log_mode)
  configure_remote_server(server1, client_name, port1)

  server2 = setup_new_collection_as_remote("server2", server2_name,
               audit_log_mode)
  configure_remote_server(server2, client_name, port2)

  client = setup_new_collection_as_remote("client", client_name,
              audit_log_mode)
  configure_remote_client(client, server1_name + "\n" + server2_name,
    TESTENV.host + ":#{port1}" + "\n" + TESTENV.host + ":#{port2}")

  [server1, server2, client]

end

def setup_server_and_client(server_name, client_name, port, audit_log_mode)

  server = setup_new_collection_as_remote("server", server_name,
               audit_log_mode)
  configure_remote_server(server, client_name, port)

  client = setup_new_collection_as_remote("client", client_name,
              audit_log_mode)
  configure_remote_client(client, server_name,
              TESTENV.host + ":#{port}")

  [server, client]

end

# Helper
def setup_a_mirror(this_server_alias, this_server_name, other_server_name,
      this_server_port, other_server_port, audit_log_mode)

  this_server = setup_new_collection_as_remote(this_server_alias,
                  this_server_name, audit_log_mode)
  configure_remote_server(this_server, other_server_name, this_server_port)
  configure_remote_client(this_server, other_server_name,
              TESTENV.host + ":#{other_server_port}")
  this_server
end

def setup_two_mirrors(server1_name, server2_name, port1, port2, audit_log_mode)

  server1 = setup_a_mirror("server1", server1_name, server2_name,
              port1, port2, audit_log_mode)

  server2 = setup_a_mirror("server2", server2_name, server1_name,
              port2, port1, audit_log_mode)
  [server1, server2]
end

# -------------------- State verification --------------

#+
# Private subroutine.
#
# Returns nil if the given string is of the form, "synchronized: n of n updates applied"
# where n is a decimal integer, or returns a descriptive error message otherwise.
#-
def sub_vfy_remote_coll_synch(state)
  return 'is missing state attribute' if state.length == 0
  match = %r|synchronized:\s*(?<count>\d+)\s+of\s+(?<total>\d+)| =~ state
  if ! match || count != total
    "state is #{state}"
  else
    nil
  end
end

#+
# Calls collection.status() to get the collection's status XML, and then inspects each of the
# <crawl-remote-collection-status name='...' status='...' /> nodes that are found within.
#
# Calls results.add(true,...) once for each such node with a status attribute of the form,
#   "synchronized: n of n updates applied" (where n is a decimal integer), and
# Calls results.add(false,...) once for each node having a status attribute of any other
#   form, or
# Calls results.add(false,...) if no such nodes exist.
#-
def vfy_remote_collection_state_is_synchronized(collection, results)
  count = 0
  collection.with_crawl_remote_all_status do |conn_name, conn_state, coll_name, coll_state|
    pfx = "remote connection, #{conn_name}/#{coll_name}"
    reason = sub_vfy_remote_coll_synch(coll_state)
    results.add(! reason, "#{pfx}, state is #{coll_state}.", "#{pfx}, #{reason}.")
    count += 1
  end

  if count == 0
    results.add(false, '---', "Collection #{collection.name} has no remotes.")
  end
end

# The same functionality, but allowing some retry time
def vfy_remote_collection_state_is_synchronized_with_retries(collection,
        results, retry_time=90)
  retry_until = Time.now + retry_time
  # Try to wait for synchronized status on all nodes
  begin
    count = 0
    some_nodes_not_ready = false
    collection.with_crawl_remote_all_status do |conn_name, conn_state, coll_name, coll_state|
      some_nodes_not_ready = ((some_nodes_not_ready) ||
        (sub_vfy_remote_coll_synch(coll_state)))
      count += 1
    end
  end while ((count !=0) && (some_nodes_not_ready) && (Time.now <= retry_until))
  # Synchronized or not, process the status
  vfy_remote_collection_state_is_synchronized(collection, results)
end

# Checks synchronization status on an array of collections
def check_all_collections_are_synchronized(collections, results)
  collections.each do |collection|
    vfy_remote_collection_state_is_synchronized_with_retries(collection, results)
  end
end

