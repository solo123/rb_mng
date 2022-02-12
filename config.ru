require 'rack'
require_relative 'app/middleware/log_every_req'

app = -> (env) do
    req = Rack::Request.new(env)
    #sleep 3
    [200, {}, ["Hello66 there!#{req.path_info}"]]
end

use LogEveryReq
run app
