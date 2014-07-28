namespace :sidekiq do
  desc 'Restart background worker'
  task :restart do
    on roles(:app) do
      puts "restarting sidekiq..."
      begin
        execute "sudo restart sidekiq"
      rescue
        execute "sudo start sidekiq"
      end
      sleep 5
      execute "ps aux | grep sidekiq"
    end
  end
end