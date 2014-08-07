# -*- encoding : utf-8 -*-
class FacebookController < ApplicationController

  before_filter :allow_iframe_requests

  def allow_iframe_requests
    response.headers.delete('X-Frame-Options')
  end

  def after_tab_actions
    register_impression
    set_giveaway_cookie
  end

  def parse_signed_request
    oauth = Koala::Facebook::OAuth.new(FB_APP_ID, FB_APP_SECRET)
    @signed_request = oauth.parse_signed_request(params[:signed_request])
  end

  def log_unique_visit
    if last_giveaway_cookie.nil? || @giveaway_cookie.does_not_belong_to_user
      GiveawayUniquesWorker.perform_async(@giveaway.id, bool_to_i(!!@giveaway_hash.has_liked), bool_to_i(@giveaway_hash.referrer_id.is_a?(String)))
    end
  end

  def update_giveaway_cookie
    @giveaway_cookie = GiveawayCookie.new(last_giveaway_cookie)
    @giveaway_cookie.giveaway_id = @giveaway.id
    @giveaway_cookie.update_cookie(@giveaway_hash)
  end

  def count_uncounted_like
    if @giveaway_cookie.uncounted_like && Like.create_from_cookie(@giveaway_cookie)
      @giveaway_cookie.like_counted = true
    end
  end

  def register_impression
    message = @signed_request['user_id'] ? "fb_uid: #{@signed_request['user_id']}" : ""
    message += ", ref_id: #{@giveaway_hash.referrer_id}" if @giveaway_hash.referrer_id.is_a?(String)

    impressionist @giveaway, message: message, unique: [:session_hash]
  end

  def last_giveaway_cookie
    cookies.encrypted[Giveaway.cookie_key(@giveaway.id)] rescue nil
  end

  def set_giveaway_cookie
    if @giveaway_hash && @giveaway_hash.giveaway
      key = Giveaway.cookie_key(@giveaway_hash.giveaway.id)
      cookies.encrypted[key] = @giveaway_cookie.to_json
    end
  end
end
