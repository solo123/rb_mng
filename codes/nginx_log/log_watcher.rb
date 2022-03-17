require 'pry'
require 'pry-nav'

module Codes
  module NginxLog
    class LogWatcher
      def initialize(src, des, append_mode=false)
        puts "last line: #{@last_line}"
        @f_src = File.open(src, 'r')
        @f_des_filename = des
        @f_des = nil
        @buf = []
        @append_mode = append_mode
        if append_mode
          @last_line = `tail -1 #{des}`
          @last_line = @last_line[0..30] if @last_line
        end
      end

      def next_rec(step = 1)
        s = 0
        @f_des = File.open(@f_des_filename, 'a')
        while !@f_src.eof?
          line = @f_src.readline.strip
          loop if line.empty? and @buf.empty?
          if line.empty?
            s += write_des
            @buf.clear
            break if s >= step
          else
            @buf << line
          end
        end
        @f_des.close
      end

      def write_des()
        s = @buf.join(' ')
        if !@append_mode or s > @last_line
          @f_des.puts s
          puts s
          return 1
        else
          #puts ">#{s}"
          return 0
        end
      end

      def close()
        @f_src.close() if @f_src
      end
    end
  end
end