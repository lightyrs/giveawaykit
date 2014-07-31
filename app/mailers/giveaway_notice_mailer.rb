require 'haml'
require 'haml/template/plugin'
require 'mail'

class GiveawayNoticeMailer < ActionMailer::Base

  def start(user, giveaway)
    @giveaway = giveaway
    @user_first_name = user.name.split(" ")[0] rescue user.name
    mail subject: 'Your Giveaway Has Begun',
         to: formatted_email(user.identities.pop.email, @user_first_name),
         from: formatted_email("support@simplegiveaways.com", "Giveaway Kit"),
         template_path: 'mailers/giveaway_notice_mailer',
         template_name: 'start'
  end

  def end(user, giveaway)
    @giveaway = giveaway
    @user_first_name = user.name.split(" ")[0] rescue user.name
    mail subject: 'Your Giveaway Has Ended',
         to: formatted_email(user.identities.pop.email, @user_first_name),
         from: formatted_email("support@simplegiveaways.com", "Giveaway Kit"),
         template_path: 'mailers/giveaway_notice_mailer',
         template_name: 'end'
  end

  private

  def formatted_email(email, name)
    address = Mail::Address.new email
    address.display_name = name
    address.format
  end
end
