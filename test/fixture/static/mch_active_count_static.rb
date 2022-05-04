module Fixture
  module Static
    class MchActiveCountStatic
      def self.clean_data
        ::Static::MerchantActiveCount.delete_all
        puts "-- clean: merchant_active_count"
      end

      def self.seed_data
        seed_data_day
        seed_data_month
      end

      def self.seed_data_day
        level_codes = %w(001001001 001002001001)
        dates = "2021-01-01".."2021-01-31"
        plts = %w(3001 3002)
        pms = %w(tran_transfer pay_payment)
        dates.each do |dt|
          plts.each_with_index do |plt, p_idx|
            pms.each do |pm|
              js = {
                "time_period": "day",
                "active_cnt": 10,
                "s_date": dt,
                "platform_id": plt,
                "pay_method": pm,
                "level_code": level_codes[p_idx]
              }
              ::Static::MerchantActiveCount.create(js)
            end
          end
        end
        puts "-- seed: merchant_active_count #{dates}"
      end

      def self.seed_data_month
        level_codes = %w(001001001 001002001001)
        dates = "2021-01".."2021-12"
        plts = %w(3001 3002)
        pms = %w(tran_transfer pay_payment)
        dates.each do |dt|
          plts.each_with_index do |plt, p_idx|
            pms.each do |pm|
              js = {
                "time_period": "month",
                "active_cnt": 100,
                "s_date": dt,
                "platform_id": plt,
                "pay_method": pm,
                "level_code": level_codes[p_idx]
              }
              ::Static::MerchantActiveCount.create(js)
            end

          end
        end
        puts "-- seed: merchant_active_count #{dates}"
      end
    end
  end
end
