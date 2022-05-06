module Mng
  class QueryTrade
    #cnd:
    # s_date, e_date, time_period: day/month,
    # pls: platform_ids,
    # q_field: cnt/amount/refund,
    #
    def platform_static(t, plts)
      return [] unless plts && !plts.empty?
      match = {platform_id: {:$in => plts}}.merge(t[:match])
      group = {
        _id: {pid: '$platform_id', s_date: '$s_date'},
        cnt: {:$sum => '$cnt'},
        amount: {:$sum => '$amount'},
        refund: {:$sum => '$refund'},
        active_cnt: {:$sum => '$active_cnt'}
      }

      if t[:active_cnt] == 1
        q = [{:$match => match}, {:$group => group}]
        ::Static::MerchantActiveCount.collection.aggregate(q)
      elsif t[:active_cnt] == 2
        match1 = match.dup
        match1[:pay_type] = match1.delete :pay_method
        match1[:pay_type] = 'all' if match1[:pay_type].nil?
        union_with = {
          coll: "static_merchant_active_counts",
          pipeline: [{:$match => match1}],
        }
        q = [{:$match => match},{:$unionWith => union_with},{:$group => group}]
        ::Static::Trade.collection.aggregate(q)
      else
        q = [{:$match => match},{:$group => group}]
        ::Static::Trade.collection.aggregate(q)
      end
    end
    def summary_static(t, plts)
      return [] unless plts && !plts.empty?
      match = {platform_id: {:$in => plts}}.merge(t[:match])
      group = {
        _id: '$s_date',
        cnt: {:$sum => '$cnt'},
        amount: {:$sum => '$amount'},
        refund: {:$sum => '$refund'},
        active_cnt: {:$sum => '$active_cnt'}
      }

      project = {_id:0, active_cnt: '$cnt', platform_id: 1, s_date: 1, time_period: 1}
      union_with = {
        coll: "static_merchant_active_counts",
        pipeline: [{:$match => match},{:$project => project}],
      }
      q = [{:$match => match},{:$unionWith => union_with},{:$group => group},{:$sort => {s_date: 1}}]
      ::Static::Trade.collection.aggregate(q)
    end

    # @param [Hash] t 原始查询条件
    # @return [Hash{}] 新查询条件
    def translate_query_condition(t)
      active_cnt = 0
      t[:field] = t[:tab] if t[:field].nil?
      field = case t[:field]
              when 'total_fee'
                :amount
              when 'order_count', 'total_count', 'business_count', 'dealer_count'
                :cnt
              when 'total_refund_fee'
                :refund
              when 'total_trade_fee'
                :fee
              when 'merchant_count'
                active_cnt = 1
                :active_cnt
              when 'bijun'
                [:amount, :cnt]
              when 'shanghujun'
                active_cnt = 2
                [:amount, :active_cnt]
              else
                :amount
              end
      match = {}
      if !t.include?(:search_type) || t[:search_type] == 'all'
        # {}
      elsif t[:search_type] == 'trade_type'
        if t[:value] == 'payment'
          match[:pay_method] = /^pay/
        elsif t[:value] == 'fund'
          match[:pay_method] = /^tran/
        end
      elsif t[:search_type] == 'payment'
        match[:pay_method] = /^pay/
      elsif t[:search_type] == 'fund'
        match[:pay_method] = /^tran/
      elsif t[:search_type] == 'channel'
        match[:channel] == t[:value].downcase
      end
      if t[:type] == 'month'
        match[:s_date] = {:$gte => "#{t[:year]}-01", :$lte => "#{t[:year]}-12"}
        match[:time_period] = 'month'
      else
        sd = (t[:month]+"01").to_date
        ed = sd.end_of_month
        match[:s_date] = {:$gte => sd.strftime('%F'), :$lte => ed.strftime('%F')}
        match[:time_period] = 'day'
      end
      {
        field: field,
        active_cnt: active_cnt,
        match: match,
      }
    end
  end
end
