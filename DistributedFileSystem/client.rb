# Obfuscated - 44c032e8bdd6a98f514cd3ecfccaab9fcb1e2da42e2401113acbcd17a05da34b
# Distributed Systems - CS4032

require 'socket'
class Client
  def initialize()
    @ClientProxyServerConnection = TCPSocket.open("localhost", 4000)
    # Info of file system and how to use the client
    puts "Available files: 1, 2, 3, 4"
    puts "EXAMPLES OF VALID COMMANDS:"
    puts "READ 1"
    puts "WRITE 2 : Updated file text"
    puts "CLOSE 2"
    puts "HELO text"
    puts "KILL_SERVICE"
    pingServer
  end
  def pingServer()
      loop{
        msg = gets.chomp
        fileId = msg.split[1]
        @ClientProxyServerConnection.puts(msg)
        msgRec = @ClientProxyServerConnection.gets("\0").chomp("\0")
        msgRec = msgRec.strip
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
