require 'drb'
require 'taskmaster'
uri = "druby://localhost:64105"

# You need jobs!
Taskmaster.cookbook do
  task :eat do
    puts "eating!"
  end
end

DRb.start_service(uri, Taskmaster)
puts "Server => #{DRb.uri}"
DRb.thread.join
