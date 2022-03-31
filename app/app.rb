require "roda"
require "async/container"

module Ns
  class App < Roda
    #plugin :websockets
    plugin :default_headers, {
        'Content-Type' => 'application/json',
        'Access-Control-Allow-Origin' => '*', #todo: is it need to specify ?
        'Access-Control-Allow-Methods' => 'GET, POST, PATCH, PUT, DELETE, OPTIONS, OPTNS',
        'Access-Control-Allow-Headers' => 'Origin, Content-Type, X-Auth-Token, Authorization',
        'Access-Control-Allow-Credentials' => 'true'
    }
    plugin :json

    route do |r|
      r.root {
        "Home here"
      }

      r.on('html') {
        r.run AppHtml
      }

      r.on('settle'){
        r.on('error'){
          r.get('orders', String){|dt|
            Ns::PayOrder.where(s_date: dt.to_date).and(:settle.ne => 1).limit(50).all.to_json
          }
          r.get('orders', String, String){|dt, route|
            Ns::PayOrder.where(s_date: dt.to_date).and(:settle.ne => 1).and(doc_type: "Ns::PayOrder::#{route}").limit(50).all.to_json
          }
          r.get('statements', String){|dt|
            Ns::ChannelStatement.where(w_date: dt.to_date).and(:settle.ne => 1).limit(50).all.to_json
          }
          r.get('statements', String, String){|dt, route|
            Ns::ChannelStatement.where(w_date: dt.to_date).and(:settle.ne => 1).and(route: route).limit(50).all.to_json
          }
          r.get(String){ |dt|
            Ns::Settlement.find_by(s_date: dt.to_date).to_json
          }
        }
      }
      r.on('db'){
        r.get('show', String, String) { |db, dbid|
        c = ('Ns::' + db.classify).constantize
          r = nil
          if dbid == 'last'
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
          r.get('task_10'){
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
