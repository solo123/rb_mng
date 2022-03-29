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
  settle_date = dt
  rt = {s_date: dt}
  cnt = 0
  Ns::ChannelStatement.where({w_date: dt, settle: nil}).each_with_index do |statement, index|
    doc_type = statement.doc_type.split('::')[2]
    rt[doc_type] = {cnt: 0, amount: 0} unless rt[doc_type]
    rt[doc_type][:cnt] += 1
    rt[doc_type][:amount] += statement.total_fee
    cnt += 1
    ord = Ns::PayOrder.find(statement.pay_order_id)
    if ord
      if ord[:settle] == 1
        statement.update({settle: 3})
      elsif statement.match?(ord)
        ord.update({settle: 1, s_date: statement.w_date})
        statement.update({settle: 1})
      else
        ord.update({settle: 2, s_date: statement.w_date})
        statement.update({settle: 2})
      end
    else
      statement.update({settle: 0})
    end
  end
  puts "new settlement: #{cnt}"

  # summary statements
  rt.keys.each do |k|
    if k != :s_date
      cnt = Ns::ChannelStatement.where(s_date: dt).and(settle: 0).count
      rt[k][:unmatch_settlements_count] = cnt if cnt > 0
    end
  end

  # summary orders
  Ns::PayOrder.where(trade_state: 0).and(s_date: nil).and(:updated_at.lte => dt+1)
    .update_all(s_date: dt)
  
  client = Mongoid.client(:default)
  ords = client[:ns_pay_orders]
  agg = ords.aggregate([
    {
      '$match': {trade_state: 0, s_date: dt, settle: {'$ne': 1}}
    },
    {
      '$group': {
        _id: "$doc_type", 
        cnt: {'$sum': 1},
        amount: {'$sum': "$total_fee"}
      }
    }
  ])
  agg.each do |ag|
    doc_type = ag["_id"].split('::')[2]
    rt[doc_type] = {} unless rt[doc_type]
    rt[doc_type][:unmatch_orders_count] = ag["cnt"]
    rt[doc_type][:unmatch_orders_amount] = ag["amount"]
  end

  puts "Settle: #{cnt} records."
  puts rt.inspect
  #Ns::Settlement.create!(rt)
end

def re_init
  PayOrder.where(:settle.ne => nil).update_all(settle: nil)
  ChannelStatement.where(:settle.ne => nil).update_all(settle: nil)
end

if ARGV.length < 2
  puts "Usage: xxxx [init|do] [20220101]"
  return
end

dt = Date.parse(ARGV[1])
if ARGV[0] == "init"
  re_init(dt)
elsif ARGV[0] == "do"
  settle(dt)
else
  puts "unknow command: #{ARGV[0]}"
end