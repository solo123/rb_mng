require 'pry'
require 'pry-nav'

module Codes
  module NginxLog
    NGINX_LOG_REG = /^\[(?<time_local>[^\]]*)\] (?<remote_addr>[^ ]*) => (?<request_host>[^ ]*) \[(?<status>[^\]]*)\] \((?<http2>[^)]*)\) (?<request_method>[^ ]*) (?<request_path>[^ ]*) HTTP\/(?<http_version>[^ ]*) \(Byte: (?<body_bytes_sent>[^ ]*) ratio: (?<gzip_ratio>[^)]*)\) time_elapsed: (?<request_time>[^ ]*) Accept-Encoding: (?<http_accept_encoding>[^\|]*)\| Content-Type: (?<sent_http_content_type>[^ ]*) User-Agent: (?<http_user_agent>.*)/

    class LogParser
      attr_accessor :handler
      def initialize(src, pos = 0)
        @f_src = File.open(src, 'r')
        @f_src.pos = pos if pos > 0
        @buf = []
      end

      def next_rec(max = 10)
        s = 0
        while !@f_src.eof?
          line = @f_src.readline.strip
          loop if line.empty? and @buf.empty?

          if line.empty? # end of a record
            t = @buf.join(' ')
            if mt = t.match(NGINX_LOG_REG)
              @handler.call(mt.named_captures) if @handler
            else
              puts "ERROR: #{t}"
              break
            end
            @buf.clear
            s += 1
            break if s > max
          else # not end of a record
            @buf << line
          end
        end
      end

      def close()
        if @f_src and !@f_src.closed?
          puts "current pos: #{@f_src.pos}"
          @f_src.close()
        end
      end
    end
  end
end