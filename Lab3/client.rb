#!/usr/bin/env ruby -w
require "socket"
class Client
  def initialize( server )
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
        puts "#{msg}"
      }
    end
  end

  def send
    puts "Enter the username:"
    name = $stdin.gets.chomp
    puts "Enter rooms to join:"
    roomName = $stdin.gets.chomp
    msg = "JOIN_CHATROOM: #{roomName}.CLIENT_IP: 0.PORT: 0.CLIENT_NAME: #{name}."
    puts msg
    @request = Thread.new do
      loop {
        @server.puts(msg)
      }
    end
  end
end

server = TCPSocket.open( "localhost", 4000 )
Client.new( server )
