#!/usr/bin/env ruby -w
require "socket"
class Client
  def initialize( server )
    @name = nil
    @server = server
    @request = nil
    @response = nil
    listen
    send
    @request.join
    @response.join
  end

  def listen
    @response = Thread.new do
      loop {
        msg = @server.gets.chomp
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
        # fullMsg = "CHAT: []\nJOIN_ID: []\nCLIENT_NAME: []\nMESSAGE: [#{msg} '\n\n']"
        # Command to leave a chatroom: LEAVE_CHATROOM: roomName
        @server.puts( msg )
      }
    end
  end
end

server = TCPSocket.open( "localhost", 3000 )
Client.new( server )
