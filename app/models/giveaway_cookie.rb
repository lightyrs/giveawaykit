class GiveawayCookie

  attr_accessor :uid, :giveaway_id, :ref_ids, :entry_id,
                :wasnt_fan, :is_fan, :like_counted

  def initialize(cookie=nil)
    @last_cookie = deserialize_cookie(cookie)
    @uid = @last_cookie["uid"]
    @entry_id = @last_cookie["entry_id"]
    @giveaway_id = @last_cookie["giveaway_id"]
    @ref_ids = @last_cookie["ref_ids"] ? @last_cookie["ref_ids"] : []
    @wasnt_fan ||= @last_cookie["wasnt_fan"]
    @is_fan ||= @last_cookie["is_fan"]
    @like_counted ||= @last_cookie["like_counted"] || false
  end

  def uncounted_like
    !!is_fan && !!wasnt_fan && !like_counted && belongs_to_user
  end

  def belongs_to_user
    uid == @last_cookie["uid"]
  end

  def does_not_belong_to_user
    !belongs_to_user
  end

  def update_cookie(giveaway_hash)
    self.giveaway_id = giveaway_hash.giveaway.id

    if giveaway_hash.referrer_id.present?
      self.ref_ids = ref_ids.push(giveaway_hash.referrer_id.to_i).uniq
    end

    if giveaway_hash.has_liked
      self.is_fan = true
    else
      self.wasnt_fan = true
      self.is_fan = false
    end

    self.uid = giveaway_hash.fb_uid
  end

  def as_json(options={})
    { uid: uid,
      entry_id: entry_id,
      giveaway_id: giveaway_id,
      ref_ids: ref_ids,
      wasnt_fan: wasnt_fan,
      is_fan: is_fan,
      like_counted: like_counted }
  end

  private

  def deserialize_cookie(cookie=nil)
    ActiveSupport::JSON.decode(cookie) rescue {}
  end
end
