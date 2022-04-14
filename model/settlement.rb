module Ns
  class Settlement
    include Mongoid::MyDbTools

    field :_id, type: Integer, default: ->{ AutoIncId.get_next(:Settlement) }
    field :s_date, type: Date

    index({ s_date: 1 }, { unique: true, name: "s_date_index" })

    def self.main_fields
      only(:id, :s_date, :statements_count, :orders_count, :refunds_count, :statements_error_count, :orders_error_count, :refunds_error_count)
    end
  end
end