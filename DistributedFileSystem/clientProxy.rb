# Obfuscated - 44c032e8bdd6a98f514cd3ecfccaab9fcb1e2da42e2401113acbcd17a05da34b
# Distributed Systems - CS4032

require "socket"
require 'timeout'

class ClientProxy

  def initialize(ip, port)
    @ipAddr = ip
    @port = port
    @server = TCPServer.open(@ipAddr, @port)
    @DirectoryServerConnection = TCPSocket.open("localhost", 5000)
    @LockServerConnection = TCPSocket.open("localhost", 4001)
    @fileServers = Hash.new
    @fileServers = {1=>3000, 2=>3001}
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
    # Not used in NFS
    elsif msg.include?("OPEN")
      file_id = msg.split(':')[1].strip
      puts("OPEN request received for file_id - not used in NFS model #{file_id}:\n\0")

    #close - tell lock server to unlock the mutex associated with the file
    elsif msg.include?("CLOSE")
      file_id = msg.split(' ')[1].strip
      puts("CLOSE request received for file_id #{file_id}\n\0")
      msg = queryLockServer("CLOSE #{file_id}\n", client)
      client.puts("#{msg}\n\0")

    #read
    elsif msg.include?("READ")
      file_id = msg.split(' ')[1].strip
      puts("READ request received for file_id #{file_id}:\n\0")
      msg = queryLockServer(file_id, client)
      unless !checkLock(msg)
        msg = queryDirectoryServer(file_id)
        unless !checkMsg(msg)
          file = msg.split()[0]
          filerServerId = Integer(msg.split()[1])
          if port_open?("localhost", 3000, 1)
            connection = TCPSocket.open("localhost", @fileServers[filerServerId])
          else connection = TCPSocket.open(@ipAddr, 3002)
          end
          msg = readFile(file, client, connection)
          client.puts("#{msg}\n\0")
        else client.puts("File not found\n\0")
        end
      else client.puts("File is currently locked\n\0")
      end

    #write
    elsif msg.include?("WRITE")
      file_id = msg.split(' ')[1].strip
      edit = msg.split(':')[1]
      puts("WRITE request received for file_id #{file_id}:\n\0")
      msg = queryLockServer(file_id, client)
      unless !checkLock(msg)
        msg = queryDirectoryServer(file_id)
        unless !checkMsg(msg)
          file = msg.split()[0]
          filerServerId = Integer(msg.split()[1])
          if port_open?("localhost", 3000, 1)
            connection = TCPSocket.open("localhost", @fileServers[filerServerId])
          else
            puts "Primary file server down, routing request to replica set"
            connection = TCPSocket.open(@ipAddr, 3002)
          end
          msg = writeFile(file, edit, client, connection)
          client.puts("#{msg}\n\0")
        else client.puts("File not found\n\0")
        end
      else client.puts("File is currently locked\n\0")
      end

    #invalid input
    else
      client.puts("Invalid message received\n\0")
    end
  end

  def queryLockServer(msg, client)
    msg = msg.chomp
    @LockServerConnection.puts("#{msg} #{client}")
    msgRec = @LockServerConnection.gets("\0").chomp("\0")
    puts "Message Received from Lock Server: #{msgRec}"
    return msgRec
  end

  def checkLock(msg)
    if msg.include?("locked")
      return false
    else return true
    end
  end

  def queryDirectoryServer(file_id)
    @DirectoryServerConnection.puts(file_id)
    msgRec = @DirectoryServerConnection.gets("\0").chomp("\0")
    puts "Message Received from Directory Server: #{msgRec}"
    return msgRec
  end

  def checkMsg(msg)
    if msg.include?("Not a valid file_id") || msg.include?("File not found...")
      return false
    else return true
    end
  end

  def readFile(file, client, connection)
    connection.puts("READ: #{file}")
    msgRec = connection.gets("\0").chomp("\0")
    return msgRec
  end

  def writeFile(file, edit, client, connection)
    connection.puts("WRITE: #{file} : #{edit}\n")
    msgRec = connection.gets("\0").chomp("\0")
    return msgRec
  end

  def port_open?(ip, port, seconds)
    Timeout::timeout(seconds) do
      begin
        TCPSocket.new(ip, port).close
        true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        false
      end
    end
  rescue Timeout::Error
    false
  end

end

ClientProxy.new("localhost", 4000)
