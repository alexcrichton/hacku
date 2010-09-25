require 'rvm/capistrano'
require 'paste/capistrano'
require 'bundler/capistrano'

server 'eve.alexcrichton.com', :app, :web, :db, :primary => true
ssh_options[:port] = 7779

set :user, 'capistrano'
set :use_sudo, false
set :rails_env do (ENV['RAILS_ENV'] || 'production').to_sym end
set :rvm_ruby_string, 'ree'
set :bundle_flags, '--deployment'

set :scm, :git
set :repository, 'git://github.com/alexcrichton/hacku.git'
set :branch, 'master'
set :deploy_via, :remote_cache

set :deploy_to, '/srv/http/ngon'

before 'deploy:setup', :db
after 'deploy:update_code', 'db:symlink'

namespace :db do
  task :default do
    run "mkdir -p #{shared_path}/config"
  end

  desc "Make symlink for database yaml"
  task :symlink do
    run "ln -nsf #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nsf #{shared_path}/config/production.sqlite3 #{release_path}/db/production.sqlite3"
    run "ln -nsf #{shared_path}/config/facebook.rb #{release_path}/config/initializers"
    run "ln -nsf #{shared_path}/bundle #{latest_release}/.bundle"
  end

end

# run through phusion passenger on nginx
namespace :deploy do
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
  task :stop, :roles => :app do
    # Do nothing, don't want to kill nginx
  end
end
