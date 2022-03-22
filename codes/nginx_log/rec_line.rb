module Codes
  module Tools
    class RecLine
      INDICATOR_NAMES = [:count,:size,:time]
      attr_accessor :metric
      attr_accessor :handler

      def print_matric(time, metric)
        @time = time
        to_lines([], metric)
      end

      def to_lines(pre_names, metric)
        metric.each do |k,v|
          nm = pre_names + [k]
          line = {
            ts: @time * 1000,
            level: nm.length,
            name: nm.join('/'),
            names: nm,
          }
          line.merge!(v.slice(*INDICATOR_NAMES))
          @handler.call(line) if @handler

          to_lines(nm, v.except(*INDICATOR_NAMES))
        end
      end

    end
  end
end