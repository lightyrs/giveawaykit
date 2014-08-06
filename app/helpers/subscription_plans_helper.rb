module SubscriptionPlansHelper

  def stripe_button(plan)
    haml_tag :script, class: 'stripe-button', "data-amount" => "#{plan.price_in_cents_per_cycle}", "data-name" => "Giveaway Kit", "data-description" => "#{plan.name}", "data-label" => price_label(plan), "data-key" => Rails.configuration.stripe.publishable_key, :src => "https://checkout.stripe.com/checkout.js"
  end

  def panel_wrapper_class(plan)
    if plan.is_single_page_plan?
      'fadeInLeftBig'
    elsif plan.is_single_page_pro_plan?
      'fadeInUp'
    elsif plan.is_multi_page_pro_plan?
      'fadeInRightBig'
    end
  end

  def panel_class(plan, options = {})
    class_string = options[:is_current_plan] ? "current-subscription" : ""
    if plan.is_single_page_pro_plan?
      class_string += " b-primary"
    else
      class_string += " b-light m-t"
    end
    class_string
  end

  def panel_heading_class(plan)
    if plan.is_single_page_plan?
      'bg-white b-light'
    elsif plan.is_single_page_pro_plan?
      'bg-primary'
    elsif plan.is_multi_page_pro_plan?
      'bg-white b-light'
    end
  end

  def radio_container_class(auto_select, is_exact_current_plan)
    class_string = auto_select ? 'default' : 'resetable'
    class_string += ' fake-check' if is_exact_current_plan
    class_string
  end

  def price_label(plan)
    if plan.is_single_page_plan?
      "<span class='plan-price text-danger font-bold h1'>#{basic_price_string(plan)}</span> / month".html_safe
    elsif plan.is_single_page_pro_plan?
      "<div class='padder-v'><span class='plan-price text-danger font-bold h1'>#{basic_price_string(plan)}</span> / month</div>".html_safe
    elsif plan.is_multi_page_pro_plan?
      "<span class='plan-price text-danger font-bold h1'>#{basic_price_string(plan)}</span> / month".html_safe
    end
  end

  def basic_price_string(plan)
    plan.price.split('.00')[0]
  end

  def basic_plan_name_string(plan)
    if plan.is_single_page_plan?
      "Single Page"
    elsif plan.is_single_page_pro_plan?
      "Single Page <strong>Pro</strong>".html_safe
    elsif plan.is_multi_page_pro_plan?
      "Multi Page <strong>Pro</strong>".html_safe
    end
  end

  def basic_plan_tagline(plan)
    if plan.is_single_page_plan?
      "the essentials"
    elsif plan.is_single_page_pro_plan?
      "the good stuff"
    elsif plan.is_multi_page_pro_plan?
      "for the power user"
    end
  end

  def page_count_string(plan)
    plan.is_single_page? ? 'One Facebook Page' : 'Unlimited Facebook Pages'
  end

  def giveaway_count_string(plan)
    plan.is_free_trial? ? 'One Giveaway' : 'Unlimited Giveaways'
  end

  def analytics_string(plan)
    str = plan.name.include?("Pro") ? 'Advanced Analytics' : 'Basic Analytics'
    str.html_safe
  end

  def schedule_string(plan)
    str = plan.name.include?("Pro") ? 'Scheduled Giveaways' : '<strike>Scheduled Giveaways</strike>'
    str.html_safe
  end

  def viral_referrals_string(plan)
    str = plan.name.include?("Pro") ? 'Viral Referral Tracking' : '<strike>Viral Referral Tracking</strike>'
    str.html_safe
  end

  def shortlink_string(plan)
    str = plan.name.include?("Pro") ? 'Giveaway Shortlink' : '<strike>Giveaway Shortlink</strike>'
    str.html_safe
  end

  def white_label_string(plan)
    str = plan.name.include?("Pro") ? 'White-label' : '<strike>White-label</strike>'
    str.html_safe
  end

  def subscription_message(sub_object)
    if sub_object.has_free_trial_remaining?
      free_trial_message(sub_object)
    elsif sub_object.has_active_subscription?
      active_subscription_message(sub_object)
    elsif sub_object.has_inactive_subscription?
      inactive_subscription_message(sub_object)
    else
      no_subscription_message(sub_object)
    end
  end

  def plan_string(sub_object)
    ps = if sub_object.subscription_plan.is_single_page?
      "<strong>#{sub_object.name}</strong> is subscribed to the <strong>#{sub_object.subscription_plan_name}</strong> plan for <strong>#{sub_object.subscription.facebook_pages.first.name}</strong>."
    else
      "<strong>#{sub_object.name}</strong> is subscribed to the <strong>#{sub_object.subscription_plan_name}</strong> plan."
    end
    if sub_object.subscription.cancellation_pending?
      "#{ps}<br /><br /><i class='warning icon'></i>Your subscription will be <strong>cancelled</strong> on #{sub_object.subscription.activate_next_after}."
    elsif sub_object.subscription.downgrade_pending?
      "#{ps}<br /><br /><i class='warning icon'></i>Your subscription will be <strong>downgraded</strong> to <strong>#{sub_object.subscription.next_plan.name}</strong> for <strong>#{sub_object.subscription.next_page.name}</strong> on #{sub_object.subscription.activate_next_after}."
    else
      "#{ps}<br /><br /><i class='refresh icon'></i>Your subscription will be <strong>renewed</strong> on <strong>#{sub_object.subscription.current_period_end}</strong>."
    end
  end

  def active_subscription_message(sub_object)
    if sub_object.is_a? FacebookPage
      "<strong>#{sub_object.name}</strong> is subscribed to the <strong>#{sub_object.subscription_plan_name}</strong> plan. Go ahead and start the giveaway when you're ready. Good luck and please don't hesitate to contact us for any help or advice. Thank you for using <strong>Giveaway Kit</strong>.<br /><br />When you click <strong>Next</strong>, your giveaway will be published to your page.".html_safe
    elsif sub_object.is_a? User
      "#{plan_string(sub_object)}<br /><br /><i class='info icon'></i>You may update your plan.<br /><ul><li><strong>Upgrades</strong> will take effect immediately. You will receive credit for unused time on your old plan.</li><li><strong>Downgrades</strong> will take effect at the end of the billing cycle.</li><li><strong>Cancellations</strong> will take effect at the end of the billing cycle. Your subscription will not be renewed.</li><li><strong>Single Page Plans</strong> will update the subscribed page immediately, regardless of when the next plan is set to take effect.</li></ul> Thank you for using <strong>Giveaway Kit</strong>.".html_safe
    end
  end

  def inactive_subscription_message(sub_object)
    if sub_object.is_a? FacebookPage
      "<strong>#{sub_object.name}</strong> is subscribed to the #{sub_object.subscription_plan_name} plan, however, the plan has been deactivated due to outdated billing information. Please correct your billing information and then start the giveaway when you're ready. Good luck and please don't hesitate to contact us for any help or advice. Thank you for using <strong>Giveaway Kit</strong>.".html_safe
    elsif sub_object.is_a? User
      "<strong>#{sub_object.name}</strong> is subscribed to the #{sub_object.subscription_plan_name} plan, however, the plan has been deactivated due to outdated billing information. Please correct your billing information and don't hesitate to contact us for any help or advice. Thank you for using <strong>Giveaway Kit</strong>.".html_safe
    end
  end

  def free_trial_message(sub_object)
    "Since this is the first giveaway for <strong>#{sub_object.name}</strong>, it's on the house &mdash; free with no strings attached. Go ahead and start the giveaway when you're ready. Good luck and please don't hesitate to contact us for any help or advice. Thank you for using <strong>Giveaway Kit</strong>.<br /><br />When you click <strong>Next</strong>, your giveaway will be published to your page.".html_safe
  end

  def no_subscription_message(sub_object)
    if sub_object.is_a? FacebookPage
      "<strong>#{sub_object.name}</strong> is not currently subscribed to any plan. Please choose the plan that is right for you and then start the giveaway when you're ready. Good luck and please don't hesitate to contact us for any help or advice. Thank you for using <strong>Giveaway Kit</strong>.".html_safe
    elsif sub_object.is_a? User
      "<strong>#{sub_object.name}</strong> is not currently subscribed to any plan. Please choose the plan that is right for you and don't hesitate to contact us for any help or advice. Thank you for using <strong>Giveaway Kit</strong>.".html_safe
    end
  end

  def no_subscription_schedule_message(sub_object)
    "<strong>#{sub_object.name}</strong> is not currently subscribed to any plan. In order to schedule a giveaway to start or end automatically, a Pro subscription is required. Please choose the plan that is right for you and then we will automatically publish the giveaway at the chosen date and time. If you decide not to choose a plan right now, we will save your giveaway but ignore the scheduling information so that you can come back to it in the future. Good luck and please don't hesitate to contact us for any help or advice. Thank you for using <strong>Giveaway Kit</strong>.".html_safe
  end
end
