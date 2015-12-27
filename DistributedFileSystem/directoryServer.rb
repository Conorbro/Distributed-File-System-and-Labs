# Obfuscated - 44c032e8bdd6a98f514cd3ecfccaab9fcb1e2da42e2401113acbcd17a05da34b
# Distributed Systems - CS4032

require "socket"

class DirectoryServer

  def initialize(ip, port)
    @ipAddr = ip
    @port = port
    @server = TCPServer.open(@ipAddr, @port)
    @fileServer1 = Hash.new
    @fileServer2 = Hash.new
    @fileServer1 = {1=>"file1.txt", 2=>"file2.txt", 3=>"file3.txt"}
    @fileServer2 = {4=>"file4.txt"}
    @fileServers = Hash.new
    @fileServers = {1=>@fileServer1, 2=>@fileServer2}
    puts "Directory Server running on #{@ipAddr}:#{@port}"
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
        msg = client.gets.chomp
        processMessage(msg, client)
    }
  end

  def processMessage(msg, client)
    if msg.include?("KILL_SERVICE")
      exit
    end
    unless !isInteger?(msg)
        fileId = Integer(msg)
    else client.puts("Not a valid file_id")
    end
    msg = findFile(fileId)
    client.puts("#{msg}\n\0")
  end

  def findFile(fileId)
    msg = "File not found..."
    @fileServers.each do |key, value|
      puts key
     if value.has_key?(fileId)
       fileName = value[fileId]
       puts "fileName = #{fileName}"
       puts "fileServerId = #{key}"
       msg = "#{fileName} #{key}"
       return msg
     end
    end
  end

  def isInteger?(msg)
   !!(msg =~ /\A[-+]?[0-9]+\z/)
  end

end

DirectoryServer.new("localhost", 5000)
