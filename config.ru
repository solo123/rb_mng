require 'require_all'
require_all %w[app config lib helper model]

puts ">> server start..."
use Ns::LogJsonReq
run Ns::App.new
