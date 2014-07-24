namespace :unicorn do
  desc 'Restart application'
  task :restart do
    on roles(:app) do
      puts "restarting unicorn..."
      execute "sudo service unicorn restart"
      sleep 5
      execute "ps aux | grep unicorn"
    end
  end
end