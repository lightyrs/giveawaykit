# -*- encoding : utf-8 -*-
class GiveawaysController < FacebookController

  include PublicUtils

  respond_to :html, :json

  load_and_authorize_resource :facebook_page, except: [:tab, :enter]
  load_and_authorize_resource :giveaway, through: :facebook_page, except: [:tab, :enter]

  before_filter :assign_page, only: [:show, :active, :pending, :completed, :new, :create, :clone, :destroy, :start_modal]
  before_filter :assign_giveaway, only: [:show, :edit, :update, :destroy, :start, :end, :export_entries, :clone, :destroy, :start_modal]
  before_filter :sanitize_params, only: [:create, :update]
  before_filter :parse_signed_request, only: [:tab], if: -> { params[:signed_request] }

  after_filter :after_tab_actions, only: [:tab]

  def index
    @giveaways = Giveaway.visible.paginate(page: params[:page])
  end

  def active
    @giveaway = @page.active_giveaway
    @entries = @giveaway.entries.sort_by(&:created_at).reverse.first(50) rescue []
    @flot = flot_hash
  end

  def pending
    @giveaways = @page.giveaways.visible.pending.paginate(page: params[:page])
  end

  def completed
    @giveaways = (@page.giveaways.visible.completed | @page.giveaways.to_end).sort_by(&:end_date).reverse.paginate(page: params[:page])
  end

  def show
    if request.xhr?
      render partial: 'giveaways/details', locals: { giveaway: @giveaway, page: @page }, status: :ok
    else
      if @giveaway.active?
        flash.keep
        redirect_to active_facebook_page_giveaways_path(@page)
      elsif @giveaway.completed?
        @entries = @giveaway.entries.sort_by(&:created_at).reverse.first(50)
        @flot = flot_hash
      end
    end
  end

  def new
    @giveaway = @page.giveaways.build
  end

  def edit
    @page = @giveaway.facebook_page
    if @giveaway.completed?
      redirect_to facebook_page_path(@page)
    end
  end

  def create
    @giveaway = @page.giveaways.build(@giveaway_params)
    @giveaway.giveaway_url = "#{@page.url}?sk=app_#{FB_APP_ID}&ref=ts"

    if @giveaway.save
      ga_event("Giveaways", "Giveaway#create", @giveaway.title, @giveaway.id)

      flash[:success] = { title: t('flash.giveaways.create.success.title'), content: t('flash.giveaways.create.success.content', giveaway: @giveaway.title).html_safe }

      if (@giveaway.start_date || @giveaway.end_date) && @page.cannot_schedule?
        flash[:success][:content] += t('flash.giveaways.create.success.cannot_schedule', page: @page.name, link: "#{facebook_page_subscription_plans_path(@page)}").html_safe
      end

      redirect_to pending_facebook_page_giveaways_path(@page)
    else
      flash.now[:error] = { title: t('flash.giveaways.create.error.title'), content: t('flash.giveaways.create.error.content', errors: @giveaway.errors_list).html_safe }
      render :new
    end
  end

  def update
    @page = @giveaway.facebook_page

    @schedule_change = detect_schedule_change

    if @giveaway.update_attributes(@giveaway_params)
      flash[:info] = { title: t('flash.giveaways.update.success.title'), content: t('flash.giveaways.update.success.content', giveaway: @giveaway.title).html_safe }

      if @schedule_change
        flash[:info][:content] += t('flash.giveaways.update.success.cannot_schedule', page: @page.name, link: "#{facebook_page_subscription_plans_path(@page)}").html_safe
      end

      respond_to do |format|
        format.html { redirect_to facebook_page_giveaway_url(@page, @giveaway) }
        format.json { render json: @giveaway }
      end

      @giveaway.update_tab if @giveaway.active?
    else
      flash.now[:error] = { title: t('flash.giveaways.update.error.title'), content: t('flash.giveaways.update.error.content', errors: @giveaway.errors_list).html_safe }

      respond_to do |format|
        format.html { render :edit }
        format.json {
          render json: { giveaway: @giveaway, errors: @giveaway.errors.full_messages }
        }
      end
    end
  end

  def destroy
    if @giveaway.hide
      flash[:info] = { title: t('flash.giveaways.destroy.success.title'), content: t('flash.giveaways.destroy.success.content', giveaway: @giveaway.title) }
      redirect_to facebook_page_url(@giveaway.facebook_page)
    else
      flash[:error] = { title: t('flash.giveaways.destroy.error.title'), content: t('flash.giveaways.destroy.error.content', errors: @giveaway.errors_list).html_safe }
      redirect_to facebook_page_url(@giveaway.facebook_page)
    end
  end

  def start_modal
    render partial: 'giveaways/pending/start', locals: { giveaway: @giveaway }
  end

  def start
    session.delete(:proposed_end_date)
    session.delete(:proposed_tab_name)

    if @giveaway.publish(params[:giveaway])
      flash[:success] = { title: t('flash.giveaways.start.success.title', giveaway: @giveaway.title), content: t('flash.giveaways.start.success.content', giveaway: @giveaway.title, giveaway_url: @giveaway.giveaway_url).html_safe }
      redirect_to active_facebook_page_giveaways_url(@giveaway.facebook_page)
    else
      flash[:error] = { title: t('flash.giveaways.start.error.title'), content: t('flash.giveaways.start.error.content', giveaway: @giveaway.title, errors: @giveaway.errors_list).html_safe }
      redirect_to facebook_page_giveaway_url(@giveaway.facebook_page, @giveaway)
    end
  end

  def end
    if @giveaway.unpublish
      flash[:info] = { title: t('flash.giveaways.end.success.title', giveaway: @giveaway.title), content: t('flash.giveaways.end.success.content', giveaway: @giveaway.title) }
      redirect_to completed_facebook_page_giveaways_path(@giveaway.facebook_page)
    else
      flash[:error] = { title: t('flash.giveaways.end.error.title'), content: t('flash.giveaways.end.error.content', giveaway: @giveaway.title, errors: @giveaway.errors_list).html_safe }
      redirect_to facebook_page_giveaway_url(@giveaway.facebook_page, @giveaway)
    end
  end

  def tab
    if @signed_request
      @giveaway_hash = Giveaway.tab(@signed_request) rescue nil

      if @giveaway_hash.nil? || @giveaway_hash.giveaway.nil?
        redirect_to root_path
      else
        @giveaway = Giveaway.find_by_id(@giveaway_hash.giveaway.id)

        update_giveaway_cookie
        count_uncounted_like
        log_unique_visit

        ga_event('Giveaways', 'Giveaway#tab', @giveaway.title, @giveaway.id)
        render layout: 'tab'
      end
    else
      redirect_to root_path
    end
  end

  def enter
    @giveaway = Giveaway.find(params[:giveaway_id])
    @page = @giveaway.facebook_page
    if @giveaway.active?
      ga_event("Giveaways", "Giveaway#enter", @giveaway.title, @giveaway.id)
      render layout: "enter"
    else
      redirect_to root_path
    end
  end

  def check_schedule
    page = FacebookPage.find(params[:facebook_page_id])
    giveaway = params[:giveaway_id].present? ? Giveaway.find(params[:giveaway_id]) : page.giveaways.build

    if params[:date_type] == 'end'
      giveaway.end_date = params[:date]
      conflicts = giveaway.end_date_conflicts
    else
      giveaway.start_date = params[:date]
      conflicts = giveaway.start_date_conflicts
    end

    if conflicts
      render json: conflicts
    else
      head :unprocessable_entity
    end
  end

  def export_entries
    return false unless send_data(@giveaway.csv, type: 'text/csv', filename: 'entries_export.csv')
    ga_event("Giveaways", "Giveaway#export_entries", @giveaway.title, @giveaway.id)
  end

  def clone
    @clone = @giveaway.dup
    @clone.title = "Copy of #{@clone.title} (#{Time.now.to_s(:short)})"
    @clone.start_date = nil
    @clone.end_date = nil
    @clone.analytics = nil
    @clone.uniques = 0
    @clone.image = @giveaway.image
    @clone.feed_image = @giveaway.feed_image

    if @clone
      @giveaway = @clone
      flash.now[:info] = { title: t('flash.giveaways.clone.success.title'), content: t('flash.giveaways.clone.success.content', giveaway: @giveaway.title) }
      render :edit
    else
      flash[:error] = { title: t('flash.giveaways.clone.error.title'), content: t('flash.giveaways.clone.error.content', giveaway: @giveaway.title, errors: @giveaway.errors_list).html_safe }
      redirect_to facebook_page_giveaway_path(@page, @giveaway)
    end
  end

  private

  def assign_page
    @page = if @giveaway
      @giveaway.facebook_page
    elsif params[:facebook_page_id]
      FacebookPage.find(params[:facebook_page_id])
    elsif params[:giveaway_id]
      @giveaway ||= Giveaway.find(params[:giveaway_id])
      @giveaway.facebook_page
    end
  end

  def assign_giveaway
    @giveaway = if params[:giveaway_id]
      Giveaway.find(params[:giveaway_id])
    else
      Giveaway.find(params[:id])
    end
  end

  def sanitize_params
    @giveaway_params = {}
    params[:giveaway].each do |key, value|
      value = Sanitize.clean(value, Sanitize::Config::SG) if key == 'description'
      value = value.gsub(/<br>|<br\/>|<br \/>/, "\n") if value.is_a?(String)
      @giveaway_params["#{key}"] = value
    end
  end

  def flot_hash
    giveaways_graph = Graph::GiveawayGraph.new(@giveaway)
    { page_likes: giveaways_graph.page_likes,
      net_likes: giveaways_graph.net_likes,
      shares:    giveaways_graph.shares,
      entries:   giveaways_graph.entries,
      views:     giveaways_graph.views }
  rescue StandardError
    {}
  end

  def detect_schedule_change
    if @giveaway_params.keys.grep(/_date/).any? && @page.cannot_schedule?
      return false if (@giveaway_params['start_date'] && Time.zone.parse(@giveaway_params['start_date']) == @giveaway.start_date) || (@giveaway_params['end_date'] && Time.zone.parse(@giveaway_params['end_date']) == @giveaway.end_date)
      true
    end
  end
end

