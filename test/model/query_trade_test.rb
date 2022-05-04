require_relative '../test_helper'
module Mng
  class QueryTradeTest < Minitest::Test
    def test_cnd1
      qt = Mng::QueryTrade.new
      t = {
        :field=>:cal_active_cnt, :active_cnt=>2, :match=>{:pay_method=>/^pay_/}
      }
      plts = ['3001']
      rs = qt.platform_static(t, plts)
      #puts rs.pipeline.to_json
      #rs.each {|r| puts r}
      assert rs
    end
    def test_translate1
      qt = Mng::QueryTrade.new
      t = {
        search_type: "payment",
        value: nil,
        field: 'shanghujun',
        type: 'day',
        month: '202101',
      }
      r = qt.translate_query_condition(t)
      #{:field=>:cal_active_cnt, :active_cnt=>2, :match=>{:pay_method=>/^pay_/, :s_date=>{:$gte=>"2021-01-01", :$lte=>"2021-01-31"}, :time_period=>"day"}}
      assert_equal /^pay_/, r[:match][:pay_method]
      assert_equal "2021-01-01", r[:match][:s_date][:$gte]
      assert_equal "2021-01-31", r[:match][:s_date][:$lte]
      assert_equal 'day', r[:match][:time_period]
      assert_equal 2, r[:active_cnt]
    end
    def test_translate2
      qt = Mng::QueryTrade.new
      t = {
        search_type: "fund",
        value: nil,
        field: 'fee',
        type: 'day',
        month: '202101',
      }
      r = qt.translate_query_condition(t)
      #{:field=>:cal_active_cnt, :active_cnt=>2, :match=>{:pay_method=>/^pay_/, :s_date=>{:$gte=>"2021-01-01", :$lte=>"2021-01-31"}, :time_period=>"day"}}
      assert_equal /^tran_/, r[:match][:pay_method]
      assert_equal "2021-01-01", r[:match][:s_date][:$gte]
      assert_equal "2021-01-31", r[:match][:s_date][:$lte]
      assert_equal 'day', r[:match][:time_period]
      assert_equal 0, r[:active_cnt]
    end
  end
end
