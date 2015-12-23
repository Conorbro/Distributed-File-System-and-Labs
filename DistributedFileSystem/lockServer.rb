# Obfuscated - 44c032e8bdd6a98f514cd3ecfccaab9fcb1e2da42e2401113acbcd17a05da34b
# Distributed Systems - CS4032

require "socket"

class LockServer

  def initialize(ip, port)
    @ipAddr = ip
    @port = port
    @server = TCPServer.open(@ipAddr, @port)
    @lock1 = Mutex.new
    @lock2 = Mutex.new
    @lock3 = Mutex.new
    @lock4 = Mutex.new
    @files = Hash.new
    @lockedBy = Hash.new
    @files = {1=>@lock1, 2=>@lock2, 3=>@lock3, 4=>@lock4} # file id : assocaited lock
    @lockedBy ={1=>0, 2=>0, 3=>0, 4=>0}
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
        msg = client.gets.chomp
        processMessage(msg, client)
    }
  end

  def processMessage(msg, client)
    if msg.include?("CLOSE")
      fileId = msg.split[1].strip
      client_id = msg.split[2].strip
      fileId = Integer(fileId)
      if unlockFileLock(fileId, client_id)
        client.puts("#{fileId} unlocked\0\n")
      else client.puts("Cannot unlock file locked by another client...\0\n")
      end
    else
      fileId = msg.split[0].strip
      unless !isInteger?(fileId)
          # fileId = msg.split[0].strip
          fileId = Integer(fileId)
          client_id = msg.split[1].strip
      else client.puts("Not a valid file_id")
      end
      msg = checkFileLock(fileId, client_id)
      client.puts("#{msg}\n\0")
    end
  end

  def unlockFileLock(fileId, client_id)
    @files.each do |key, value|
      key = Integer(key)
      if key == fileId && value.locked? && @lockedBy[key] == client_id
        @lockedBy[key] = 0
        value.unlock
        return true
      elsif key == fileId && value.locked? && @lockedBy[key] != client_id
        return false
      end
    end
  end

  def checkFileLock(fileId, client_id)
    msg = "File not found..."
    if @lockedBy[fileId] == client_id
      return "File access granted for file_id #{fileId}"
    end
    @files.each do |key, value|
     key = Integer(key)
     if key == fileId && !value.locked? # lock file if file is found and not locked
       value.lock
       @lockedBy[key] = client_id
       return "File access granted for file_id #{fileId}"
     elsif key == fileId && value.locked?
       return "File #{fileId} is currently locked by client another client"
     end
    end
    return msg
  end

  def isInteger?(msg)
   !!(msg =~ /\A[-+]?[0-9]+\z/)
  end


end

LockServer.new("localhost", 4001)
