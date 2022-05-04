module Fixture
  module Static
    class TradeStatic
      def self.clean_data
        ::Static::Trade.delete_all
        puts "-- clean: platform_trades"
      end
      def self.seed_data
        seed_data_day
        seed_data_month
      end
      def self.seed_data_day
        dates = "2021-01-01".."2021-01-31"
        plts = %w(3001 3002)
        chs = %w(ch01 ch02 ch03)
        pms = %w(tran_01 tran_02 pay_p01_m01 pay_p02_m02)
        dates.each do |dt|
          plts.each do |plt|
            chs.each do |ch|
              pms.each do |pm|
                js = {
                  "time_period": "day",
                  "amount": 100,
                  "refund": 1,
                  "cnt": 10,
                  "s_date": dt,
                  "platform_id": plt,
                  "channel": ch,
                  "pay_method": pm,
                  "fee": 1
                }
                ::Static::Trade.create(js)
              end
            end
          end
        end
        puts "-- seed: trade_statics #{dates}"
      end
      def self.seed_data_month
        dates = "2021-01".."2021-12"
        plts = %w(3001 3002)
        chs = %w(ch01 ch02 ch03)
        pms = %w(tran_01 tran_02 pay_p01_m01 pay_p02_m02)
        dates.each do |dt|
          plts.each do |plt|
            chs.each do |ch|
              pms.each do |pm|
                js = {
                  "time_period": "month",
                  "amount": 100,
                  "refund": 1,
                  "cnt": 10,
                  "s_date": dt,
                  "platform_id": plt,
                  "channel": ch,
                  "pay_method": pm,
                  "fee": 1
                }
                ::Static::Trade.create(js)
              end
            end
          end
        end
        puts "-- seed: trade_statics #{dates}"
      end

    end
  end
end