require 'drb'
require 'taskmaster'

class RemoteTaskmasterClient

  URI = "druby://localhost:64105"
  attr_accessor :client

  def initialize
    DRb.start_service
    @proxy = DRbObject.new_with_uri(URI)
    @proxy.extend DRbUndumped
  end
  
  def do_stuff_that_works

    @proxy.task :sayHello do 
      puts 'hello!' 
    end
    
    puts @proxy.returnTasks
    @proxy.run(:sayHello)
  end

  def do_stuff_that_breaks
  
    @proxy.cookbook do
      task :eat do
        puts "eating!"
      end
    end
  
  end

end

client = RemoteTaskmasterClient.new

client.do_stuff_that_works
client.do_stuff_that_breaks


###########
# Leftovers
#
# proxy = DRbObject.new(nil, uri)
# puts proxy.run_list_for(:eat).inspect
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
