require "roda"

module Ns
  class App < Roda
    #plugin :websockets
    plugin :default_headers, {
        'Access-Control-Allow-Origin' => '*', #todo: is it need to specify ?
        'Access-Control-Allow-Methods' => 'GET, POST, PATCH, PUT, DELETE, OPTIONS, OPTNS',
        'Access-Control-Allow-Headers' => 'Origin, Content-Type, X-Auth-Token, Authorization',
        'Access-Control-Allow-Credentials' => 'true'
    }

    route do |r|
      r.root {
        "Home here"
      }

      r.on('html') {
        r.run AppHtml
      }

      r.on("v1") {
        r.on("test") {
          r.get("sleep", Integer) { |seconds|
              t = seconds/1000.0
              sleep t
              " #{t}"
          }
          r.get('ping') {
              "pong"
          }
          r.get("demo.dat") {
            dt = MyLog.query_access_times
            dt.to_s
          }
        }
      }
    end

  end
end
