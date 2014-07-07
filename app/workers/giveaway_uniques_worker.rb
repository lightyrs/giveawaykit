class GiveawayUniquesWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(giveaway_id, is_fan, is_viral)
    Giveaway.uniques_worker(
      giveaway_id: giveaway_id,
      is_fan: is_fan,
      is_viral: is_viral
    )
  end
end
