# This will delete and recreate each collection with the appropriate configuration.
#
# The distributed configuration:
# * Each server will serve to the other server and the same-numbered client.
# * Each server will connect to the opposite-numbered server.
# * Each server is configured to proxy the data of the opposite-numbered server.
# * Each client will connect to the same-numbered server.
# * Each client asks for both server's data.
def setup_servers_and_clients(server1, server1_addr,
                              server2, server2_addr,
                              client1, client1_addr,
                              client2, client2_addr,
                              audit_log_mode)

  msg "Creating empty collections"

  msg "Creating empty collection for #{server1_addr}"
  server1.delete
  server1.create
  configure_audit_log(server1, audit_log_mode)
  configure_remote_client(server1, SERVER2_NAME, server2_addr + ":#{SERVER2_PORT}")
  configure_remote_common(server1)
  configure_remote_server(server1, SERVER2_NAME + "\n" + CLIENT1_NAME, SERVER1_PORT, SERVER2_NAME)

  msg "Creating empty collection for #{server2_addr}"
  server2.delete
  server2.create
  configure_audit_log(server2, audit_log_mode)
  configure_remote_client(server2, SERVER1_NAME, server1_addr + ":#{SERVER1_PORT}")
  configure_remote_common(server2)
  configure_remote_server(server2, SERVER1_NAME + "\n" + CLIENT2_NAME, SERVER2_PORT, SERVER1_NAME)

  msg "Creating empty collection for #{client1_addr}"
  client1.delete
  client1.create
  configure_audit_log(client1, audit_log_mode)
  configure_remote_client(client1, SERVER1_NAME + "\n" + SERVER2_NAME, server1_addr + ":#{SERVER1_PORT}")
  configure_remote_common(client1)

  msg "Creating empty collection for #{client2_addr}"
  client2.delete
  client2.create
  configure_audit_log(client2, audit_log_mode)
  configure_remote_client(client2, SERVER2_NAME + "\n" + SERVER1_NAME, server2_addr + ":#{SERVER2_PORT}")
  configure_remote_common(client2)
end
