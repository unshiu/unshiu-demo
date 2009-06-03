require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/base/test/functional/base_favorite_controller_mobile_test.rb'

class BaseFavoriteControllerMobileTest < ActionController::TestCase
  include BaseFavoriteControllerMobileTestModule
  
  def setup
    @controller = BaseFavoriteController.new
    super
  end

  # You must write UnitTest!!
  def test_default
    assert true
  end

end
