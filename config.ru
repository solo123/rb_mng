require 'rack'

app = proc do |env|
    req = Rack::Request.new(env)
    #sleep 3
    [200, {}, ["Hello66 there!#{req.path_info}"]]
end
    
run app
