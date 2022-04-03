module Ns
  class ChannelStatement
    include Mongoid::MyDbTools

    field :doc_type, type: String
    field :route, type: String
    field :settle_type, type: String
    field :w_date, type: Date

    index({w_date: 1})
    index({route: 1, settle_type: 1})

    def match?(ord)
      if self.settle_type == 'Success'
        self[:total_fee] == ord.total_fee
      elsif self.settle_type == 'Refund'
        self[:refund_fee] == ord.refund_fee && ord.refund_status == 0
      else
        false
      end
    end
  end
end