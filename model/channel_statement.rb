module Ns
  class ChannelStatement
    include Mongoid::MyDbTools

    field :doc_type, type: String
    field :w_date, type: Date

    COMMON_CHANNEL = %(
      Ns::UpstreamDailyBill::Wechat::Success
      Ns::UpstreamDailyBill::Alipay::Success
      Ns::UpstreamDailyBill::Tl::Success
    )
    def match?(ord)
      if COMMON_CHANNEL.include?(self.doc_type)
        self[:total_fee] == ord.total_fee && ord.trade_state == 0
      else
        false
      end
    end
  end
end