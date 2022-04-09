module Ns
  module Route
    class App < Roda
      hash_branch("settle") do |r|
        r.get('index') {
          Ns::Settlement.order(_id: -1).limit(20).all.to_json
        }
        r.get(String){|dt|
          Ns::Settlement.find_by(s_date: dt.to_date).to_json
        }
        r.on("errors") {
          r.get("statements", String) { |dt|
            Ns::ChannelStatement.where(w_date: dt.to_date).and(:settle.ne => 1).limit(100).all.to_json
          }
          r.get("statements", String, String) { |dt, route|
            Ns::ChannelStatement.where(w_date: dt.to_date).and(:settle.ne => 1).and(route: route.classify).limit(100).all.to_json
          }
          r.get("orders", String) { |dt|
            Ns::PayOrder.where(s_date: dt.to_date).and(:settle.ne => 1).limit(100).all.to_json
          }
          r.get("orders", String, String) { |dt, route|
            Ns::PayOrder.where(s_date: dt.to_date).and(:settle.ne => 1).and(doc_type: "Ns::PayOrder::#{route.classify}").limit(100).all.to_json
          }
          r.get("refunds", String) { |dt|
            Ns::Refund.where(s_date: dt.to_date).and(:settle.ne => 1).limit(100).all.to_json
          }
          r.get("refunds", String, String) { |dt, route|
            Ns::Refund.where(s_date: dt.to_date).and(:settle.ne => 1).and(doc_type: "Ns::RefundOrder::#{route.classify}").limit(100).all.to_json
          }
        }
      end
    end
  end
end
