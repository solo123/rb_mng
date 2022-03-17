module Gw
  class Test
    include Mongoid::MyDbTools
    store_in client: 'pay_gateway'

    field :_id, type: Integer, default: ->{ Ns::AutoIncId.get_next(:GwTest) }
    field :platform_merchant_id, type: String
    field :file_date, type: Date
    field :file_name, type: String
  end
end
