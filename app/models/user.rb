# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  attr_accessible :name, :roles, :roles_mask, :finished_onboarding

  has_many :identities, dependent: :destroy
  has_and_belongs_to_many :facebook_pages

  belongs_to :subscription

  delegate :next_plan, to: :subscription
  delegate :next_plan_id, to: :subscription

  include SubscriptionStatus

  include Stripe::Callbacks

  after_customer_updated! do |customer, event|
    user = User.find_by_stripe_customer_id(customer.id)
    unless customer.delinquent
      user.account_current = true
    end
    user.save!
  end

  def overview
    {
      id: self.try(:id),
      name: self.try(:name),
      email: self.try(:email),
      fb_uid: self.try(:fb_uid),
      member_since: self.try(:member_since),
      subscription_plan: self.try(:subscription_plan_name),
      facebook_pages_count: self.facebook_pages.try(:size),
      giveaways_count: self.giveaways.try(:size)
    }
  end

  def giveaways
    facebook_pages.map(&:giveaways).flatten
  end

  def active_giveaways_count
    facebook_pages.sum do |page|
      page.giveaways.active.size
    end
  end

  def pending_giveaways_count
    facebook_pages.sum do |page|
      page.giveaways.pending.size
    end
  end

  def completed_giveaways_count
    facebook_pages.sum do |page|
      page.giveaways.completed.size
    end
  end

  def stripe_customer(stripe_token = nil)
    if stripe_customer_id
      Stripe::Customer.retrieve(stripe_customer_id)
    elsif stripe_token
      create_customer(stripe_token)
    end
  end

  def create_customer(stripe_token)
    customer = Stripe::Customer.create(
      email: email,
      card: stripe_token
    )
    self.stripe_customer_id = customer.id
    save ? customer : false
  end

  def current_identity
    identities.order("logged_in_at desc").limit(1).first
  end

  def email
    current_identity.email rescue nil
  end

  def avatar
    current_identity.avatar rescue nil
  end

  def member_since
    self.created_at.to_formatted_s(:date) rescue nil
  end

  def fb_uid
    identities.where("provider = 'facebook'").first.uid rescue nil
  end

  def fb_token
    identities.where("provider = 'facebook'").first.token rescue nil
  end

  def first_name
    name.split(' ').first rescue name
  end

  def just_finished_onboarding?
    finished_onboarding && current_identity.login_count == 1
  end

  ROLES = %w[superadmin admin team restricted banned]

  def is?(role)
    roles.include?(role.to_s)
  end

  def roles=(roles)
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end

  def roles
    ROLES.reject do |r|
      ((roles_mask || 0) & 2**ROLES.index(r)).zero?
    end
  end

  def self.pages_worker(user_id, fb_token, csrf_token)
    graph = Koala::Facebook::API.new(fb_token)
    pages = graph.get_connections("me", "accounts")
    @user = User.find_by_id(user_id)
    FacebookPage.retrieve_fb_meta(@user, pages, csrf_token)
  end
end
