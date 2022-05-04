require 'rake/testtask'
require 'active_support'

task default: "test"
Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*_test.rb']
end

namespace :db do
  ENV['APP_ENV'] = 'test'
  require 'require_all'
  require 'mongoid'
  require_all %w[init lib service_lib model]
  seeds_reg = /^test\/(.+)\.rb$/
  seeds_rb = FileList['test/fixture/**/*.rb']

  desc 'clean, seed for sample data'
  task re_seed: [:clean, :seed] do
    puts 'Ready to go!'
  end

  task :clean do
    seeds_rb.each do |f|
      dt = seeds_reg.match(f)&.captures&.first
      (require "./#{f}"; dt.classify.constantize.clean_data) if dt
    end
  end
  task :seed do
    seeds_rb.each do |f|
      dt = seeds_reg.match(f)&.captures&.first
      (require "./#{f}"; dt.classify.constantize.seed_data) if dt
    end
  end

end