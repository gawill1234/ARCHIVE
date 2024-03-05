# Setup two independent (not getting updates from each other)
# servers, server1 and server2, and one client that
# is getting updates from both servers.
# Created for replicated-synch-conflict test

def setup_collection_as_remote(host_alias, host, audit_log_mode)
  msg "Creating empty collection for #{host_alias} (#{host.name})"
  host.delete
  host.create
  configure_audit_log(host, audit_log_mode)
  configure_remote_common(host)
end

def setup_three(server1, server1_addr,
                server2, server2_addr,
                client, client_addr,
                port1, port2, audit_log_mode)

  setup_collection_as_remote("server1", server1, audit_log_mode)
  configure_remote_server(server1, client.name, port1)

  setup_collection_as_remote("server2", server2, audit_log_mode)
  configure_remote_server(server2, client.name, port2)

  setup_collection_as_remote("client", client, audit_log_mode)
  configure_remote_client(client, server1.name + "\n" + server2.name, server1_addr + ":#{port1}" + "\n" + server2_addr + ":#{port2}")

end
