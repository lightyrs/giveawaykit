class GiveawayScheduleWorker
  include Sidekiq::Worker
  sidekiq_options queue: :often

  def perform(method)
    Giveaway.schedule_worker(method)
  end
end
