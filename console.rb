#!/usr/bin/env ruby

require 'require_all'
require 'mongoid'
require_all 'helper'
require_all %w[init app lib service_lib model]

include Ns

def reload!(print = true)
  puts "Reloading..." if print
  root_dir = File.expand_path(__dir__)
  reload_dirs = %w[app lib service_lib model]
  reload_dirs.each do |dir|
    Dir.glob("#{root_dir}/#{dir}/**/*.rb").each {|f| load(f) }
  end
  true
end

def create_indexes
  ::Mongoid::Tasks::Database.create_indexes
end

def remove_undefined_indexes
  ::Mongoid::Tasks::Database.remove_undefined_indexes
end

def remove_indexes
  ::Mongoid::Tasks::Database.remove_indexes
end

def refresh_indexes
  remove_indexes
  create_indexes
end

def refresh_indexes2
  remove_undefined_indexes
  create_indexes
end

def show_index(k)
  Constget(k).collection.indexes.each {|d| p d} && nil
end

def all_index
  Merchant.mongo_client.database.collections.sort_by(&:name).each do |c|
    puts "\n", c.name
    c.indexes.each {|e| p e.except('v', 'ns', 'background', 'name') unless e['name'] == '_id_'}
  end
  nil
end