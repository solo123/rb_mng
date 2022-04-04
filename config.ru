require 'require_all'
require 'mongoid'

require_all %w[init app lib helper model]

#puts ">> server start..."
#use Ns::LogJsonReq
#run Ns::App.freeze.app
#run Ns::AppHtml.freeze.app
run Ns::App.app