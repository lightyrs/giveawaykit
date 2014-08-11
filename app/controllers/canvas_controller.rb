# -*- encoding : utf-8 -*-
require 'net/http'
require 'open-uri'

class CanvasController < ApplicationController

  before_filter :giveaway_from_request, only: [:index]

  skip_before_filter :verify_authenticity_token

  def index
    if @giveaway_found
      render 'giveaways/apprequest', layout: false
      GabbaClient.new.event(category: "Canvas", action: "Canvas#index", label: @giveaway.title, value: JSON.parse(@request['data'])['referrer_id'].to_i)
    elsif params['request_ids']
      redirect_to 'http://facebook.com'
    else
      redirect_to root_path
    end
  end

  def edit
    if @page = FacebookPage.find_by_pid(params['fb_page_id'])
      redirect_to active_facebook_page_giveaways_path(@page)
    else
      redirect_to root_path
    end
  end

  private

  def giveaway_from_request
    begin
      if params['request_ids']

        @request_ids = [params['request_ids'].split('%2C').split(',')].compact.flatten.pop.split(',')

        @oauth = Koala::Facebook::OAuth.new(FB_APP_ID, FB_APP_SECRET)
        @graph = Koala::Facebook::API.new(@oauth.get_app_access_token)

        if @request = select_request
          @giveaway = Giveaway.select('id, title, giveaway_url').find_by_id(JSON.parse(@request['data'])['giveaway_id'])
          @app_data = "ref_#{JSON.parse(@request['data'])['referrer_id']}"

          if @giveaway
            FbAppRequestWorker.perform_async(@request['id'], params['signed_request'])
            @giveaway_found = true
          end
        end
      end
    rescue StandardError
      @giveaway_found = false
    end
  end

  def select_request
    @request_ids.map do |rid|
      @graph.get_object(@request_ids.pop.to_i) rescue nil
    end.compact.pop
  rescue StandardError
    false
  end
end
