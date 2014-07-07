class SubscriptionPlan < ActiveRecord::Base

  include Comparable

  has_many :subscriptions

  validates :name, uniqueness: true

  scope :visible, where("price_in_cents_per_cycle > ?", 0)

  PLAN_HIERARCHY = [
    { name: "Single Page",
      weight: 0 },
    { name: "Single Page Pro",
      weight: 1 },
    { name: "Multi Page Pro",
      weight: 2 }
  ]

  def weight
    plan = PLAN_HIERARCHY.select do |plan_hash|
      plan_hash[:name] == self.name
    end.pop
    plan[:weight]
  end

  def <=>(another_plan)
    self.weight <=> another_plan.weight
  end

  def price
    "$#{price_in_cents_per_cycle / 100}.00"
  end

  def is_free_trial?
    price_in_cents_per_cycle == 0
  end

  def is_single_page_plan?
    self == SubscriptionPlan.single_page
  end

  def is_single_page_pro_plan?
    self == SubscriptionPlan.single_page_pro
  end

  def is_multi_page_pro_plan?
    self == SubscriptionPlan.multi_page_pro
  end

  def stripe_subscription_id
    name.downcase.gsub(/\s/, '_').gsub(/\(|\)/, '')
  end

  def canhaz_basic_analytics?
    !canhaz_advanced_analytics?
  end

  def canhaz_advanced_analytics?
    name.include? 'Pro'
  end

  def canhaz_scheduled_giveaways?
    name.include? 'Pro'
  end

  def canhaz_referral_tracking?
    name.include? 'Pro'
  end

  def canhaz_giveaway_shortlink?
    name.include? 'Pro'
  end

  def canhaz_white_label?
    name.include? 'Pro'
  end

  class << self

    def free_trial
      self.find_or_create_by(name: "Free Trial") do |sp|
        sp.description = "Run a free giveaway on your page."
        sp.price_in_cents_per_cycle = 0
        sp.is_single_page = true
        sp.is_multi_page = false
        sp.is_onetime = true
        sp.is_monthly = false
        sp.is_yearly = false
      end
    end

    def single_page
      self.find_or_create_by(name: "Single Page") do |sp|
        sp.description = "Run unlimited giveaways on one of your pages."
        sp.price_in_cents_per_cycle = 700
        sp.is_single_page = true
        sp.is_multi_page = false
        sp.is_onetime = false
        sp.is_monthly = true
        sp.is_yearly = false
      end
    end

    def single_page_pro
      self.find_or_create_by(name: "Single Page Pro") do |sp|
        sp.description = "Run unlimited giveaways on one of your pages. Track viral sharing and referrals, gain insights from advanced analytics, and remove Simple Giveaways branding from your giveaways."
        sp.price_in_cents_per_cycle = 1500
        sp.is_single_page = true
        sp.is_multi_page = false
        sp.is_onetime = false
        sp.is_monthly = true
        sp.is_yearly = false
      end
    end

    def multi_page_pro
      self.find_or_create_by(name: "Multi Page Pro") do |sp|
        sp.description = "Run unlimited giveaways on any of your pages. Track viral sharing and referrals, gain insights from advanced analytics, and remove Simple Giveaways branding from your giveaways."
        sp.price_in_cents_per_cycle = 4500
        sp.is_single_page = false
        sp.is_multi_page = true
        sp.is_onetime = false
        sp.is_monthly = true
        sp.is_yearly = false
      end
    end
  end
end
