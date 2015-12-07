require "socket"
require "securerandom"

class Server

  def initialize( port, ip )
    @server = TCPServer.open( ip, port )
    @roomIds = Hash.new
    @connections = Hash.new
    @rooms = Hash.new { |hash, key| hash[key] = [] }
    @clients = Hash.new
    @connections[:server] = @server
    @connections[:rooms] = @rooms
    @connections[:clients] = @clients
    run
  end

  def run
    loop {
      Thread.start(@server.accept) do | client |
        init_msg = client.gets.chomp
        room = init_msg.split[1]
        room_id = SecureRandom.uuid
        nick_name = init_msg.split[7]

        # Check if user/room exists
        doesUserExist(nick_name, client)
        doesRoomExist(room, room_id)

        # Add client and room to relevant hash tables
        @connections[:clients][nick_name] = client # add client attribute to client's name in client hash
        @connections[:rooms]["#{room}"].push("#{nick_name}")

        # Debugging Messages
        puts "Adding #{nick_name} to room #{room}"
        puts @connections[:rooms]
        puts @roomIds
        puts @connections[:clients]

        # Push init message to client
        client.puts("JOINED_CHATROOM: #{room}\nSERVER_IP: 0\nPORT: 0\nROOM_REF: #{room_id}\nJOIN_ID: #{client}") # Return initial message to client before forwarding any more messages

        # Start listening for new messages
        listen_user_messages( nick_name, client )
      end
    }.join
  end

  def listen_user_messages( username, client )
    puts "Listening for messages...."
    loop {
      msg = client.gets.chomp
      # Check if user wants to leave chat room, remove if neccessary...
      if msg.split()[0] == "LEAVE_CHATROOM:"
        puts "Removing #{username} from #{msg.split()[1]}..."
        @connections[:rooms][msg.split()[1]].delete(username)
        @connections[:clients][username].puts "LEFT_CHATROOM: #{msg.split()[1]}\nJOIN_ID: #{client}"
        room = msg.split()[1]
        @connections[:rooms][msg.split()[1]].each do |user|
          @connections[:clients][user].puts "#{username.to_s} has left room #{msg.split()[1]}..."
        end
      end

      # Check if user wants to terminate the client/server connection...
      if msg.split()[0] == "DISCONNECT:"
        puts "Terminating connection to client #{client} from server"
        msg = nil
        client.close
      end

      # Check if user wants to join another chat room...
      if msg.split()[0] == "JOIN_CHATROOM:"
        puts "Adding #{username} to #{msg.split()[1]}"
        @connections[:rooms][msg.split()[1]].push(username)
        msg = "#{username} joined #{msg.split()[1]}"
      end

      # Send message to all users in current chat room
      # This is so hacky and bad but it kinda works as long as you're not in two different chat rooms

      if msg.split()[0] == "CHAT:"
        room = msg.split()[1]
        puts "User: #{username} sending message to room: #{room}"
        puts msg
        message = msg.split(':')[4]
        msg = message
      end

      @connections[:rooms][room].each do |room_user|
        unless room_user == username
          @connections[:clients][room_user].puts "#{username.to_s}: #{msg}"
        end
      end
    }
  end

  def doesUserExist(nick_name, client)
    @connections[:clients].each do |other_name, other_client|
      if nick_name == other_name || client == other_client
        client.puts "This username already exists, closing connection"
        Thread.kill self
      end
    end
  end

  def doesRoomExist(room, room_id)
    found = false
    @roomIds.each do |room_id, room_name|
      if room == room_name
        found = true
      end
    end
    if !found
      @roomIds[room_id] = room
    else
      puts "Room already exists"
    end
  end

end

Server.new( 3000, "localhost" )
