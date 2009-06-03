require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/functional/base_terms_controller_mobile_test.rb'

class BaseTermsControllerMobileTest < ActionController::TestCase
  include BaseTermsControllerMobileTestModule
  
  def setup
    @controller = BaseTermsController.new
    super
  end

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
