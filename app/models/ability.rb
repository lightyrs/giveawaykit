class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.is?('superadmin')
      can :manage, FacebookPage do |page|
        page.user_ids.include? user.id
      end
      can :manage, Giveaway do |giveaway|
        user.facebook_page_ids.include? giveaway.facebook_page.id
      end
    elsif user.is?('admin')
      can :read, FacebookPage do |page|
        page.user_ids.include? user.id
      end
      can :manage, Giveaway do |giveaway|
        user.facebook_page_ids.include? giveaway.facebook_page.id
      end
    elsif user.is?('team')
      can :read, FacebookPage do |page|
        page.user_ids.include? user.id
      end
      can :update, Giveaway do |giveaway|
        user.facebook_page_ids.include? giveaway.facebook_page.id
      end
    elsif user.is?('restricted')
      can :read, FacebookPage do |page|
        page.user_ids.include? user.id
      end
      can :read, Giveaway do |giveaway|
        user.facebook_page_ids.include? giveaway.facebook_page.id
      end
      cannot :read, Giveaway, completed: true
    elsif user.is?('banned')
      cannot :read, :all
    else
      cannot :read, :all
    end
  end
end
