module Ns
  class Settlement
    include Mongoid::MyDbTools

    field :_id, type: Integer, default: ->{ AutoIncId.get_next(:Settlement) }
    field :s_date, type: Date
  end
end