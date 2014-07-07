class SubscriptionsController < ApplicationController

  respond_to :html

  def create
    begin
      if @subscription = update_sg_subscription
        session[:just_subscribed] = true
        flash[:info] = { title: t('flash.subscriptions.subscribed.title'), content: t('flash.subscriptions.subscribed.content', plan: current_user.subscription_plan_name).html_safe }
      else
        flash[:error] = { title: t('flash.subscriptions.unknown_error.subscribe.title'), content: t('flash.subscriptions.unknown_error.subscribe.content') }
      end
      redirect_to redirect_path
    rescue Stripe::CardError => error
      flash[:error] = { title: t('flash.subscriptions.unknown_error.subscribe.title'), content: t('flash.subscriptions.unknown_error.subscribe.content') }
      redirect_to redirect_path
    end
  end

  def destroy
    begin
      if @subscription = cancel_sg_subscription
        flash[:info] = { title: t('flash.subscriptions.unsubscribed.title'), content: t('flash.subscriptions.unsubscribed.content').html_safe }
      else
        flash[:error] = { title: t('flash.subscriptions.unknown_error.unsubscribe.title'), content: t('flash.subscriptions.unknown_error.unsubscribe.content') }
      end
      redirect_to user_subscription_plans_path(current_user)
    rescue Stripe::CardError => error
      respond_with error
    end
  end

  private

  def update_sg_subscription
    Subscription.create_or_update(
      user_id: current_user.id,
      subscription_plan_id: params[:subscription_plan_id],
      stripe_token: params[:stripe_token],
      facebook_page_ids: facebook_page_ids
    )
  end

  def cancel_sg_subscription
    Subscription.cancel(user_id: current_user.id)
  end

  def facebook_page_ids
    params[:facebook_page_ids] || current_user.facebook_page_ids
  end

  def redirect_path
    if session[:return_to]
      session.delete(:return_to)
    else
      user_subscription_plans_path(current_user)
    end
  end
end
