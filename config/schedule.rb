env :PATH, ENV['PATH']

every 1.weeks do
  case @environment
    when 'production'
      command "source /usr/local/rvm/scripts/rvm; if [ -f /etc/default/giveawaykit ]; then . /etc/default/giveawaykit fi; cd /home/gk/giveawaykit/current; bundle exec rails runner 'GiveawayOrphansWorker.perform_async'"
    else
      runner 'GiveawayOrphansWorker.perform_async'
  end
end

every 1.hours do
  case @environment
    when 'production'
      command "source /usr/local/rvm/scripts/rvm; if [ -f /etc/default/giveawaykit ]; then . /etc/default/giveawaykit fi; cd /home/gk/giveawaykit/current; bundle exec rails runner 'SubscriptionScheduleWorker.perform_async'"
    else
      runner 'SubscriptionScheduleWorker.perform_async'
  end
end

every 30.minutes do
  case @environment
    when 'production'
      command "source /usr/local/rvm/scripts/rvm; if [ -f /etc/default/giveawaykit ]; then . /etc/default/giveawaykit fi; cd /home/gk/giveawaykit/current; bundle exec rails runner 'RefreshWorker.perform_async'"
    else
      runner 'RefreshWorker.perform_async'
  end
end

every 5.minutes do
  case @environment
    when 'production'
      command "source /usr/local/rvm/scripts/rvm; if [ -f /etc/default/giveawaykit ]; then . /etc/default/giveawaykit fi; cd /home/gk/giveawaykit/current; bundle exec rails runner 'GiveawayScheduleWorker.perform_async(\"unpublish\")'; bundle exec rails runner 'GiveawayScheduleWorker.perform_async(\"publish\")';"
    else
      runner 'GiveawayScheduleWorker.perform_async("unpublish")'
      runner 'GiveawayScheduleWorker.perform_async("publish")'
  end
end
