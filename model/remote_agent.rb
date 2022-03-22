module Ns
  class RemoteAgent
    include Mongoid::MyDbTools
    field :_id, type: Integer, default: ->{ AutoIncId.get_next(:RemoteAgent) }
  end
end
