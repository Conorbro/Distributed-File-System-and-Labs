# connections = Hash.new
# rooms = Hash.new { |hash, key| hash[key] = [] }
# connections[:rooms] = rooms
# room = "football-chat"
# rooms["#{room}"].push("Conor")
# puts connections[:rooms]["football-chat"][1]
# puts connections[0]
msg = "CHAT: room JOIN_ID: id CLIENT_NAME: name MESSAGE: msg g g g '\n\n'"
puts msg.split(':')[4]
