require 'socket'

# This class can be used to simulate strange webserver responses for the crawler
class SimpleCrawlingServer
  # Starts the server bound to a random port
  def initialize
    @server = TCPServer.new(0)
  end

  # Returns a URL that can be used to access this server
  def local_url
    "http://#{host}:#{port}/"
  end

  # Executes the specified block with an accepted connection
  def accept
    client = @server.accept

    begin
      # puts "Connection from #{client.peeraddr.join(' ')}"
      # puts client.readline

      yield client
    ensure
      client.shutdown
    end
  end

  # Shuts down the server, freeing the socket
  def shutdown
    @server.shutdown
  end

  # Returns a host for the current machine.
  # This hasn't been tested on machines with lots of network interfaces...
  def host
    interface = Socket.ip_address_list.find do |intf|
      intf.ipv4? && !intf.ipv4_loopback?
    end
    interface.ip_address
  end
  private :host

  # Returns the port that has been selected for the server
  def port
    @server.addr[1]
  end
  private :port
end
