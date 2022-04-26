module Ns
  module Route
    module RouteHelper
      def parse_json(str)
        JSON.parse(str)
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
        m = Ns::Merchant.find(mid)
        raise "merchent:#{mid} not found." unless m
        m
      end
      
    end
  end
end