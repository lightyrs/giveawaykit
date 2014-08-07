# -*- encoding : utf-8 -*-
class FacebookPage < ActiveRecord::Base

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  include ActionView::Helpers::UrlHelper

  attr_accessible :name, :category, :pid, :token, :avatar_square,
                  :avatar_large, :description, :likes, :talking_about_count,
                  :url, :has_added_app, :subscription_id

  has_many :audits, as: :auditable

  has_many :giveaways
  has_and_belongs_to_many :users

  belongs_to :subscription

  validates :pid, uniqueness: true

  scope :unsubscribed, where(subscription_id: nil)
  scope :subscribed, where("subscription_id IS NOT ?", nil)

  delegate :next_plan, to: :subscription
  delegate :next_plan_id, to: :subscription

  include SubscriptionStatus

  def has_better_plan_with_other_user?(options = {})
    user = User.find_by_id(options[:user_id])
    new_plan = SubscriptionPlan.find_by_id(options[:subscription_plan_id])
    return false unless has_active_subscription? && subscription.user != user && subscription_plan > new_plan
  rescue
    false
  end

  def has_worse_plan_with_other_user?(options = {})
    user = User.find_by_id(options[:user_id])
    new_plan = SubscriptionPlan.find_by_id(options[:subscription_plan_id])
    return false unless has_active_subscription? && subscription.user != user && subscription_plan < new_plan
  rescue
    false
  end

  def cannot_schedule?
    needs_subscription? || !canhaz_scheduled_giveaways?
  end

  def can_schedule?
    !cannot_schedule?
  end

  def active_giveaway
    giveaways.active.first
  end

  def active_giveaway_title
    return nil unless active_giveaway
    active_giveaway.title
  end

  def no_active_giveaways?
    giveaways.active.empty?
  end

  def no_pending_giveaways?
    giveaways.pending.empty?
  end

  def no_completed_giveaways?
    giveaways.completed.empty?
  end

  def refresh_likes
    batch = FacebookPage.graph_data(page: self)

    self.likes = batch[:data]["likes"]
    self.talking_about_count = batch[:data]["talking_about_count"]
    self.audits << likes_audit
    save
  end

  def likes_audit
    Audit.new(
      was: {
        likes: likes_was,
        talking_about_count: talking_about_count_was
      },
      is: {
        likes: likes,
        talking_about_count: talking_about_count
      }
    )
  end

  def page_admin_emails
    users.map do |user|
      user.identities.first.email if user
    end
  end

  def path
    Rails.application.routes.url_helpers.facebook_page_path(self)
  end

  def canhaz_basic_analytics?
    !!subscription && subscription.canhaz_basic_analytics?
  end

  def canhaz_advanced_analytics?
    !!subscription && subscription.canhaz_advanced_analytics? || has_free_trial_remaining?
  end

  def canhaz_scheduled_giveaways?
    !!subscription && subscription.canhaz_scheduled_giveaways? || has_free_trial_remaining?
  end

  def canhaz_referral_tracking?
    !!subscription && subscription.canhaz_referral_tracking? || has_free_trial_remaining?
  end

  def canhaz_giveaway_shortlink?
    !!subscription && subscription.canhaz_giveaway_shortlink? || has_free_trial_remaining?
  end

  def canhaz_white_label?
    !!subscription && subscription.canhaz_white_label?
  end

  def find_or_remove_subscription
    potentials = users.map(&:subscription).select(&:active?) rescue []
    if potentials.select(&:is_multi_page?).any?
      self.subscription_id = potentials.first.id
    else
      self.subscription_id = nil
    end
    save
  end

  def active_giveaways_count
    giveaways.active.count rescue 0
  end

  def pending_giveaways_count
    giveaways.pending.count
  end

  def completed_giveaways_count
    giveaways.completed.count
  end

  class << self

    def select_pages(options = {})
      pages = options[:pages].reject do |page|
        page["category"] == "Application"
      end

      pages.collect do |page|
        begin
          if page_eligible?(batch = graph_data(page: page, fb_uid: options[:fb_uid]))
            { page: page, fb_meta: batch }
          end
        rescue
          nil
        end
      end
    end

    def graph_data(options = {})
      batch = batch_data(page: options[:page], fb_uid: options[:fb_uid])

      { data: batch[0],
        avatar_square: batch[1],
        avatar_large: batch[2],
        fb_admin: batch[3].pop }
    end

    def batch_data(options = {})
      @token = options[:page]["access_token"] || options[:page].token
      @graph = Koala::Facebook::API.new(@token)

      @graph.batch do |batch_api|
        batch_api.get_object("me")
        batch_api.get_picture("me", type: "square")
        batch_api.get_picture("me", type: "large")
        batch_api.get_connection("me", "admins/#{options[:fb_uid]}")
      end
    rescue
    end

    def page_eligible?(batch)
      batch[:data]["link"].include?("facebook.com") && %w(MANAGER CONTENT_CREATOR).include?(batch[:fb_admin]["role"])
    end

    def retrieve_fb_meta(user, pages, csrf_token)
      pages = select_pages(pages: pages, fb_uid: user.fb_uid).compact.flatten
      page_count = (pages.size - 1)

      pages.each_with_index do |page_hash, index|
                    page = page_hash[:page]
                 fb_meta = page_hash[:fb_meta][:data]
        fb_avatar_square = page_hash[:fb_meta][:avatar_square]
         fb_avatar_large = page_hash[:fb_meta][:avatar_large]

        @page = find_or_create_by(pid: page["id"])

        previous_likes = @page.likes || fb_meta["likes"]

        @page.update_attributes(
          name: page["name"],
          category: page["category"],
          pid: page["id"],
          token: page["access_token"],
          avatar_square: fb_avatar_square,
          avatar_large: fb_avatar_large,
          description: fb_meta["description"],
          url: fb_meta["link"],
          likes: fb_meta["likes"],
          has_added_app: fb_meta["has_added_app"]
        )

        unless user.facebook_pages.include? @page
          @page.refresh_likes
          user.facebook_pages << @page
          if user.has_active_subscription? && user.has_multi_page_subscription?
            @page.update_attributes(subscription_id: user.subscription_id)
          end
        end
      end

      user.update_attributes(finished_onboarding: true)

      remove_outdated_pages(user, pages)
    end

    def remove_outdated_pages(user, pages)
      user_pids = user.facebook_pages.pluck(:pid)
      fb_pids = pages.map { |page_hash| page_hash[:page]["id"] }
      (user_pids - fb_pids).each do |pid|
        page = find_by_pid(pid)
        if page.has_active_subscription? && page.subscription.user == user
          page.find_or_remove_subscription
        end
        user.facebook_pages.delete(page)
      end
    end
  end
end
