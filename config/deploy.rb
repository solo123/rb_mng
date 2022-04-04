require 'mina/deploy'
require 'mina/bundler'
require 'mina/git'
require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)

set :application_name, 'mng_service'
set :domain, 'pooul.svc'
set :deploy_to, '/home/jimmy/work/pooul_mng'
set :repository, 'git@e.coding.net:pooul/Pooul/pooul_mng.git'
set :branch, 'master'

set :user, 'jimmy'          # Username in the server to SSH to.
set :forward_agent, true     # SSH forward_agent.

# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
set :shared_dirs, fetch(:shared_dirs, []).push('vendor/bundle')
set :shared_files, fetch(:shared_files, []).push('.ruby-version', 'config/mongoid.yml')

task :remote_environment do
  invoke :'rbenv:load'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  command %{rbenv install 3.1.1 --skip-existing}
  # command %{rvm install ruby-2.5.3}
  command %{gem install bundler}
end

desc "Deploys the current version to the server."
task :deploy do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %{cp ~/work/pooul_mng/shared/falcon.rb .}
        command %{mkdir -p tmp/}
        #command %{bundle}
        command %{eye restart app:mng:test}
      end
    end
  end
  run(:local){ command  "echo 'deploy done.'" }
end

desc "Deploys the current TEST version to the server."
task :deploy_test do
  set :deploy_to, '/home/jimmy/test/pooul_mng'
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %{cp ~/test/pooul_mng/shared/falcon.rb .}
        command %{mkdir -p tmp/}
        #command %{bundle}
        command %{eye restart app:mng:test}
      end
    end
  end
  run(:local){ command  "echo 'deploy done.'" }
end
# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
