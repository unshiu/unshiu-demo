require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/mlg/test/unit/mlg_mailer_test.rb'

class MlgMailerTest < ActiveSupport::TestCase
  include MlgMailerTestModule
  
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
    @expected.mime_version = '1.0'
  end
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
