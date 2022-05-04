require 'minitest/autorun'
require 'rack/test'

ENV["APP_ENV"] = "test"

require 'require_all'
require 'mongoid'
require_all %w[init app lib service_lib model]

puts "loaded"

