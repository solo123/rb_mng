module Ns
  module Route
    class App < Roda
      hash_branch("settle") do |r|
        r.get('index') {
          Ns::Settlement.order(_id: -1).limit(20).all.to_json
        }
        r.on("error") {
          r.get("orders", String) { |dt|
            Ns::PayOrder.where(s_date: dt.to_date).and(:settle.ne => 1).limit(50).all.to_json
          }
          r.get("orders", String, String) { |dt, route|
            Ns::PayOrder.where(s_date: dt.to_date).and(:settle.ne => 1).and(doc_type: "Ns::PayOrder::#{route}").limit(50).all.to_json
          }
          r.get("statements", String) { |dt|
            Ns::ChannelStatement.where(w_date: dt.to_date).and(:settle.ne => 1).limit(50).all.to_json
          }
          r.get("statements", String, String) { |dt, route|
            Ns::ChannelStatement.where(w_date: dt.to_date).and(:settle.ne => 1).and(route: route).limit(50).all.to_json
          }
          r.get(String) { |dt|
            Ns::Settlement.find_by(s_date: dt.to_date).to_json
          }
        }
      end
    end
  end
end
