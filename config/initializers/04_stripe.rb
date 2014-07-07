Rails.configuration.stripe = OpenStruct.new({
  :publishable_key => STRIPE_PUBLISHABLE_KEY,
  :secret_key      => STRIPE_SECRET_KEY,
  :api_key         => STRIPE_SECRET_KEY
})

Stripe.api_key = Rails.configuration.stripe.secret_key

StripeTester.webhook_url = 'http://localhost:7777/stripe/events'
