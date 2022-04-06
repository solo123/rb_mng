require "roda"
require "async/container"

module Ns
  module Route
    class App < Roda
      #plugin :websockets
      plugin :default_headers, {
        "Content-Type" => "application/json",
        "Access-Control-Allow-Origin" => "*", #todo: is it need to specify ?
        "Access-Control-Allow-Methods" => "GET, POST, PATCH, PUT, DELETE, OPTIONS, OPTNS",
        "Access-Control-Allow-Headers" => "Origin, Content-Type, X-Auth-Token, Authorization",
        "Access-Control-Allow-Credentials" => "true",
      }
      plugin :json
      plugin :hash_routes

      route do |r|
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
      end
    end
  end
end
