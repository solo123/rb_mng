module Ns
    class LogJsonReq
        def initialize(app)
            @app = app
        end

        def call(env)
            puts "> log here. #{env.inspect}"
            before = Time.now
            status, headers, js_body = @app.call(env)
            after = Time.now
            [status, headers, js_body]
        end
    end
end