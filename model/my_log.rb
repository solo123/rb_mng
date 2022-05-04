module Ns
  class MyLog
    include Mongoid::MyDbTools

    field :_id, type: Integer, default: ->{ AutoIncId.get_next(:MyLog) }, overwrite: true

    def self.query_access_times()
      where({level: 1, name: 'request_host'}).limit(10000).all.pluck(:ts, :count)
    end
  end
end
