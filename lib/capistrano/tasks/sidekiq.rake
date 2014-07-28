namespace :sidekiq do
  desc 'Restart background worker'
  task :restart do
    on roles(:app) do
      puts "restarting sidekiq..."
      execute "sudo restart sidekiq || sudo start sidekiq"
      sleep 5
      execute "ps aux | grep sidekiq"
    end
  end
end