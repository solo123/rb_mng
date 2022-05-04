module Ns
  class Tk10
    include Mongoid::MyDbTools

    field :_id, type: Integer, default: ->{ AutoIncId.get_next(:Tk10) }, overwrite: true 
    field :platform_merchant_id, type: String
    field :file_date, type: Date
    field :file_name, type: String
  end
end
