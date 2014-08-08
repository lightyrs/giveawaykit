# -*- encoding : utf-8 -*-
module ApplicationHelper

  def inside_layout(layout, &block)
    layout = "layouts/#{layout}" unless layout =~ %r[\Alayouts/]
    content_for :layout, capture(&block)
    render template: layout
  end

  def current_host_url
    request.env['HTTP_HOST']
  end

  def active_nav_item(item, giveaway=nil)
    if giveaway.present? && giveaway.status
      giveaway.status.downcase == item.downcase ? "active" : ""
    else
      controller.action_name == "#{item}" ? "active" : ""
    end
  end

  def boolean_table_item(bool)
    bool ? '&#10004;'.html_safe : '&#10008;'.html_safe
  end

  def body_class
    "#{controller.controller_name} #{controller.controller_name}-#{controller.action_name}"
  end

  def current_action
    "#{controller.controller_name}/#{controller.action_name}"
  end

  def uid_class
    session['uid'] || cookies.signed[:_sg_uid]
  end

  def flash_class(level)
    case level
    when :notice
      "alert"
    when :success
      "alert alert-success"
    when :error
      "alert alert-error"
    when :alert
      "alert alert-error"
    else
      "alert alert-info"
    end
  end

  def datetime_mdy(datetime)
    datetime.strftime('%m/%d/%Y') rescue ""
  end

  def datetime_mdy_imp(datetime)
    datetime.strftime('%m/%d/%Y<br />%I:%M %p').html_safe rescue ""
  end

  def pretty_datetime(datetime)
    datetime.to_formatted_s
  end

  def bonus_entries_select
    (1..100).collect{ |i| i if i % 5 == 0 }.compact.unshift(0, 1)
  end

  def raw_escape(html)
    raw(CGI::escapeHTML(html))
  end
end
