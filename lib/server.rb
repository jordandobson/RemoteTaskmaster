require 'drb'
require 'taskmaster'

class RemoteTaskmasterServer

  URI = "druby://localhost:64105"
  OBJ = Taskmaster

  def initialize
    DRb.start_service(URI, OBJ)
    puts "Server => #{DRb.uri}"
    DRb.thread.join
  end

end

server = RemoteTaskmasterServer.new






# require 'drb'
# require 'taskmaster'
# uri = "druby://localhost:64105"
# 
# # You need jobs!
# Taskmaster.cookbook do
#   task :eat do
#     puts "eating!"
#   end
# end
# 
# DRb.start_service(uri, Taskmaster)
# puts "Server => #{DRb.uri}"
# DRb.thread.join