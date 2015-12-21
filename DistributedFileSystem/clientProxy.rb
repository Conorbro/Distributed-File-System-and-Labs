# Obfuscated - 44c032e8bdd6a98f514cd3ecfccaab9fcb1e2da42e2401113acbcd17a05da34b
# Distributed Systems - CS4032

require "socket"

class ClientProxy

  def initialize(ip, port)
    @ipAddr = ip
    @port = port
    @server = TCPServer.open(@ipAddr, @port)
    @FileServerConnection = TCPSocket.open("localhost", 3000)
    @studentID = "44c032e8bdd6a98f514cd3ecfccaab9fcb1e2da42e2401113acbcd17a05da34b"
    puts "Client proxy running on #{@ipAddr}:#{@port}"
    run
  end

  def run
    loop {
      Thread.start(@server.accept) do | client |
        handleClient(client)
        puts "Client Connected"
      end
    }.join
  end

  def handleClient(client)
    loop {
        msg = client.gets.chomp
        processMessage(msg, client)
    }
  end

  def processMessage(msg, client)

    # Basic commands from labs
    if msg.split[0] == "HELO"
      client.puts("HELO #{msg.split[1]}\nIP:#{@ipAddr}\nPort:#{@port}\nStudentID:#{@studentID}\n\0") # Return initial message to client before forwarding any more messages
    elsif msg.include?("KILL_SERVICE")
      client.close
      exit

    #open
    elsif msg.include?("OPEN")
      file = msg.split(':')[1].strip
      client.puts("OPEN request received for file #{file}:\n\0")
      #open(client)

    #close
    elsif msg.include?("CLOSE")
      file = msg.split(':')[1].strip
      client.puts("CLOSE request received for file #{file}:\n\0")

    #read
    elsif msg.include?("READ")
      file = msg.split(':')[1].strip
      puts("READ request received for file #{file}:\n\0")
      msg = readFile(file, client)
      puts msg
      client.puts("#{msg}\n\0")

    #write
    elsif msg.include?("WRITE")
      file = msg.split(' ')[1].strip
      edit = msg.split(' ')[2].strip
      puts file
      puts edit
      puts("WRITE request received for file #{file}:\n\0")
      msg = writeFile(file, edit, client)
      client.puts("#{msg}\n\0")

    #invalid input
    else
      client.puts("Invalid message received\n\0")
    end
  end

  def readFile(file, client)
    @FileServerConnection.puts("READ: #{file}")
    msgRec = @FileServerConnection.gets("\0").chomp("\0")
    return msgRec
  end

  def writeFile(file, edit, client)
    @FileServerConnection.puts("WRITE: #{file} #{edit}\n")
    msgRec = @FileServerConnection.gets("\0").chomp("\0")
    return msgRec
  end

end

ClientProxy.new("localhost", 4000)
