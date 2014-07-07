class EntryConversionWorker
  include Sidekiq::Worker

  def perform(has_liked, ref_ids, giveaway_cookie)
    Entry.conversion_worker(has_liked, ref_ids, giveaway_cookie)
  end
end
