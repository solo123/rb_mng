module Ns
  class Settlement
    include Mongoid::MyDbTools

    field :_id, type: Integer, default: ->{ AutoIncId.get_next(:Settlement) }
    field :s_date, type: Date

    index({ s_date: 1 }, { unique: true, name: "s_date_index" })
  end
end