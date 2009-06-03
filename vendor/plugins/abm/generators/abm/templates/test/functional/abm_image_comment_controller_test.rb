require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/abm/test/functional/abm_image_comment_controller_test.rb'

class AbmImageCommentControllerTest < ActionController::TestCase
  include AbmImageCommentControllerTestModule
  
  def setup
    super    
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
