connections = Hash.new
rooms = Hash.new { |hash, key| hash[key] = [] }
connections[:rooms] = rooms
room = "football-chat"
rooms["#{room}"].push("Conor")
puts connections[:rooms]["football-chat"][1]
puts connections[0]
