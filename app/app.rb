require 'rack'

module Ns
    class App
        def call(env)
            req = Rack::Request.new(env)
            #sleep 3
            [200, {}, ["Hello66 there! #{req.path_info}"]]
        end
    end
end