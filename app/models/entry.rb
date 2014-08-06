# -*- encoding : utf-8 -*-
class Entry < ActiveRecord::Base

  attr_accessible :email, :has_liked, :has_shared, :name, :fb_url,
                  :datetime_entered, :wall_post_count, :entry_count,
                  :request_count, :convert_count, :status, :uid, :ref_ids,
                  :referrer_id, :is_viral, :shortlink, :bonus_entries

  attr_accessor :referrer_id

  has_many :audits, as: :auditable

  belongs_to :giveaway
  has_many :likes

  validates :email, presence: true, uniqueness: { scope: :giveaway_id }

  serialize :ref_ids, Array

  before_validation(on: :update) do
    self.has_shared = true if total_shares > 0
    self.bonus_entries = calculate_bonus_entries
  end

  after_commit :create_shortlink, unless: -> { self.shortlink.present? }

  scope :shared, -> { where("has_shared IS TRUE") }

  def as_json(options = {})
    { id: id,
      shortlink: shortlink,
      wall_post_count: wall_post_count,
      request_count: request_count }
  end

  def process(*args)
    options = args.extract_options!

    @cookie = options[:cookie]
    @referrer_id = options[:referrer_id].blank? ? nil : options[:referrer_id].to_i
    @auth_user = options[:access_token].present? && options[:access_token] != "auth_disabled"

    if @auth_user
      graph = Koala::Facebook::API.new(options[:access_token])
      profile = graph.get_object("me")
      @existing_entry = Entry.find_by_uid_and_giveaway_id(profile["id"], options[:giveaway_id])
    else
      @existing_entry = Entry.find_by_email_and_giveaway_id(options[:email], options[:giveaway_id])
    end

    unless @existing_entry

      self.entry_count = 1

      if @auth_user
        self.uid = profile["id"]
        self.name = profile["name"]
        self.email = profile["email"]
        self.fb_url = profile["link"]
      else
        self.email = options[:email]
      end

      self.datetime_entered = DateTime.now

      if @cookie.belongs_to_user && @referrer_id
        self.ref_ids = @cookie.ref_ids.push(@referrer_id).uniq
      else
        puts "@referrer_id: #{@referrer_id}".green
        self.ref_ids = [@referrer_id].compact
      end

      self.ref_ids = self.ref_ids.reject { |id| id == 0 }

      self.is_viral = self.ref_ids.any?

      status = self.determine_status(options[:has_liked], options[:access_token]).has_liked

      EntryConversionWorker.perform_async(status, ref_ids, @cookie) if status && ref_ids.any?

      @entry = self
    end

    @entry ||= @existing_entry
  end

  def determine_status(has_liked, access_token=nil)
    if has_liked == "true"
      self.has_liked = true
      self.status = "complete"
    elsif access_token == "auth_disabled"
      self.has_liked = true
      self.status = "complete"
    else
      if like_status(access_token) == false
        self.has_liked = false
        self.status = "incomplete"
      else
        self.has_liked = true
        self.status = "complete"
      end
    end

    self
  end

  def like_status(access_token)
    rest = Koala::Facebook::API.new(access_token)
    status = rest.fql_query("SELECT uid FROM page_fan WHERE uid=#{uid} AND page_id=#{giveaway.page_pid}")
    status[0].nil? ? false : true
  end

  def new_fan?
    likes.any?
  end

  def total_shares
    wall_post_count + request_count
  end

  def calculate_bonus_entries
    ( (giveaway.bonus_value.to_i * convert_count) + (entry_count - 1) ) rescue 0
  end

  def referral_url
    "#{giveaway.giveaway_url}&app_data=ref_#{id}"
  end

  def bitly_client
    Bitly.use_api_version_3
    Bitly.new(BITLY_USERNAME, BITLY_KEY)
  end

  def self.conversion_worker(has_liked, ref_ids, giveaway_cookie)
    if has_liked
      ref_ids.uniq.each do |ref|
        if @ref = Entry.find_by_id_and_giveaway_id(ref, giveaway_cookie['giveaway_id'])
          @ref.convert_count += 1
          @ref.save
        end
      end
    end
  end

  def create_shortlink
    link = bitly_client.shorten(referral_url).short_url rescue referral_url
    self.update_attributes(shortlink: link)
  end
end
