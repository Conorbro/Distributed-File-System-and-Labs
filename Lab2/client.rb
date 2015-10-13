# Conor Broderick - 11349681
# Distributed Systems - CS4032

require 'socket'
class Client
  def initialize()
    @server = TCPSocket.open('localhost', 2000)
    pingServer
  end
  def pingServer()
    print @server.read # Read response from server (server.rb)
    # @server.puts "KILL_SERVICE\n"
    # @server.puts "HELO text\n"
    @server.close # Close the socket
  end
end
