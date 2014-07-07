class FbAppRequestWorker
  include Sidekiq::Worker

  def perform(request_id, signed_request)
    return unless signed_request.present?
    Giveaway.app_request_worker(request_id, signed_request)
  end
end
