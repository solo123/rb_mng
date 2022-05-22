module Mng
  module Helper
    module RouteHelper
      def parse_json(str)
        JSON.parse(str, symbolize_names: true)
      rescue JSON::ParserError
        {}
      end

      def get_date_array(date_type, start_date)
        if date_type == 'day'
          (start_date + '01').to_date.all_month.map{ |d| d.strftime('%Y-%m-%d') }.uniq
        else
          y = start_date[0..3]
          ('01'..'12').map{|m| "#{y}-#{m}"}
        end
      end

      def get_merchant_by_id(mid)
        if mid.nil? || mid.empty?
          m = Ns::Merchant.where({parent_id: nil, status: 5}).first
          debug_log({use_default_mch: m.id})
        else
          m = Ns::Merchant.find(mid)
        end
        raise "merchent:#{mid} not found." unless m
        m
      end

      def debug_log(info)
        return unless @debug && @debug.include?(:debug)
        @debug[:debug].merge!(info)
      end

      def to_object_id(tb_name, str)
        tbs = [
          "ns_err_logs",
               "static_platform_merchants",
               "static_trades",
               "jobs_my_queues",
               "static_merchant_actives",
               "jobs_my_schedules",
               "acc_settlements",
               "static_merchant_active_counts",
               "jobs_my_tasks"]
        if tbs.include?(tb_name)
          str.to_i
        elsif BSON::ObjectId.legal?(str)
          BSON::ObjectId.from_string(str)
        else
          str
        end
      end

      
    end
  end
end