require "roda"
require "async/container"

module Ns
  module Route
    class App < Roda
      include Ns::Helper
      
      #plugin :websockets
      plugin :default_headers, {
        "Content-Type" => "application/json;charset=utf-8",
        "Access-Control-Allow-Origin" => "*", #todo: is it need to specify ?
        "Access-Control-Allow-Methods" => "GET, POST, PATCH, PUT, DELETE, OPTIONS, OPTNS",
        "Access-Control-Allow-Headers" => "*, Scene, Authorization, Content-Type, Origin, X-Requested-With",
        "Access-Control-Allow-Credentials" => "true",
        "Access-Control-Expose-Headers" =>  "Authorization",
      }
      plugin :halt
      plugin :json, classes: [Array, Hash, String], serializer: proc { |o| 
        if o.is_a?(String)
          begin
            {code: 0, msg: nil, data: JSON.parse(o)}.to_json
          rescue JSON::ParserError
            o
          end
        elsif o.is_a?(Hash) && o.include?(:code)
          o
        else
          {code: 0, msg: nil, data: o}.to_json
        end
      }
      plugin :hash_routes
      plugin :error_handler
      plugin :not_found do
        "Where did it go?"
      end

      error do |e|
        puts e.backtrace #TODO: add to error_log
        {code: 500, msg: "Oh No! Class:#{e.class.name}", e: e}
      end
      
      route do |r|
        response.status = 200
        r.root {
          "Home here"
        }
        r.get('ping'){
          "pong"
        }
        r.hash_branches

        r.on("db") {
          r.get("show", String, String) { |db, dbid|
            c = ("Ns::" + db.classify).constantize
            r = nil
            if dbid == "last"
              r = c.last
            else
              r = c.find(dbid)
            end
            r.to_json
          }
        }
        
        r.on("v1") {
          r.on("test") {
            r.get("sleep", Integer) { |seconds|
              t = seconds / 1000.0
              sleep t
              " #{t}"
            }
            r.get("ping") {
              "pong"
            }

            r.get("demo.dat") {
              dt = MyLog.query_access_times
              dt.to_s
            }
            r.get("task_10") {
              rt = ""
              if $mytask
                rt = "task: #{$mytask} running..."
              else
                $mytask = "my_task_10"
                container = Async::Container.new
                container.async do |task|
                  puts "> task #{$mytask} start..."
                  task.sleep(10)
                  puts "> task #{$mytask} end."
                  $mytask = nil
                end
                rt = "start #{$mytask}"
              end
              rt
            }
          }
        }

        r.on(:all) { 
          "NOT FOUND!!"
        }
      end
    end
  end
end
