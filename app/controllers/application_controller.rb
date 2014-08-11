# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base

  helper_method :xeditable?

  before_filter :user_pages, :if => :signed_in?
  before_filter :init_js_vars

  before_render :assign_js_vars

  after_filter :flash_to_headers

  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  def xeditable?(object = nil)
    true
  end

  protected

  def flash_to_headers
    if request.xhr? && flash_msg
      response.headers['X-Message'] = flash_message
      response.headers['X-Message-Type'] = flash_type
      response.headers['X-Message-Title'] = flash_title
      flash.discard
    end
  end

  def flash_msg
    flash.first.last rescue nil
  end

  def flash_message
    flash_msg.is_a?(Hash) ? flash_msg[:content] : flash_msg
  end

  def flash_type
    "#{flash.first.first}" rescue nil
  end

  def flash_title
    flash_msg.is_a?(Hash) ? flash_msg[:title] : nil
  end

  def init_js_vars
    if action_string == 'giveaways#tab'
      gon.paths = {}
      gon.currentGiveaway = {}
    elsif signed_in?
      gon.paths ||= {}
      gon.currentUser ||= {}
      gon.currentPage ||= {}
      gon.currentGiveaway ||= {}
    end
  end

  def assign_js_vars
    if action_string == 'giveaways#tab'
      assign_gon_tab_vars
    else
      assign_gon_page_vars if @page
      assign_gon_giveaway_vars if @giveaway
      assign_gon_user_vars if current_user && current_user.fb_uid
    end
  end

  def assign_gon_page_vars
    gon.currentPage[:id] = "#{@page.id}"
    gon.currentPage[:isSubscribed] = @page.has_active_subscription?
    gon.paths[:facebookPage] = facebook_page_path(@page)
    gon.paths[:giveaways] = facebook_page_giveaways_path(@page)
    gon.paths[:checkSchedule] = check_schedule_facebook_page_giveaways_path(@page)
    gon.paths[:subscriptionPlans] = facebook_page_subscription_plans_path(@page)
    gon.paths[:pageSubscribe] = facebook_page_subscribe_path(@page)
  end

  def assign_gon_tab_vars
    gon.currentGiveaway = @giveaway_hash.as_json
    gon.paths[:likes] = likes_path
    gon.paths[:giveawayEntries] = facebook_page_giveaway_entries_path(@giveaway_hash.current_page, @giveaway_hash.giveaway.id)
  end

  def assign_gon_giveaway_vars
    gon.currentGiveaway[:id] = "#{@giveaway.id}"
    gon.currentGiveaway[:status] = "#{@giveaway.status}"

    if @giveaway.persisted?
      gon.paths[:giveawayEntries] = facebook_page_giveaway_entries_path(@giveaway.facebook_page, @giveaway)
    end

    if session[:proposed_end_date]
      gon.currentGiveaway[:proposedEndDate] = "#{session[:proposed_end_date]}"
    end

    if session[:proposed_tab_name]
      gon.currentGiveaway[:proposedTabName] = "#{session[:proposed_tab_name]}"
    end
  end

  def assign_gon_user_vars
    gon.currentUser[:name] = "#{current_user.name}"
    gon.currentUser[:fbUID] = "#{current_user.fb_uid}"
    gon.currentUser[:email] = "#{current_user.email}"
    gon.paths[:userPages] = "#{facebook_pages_path}"
    gon.paths[:userSubscribe] = "#{user_subscribe_path(current_user)}"

    if session[:just_subscribed]
      gon.currentUser[:justSubscribed] = "#{session.delete(:just_subscribed)}"
    end
  end

  def user_pages
    @user_pages ||= current_user.facebook_pages.select([:id, :pid, :name]) rescue nil
  end

  def current_user
    @current_user ||= (User.find_by_id(session[:user_id]) ||
      Identity.find_by_uid(cookies.signed[:_sg_uid]).user if cookies.signed[:_sg_uid])
  rescue StandardError
    nil
  end

  def signed_in?
    !!current_user
  end

  helper_method :current_user, :signed_in?, :user_pages

  def current_user=(user)
    @current_user = user
    session[:user_id] = user.nil? ? user : user.id
  end

  def action_string
    "#{controller_name}##{action_name}"
  end
end
