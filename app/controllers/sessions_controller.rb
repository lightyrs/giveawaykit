# -*- encoding : utf-8 -*-
class SessionsController < ApplicationController

  skip_before_filter :verify_authenticity_token

  after_filter  :set_session_vars, only: [:create]

  def create
    auth = request.env['omniauth.auth']

    unless @identity = Identity.find_or_create_with_omniauth(auth)
      redirect_to root_url, alert: { title: t('flash.defaults.alert.unknown_error.title'), content: t('flash.defaults.alert.unknown_error.content').html_safe }
    end

    unless signed_in? || @identity.create_or_login_user(auth)
      flash[:alert] = { title: t('flash.defaults.alert.unknown_error.title'), content: t('flash.defaults.alert.unknown_error.content').html_safe }
    end

    render 'sessions/create', layout: false
  end

  def destroy
    self.current_user = nil
    session[:user_id] = nil
    if params[:fb] == "true"
      flash[:alert] = { title: t('flash.sessions.logout.facebook_session.title'), content: t('flash.sessions.logout.facebook_session.content').html_safe }
    else
      flash[:info] = { title: t('flash.sessions.logout.default.title'), content: t('flash.sessions.logout.default.content').html_safe }
    end
    cookies.delete :'_sg-just_logged_in'
    cookies.delete :_sg_uid
    redirect_to root_url
  end

  private

  def set_session_vars
    if @identity
      if @identity.process_login(DateTime.now, session['_csrf_token'])
        self.current_user = @identity.user
      end

      session['uid'] = @identity.uid
      cookies.signed[:_sg_uid] = { value: @identity.uid, expires: Time.zone.now + 7200 }
    end
  end
end
