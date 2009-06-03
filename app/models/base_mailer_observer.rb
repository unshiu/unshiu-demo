class BaseMailerObserver < ActiveRecord::Observer
  def after_create(base_mailer)
    BaseMailerNotifier.deliver_signup_notification(base_mailer)
  end

  def after_save(base_mailer)
    BaseMailerNotifier.deliver_activation(base_mailer) if base_mailer.recently_activated?
  end
end