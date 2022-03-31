module Ns
  class Refund
    include Mongoid::MyDbTools

    field :s_date, type: Date
  end
end