require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/tpc/test/unit/tpc_comment_test.rb'

class TpcCommentTest < ActiveSupport::TestCase
  include TpcCommentTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
