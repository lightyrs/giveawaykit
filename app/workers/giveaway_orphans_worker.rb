class GiveawayOrphansWorker
  include Sidekiq::Worker
  sidekiq_options queue: :seldom

  def perform
    Giveaway.orphans_worker
  end
end
