if Rails.env.production?
  SG_DOMAIN = 'giveawaykit.com'
  SG_SSL_DOMAIN = 'giveawaykit.com'
else
  SG_DOMAIN = 'localhost:7777'
  SG_SSL_DOMAIN = 'localhost:3000'
end
