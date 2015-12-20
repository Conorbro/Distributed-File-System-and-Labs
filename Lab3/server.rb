require "socket"
require "securerandom"
require 'open-uri'
# 52.31.144.213
class Server

  def initialize(port, ip)
    @studentID = "44c032e8bdd6a98f514cd3ecfccaab9fcb1e2da42e2401113acbcd17a05da34b"
    @ipAddr = open('http://whatismyip.akamai.com').read
    @port = port
    @server = TCPServer.open(port)
    @roomIds = Hash.new
    @connections = Hash.new
    @rooms = Hash.new { |hash, key| hash[key] = [] }
    @roomids = Hash.new
    @clients = Hash.new
    @links = Hash.new
    @connections[:server] = @server
    @connections[:rooms] = @rooms
    @connections[:clients] = @clients
    @connections[:roomids] = @roomids
    @connections[:links] = @links
    @clients = 0
    @rooms = 0
    run
  end

  def run
    loop {
      Thread.start(@server.accept) do | client |
        handleClient(client)
      end
    }.join
  end

  def handleClient(client)
    loop {
        init_msg = client.gets.chomp
        processMessage(init_msg, client)
    }
  end

  def processMessage(init_msg, client)
        if init_msg.split[0] == "HELO"
          client.puts("HELO #{init_msg.split[1]}\nIP:#{@ipAddr}\nPort:#{@port}\nStudentID:#{@studentID}\n") # Return initial message to client before forwarding any more messages
        elsif init_msg.split[0].include?("JOIN_CHATROOM:")
          joinRoom(init_msg, client)
        elsif init_msg.split[0].include?("LEAVE_CHATROOM:")
          leaveRoom(init_msg, client)
        elsif init_msg.split[0] == "ANYTHING"
            puts "."
        elsif init_msg.split[0].include?("CHAT:")
            sendMessage(init_msg, client)
        end
  end

  def sendMessage(init_msg, client)
      puts init_msg
      room_id = init_msg.split(':')[1]
      room_id = Integer(room_id)

      msg = client.gets.chomp
      puts msg
      client_id = msg.split()[1]
      client_id = Integer(client_id)

      msg = client.gets.chomp
      puts msg
      nickName = msg.split()[1]

      msg = client.gets.chomp
      puts msg
      message = msg.split(':')[1]
      puts " "
      msg = "CHAT:#{room_id}\nCLIENT_NAME:#{nickName}\nMESSAGE:#{message}\n\n"
      puts msg
      room = @connections[:roomids][room_id]

    #   puts @connections[:rooms]
    #   puts @connections[:links]
    #   puts @connections[:clients].key("client3")
      @connections[:rooms][room].each do |user| # Post message to each user in the room
            @connections[:links][Integer(user)].puts(msg)
        end

  end

  def leaveRoom(init_msg, client)
        room_id = init_msg.split(':')[1]
        room_id = Integer(room_id)
        msg = client.gets
        client_id = msg.split(':')[1].chomp
        client_id = client_id.gsub(/\s+/, "")
        client_id = Integer(client_id)
        room = @connections[:roomids][room_id]
        @connections[:rooms][room].delete(String(client_id))
        nickName = @connections[:clients][client_id]
        msg = "LEFT_CHATROOM:#{room_id}\nJOIN_ID:#{client_id}\n"
        client.puts(msg)
        msg = "CHAT:#{room_id}\nCLIENT_NAME:#{nickName}\nMESSAGE:#{nickName} has left this chatroom.\n\n"
        client.puts(msg)
        @connections[:rooms][room].each do |user| # Post to each user in the room that the new user has left
            @connections[:links][Integer(user)].puts msg
        end
  end

  def joinRoom(init_msg, client)
      room = init_msg.split(':')[1]
      room = room.strip
      msg = client.gets
      clientIp = msg.split(':')[1].chomp

      msg = client.gets
      clientPort = msg.split(':')[1].chomp

      msg = client.gets
      nickName = msg.split(':')[1].chomp

      if @connections[:clients].has_value?(nickName) == false
          client_id = getNextClientId
          @connections[:clients][client_id] = nickName # add client id to client
          @connections[:links][client_id] = client
      else
        client_id = @connections[:clients].key(nickName)
      end

      if @connections[:roomids].has_value?(room) == false
        room_id = getNextRoomId
        @connections[:roomids][room_id] = room
      else
        room_id = @connections[:roomids].key(room)
      end
      @connections[:rooms]["#{room}"].push("#{client_id}") # add client to room by id
      msg = "JOINED_CHATROOM:#{room}\nSERVER_IP:#{@ipAddr}\nPORT:#{@port}\nROOM_REF:#{room_id}\nJOIN_ID:#{client_id}"
      client.puts(msg)
      msg = "CHAT:#{room_id}\nCLIENT_NAME:#{nickName}\nMESSAGE:#{nickName} has joined this chatroom.\n\n"
      @connections[:rooms][room].each do |user| # Post to each user in the room that the new user has joined
        @connections[:links][Integer(user)].puts msg
      end
  end

  def getNextClientId()
    @clients += 1
    return @clients
  end
  def getNextRoomId()
    @rooms += 1
    return @rooms
  end
end

Server.new(80, "localhost")
