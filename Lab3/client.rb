#!/usr/bin/env ruby -w
require "socket"
class Client
  def initialize( server )
    @name = nil
    @server = server
    @request = nil
    @response = nil
    @id = nil
    listen
    send
    @request.join
    @response.join
  end

  def listen
    @response = Thread.new do
      loop {
        msg = @server.gets.chomp
        if msg.split()[2] = "SERVER_IP:"
          @id = msg.split()[9]
        end
        puts " #{msg}"
      }
    end
  end

  def send
    puts "Enter the username:"
    @name = $stdin.gets.chomp
    puts "Enter chatroom to join:"
    room = $stdin.gets.chomp
    @server.puts("JOIN_CHATROOM: #{room} CLIENT_IP: 0 PORT 0 CLIENT_NAME #{@name}") # Send initial message to server
    @request = Thread.new do
      loop {
        msg = $stdin.gets.chomp
        if msg.split()[0] == "JOIN_CHATROOM:"
          room = msg.split()[1]
          @server.puts(msg)
        elsif msg.split()[0] == "LEAVE_CHATROOM:"
          room = nil
          @server.puts(msg)
        elsif msg.split()[0] == "DISCONNECT:"
          @server.puts(msg)
        else
          fullMsg = "CHAT: #{room} JOIN_ID: #{@id} CLIENT_NAME: #{@name} MESSAGE:#{msg} \n\n"
          # Command to leave a chatroom: LEAVE_CHATROOM: roomName
          @server.puts(fullMsg)
        end
      }
    end
  end
end

server = TCPSocket.open( "localhost", 3000 )
Client.new( server )
