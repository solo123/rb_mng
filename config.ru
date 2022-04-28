require 'require_all'
require 'mongoid'
require_all %w[init app lib service_lib model]

#puts ">> server start..."
#use Ns::LogJsonReq
#run Ns::App.freeze.app
#run Ns::AppHtml.freeze.app
run Mng::Route::App.app