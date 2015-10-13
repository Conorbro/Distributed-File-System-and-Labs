# Conor Broderick - 11349681
# Distributed Systems - CS4032

# Open a server socket connection
# Wait for clients to connect
# If client connects -> create a new thread and hand off the client interation to the thread
# (New thread should be passed the socket connected to the client)
# Go back to waiting for a client connection

# Create separate thread to handle each client request

# Must support Thread Pooling!
  # - Server on init creates set of worker threads called thread pool (maybe null)
  # - Pass client to worker thread as they arrive
  # - Server should manage number of worker threads
    # - Limit worker threads to some maximum the server is capable of handling to avoid overloading
    # - Delete worker thread if client activity drops such that there are a surplus worker threads never used
    # - If server reaches client limit - simply reject new connections

require 'socket' # Get sockets from stdlib
require 'thread' # Get threads from stdlib

class Server
  def initialize()
    @work_q = Queue.new
    @port = ARGV[0]
    @ipAddr = Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }.ip_address
    @server = TCPServer.open(@port) # Socket to listen on port 2000
    puts "Server listening on port #{@port} of #{@ipAddr}"
    startServer
  end

  def startServer
    loop {
        if @work_q.size < 2 # Limit queue and thus thread pool
          Thread.start(@server.accept) do |client| # Kick off new thread for every client if resources available
            puts "Accepting new client"
            @work_q.push 1 # Add "work" to queue
            # if client.gets.chomp == "KILL_SERVICE\n"
            #   exit
            # end
            # if client.gets.chomp == "HELO text\n"
            #   puts "HELO text\nIP:#{@ipAddr}\nPort:[#{@port}]\n11349681\n"
            # end
            client.puts(Time.now.ctime) # Send the time to the client for the craic
            client.puts "Closing the connection. Bye! Thread Pool Size = #{@work_q.size}"
            sleep 5 # Put thread to sleep for 5 secs to simulate doing some kind of work
            @work_q.pop(true) # Finish the "work"
            client.close                # Disconnect from the client
            puts "Client Closed"
          end
        else puts "Connection rejected, worker thread pool exhausted"
            sleep 5
        end
    }
  end
end

server = Server.new
