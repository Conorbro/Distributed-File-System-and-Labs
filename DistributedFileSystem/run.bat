start "1" cmd /k ruby FileServer.rb
start "2" cmd /k ruby directoryServer.rb
start "3" cmd /k ruby ClientProxy.rb
start "4" cmd /k ruby client.rb
