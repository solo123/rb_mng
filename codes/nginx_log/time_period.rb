require 'time'

module Codes
  module Tools
    class TimePeriod
      attr_accessor :period_time
      attr_reader :prev_period

      def initialize
        @time_start = 0
        @time_end = 0
        @period_time = 10 # 10s period default
      end

      def next_period?(time_string)
        time_string[11] = 'T'
        time = Time.parse(time_string).to_i
        if @time_start == 0
          @time_start = time / @period_time * @period_time
          @time_end = @time_start + @period_time
          #puts "> init: #{time_string}, #{time}, #{@time_end}"
          return false
        end

        if time < @time_end
          #puts "> skip: #{time_string}, #{time}, #{@time_end}"
          return false
        end

        @prev_period = @time_start
        @time_start = time / @period_time * @period_time
        @time_end = @time_start + @period_time
        #puts "> next: #{time_string}, #{time}, #{@time_end}"
        return true
      end
      
    end
  end
end
