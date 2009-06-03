require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/mlg/test/unit/mlg_magazine_test.rb'

class MlgMagazineTest < ActiveSupport::TestCase
  include MlgMagazineTestModule

  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
