class SubscriptionPlansController < ApplicationController

  def index
    if request.post? && params[:starting]
      session[:proposed_end_date] = params[:end_date]
      session[:proposed_tab_name] = params[:custom_tab_name]
      session[:return_to] ||= request.referer
      head :ok
    else
      @scheduling = true if params[:scheduling]
      @page = FacebookPage.find(params[:facebook_page_id]) if params[:facebook_page_id]
      @subscription_plans = SubscriptionPlan.visible
    end
  end
end
