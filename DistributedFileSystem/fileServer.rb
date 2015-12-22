# Obfuscated - 44c032e8bdd6a98f514cd3ecfccaab9fcb1e2da42e2401113acbcd17a05da34b
# Distributed Systems - CS4032

require "socket"

class FileServer

  def initialize(ip, port)
    @studentID = "44c032e8bdd6a98f514cd3ecfccaab9fcb1e2da42e2401113acbcd17a05da34b"
    @ipAddr = ip
    @port = port
    @server = TCPServer.open(@ipAddr, @port)
    puts "Server running on #{@ipAddr}:#{@port}"
    run
  end

  def run
    loop {
      Thread.start(@server.accept) do | client |
        handleClient(client)
        puts "Client Proxy Request Received!"
      end
    }.join
  end

  def handleClient(client)
    loop {
        msg = client.gets
        processMessage(msg, client)
    }
  end

  def processMessage(msg, client)
    if msg.include?("OPEN")
      file = msg.split(':')[1].strip
      client.puts("OPEN request received from client proxy for file #{file}:\n\0")

    #close
    elsif msg.include?("CLOSE")
      file = msg.split(':')[1].strip
      client.puts("CLOSE request received from client proxy for file #{file}:\n\0")

    #read
    elsif msg.include?("READ")
      file = msg.split(':')[1].strip
      puts("READ request received from client proxy for file #{file}:\n\0")
      read(file, client)

    #write
    elsif msg.include?("WRITE")
      file = msg.split(' ')[1].strip
      edit = msg.split(' ')[2].strip
      if(write(file, edit, client))
        puts("WRITE request completed from client proxy for file #{file}:\n\0")
        client.puts("Write successful\n\0")
      else client.puts("Write failed\n\0")
      end

    #invalid input
    else
      client.puts("Invalid message received\n\0")
    end
  end

  def read(file, client)
    contents = ""
    oFile = File.open("files/#{file}", "r")
    oFile.each_line do |line|
      contents += line
    end
    oFile.close
    puts contents
    client.puts("#{contents}\n\0")
  end

  def write(file, edit, client)
    contents = ""
    File.write("files/#{file}", edit)
    return true
  end

end

FileServer.new("localhost", 3000)
