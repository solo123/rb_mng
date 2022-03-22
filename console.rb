#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'require_all'
require 'mongoid'

require_all %w[app config lib helper model model_gw]
include Ns

def reload!(print = true)
  puts "Reloading..." if print
  root_dir = File.expand_path(__dir__)
  reload_dirs = %w[app config lib helper model model_gw]
  reload_dirs.each do |dir|
    Dir.glob("#{root_dir}/#{dir}/**/*.rb").each {|f| load(f) }
  end
  true
end
