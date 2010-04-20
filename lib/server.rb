require 'drb'
require 'taskmaster'
uri = "druby://localhost:64105"
obj = Taskmaster
DRb.start_service(uri, obj)
puts "Server => #{DRb.uri}"
DRb.thread.join