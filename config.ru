require 'require_all'
require 'mongoid'

require_all %w[app config lib helper model]

puts ">> server start..."
#use Ns::LogJsonReq
run Ns::App.freeze.app
#run Ns::AppHtml.freeze.app