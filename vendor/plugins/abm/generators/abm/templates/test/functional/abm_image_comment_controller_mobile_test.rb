require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/abm/test/functional/abm_image_comment_controller_mobile_test.rb'

class AbmImageCommentControllerMobileTest < ActionController::TestCase
  include AbmImageCommentControllerMobileTestModule
  
  def setup
    super
    @controller = AbmImageCommentController.new
    setup_fixture_files
  end

  def teardown
    teardown_fixture_files
  end
  
  # You must write UnitTest!!
  def test_default
    assert true
  end

end
