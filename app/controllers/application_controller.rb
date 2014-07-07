# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base

  helper_method :xeditable?

  before_filter :user_pages, :if => :signed_in?
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

  def user_pages
    @user_pages ||= current_user.facebook_pages.select([:id, :pid, :name]) rescue nil
  end

  def current_user
    @current_user ||= (User.find_by_id(session[:user_id]) ||
      Identity.find_by_uid(cookies.encrypted[:_sg_uid]).user if cookies.encrypted[:_sg_uid])
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
end
