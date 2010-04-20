require 'drb'
DRb.start_service
uri = "druby://localhost:64105"
# proxy = DRbObject.new_with_uri(uri)
proxy = DRbObject.new(nil, uri)
puts proxy.run_list_for(:eat).inspect
