crumb :root do
  link "<i class='fa fa-home'></i> Dashboard".html_safe, dashboard_path
end

crumb :user do |user|
  link user.name, edit_user_path(user)
end

crumb :subscription_plans do |user|
  link 'Subscription', user_subscription_plans_path(user)
  parent :user, user
end

crumb :facebook_page do |facebook_page|
  link facebook_page.name, facebook_page_path(facebook_page)
  parent :root
end

crumb :active_giveaway do |facebook_page|
  link "Active Giveaway", active_facebook_page_giveaways_path(facebook_page)
  parent :facebook_page, facebook_page
end

crumb :pending_giveaways do |facebook_page|
  link "Pending Giveaways", pending_facebook_page_giveaways_path(facebook_page)
  parent :facebook_page, facebook_page
end

crumb :completed_giveaways do |facebook_page|
  link "Completed Giveaways", completed_facebook_page_giveaways_path(facebook_page)
  parent :facebook_page, facebook_page
end

crumb :giveaway do |giveaway|
  if giveaway.persisted?
    link giveaway.title, facebook_page_giveaway_path(giveaway.facebook_page, giveaway)
  else
    link "New Giveaway", new_facebook_page_giveaway_path(giveaway.facebook_page)
  end
  parent :facebook_page, giveaway.facebook_page
end
