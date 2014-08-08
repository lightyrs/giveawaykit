class GiveawayScheduleWorker
  include Sidekiq::Worker
  sidekiq_options queue: :often

  def perform(method)
    puts ENV['PATH'].inspect rescue nil
    Giveaway.schedule_worker(method)
  end
end
