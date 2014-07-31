require 'haml'
require 'haml/template/plugin'
require 'mail'

class WelcomeNewUserMailer < ActionMailer::Base

  def welcome(recipient_identity)
    user_name = recipient_identity.user.name
    @user_first_name = user_name.split(" ")[0] rescue user_name
    mail subject: 'Welcome to Giveaway Kit',
         to: formatted_email(recipient_identity.email, @user_first_name),
         from: formatted_email("support@simplegiveaways.com", "Giveaway Kit"),
         template_path: 'mailers/welcome_new_user_mailer',
         template_name: 'welcome'
  end

  private

  def formatted_email(email, name)
    address = Mail::Address.new email
    address.display_name = name
    address.format
  end
end
