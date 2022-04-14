module Ns
  module Route
    class App < Roda
      hash_branch("settle") do |r|
        page_size = r.params['page_size']&.to_i || 50
        cnd = {}
        r.get('index') {
          cnd = {_id: {'$lt': r.params['last_id'.to_i]}} if r.params['last_id']
          Ns::Settlement.where(cnd).order(_id: -1).limit(page_size).all.map{|s| s.attributes.slice(:_id,:s_date,:orders_count,:refunds_count,:statements_count,:orders_error_count,:refunds_error_count,:statements_count)}
        }
        r.get(String){|dt|
          Ns::Settlement.find_by(s_date: dt.to_date).attributes
        }
        r.on("errors") {
          cnd = {_id: {'$gt': r.params['last_id'.to_i]}} if r.params['last_id']
          r.get("statements", String) { |dt|
            Ns::ChannelStatement.where(w_date: dt.to_date).and(:settle.ne => 1).and(cnd).order(_id: 1).limit(page_size).all.to_a
          }
          r.get("statements", String, String) { |dt, route|
            Ns::ChannelStatement.where(w_date: dt.to_date).and(:settle.ne => 1).and(route: route.classify).and(cnd).order(_id: 1).limit(page_size).all.to_a
          }
          r.get("orders", String) { |dt|
            Ns::PayOrder.where(s_date: dt.to_date).and(:settle.ne => 1).and(cnd).order(_id: 1).limit(page_size).all.to_a
          }
          r.get("orders", String, String) { |dt, route|
            Ns::PayOrder.where(s_date: dt.to_date).and(:settle.ne => 1).and(doc_type: "Ns::PayOrder::#{route.classify}").and(cnd).order(_id: 1).limit(page_size).all.to_a
          }
          r.get("refunds", String) { |dt|
            Ns::Refund.where(s_date: dt.to_date).and(:settle.ne => 1).and(cnd).order(_id: 1).limit(page_size).all.to_a
          }
          r.get("refunds", String, String) { |dt, route|
            Ns::Refund.where(s_date: dt.to_date).and(:settle.ne => 1).and(doc_type: "Ns::RefundOrder::#{route.classify}").and(cnd).order(_id: 1).limit(page_size).all.to_a
          }
        }
      end
    end
  end
end
