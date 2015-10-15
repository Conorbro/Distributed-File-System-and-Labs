# Obfuscated - 44c032e8bdd6a98f514cd3ecfccaab9fcb1e2da42e2401113acbcd17a05da34b
# Distributed Systems - CS4032

require 'socket'
class Client
  def initialize()
    @server = TCPSocket.open('localhost', 2000)
    pingServer
  end
  def pingServer()
    @server.puts("CB\n")
    # @server.puts("KILL_SERVICE\n")
    # @server.puts("HELO bob\n")
    while line = @server.gets
      puts line.chop
    end
    @server.close # Close the socket
  end
end
