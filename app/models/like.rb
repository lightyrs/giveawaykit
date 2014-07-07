class Like < ActiveRecord::Base

  attr_accessible :entry_id, :giveaway_id, :ref_ids,
                  :fb_uid, :from_entry

  belongs_to :giveaway
  belongs_to :entry

  serialize :ref_ids, Array

  validates :fb_uid, uniqueness: { scope: :giveaway_id }, allow_blank: true, allow_nil: true
  validates :entry_id, uniqueness: { scope: :giveaway_id }, allow_blank: true, allow_nil: true

  before_save :assess_virality

  def self.create_from_cookie(giveaway_cookie)
    Like.create(
      from_entry: giveaway_cookie.entry_id.present?,
      fb_uid: giveaway_cookie.uid,
      entry_id: giveaway_cookie.entry_id,
      ref_ids: giveaway_cookie.ref_ids,
      giveaway_id: giveaway_cookie.giveaway_id
    )
  end

  private

  def assess_virality
    self.is_viral = true if self.ref_ids.any?
  end
end
