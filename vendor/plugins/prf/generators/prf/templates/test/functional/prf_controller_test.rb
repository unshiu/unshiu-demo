require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/prf/test/functional/prf_controller_test.rb'

class PrfControllerTest < ActionController::TestCase
  include PrfControllerTestModule
  
  def setup
    setup_fixture_files
    super
  end
  
  def teardown
    teardown_fixture_files
  end
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
