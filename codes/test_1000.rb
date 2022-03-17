require 'async'
require 'async/http/internet'

start = Time.now

Async do |task|
    http_client = Async::HTTP::Internet.new
    1000.times do
        task.async do
            t = rand
            res = http_client.get("http://localhost:3000/delay/#{t}")
            js = JSON.parse(res.read)
            if js['delay'] != t
                puts "error: #{js['delay']} - #{t}"
            else
                print "%.2f, " % t
            end
        end
    end
end

puts "\nTotal: %.3f seconds." % (Time.now - start)