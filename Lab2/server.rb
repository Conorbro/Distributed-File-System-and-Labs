# Obfuscated Student Number - 44c032e8bdd6a98f514cd3ecfccaab9fcb1e2da42e2401113acbcd17a05da34b
# Distributed Systems - CS4032

require 'socket' # Get sockets from stdlib
require 'thread' # Get threads from stdlib

class Server
  def initialize()
    @work_q = Queue.new
    @port = ARGV[0]
    @ipAddr = Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }.ip_address # Get IP of machine on network
    @server = TCPServer.open(@port) # Socket to listen on port 2000
    puts "Server listening on port #{@port} of #{@ipAddr}"
    startServer
  end

  def startServer
    loop {
        if @work_q.size < 1 # Limit queue and thus thread pool
          Thread.start(@server.accept) do |client| # Kick off new thread for every client if resources available
            # Reads in message from client
            puts "Accepting new client and reading message..."
            msg = client.gets
            if msg == "KILL_SERVICE\n"
              puts "Killing Server on request of client"
              client.puts "Killing Server"
              client.close
              exit
            elsif msg.include?("HELO")
              puts "Sending info to client and then closing client connection"
              client.puts "HELO text\nIP:#{@ipAddr}\nPort:#{@port}\nObfuscated Student Number: 44c032e8bdd6a98f514cd3ecfccaab9fcb1e2da42e2401113acbcd17a05da34b\n"
              client.close
            else client.puts(Time.now.ctime) # Send the time to the client for the craic
              @work_q.push 1 # Add "work" to queue
              puts "Thread Pool Size = #{@work_q.size}"
              client.puts "Simulating thread work for client..."
              sleep 3 # Put thread to sleep for a few secs to simulate doing some kind of work
              @work_q.pop(true) # Finish the "work"
              client.puts "Closing the connection, bye!"
              client.close                # Disconnect from the client
              puts "Client Closed"
            end
          end
        else puts "Connection rejected, worker thread pool exhausted"
        end
    }
  end
end

server = Server.new
