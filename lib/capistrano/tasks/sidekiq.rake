namespace :sidekiq do
  desc 'Restart background worker'
  task :restart do
    on roles(:app) do
      puts "restarting sidekiq..."
      execute "sudo restart sidekiq index=0"
      sleep 5
      execute "ps aux | grep sidekiq"
    end
  end
end