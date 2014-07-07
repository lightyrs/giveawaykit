class RefreshWorker
  include Sidekiq::Worker

  def perform
    Refresh.facebook_page_like_count
    Refresh.giveaway_analytics
  end
end