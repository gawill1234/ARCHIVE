# This will delete and recreate each collection with the appropriate configuration.
#
# The distributed configuration:
# * The server will serve to the same-numbered client.
# * The client will connect to the same-numbered server.
# * The client asks for the server's data.
def setup_server_and_client(server1, server1_addr,
                             client1, client1_addr,
                             audit_log_mode)

  msg "Creating empty collections"

  msg "Creating empty collection for #{server1_addr}"
  server1.delete
  server1.create
  configure_audit_log(server1, audit_log_mode)
  configure_remote_common(server1)
  configure_remote_server(server1,CLIENT1_NAME, SERVER1_PORT)

  msg "Creating empty collection for #{client1_addr}"
  client1.delete
  client1.create
  configure_audit_log(client1, audit_log_mode)
  configure_remote_client(client1, SERVER1_NAME, server1_addr + ":#{SERVER1_PORT}")
  configure_remote_common(client1)
end
