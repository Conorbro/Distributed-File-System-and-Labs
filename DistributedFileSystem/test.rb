def is_i?(msg)
 !!(msg =~ /\A[-+]?[0-9]+\z/)
end

msg = "1"

if is_i?(msg)
  puts true
else puts false
end
