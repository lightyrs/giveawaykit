class Subscription < ActiveRecord::Base

  belongs_to :subscription_plan

  has_one  :user
  has_many :facebook_pages

  serialize :next_page_ids, Array

  scope :to_update, -> { where("activate_next_after IS NOT NULL AND activate_next_after <= ? AND next_plan_id >= ?", Time.zone.now, 1) }

  scope :to_cancel, -> { where("activate_next_after IS NOT NULL AND activate_next_after <= ? AND next_plan_id < ?", Time.zone.now, 1) }

  delegate :name,                        to: :subscription_plan
  delegate :canhaz_basic_analytics?,     to: :subscription_plan
  delegate :canhaz_advanced_analytics?,  to: :subscription_plan
  delegate :canhaz_scheduled_giveaways?, to: :subscription_plan
  delegate :canhaz_referral_tracking?,   to: :subscription_plan
  delegate :canhaz_giveaway_shortlink?,  to: :subscription_plan
  delegate :canhaz_white_label?,         to: :subscription_plan

  include Stripe::Callbacks

  after_customer_subscription_deleted! do |sub, event|
    begin
      if sub.status == 'canceled'
        user = User.find_by_stripe_customer_id(sub.customer)
        user.account_current = false
        user.subscription.after_cancel_actions if user.save
      end
    rescue => e
      Rails.logger.debug("#{e.class}: #{e.message}")
    end
  end

  def active?
    subscription_plan.present? && user.account_current?
  end

  def inactive?
    !active?
  end

  def has_failed_payments?
    !user.account_current?
  end

  def cancellation_pending?
    activate_next_after && next_plan_id == 0
  end

  def downgrade_pending?
    activate_next_after && next_plan_id != 0
  end

  def next_plan
    SubscriptionPlan.find_by_id(next_plan_id)
  end

  def next_page
    if next_plan && next_plan.is_single_page?
      if next_page_ids.any?
        FacebookPage.find_by_id(next_page_ids.first)
      else
        FacebookPage.find_by_id(facebook_pages.first.id)
      end
    end
  end

  def cancel_plan
    self.subscription_plan = nil
    self.activate_next_after = nil
    self.next_plan_id = nil
    self.next_page_ids = nil
    save

    after_cancel_actions
  end

  def update_plan
    self.subscription_plan_id = next_plan_id

    subscribe_next_pages if next_page_ids.any?

    self.activate_next_after = nil
    self.next_plan_id = nil
    self.next_page_ids = nil

    save
  end

  def process_update_request(options = {})
    assess_update_type(options[:subscription_plan_id])

    if @downgrade
      self.activate_next_after = current_period_end
      self.next_plan_id = options[:subscription_plan_id]
    else
      self.subscription_plan_id = options[:subscription_plan_id]
      self.activate_next_after = nil
      self.next_plan_id = nil
      self.next_page_ids = nil
    end

    if @plan_class_downgrade
      self.next_page_ids = options[:facebook_page_ids]
    end
  end

  def process_cancellation_request(stripe_token)
    @cancellation = true

    if find_or_create_customer(stripe_token) && cancel_stripe_subscription
      self.activate_next_after = current_period_end
      self.next_plan_id = 0
      save ? self : false
    end
  end

  def after_update_actions(options = {})
    if find_or_create_customer(options[:stripe_token])

      subscribe_pages(options[:facebook_page_ids]) unless @plan_class_downgrade

      unless @page_change
        stripe_response = update_stripe_subscription

        self.stripe_subscription_id = stripe_response.id
        self.current_period_start = DateTime.strptime("#{stripe_response.current_period_start}", '%s')
        self.current_period_end = DateTime.strptime("#{stripe_response.current_period_end}", '%s')
      end

      save ? self : false
    end
  end

  def after_cancel_actions
    facebook_pages.each(&:find_or_remove_subscription)
  end

  class << self

    def create_or_update(options = {})
      user = User.find_by_id(options[:user_id])

      if subscription = user.subscription
        subscription.process_update_request(options)
      else
        subscription = Subscription.create(user: user, subscription_plan_id: options[:subscription_plan_id])
      end

      subscription.after_update_actions(options)
    end

    def cancel(options = {})
      user = User.find_by_id(options[:user_id])

      if subscription = user.subscription
        subscription.process_cancellation_request(options[:stripe_token])
      end
    end

    def schedule_worker
      Subscription.to_cancel.each(&:cancel_plan)
      Subscription.to_update.each(&:update_plan)
    end
  end

  private

  def assess_update_type(plan_id)
    plan = SubscriptionPlan.find_by_id(plan_id)
    if subscription_plan < plan
      @upgrade = true
    elsif subscription_plan > plan
      @downgrade = true
      if subscription_plan.is_multi_page? && plan.is_single_page?
        @plan_class_downgrade = true
      end
    elsif subscription_plan == plan
      @page_change = true
    end
  end

  def update_stripe_subscription
    @customer.update_subscription(stripe_update_options).tap do |customer|
      create_stripe_invoice if @upgrade
    end
  end

  def cancel_stripe_subscription
    @customer.cancel_subscription(stripe_update_options)
  end

  def create_stripe_invoice
    invoice = Stripe::Invoice.create(customer: @customer.id)
    invoice.pay
  end

  def stripe_update_options
    defaults = { plan: subscription_plan.stripe_subscription_id }
    if @upgrade
      defaults.merge(prorate: true)
    elsif @downgrade
      defaults.merge(plan: next_plan.stripe_subscription_id, prorate: false)
    elsif @cancellation
      { at_period_end: true }
    else
      defaults
    end
  end

  def find_or_create_customer(stripe_token)
    @customer = user.stripe_customer(stripe_token)
  end

  def subscribe_pages(facebook_page_ids)
    self.facebook_pages = select_pages(facebook_page_ids)
  end

  def subscribe_next_pages
    self.facebook_pages = select_pages(next_page_ids)
  end

  def select_pages(facebook_page_ids)
    facebook_page_ids.map do |pid|
      page = FacebookPage.find_by_id(pid)
      page if page.subscription_id.nil? || page.subscription_id == self.id || page.subscription_plan < self.subscription_plan
    end
  end
end
