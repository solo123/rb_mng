require 'async/container'

puts "start..."

container = Async::Container.new

container.async do |task|
  puts "sleeping..."
  task.sleep(1)
  puts "waking up!"
end

puts "waiting..."
#container.wait
puts "Finished."