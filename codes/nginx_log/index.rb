#!ruby
load './console.rb'
require_relative 'log_parser'
require_relative 'metric'
require_relative 'time_period'
require_relative 'rec_line'
require_relative 'remote_agent'

unless ARGV[0]
  puts "Usage: import_log nginx.log 0"
  exit
end

def print_rec(rec)
  puts "#{rec}"
end
def save_rec(rec)
  @count += 1
  l = Ns::MyLog.new(rec)
  l.save
  print "#{@count}\r"
end
def save_agents(agents)
  agents.each do |agent|
    l = Ns::RemoteAgent.new({code: agent[1], agent: agent[0]})
    l.save
  end
end

def metric(rec)
  path = rec['request_path']
  path_nodes = path ? path.split('/') : []
  path_nodes.reject!{|x| x.nil? }
  if path_nodes[-1] && path_nodes[-1].include?('?')
    path_nodes[-1] = path_nodes[-1].split('?')[0]
  end
  path_nodes.each_with_index do |path_node,index|
    path_nodes[index] = '(merchant_id)' if path_node.match(/[0-9a-f]+{4,}/)
  end

  if @time_period.next_period?(rec['time_local'])
    @rec_lines.print_matric(@time_period.prev_period, @mt.metrics)
    @mt.clear
  end
  size = rec['body_bytes_sent'].to_i
  time = rec['request_time'].to_f
  agent = @remote_agent.agent_code(rec['http_user_agent'])
  @mt.add_metrics([:request_host, rec['request_host']], size,time)
  @mt.add_metrics([:status, rec['status']], size,time)
  @mt.add_metrics([:http_user_agent, agent], size,time)
  @mt.add_metrics([:path, *path_nodes[1..3]], size,time)
end

@mt = Codes::NginxLog::Metric.new
@time_period = Codes::Tools::TimePeriod.new
@rec_lines = Codes::Tools::RecLine.new
@rec_lines.handler = method(:save_rec)
#@rec_lines.handler = method(:print_rec)
@time_period.period_time = 60
@remote_agent = Codes::Tools::RemoteAgent.new

@count = 0
puts "----begin----"
wc = Codes::NginxLog::LogParser.new(ARGV[0], ARGV[1].to_i)
wc.handler = method(:metric)
wc.next_rec(100000000)
wc.close
save_agents(@remote_agent.agents)
#pp @remote_agent