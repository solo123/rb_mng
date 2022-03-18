module Codes
  module NginxLog
    class Metric
      attr_reader :metrics
      def initialize
        @metrics = {}
      end

      def add_metric(arr, metric, size, time)
        arr[metric] = {count: 0, size: 0, time: 0.0} if !arr.include?(metric)
        arr[metric][:count] += 1
        arr[metric][:size] += size
        arr[metric][:time] += time
        arr[metric]
      end

      def add_metrics(metrics, size, time)
        arr = @metrics
        metrics.each_with_index do |metric, index|
          arr = add_metric(arr, metric, size, time)
        end
      end

      def clear
        @metrics.clear
      end
    end
  end
end