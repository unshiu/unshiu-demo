require File.dirname(__FILE__) + '/../test_helper.rb'
require File.dirname(__FILE__) + '/../../vendor/plugins/tpc/test/unit/tpc_topic_test.rb'

class TpcTopicTest < ActiveSupport::TestCase
  include TpcTopicTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
end
