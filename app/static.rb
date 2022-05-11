module Mng
  module Route
    class App < Roda
      hash_branch("statics") do |r|
        page_size = r.params["page_size"] || 100
        last_id = r.params["last_id"]
        r.get('trades') {
          cnd = {}
          cnd[:_id] = {:$gt => last_id} if last_id
          cnd[:time_period] = r.params['time_period'] if r.params['time_period']
          Static::Trade.where(cnd).order(_id: 1).limit(page_size).all.to_json
        }
      end
    end
  end
end
