contents = ""
oFile = File.open("files/file1.txt", "r")
oFile.each_line do |line|
  contents += line
end
oFile.close
puts contents
