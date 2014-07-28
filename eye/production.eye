Eye.application 'giveawaykit' do

  Eye.load('../config/production.eye')

  process('unicorn') do
    pid_file '/home/unicorn/pids/unicorn.pid'
    start_command 'service unicorn restart'
    stdall '/home/unicorn/log/unicorn.log'

    # stop signals:
    # http://unicorn.bogomips.org/SIGNALS.html
    stop_signals [:TERM, 10.seconds]

    # soft restart
    restart_command 'kill -USR2 {PID}'

    check :cpu, :every => 30, :below => 80, :times => 3
    check :memory, :every => 30, :below => 150.megabytes, :times => [3,5]

    start_timeout 100.seconds
    restart_grace 30.seconds

    monitor_children do
      stop_command "kill -QUIT {PID}"
      check :cpu, :every => 30, :below => 80, :times => 3
      check :memory, :every => 30, :below => 150.megabytes, :times => [3,5]
    end
  end
end