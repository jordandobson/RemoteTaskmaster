require 'drb'
require 'taskmaster'

DRb.start_service
uri = "druby://localhost:64105"
proxy = DRbObject.new_with_uri(uri)

proxy.task :sayHi do 
  puts 'task :sayHi do puts "hello" end' 
end
puts proxy.returnTasks
proxy.execute(:sayHi)



# proxy = DRbObject.new(nil, uri)

#puts proxy.run_list_for(:eat).inspect
# proxy.cookbook do
#   puts "hello";
# end

# puts proxy::TASKS



# require 'drb'
# DRb.start_service
# uri = "druby://localhost:64105"
# proxy = DRbObject.new_with_uri(uri)
# # proxy = DRbObject.new(nil, uri)
# puts proxy.inspect


#`perform_with_block': undefined method `block_yield' for Taskmaster:Module (NoMethodError)
