class LikesController < ApplicationController

  before_filter :assign_giveaway_cookie, only: [:create]

  after_filter :set_giveaway_cookie, only: [:create]

  def create
    if @like = Like.create_from_cookie(@giveaway_cookie)
      @giveaway_cookie.is_fan = true
      @giveaway_cookie.like_counted = true
      render json: @like.id, status: :ok
      GabbaClient.new.event(category: "Likes", action: "Like#create", label: @like.giveaway.title, id: @like.id)
    else
      head :not_acceptable
    end
  end

  private

  def assign_giveaway_cookie
    @giveaway_cookie = GiveawayCookie.new( cookies.signed[Giveaway.cookie_key(params[:like][:giveaway_id])] )
  end

  def set_giveaway_cookie
    key = Giveaway.cookie_key(params[:like][:giveaway_id])
    cookies.signed[key] = @giveaway_cookie.to_json
  end
end
