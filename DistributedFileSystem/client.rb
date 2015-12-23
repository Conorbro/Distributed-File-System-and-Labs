# Obfuscated - 44c032e8bdd6a98f514cd3ecfccaab9fcb1e2da42e2401113acbcd17a05da34b
# Distributed Systems - CS4032

require 'socket'
class Client
  def initialize()
    @ClientProxyServer = TCPSocket.open("localhost", 4000)
    pingServer
  end
  def pingServer()
      loop{
        msg = gets.chomp
        fileId = msg.split[1]
        @ClientProxyServer.puts(msg)
        msgRec = @ClientProxyServer.gets("\0").chomp("\0")
        puts msgRec.chomp
        # if msg.include?("READ") || msg.include?("WRITE")
        #   @ClientProxyServer.puts("CLOSE #{fileId}")
        #   msgRec = @ClientProxyServer.gets("\0").chomp("\0")
        #   puts msgRec.chomp
        # end
    }
  end
end

Client.new()


# PROTOCOL
# WRITE: command filename edit
# READ: command filename
# CLOSE: command filename
