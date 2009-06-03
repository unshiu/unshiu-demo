require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/functional/base_terms_controller_test.rb'

class BaseTermsControllerTest < ActionController::TestCase
  include BaseTermsControllerTestModule

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
