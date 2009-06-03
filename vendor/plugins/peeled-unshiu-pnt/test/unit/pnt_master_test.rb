require File.dirname(__FILE__) + '/../test_helper'

module PntMasterTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :pnt_masters
        fixtures :pnt_filters
        fixtures :pnt_points
      end
    end
  end

  # リレーションのテスト
  def test_relation
    pnt_master = PntMaster.find(1)
    assert_not_nil pnt_master.pnt_filters
    assert_not_nil pnt_master.pnt_points
  end
  
end
