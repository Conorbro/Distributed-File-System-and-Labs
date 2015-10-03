# Conor Broderick - 11349681
# Distributed Systems - CS4032

# Open a server socket connection
# Wait for clients to connect
# If client connects -> create a new thread an hand off the client interation to the thread
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

class Server
  def initialize()
    @port = 2000
    @server = TCPServer.open(@port) # Socket to listen on port 2000
    @threadPool = [] # empty thread pool
    startServer
  end

  def startServer
    loop {
      if @threadPool.length < 5 #
        spawnThread(@server.accept) # Runs when a client connects
        @threadPool.each_with_index { |thread, index| puts "Thread #{index+1} status = #{thread.status}"}

      else
        puts "threadPool empty - connection refused"
      end

    }
  end

  def spawnThread(connection)
    @threadPool << Thread.new(connection) do |client|
      puts "Firing Up Thread #{@threadPool.length}"
      client.puts(Time.now.ctime) # Send the time to the client
        sleep(2)
        client.puts "Closing the connection, Bye!\n" # Send goodbye message to client
      client.close #Disconnect from client
      # Thread.stop
    end
  end
end

server = Server.new
