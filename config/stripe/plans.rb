Stripe.plan :single_page do |plan|
  plan.name = 'Single Page'
  plan.amount = 700
  plan.interval = 'month'
end

Stripe.plan :single_page_pro do |plan|
  plan.name = 'Single Page Pro'
  plan.amount = 1500
  plan.interval = 'month'
end

Stripe.plan :multi_page_pro do |plan|
  plan.name = 'Multi Page Pro'
  plan.amount = 4500
  plan.interval = 'month'
end
