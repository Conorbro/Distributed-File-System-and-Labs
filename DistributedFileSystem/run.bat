start "1" cmd /k ruby replicaServer.rb
start "2" cmd /k ruby FileServer.rb
start "3" cmd /k ruby fileServer2.rb
start "4" cmd /k ruby directoryServer.rb
start "5" cmd /k ruby LockServer.rb
start "6" cmd /k ruby ClientProxy.rb
start "7" cmd /k ruby client.rb
