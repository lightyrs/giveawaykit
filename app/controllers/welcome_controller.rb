# -*- encoding : utf-8 -*-
class WelcomeController < ApplicationController

  def index
    redirect_to dashboard_path if current_user
  end

  def terms
  end

  def privacy
  end

  def support
  end
end
