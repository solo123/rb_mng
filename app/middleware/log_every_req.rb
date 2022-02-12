class LogEveryReq
    def initialize(app)
        @app = app
    end

    def call(env)
        before = Time.now
        status, headers, body = @app.call(env)
        after = Time.now
        msg = "\nreq:#{} took #{after-before} seconds."
        [status, headers, body << msg]
    end
end