require 'require_all'
require 'mongoid'
require 'debug'

require_all %w[init app lib helper model model_gw]
include Ns

def fetch_order_records
  client = Mongoid.client(:pay_gateway)
  ords = client[:pay_orders]
  begin_tag = BSON::ObjectId("61cf2946be1d2d5247fc8fa0")

  start_tag = (oo = Ns::PayOrder.last)? oo._id : begin_tag
  start_date = nil
  ords.find({_id: {"$gt": start_tag}}).limit(5000).each do |ord|
    if start_date.nil?
      start_date = ord[:created_at].to_date
    elsif ord[:created_at].to_date > start_date
      break # 只获取当天的数据
    end

    ord[:doc_type] = ord.delete(:_type)
    puts ord[:_id]
    oo = Ns::PayOrder.new(ord)
    oo.save!
    #debugger
  end
end

def fetch_statement_records
  client = Mongoid.client(:pay_gateway)
  src = client[:upstream_daily_bills]
  begin_tag = 1307180

  start_tag = (oo = Ns::ChannelStatement.last)? oo._id : begin_tag
  start_date = nil
  src.find({_id: {"$gt": start_tag}}).limit(5000).each do |rec|
    if start_date.nil?
      start_date = rec[:w_date].to_date
    elsif rec[:w_date].to_date > start_date
      break # 只获取当天的数据
    end

    rec[:doc_type] = rec.delete(:_type)
    puts rec[:_id]
    oo = Ns::ChannelStatement.new(rec)
    oo.save!
    #debugger
  end
end

if ARGV.empty?
  puts "Usage: xxxx [orders|statements]"
  return
end

if ARGV[0] == "orders"
  fetch_order_records
elsif ARGV[0] == "statements"
  fetch_statement_records
end
