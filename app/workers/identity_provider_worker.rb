class IdentityProviderWorker
  include Sidekiq::Worker
  sidekiq_options queue: :often

  def perform(identity_id, auth)
    Identity.provider_worker(identity_id, auth)
  end
end
