module Ns
  class PayOrder
    include Mongoid::MyDbTools

    field :pay_type, type: String
    field :mch_trade_id, type: String
    field :total_fee, type: Integer
    field :trade_state, type: Integer
    
    field :s_date, type: Date

    index({pay_type: 1})
    index({s_date: 1})
  end
end