require 'require_all'
require 'mongoid'
require 'debug'

require_all %w[init app lib helper model model_gw]
include Ns

# settle state
# 0 - not found
# 1 - match & done
# 2 - not match
# 3 - duplicate settle

def settle(dt)
  # fetch orders
  # fetch statements
  # settlement
  rt = Ns::Settlement.find_or_create_by({s_date: dt})
  cnt = 0
  Ns::ChannelStatement.where(w_date: dt).and(:settle.ne => 1).each_with_index do |statement, index|
    cnt += 1
    if op_state == 'Success'
      if statement.pay_order_id && (ord = Ns::PayOrder.find(statement.pay_order_id))
        if ord[:settle] == 1
          statement.update({settle: 3})  #duplicate
        elsif statement.match?(ord)
          ord.update({settle: 1, s_date: statement.w_date})
          statement.update({settle: 1})  #match ok!
        else
          ord.update({settle: 2, s_date: statement.w_date})
          statement.update({settle: 2})  #not match
        end
      else
        statement.update({settle: 0})  #order not found
      end
    elsif op_state == 'Refund'
      if statement.refund_order_id && (rfd = Ns::Refund.find(statement.refund_order_id))
        if rfd[:settle] == 1
          statement.update({settle: 3})
        elsif statement.match?(rfd)
          rfd.update({settle: 1, s_date: statement.w_date})
          statement.update({settle: 1})
        else
          rfd.update({settle: 2, s_date: statement.w_date})
          statement.update({settle: 2})
        end
      else
        statement.update({settle: 0})
      end
    end
  end
  puts "new settlement: #{cnt}"
end

def summary(dt)
  st = Ns::Settlement.find_or_create_by({s_date: dt})
  st.unset(st.attributes.keys - ["_id", "s_date"])  # :statics, :channels
  # summary orders
  Ns::PayOrder.where(trade_state: 0).and(s_date: nil).and(:created_at.gte => dt).and(:updated_at.lte => dt+1).update_all(s_date: dt)
  Ns::Refund.where(refund_state: 0).and(s_date: nil).and(:created_at.gte => dt).and(:updated_at.lte => dt+1).update_all(s_date: dt)
  st[:statics] = {
    statement_count: Ns::ChannelStatement.where(w_date: dt).count,
    order_count: Ns::PayOrder.where(s_date: dt).count,
    refund_count: Ns::Refund.where(s_date: dt).count,
  }

  res = {}
  client = Mongoid.client(:default)
  ords = client[:ns_pay_orders]
  agg = ords.aggregate([
    {'$match': {trade_state: 0, s_date: dt}},
    {'$group': {
      _id: "$doc_type",
      order_count: {'$sum': 1},
    }},
    {'$sort': {success_count: -1}}
  ])
  agg.each do |ag|
    res[ag[:_id][14..]] = {order_count: ag[:order_count]}
  end

  agg = ords.aggregate([
    {
      '$match': {trade_state: 0, s_date: dt, settle: {'$ne': 1}}
    },
    {
      '$group': {
        _id: "$doc_type", 
        error_count: {'$sum': 1},
      }
    }
  ])
  agg.each do |ag|
    res[ag[:_id][14..]][:error_count] = ag[:error_count]
  end

  stms = client[:ns_channel_statements]
  agg = stms.aggregate([
    {'$match': {w_date: dt}},
    {'$group': {
      _id: "$route",
      statement_count: {'$sum': 1},
    }}
  ])
  agg.each do |ag|
    res[ag[:_id]] = {} unless res[ag[:_id]]
    res[ag[:_id]][:statement_count] = ag[:statement_count]
  end
  st[:channels] = res
  st.save!
  puts st.attributes
end

def re_init(dt)
  r = PayOrder.where(s_date: dt).update_all(settle: nil, s_date: nil)
  puts "PayOrder init: #{r.n} recs"
  r = ChannelStatement.where(:settle.ne => nil).update_all(settle: nil)
  puts "Statement init: #{r.n} recs"
  st = Settlement.find_by(s_date: dt)
  if st
    st.unset(st.attributes.keys - ["_id", "s_date"])
    st.save
  end
end

if ARGV.length < 2
  puts "Usage: xxxx [init|do|sum] [20220101]"
  return
end

dt = Date.parse(ARGV[1])
if ARGV[0] == "init"
  re_init(dt)
elsif ARGV[0] == "do"
  settle(dt)
elsif ARGV[0] == "sum"
  summary(dt)
else
  puts "unknow command: #{ARGV[0]}"
end