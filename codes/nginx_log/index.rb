#!ruby
require_relative 'log_parser'
require_relative 'metric'
require_relative 'time_period'
require_relative 'rec_line'

unless ARGV[0]
  puts "Usage: import_log nginx.log 0"
  exit
end

def print_rec(rec)
  puts "#{rec}"
end

def metric(rec)
  merchant_id = nil
  path = rec['request_path']
  if path.include?('?')
    path,params = path.split('?') 
    if mt = params.match(/merchant_id=(\d{4,})/)
      merchant_id = mt[1]
    end
  end
  if mt = path.match(/\/(\d{4,})/)
    merchant_id = mt[1]
  end
  path_nodes = path.split('/')
  path_nodes.each_with_index do |path_node,index|
    if path_node.match(/\d+{4,}/)
      path_nodes[index] = '(merchant_id)'
    end
  end

  if @time_period.next_period?(rec['time_local'])
    @rec_lines.print_matric(@time_period.prev_period, @mt.metrics)
  end
  size = rec['body_bytes_sent'].to_i
  time = rec['request_time'].to_f
  @mt.add_metrics([:request_host, rec['request_host']], size,time)
  @mt.add_metrics([:status, rec['status']], size,time)
  @mt.add_metrics([:http_user_agent, rec['http_user_agent']], size,time)
  @mt.add_metrics([:path, *path_nodes[1..3]], size,time)
end

@mt = Codes::NginxLog::Metric.new
@time_period = Codes::Tools::TimePeriod.new
@rec_lines = Codes::Tools::RecLine.new
@rec_lines.handler = method(:print_rec)

wc = Codes::NginxLog::LogParser.new(ARGV[0], ARGV[1].to_i)
wc.handler = method(:metric)
wc.next_rec(1000)
wc.close
#pp @mt