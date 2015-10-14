# Conor Broderick - 11349681
# Distributed Systems - CS4032

require 'socket'
class Client
  def initialize()
    @server = TCPSocket.open('localhost', 2000)
    pingServer
  end
  def pingServer()
    @server.puts("Conor Broderick\n")
    while line = @server.gets
      puts line.chop
    end
    @server.close # Close the socket
  end
end
