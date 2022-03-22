module Ns
    class LogJsonReq
        def initialize(app)
            @app = app
        end

        def call(env)
            before = Time.now
            status, headers, js_body = @app.call(env)
            after = Time.now
            if js_body.is_a?(Hash)
                js_body['time_cost'] = after-before
                [status, headers, [js_body.to_json]]
            elsif js_body.is_a?(Array)
                [status, headers, [js_body.to_s]]
            else
                [status, headers, js_body << "\ncost time: #{after-before} seconds"]
            end
        end
    end
end