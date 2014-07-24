lock '3.2.1'

set :application, 'giveawaykit'
set :repo_url, 'git@github.com:giveawaykit/giveawaykit.git'
set :branch, 'master'
set :deploy_to, '/home/gk/giveawaykit'

set :ssh_options, {
  keepalive: true
}

set :scm, :git
set :format, :pretty
set :log_level, :debug
set :keep_releases, 5

set :linked_files, %w{config/database.yml config/.env.production}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }


namespace :deploy do

  desc 'Restart application'
  task :restart do
    invoke 'unicorn:restart'
    invoke 'sidekiq:restart'
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
