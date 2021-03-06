class ErrorsController < ApplicationController
  include Gaffe::Errors

  respond_to :html

  skip_before_filter :user_pages, :unless => :signed_in?
  skip_before_filter :init_js_vars

  skip_before_render :assign_js_vars

  skip_after_filter :flash_to_headers

  layout 'error'

  def show
    GabbaClient.new.event(category: "Errors", action: "Error#show", label: @exception.class, id: @exception.message.first(250))
  end
end