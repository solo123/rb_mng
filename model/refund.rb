module Ns
  class Refund
    include Mongoid::MyDbTools

    field :s_date, type: Date
    field :doc_type, type: String
  
    index({s_date: 1})
    index({doc_type: 1})
  end
end