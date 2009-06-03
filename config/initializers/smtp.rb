require File.join(File.dirname(__FILE__), '../../lib/app_resources.rb')

ActionMailer::Base.smtp_settings = {
  :address => AppResources[:init][:action_mailer_setting_address],
  :port => AppResources[:init][:action_mailer_setting_port],
  :domain => AppResources[:init][:action_mailer_setting_domain],
}
