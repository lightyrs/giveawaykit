namespace :monit do
  desc 'Restart monit services'
  task :restart do
    on roles(:app) do
      puts "restarting monit services..."
      execute "sudo monit restart unicorn"
      sleep 5
      execute "sudo monit summary"
      execute "sudo monit restart sidekiq"
      sleep 5
      execute "sudo monit summary"
    end
  end
end