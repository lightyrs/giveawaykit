# -*- encoding : utf-8 -*-
require 'csv'
require 'dotiw'

class Giveaway < ActiveRecord::Base

  extend FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::DateHelper

  is_impressionable

  include PublicUtils

  attr_accessible :is_hidden, :is_free_trial, :title, :description, :start_date, :end_date, :prize, :terms, :preferences, :sticky_post, :preview_mode, :giveaway_url, :facebook_page_id, :image, :image_cache, :feed_image, :feed_image_cache, :custom_fb_tab_name, :analytics, :active, :terms_url, :terms_text, :autoshow_share_dialog, :allow_multi_entries, :email_required, :bonus_value, :_total_shares, :_total_wall_posts, :_total_requests, :_viral_entry_count, :_views, :_uniques, :_viral_uniques, :_fan_uniques, :_non_fan_uniques, :_fan_visitor_rate, :_non_fan_visitor_rate, :_fan_conversion_rate, :_viral_views, :_viral_like_count, :_likes_from_entries_count, :_entry_count, :_entry_conversion_rate, :_viral_entry_conversion_rate, :_page_likes, :_page_likes_while_active, :_talking_about_count

  has_many :audits, as: :auditable

  belongs_to :facebook_page
  has_many :entries, dependent: :delete_all
  has_many :likes, dependent: :delete_all

  scope :visible, -> { where("is_hidden IS FALSE") }
  scope :hidden, -> { where("is_hidden IS TRUE") }

  scope :free_trials, -> { where(is_free_trial: true) }

  scope :active, -> { where("active IS TRUE").limit(1) }

  scope :pending, -> { where("active IS FALSE AND (end_date >= ? OR end_date IS NULL)", Time.zone.now) }

  scope :completed, -> { where("active IS FALSE AND end_date <= ?", Time.zone.now) }

  scope :incomplete, -> { where("active IS TRUE OR (active IS FALSE AND end_date >= ? OR end_date IS NULL)", Time.zone.now) }

  scope :to_start, -> { where("start_date IS NOT NULL AND active IS FALSE AND start_date <= ? AND start_date > ? AND end_date > ?", Time.zone.now + 3.minutes, Time.zone.now - 20.minutes, Time.now) }

  scope :to_end, -> { where("end_date IS NOT NULL AND active IS TRUE AND end_date <= ?", Time.zone.now + 3.minutes) }

  validates :title, presence: true, length: { maximum: 100 }, uniqueness: { scope: :facebook_page_id }
  validates :title, presence: true, length: { maximum: 100 }
  validates :description, presence: true
  validates :prize, presence: true
  validates :custom_fb_tab_name, presence: true

  store :terms, accessors: [ :terms_url, :terms_text ]

  validate :terms_present

  validates :terms_url, format: { with: /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix, multiline: true, message: "must be a proper URL and start with 'http://'" }, allow_blank: true

  store :preferences, accessors: [ :autoshow_share_dialog,
                                   :allow_multi_entries,
                                   :email_required,
                                   :bonus_value ]

  validates :autoshow_share_dialog, presence: true, inclusion: { in: [ "0", "1", 0, 1, true, false, "true", "false" ] }
  validates :allow_multi_entries, presence: true, inclusion: { in: [ "0", "1", 0, 1, true, false, "true", "false" ] }
  validates :email_required, presence: true, inclusion: { in: [ "0", "1", 0, 1, true, false, "true", "false" ] }
  validates :bonus_value, presence: true, numericality: { only_integer: true }, if: -> { canhaz_referral_tracking? || to_bool(allow_multi_entries) }

  store :sticky_post, accessors: [ :sticky_post_enabled?,
                                   :sticky_post_title,
                                   :sticky_post_body ]

  validates :sticky_post_title, presence: true, length: { maximum: 200 }, if: -> { sticky_post_enabled? }
  validates :sticky_post_body, presence: true, if: -> { sticky_post_enabled? }

  validates_datetime :start_date, is_at: -> { start_date_was },
                                  is_at_message: "cannot be changed on an active giveaway.",
                                  on: :update,
                                  if: -> { active_was },
                                  ignore_usec: true

  validates_datetime :start_date, on_or_after: -> { 5.minutes.ago },
                                  on_or_after_message: "must be in the future.",
                                  unless: -> { active || active_was || is_hidden || is_hidden_was },
                                  ignore_usec: true,
                                  allow_blank: true,
                                  allow_nil: true

  validates_datetime :start_date, before: :end_date,
                                  before_message: "must be before end date/time.",
                                  unless: -> { active || is_hidden || is_hidden_was },
                                  ignore_usec: true,
                                  allow_blank: true,
                                  allow_nil: true

  validates_datetime :end_date, on_or_after: -> { (Time.zone.now - 30.seconds) },
                                on_or_after_message: "must be in the future.",
                                unless: -> { (!active && active_was) || is_hidden || is_hidden_was },
                                ignore_usec: true,
                                allow_blank: true,
                                allow_nil: true

  validates_datetime :end_date, after: :start_date,
                                after_message: "must be after start date/time.",
                                unless: -> { (!active && active_was) || is_hidden || is_hidden_was },
                                ignore_usec: true,
                                allow_blank: true,
                                allow_nil: true

  store :analytics, accessors: [ :_total_shares,
                                 :_total_wall_posts,
                                 :_total_requests,
                                 :_viral_entry_count,
                                 :_views,
                                 :_uniques,
                                 :_viral_uniques,
                                 :_fan_uniques,
                                 :_non_fan_uniques,
                                 :_fan_visitor_rate,
                                 :_non_fan_visitor_rate,
                                 :_fan_conversion_rate,
                                 :_viral_views,
                                 :_viral_like_count,
                                 :_likes_from_entries_count,
                                 :_page_likes,
                                 :_page_likes_while_active,
                                 :_talking_about_count,
                                 :_entry_count,
                                 :_entry_conversion_rate,
                                 :_viral_entry_conversion_rate ]

  mount_uploader :image, ImageUploader, mount_on: :image_file_name
  mount_uploader :feed_image, FeedImageUploader, mount_on: :feed_image_file_name

  delegate :needs_subscription?, to: :facebook_page

  self.per_page = 10

  def cannot_schedule?
    !can_schedule?
  end

  def can_schedule?
    canhaz_scheduled_giveaways?
  end

  def canhaz_advanced_analytics?
    facebook_page.canhaz_advanced_analytics? || is_free_trial?
  end

  def canhaz_referral_tracking?
    facebook_page.canhaz_referral_tracking? || is_free_trial?
  end

  def canhaz_scheduled_giveaways?
    facebook_page.canhaz_scheduled_giveaways? || is_free_trial?
  end

  def canhaz_giveaway_shortlink?
    facebook_page.canhaz_giveaway_shortlink? || is_free_trial?
  end

  def graph_client
    @graph ||= Koala::Facebook::API.new(facebook_page.token)
  end

  def csv
    CSV.generate do |csv|
      csv << ["ID", "Email", "Name", "Viral?", "New Fan?", "Entry Time",
              "Wall Posts", "Requests", "Conversions", "Bonus Entries"]
      entries.each do |entry|
        csv << [entry.id, entry.email, entry.name, entry.is_viral,
                entry.new_fan?, entry.datetime_entered, entry.wall_post_count, entry.request_count, entry.convert_count, entry.bonus_entries]
      end
    end
  end

  def hide
    self.update_attributes(is_hidden: true)
  end

  def publish(giveaway_params = {})
    begin
      ActiveRecord::Base.transaction do
        raise ActiveRecord::Rollback unless startable?
        self.update_attributes!(giveaway_params.merge({ start_date: (Time.zone.now - 30.seconds), active: true }))
        publish_tab ? after_publish : raise(ActiveRecord::Rollback)
      end
    rescue => e
      false
    end
  end

  def publish_tab
    is_installed? ? update_tab : create_tab
  end

  def after_publish
    save_shortlink
    GabbaClient.new.event(category: "Giveaways", action: "Giveaway#start", label: title)
    facebook_page.users.each do |page_admin|
      GiveawayNoticeMailer.start(page_admin, self).deliver rescue nil
    end
    seed_graph
    self.update_attributes(is_free_trial: facebook_page.giveaways.completed.none? && active?)
  end

  def save_shortlink
    self.shortlink = bitly_client.shorten(giveaway_url).short_url rescue giveaway_url
    save!
  end

  def seed_graph
    2.times { refresh_analytics; sleep 2 }
  end

  def bitly_client
    Bitly.use_api_version_3
    Bitly.new(BITLY_USERNAME, BITLY_KEY)
  end

  def unpublish
    if delete_tab || !is_installed?
      self.end_date = Time.zone.now
      self.active = false
      save
      after_unpublish
    end
  end

  def after_unpublish
    GabbaClient.new.event(category: "Giveaways", action: "Giveaway#end", label: title)
    facebook_page.users.each do |page_admin|
      GiveawayNoticeMailer.end(page_admin, self).deliver rescue nil
    end
  end

  def startable?
    (facebook_page.has_active_subscription? || facebook_page.has_free_trial_remaining?) && facebook_page.no_active_giveaways? rescue false
  end

  def status
    case
    when pending?
      "Pending"
    when completed?
      "Completed"
    when active?
      "Active"
    else
      nil
    end
  end

  def days_left
    if end_date.nil?
      "?"
    else
      "#{distance_of_time_in_words(Time.now, end_date, include_seconds: false, only: %w(days), accumulate_on: :days)}".split(" days")[0]
    end
  end

  def has_scheduling_conflict?
    start_date_conflicts.any? || end_date_conflicts.any?
  end

  def has_start_date_conflict?
    start_date_conflicts.any?
  end

  def all_conflicts
    start_date_conflicts + end_date_conflicts
  end

  def start_date_conflicts
    return [] unless start_date
    scheduling_conflicts(start_date)
  end

  def end_date_conflicts
    return [] unless end_date
    scheduling_conflicts(end_date)
  end

  def scheduling_conflicts(date)
    (facebook_page.giveaways.incomplete - [self]).select do |pg|
      next unless pg.start_date && pg.end_date
      (pg.start_date..pg.end_date).cover?(date)
    end
  end

  def active?
    active
  end

  def pending?
    !active && (end_date.nil? || (end_date >= Time.zone.now))
  end

  def completed?
    !active && end_date && end_date <= Time.zone.now
  end

  def is_installed?
    graph_client.get_connections("me", "tabs", tab: FB_APP_ID).any? ? true : false
  end

  def create_tab
    begin
      graph_client.put_connections("me", "tabs", app_id: FB_APP_ID)
      update_tab
    rescue
      delete_tab
      false
    end
  end

  def update_tab
    begin
      options = { tab: "app_#{FB_APP_ID}",
                  custom_name: custom_fb_tab_name,
                  custom_image_url: feed_image.thumb.url }
      full_options = options.merge(position: 2)
      graph_client.put_object( facebook_page.pid, "tabs", full_options )
    rescue
      graph_client.put_object( facebook_page.pid, "tabs", options )
    end
  end

  def delete_tab
    begin
      tabs = graph_client.get_connections("me", "tabs")
      tab = select_giveaway_tab(tabs)

      graph_client.delete_object(tab["id"])
    rescue
      false
    end
  end

  def select_giveaway_tab(tabs)
    tabs.select do |tab|
      tab["application"] && tab["application"]["namespace"] == FB_NAMESPACE
    end.compact.flatten.first
  end

  def page_pid
    facebook_page.pid
  end

  def total_shares
    total_wall_posts + total_requests
  end

  def total_wall_posts
    all_wall_posts = entries.collect(&:wall_post_count)
    all_wall_posts.inject(:+) || 0
  end

  def total_requests
    all_requests = entries.collect(&:request_count)
    all_requests.inject(:+) || 0
  end

  def viral_entry_count
    entries.where(:is_viral => true).size
  end

  def views
    impressionist_count
  end

  def ip_uniques
    unique_impression_count_ip
  end

  def viral_views
    impressions.where("message LIKE ?", "%ref_id: %").size
  end

  def direct_uniques
    uniques - viral_uniques rescue 0
  end

  def viral_like_count
    viral_likes.size
  end

  def viral_likes
    likes.where(:is_viral => true)
  end

  def likes_from_entries_count
    likes_from_entries.size
  end

  def likes_from_entries
    likes.where("from_entry IS TRUE")
  end

  def visitor_like_count
    likes.size
  end

  def page_likes
    facebook_page.likes
  end

  def page_likes_while_active
    active? ? page_likes_so_far : audits.last.is[:analytics][:_page_likes_while_active]
  rescue StandardError
    0
  end

  def page_likes_so_far
    facebook_page.likes - page_likes_at_start
  rescue StandardError
    0
  end

  def page_likes_at_start
    facebook_page.audits.
        where('created_at < ?', start_date.utc).
        sort.last.is[:likes].to_i
  end

  def page_likes_at_end
    facebook_page.audits.
        where('created_at > ?', end_date.utc).
        sort.first.is[:likes].to_i
  end

  def talking_about_count
    facebook_page.talking_about_count
  end

  def entry_count
    entries.size
  end

  def sharing_entry_count
    entries.shared.size rescue 0
  end

  def entry_share_conversion_rate
    (entry_count > 0) ? "#{((sharing_entry_count.to_f / entry_count.to_f) * 100).round(1)}%" : "0%"
  rescue StandardError
    "0%"
  end

  def entry_conversion_rate
    (uniques > 0) ? "#{((entry_count.to_f / uniques.to_f) * 100).round(1)}%" : "0%"
  rescue StandardError
    "0%"
  end

  def viral_entry_conversion_rate
    (viral_uniques > 0) ? "#{((viral_entry_count.to_f / (viral_uniques.to_f)) * 100).round(1)}%" : "0%"
  rescue StandardError
    "0%"
  end

  def fan_visitor_rate
    (uniques > 0) ? "#{((fan_uniques.to_f / (uniques.to_f)) * 100).round(1)}%" : "0%"
  rescue StandardError
    "0%"
  end

  def non_fan_visitor_rate
    (uniques > 0) ? "#{((non_fan_uniques.to_f / (uniques.to_f)) * 100).round(1)}%" : "0%"
  rescue StandardError
    "0%"
  end

  def fan_conversion_rate
    (non_fan_uniques > 0) ? "#{((visitor_like_count.to_f / (non_fan_uniques.to_f)) * 100).round(1)}%" : "0%"
  rescue StandardError
    "0%"
  end

  def refresh_analytics
    self._total_shares = total_shares
    self._total_wall_posts = total_wall_posts
    self._total_requests = total_requests
    self._viral_entry_count = viral_entry_count
    self._views = views
    self._uniques = uniques
    self._viral_uniques = viral_uniques
    self._fan_uniques = fan_uniques
    self._non_fan_uniques = non_fan_uniques
    self._viral_views = viral_views
    self._viral_like_count = viral_like_count
    self._page_likes = page_likes
    self._page_likes_while_active = page_likes_while_active
    self._talking_about_count = talking_about_count
    self._likes_from_entries_count = likes_from_entries_count
    self._entry_count = entry_count
    self.audits << analytics_audit
    save
  end

  def tab_height
    Giveaway.image_dimensions(image.tab)[:height].to_i + 203
  end

  def countdown_target
    end_date.strftime("%m/%d/%Y %H:%M:%S")
  end

  def terms_link
    terms_url.present? ? terms_url_link : terms_text_link
  end

  def errors_list
    if errors.any?
      ERB.new(<<-BLOCK.squish).result(binding)
      <ul class='errors-list'>
        <% errors.full_messages.each do |msg| %>
          <li><%= msg %></li>
        <% end %>
      </ul>
      BLOCK
    end
  end

  class << self

    include PublicUtils

    def cookie_key(id)
      "_sg_gid_#{id}".to_sym
    end

    def image_dimensions(img_url)
      image = MiniMagick::Image.open(img_url) rescue []
      { width: image[:width], height: image[:height] }
    end

    def tab(signed_request)
      app_data = signed_request["app_data"]
      referrer_id = app_data.split("ref_")[1] rescue []
      current_page = FacebookPage.select("id, url, name, slug, subscription_id, avatar_large").find_by(pid: signed_request["page"]["id"])
      giveaway = current_page.active_giveaway

      OpenStruct.new({
        fb_uid: signed_request["user_id"],
        referrer_id: referrer_id,
        has_liked: signed_request["page"]["liked"],
        current_page: current_page,
        page_avatar: current_page.avatar_large,
        giveaway: giveaway.tab_attrs,
        tab_height: giveaway.tab_height,
        canhaz_white_label: giveaway.facebook_page.canhaz_white_label?,
        canhaz_referral_tracking: giveaway.canhaz_referral_tracking?
      })
    rescue StandardError => e
      puts "#{e.class}: #{e.message}".red
    end

    def app_request_worker(request_id, signed_request)
      return unless signed_request
      oauth = Koala::Facebook::OAuth.new(FB_APP_ID, FB_APP_SECRET)
      signed_request = oauth.parse_signed_request(signed_request)

      return unless signed_request["oauth_token"]
      graph = Koala::Facebook::API.new(signed_request["oauth_token"])
      graph.delete_object "#{request_id}_#{signed_request["user_id"]}"
    end

    def schedule_worker(method)
      Giveaway.to_start.reject(&:cannot_schedule?).each(&:publish) if method == "publish"
      Giveaway.to_end.reject(&:cannot_schedule?).each(&:unpublish) if method == "unpublish"
    end

    def orphans
      Giveaway.active.select(&:needs_subscription?)
    end

    def orphans_worker
      Giveaway.orphans.each(&:unpublish)
    end

    def uniques_worker(options = {})
      @giveaway = Giveaway.find_by_id(options[:giveaway_id])
      @giveaway.uniques += 1
      to_bool(options[:is_fan]) ? (@giveaway.fan_uniques += 1) : (@giveaway.non_fan_uniques += 1)
      (@giveaway.viral_uniques += 1) if to_bool(options[:is_viral])
      @giveaway.save
    end
  end

  def tab_attrs
    OpenStruct.new({
      id: id,
      title: title,
      prize: prize,
      description: description,
      description_text: ActionView::Base.full_sanitizer.sanitize(description),
      giveaway_url: giveaway_url,
      enter_url: Rails.application.routes.url_helpers.enter_url(self, host: SG_DOMAIN),
      image_url: self.image.tab.url.gsub("http://", "https://"),
      feed_image_url: self.feed_image.url.gsub("http://", "https://"),
      dominant_color: dominant_color_image,
      dominant_color_lightness: dominant_color_image_lightness,
      bonus_value: bonus_value,
      terms_text: terms_text,
      terms_link: terms_link,
      autoshow_share: autoshow_share_dialog,
      auth_required: email_required
    })
  end

  def shortlinks
    entries.pluck(:shortlink)
  end

  def shortlink_views
    bitly_client.clicks(shortlink).global_clicks
  end

  def viral_facebook_views
    viral_views - viral_shortlink_views
  end

  def viral_shortlink_views
    total_clicks = 0
    shortlinks.each_slice(15).with_index do |links, index|
      begin
        sleep 10 unless index == 0
        total_clicks += bitly_client.clicks(links).map(&:global_clicks).inject('+')
      rescue
        sleep 60
      end
    end
    total_clicks
  end

  def shortlink_referrers
    referrers = shortlinks.map.with_index do |link, index|
      begin
        sleep 10 unless index == 0 || index % 15 != 0
        ref = bitly_client.referrers(link).referrers.pop rescue nil
        { ref.referrer => ref.clicks } rescue nil
      rescue
        sleep 60
      end
    end
    referrers.compact.flatten
  end

  def shortlink_shares
    shares = shortlinks.map.with_index do |link, index|
      begin
        sleep 10 unless index == 0 || index % 15 != 0
        share = bitly_client.shares(link).shares.pop rescue nil
        { share.share_type => share.shares } rescue nil
      rescue
        sleep 60
      end
    end
    shares.compact.flatten
  end

  def dominant_color_image_lightness
    rgb = dominant_color_image.last(6).scan(/../).map { |color| color.to_i(16) }
    color = Sass::Script::Color.new(rgb)
    color.lightness > 50 ? 'light' : 'dark'
  end

  private

  def terms_url_link
    "<a href='#{terms_url}' class='terms-link terms-url' target='_blank'>Official Terms and Conditions</a>".html_safe
  end

  def terms_text_link
    "<a href='#' class='terms-link terms-text'>Official Terms and Conditions</a>".html_safe
  end

  def terms_present
    if terms_url.blank? && terms_text.blank?
      errors.add(:terms_url, "Must provide either Terms URL or Terms Text.")
      errors.add(:terms_text, "Must provide either Terms URL or Terms Text.")
    end
  end

  def analytics_audit
    Audit.new(
      was: { analytics: analytics_was },
      is: { analytics: analytics }
    )
  end
end
