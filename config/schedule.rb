env :PATH, ENV['PATH']

every 1.weeks do
  runner 'GiveawayOrphansWorker.perform_async'
end

every 1.hours do
  runner 'SubscriptionScheduleWorker.perform_async'
end

every 30.minutes do
  runner 'RefreshWorker.perform_async'
end

every 5.minutes do
  runner 'GiveawayScheduleWorker.perform_async("unpublish")'
  runner 'GiveawayScheduleWorker.perform_async("publish")'
end
