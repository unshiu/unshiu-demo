require File.dirname(__FILE__) + '/../test_helper'

module MlgMailerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include ActionMailer::Quoting
        fixtures :base_users
        fixtures :mlg_magazines
      end
    end
  end
  
  FIXTURES_PATH = File.dirname(__FILE__) + '/../../../../../test/fixtures'
  CHARSET = "utf-8"

  # メールマガジン送信処理
  def test_send_mail_magazine
    base_user = BaseUser.find(1)
    mlg_magazine = MlgMagazine.new
    mlg_magazine.id = 1
    mlg_magazine.title = 'たいとるー'
    mlg_magazine.body = 'ほんぶん'
    MlgMailer.deliver_mail_magazine(base_user, mlg_magazine)
  end
  
  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/mlg_mailer/#{action}.txt")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
