class SubscriptionScheduleWorker
  include Sidekiq::Worker
  sidekiq_options queue: :often

  def perform
    Subscription.schedule_worker
  end
end
